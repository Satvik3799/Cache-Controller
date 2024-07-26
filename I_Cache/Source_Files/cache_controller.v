`timescale 1ns/100ps

module cache_controller(
    input [31:0] current_instruction,
    input clock,
    input reset,
    input [127:0] inst_readdata,
    input inst_BUSY,
    output reg inst_read,
    output [31:0] output_instr,
    output reg [5:0] inst_address,
    output reg BUSY
);

    reg cache_VALID [7:0];
    reg [2:0] cache_TAG [7:0];
    reg [127:0] cache_DATA [7:0];
    reg [9:0] address;

    wire VALID;
    wire [2:0] TAG;
    reg [127:0] DATA;

    wire compare;
    wire HIT;

    integer i;

    always @ (current_instruction) begin
        if (current_instruction != 0) begin
            address = {current_instruction[9:0]};
        end
    end

    always @ (*) begin
        #1
        DATA = cache_DATA[address[6:4]];
    end

    assign #1 VALID = cache_VALID[address[6:4]];
    assign #1 TAG = cache_TAG[address[6:4]];

    assign #0.9 compare = (TAG == address[9:7]) ? 1 : 0;
    assign HIT = compare && VALID;

    always @(posedge clock) begin  
        
        if ( (current_instruction == 32'd0) || (HIT) ) begin
            BUSY = 1'b0;
        end 
        else begin
            BUSY = 1'b1;
        end

    end
    assign #1 output_instr = ((address[3:2] == 2'b01) && HIT) ? DATA[63:32] :
                             ((address[3:2] == 2'b10) && HIT) ? DATA[95:64] :
                             ((address[3:2] == 2'b11) && HIT) ? DATA[127:96] : DATA[31:0];

    parameter IDLE = 2'b00, MEM_READ = 2'b01, CACHE_UPDATE = 2'b10;
    reg [1:0] state, next_state;

    always @(*) begin
        case (state)
            IDLE:
                if (!HIT)
                    next_state = MEM_READ;
                else
                    next_state = IDLE;
            MEM_READ:
                if (inst_BUSY)
                    next_state = MEM_READ;
                else
                    next_state = CACHE_UPDATE;
            CACHE_UPDATE:
                next_state = IDLE;
        endcase
    end

    always @(state or reset) begin
        if (reset) begin
            for(i = 0; i < 8; i = i + 1) begin
                cache_VALID[i] = 1'd0;
                cache_TAG[i] = 3'dx;
                cache_DATA[i] = 32'dx;
            end
        end
        else begin
            case(state)
                IDLE: begin
                    inst_read = 0;
                    inst_address = 6'dx;
                    // BUSY = 0;
                end
                MEM_READ: begin
                    inst_read = 1;
                    inst_address = {address[9:4]};
                end
                CACHE_UPDATE: begin
                    inst_read = 0;
                    inst_address = 6'dx;
                    #1
                    cache_DATA[address[6:4]] = inst_readdata;
                    cache_TAG[address[6:4]] = address[9:7];
                    cache_VALID[address[6:4]] = 1'b1;
                end
            endcase
        end
    end
    
always @(posedge clock or posedge reset) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

endmodule
