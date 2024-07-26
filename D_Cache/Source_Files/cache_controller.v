`timescale 1ns/100ps

module cache_controller (
    input clock,
    input reset,
    input read,
    input write,
    input [7:0] address,
    input [7:0] writedata,
    input mem_BUSY,
    input [31:0] mem_readdata,
    output [7:0] readdata,
    output reg mem_read, mem_write,
    output reg BUSY,
    output reg [5:0] mem_address,
    output reg [31:0] mem_writedata
);

    reg cache_VALID [7:0];
    reg cache_DIRTY [7:0];
    reg [2:0] cache_TAG [7:0];
    reg [31:0] cache_DATA [7:0];

    integer i;

    wire VALID, DIRTY;
    wire [2:0] TAG;
    reg [31:0] DATA;

    wire compare;
    wire HIT;

    reg read_write_comb;

    
    parameter IDLE = 2'b00, MEM_READ = 2'b01, MEM_WRITE = 2'b10, CACHE_UPDATE = 2'b11;
    reg [1:0] state, next_state;


    always @ (read, write)
    begin
        if (read || write) begin
            read_write_comb = 1'b1;
        end else begin
            read_write_comb = 1'b0;
        end
    end

    always @ (posedge clock)
    begin
        if (HIT) begin
            BUSY <= 1'b0;
        end else begin
            BUSY <= read_write_comb;
        end
    end

    always @ (*)
    begin
        #1
        DATA = cache_DATA[address[4:2]];
    end

    assign #1 VALID = cache_VALID[address[4:2]];
    assign #1 DIRTY = cache_DIRTY[address[4:2]];
    assign #1 TAG = cache_TAG[address[4:2]];
    assign #0.9 compare = (TAG == address[7:5]) ? 1'b1 : 1'b0;
    assign HIT = compare && VALID;

    assign #1 readdata = ((address[1:0] == 2'b01) && read && HIT) ? DATA[15:8] :
                         ((address[1:0] == 2'b10) && read && HIT) ? DATA[23:16] :
                         ((address[1:0] == 2'b11) && read && HIT) ? DATA[31:24] : DATA[7:0];

    always @ (posedge clock)
    begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1) begin
                cache_VALID[i] = 1'd0;
                cache_DIRTY[i] = 1'd0;
                cache_TAG[i] = 3'dx;
                cache_DATA[i] = 32'dx;
            end
        end else begin
            if (HIT && write) begin
                #1;
                cache_DIRTY[address[4:2]] = 1'b1;

                if (address[1:0] == 2'b00) begin
                    cache_DATA[address[4:2]][7:0] = writedata;
                end else if (address[1:0] == 2'b01) begin
                    cache_DATA[address[4:2]][15:8] = writedata;
                end else if (address[1:0] == 2'b10) begin
                    cache_DATA[address[4:2]][23:16] = writedata;
                end else if (address[1:0] == 2'b11) begin
                    cache_DATA[address[4:2]][31:24] = writedata;
                end
            end else if (state == CACHE_UPDATE) begin
                #1
                cache_DATA[address[4:2]] = mem_readdata;
                cache_TAG[address[4:2]] = address[7:5];
                cache_VALID[address[4:2]] = 1'b1;
                cache_DIRTY[address[4:2]] = 1'b0;
            end
        end
    end

    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !DIRTY && !HIT)
                    next_state = MEM_READ;
                else if ((read || write) && DIRTY && !HIT)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;

            MEM_READ:
                if (mem_BUSY)
                    next_state = MEM_READ;
                else
                    next_state = CACHE_UPDATE;

            MEM_WRITE:
                if (mem_BUSY)
                    next_state = MEM_WRITE;
                else
                    next_state = MEM_READ;

            CACHE_UPDATE:
                next_state = IDLE;
        endcase
    end

    always @(state) begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
            end

            MEM_READ:
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {address[7:2]};
                mem_writedata = 32'dx;
            end

            MEM_WRITE:
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {TAG, address[4:2]};
                mem_writedata = DATA;
            end

            CACHE_UPDATE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
            end
        endcase
    end

    always @(posedge clock or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

endmodule
