`timescale 1ns/100ps

module tb_cache_controller;
    
    reg clock;
    reg reset;
    reg read;
    reg write;
    reg [7:0] address;
    reg [7:0] writedata;
    reg mem_BUSY;
    reg [31:0] mem_readdata;
    wire [7:0] readdata;
    wire mem_read;
    wire mem_write;
    wire BUSY;
    wire [5:0] mem_address;
    wire [31:0] mem_writedata;

    cache_controller uut (
        .clock(clock),
        .reset(reset),
        .read(read),
        .write(write),
        .address(address),
        .writedata(writedata),
        .mem_BUSY(mem_BUSY),
        .mem_readdata(mem_readdata),
        .readdata(readdata),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .BUSY(BUSY),
        .mem_address(mem_address),
        .mem_writedata(mem_writedata)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        // Initialize inputs
        reset = 0;
        read = 0;
        write = 0;
        address = 0;
        writedata = 0;
        mem_BUSY = 0;
        mem_readdata = 0;

        // Reset the cache controller
        reset = 1;
        #10;
        reset = 0;

        // Write to the cache
        write = 1;
        address = 8'b00000000; // Block 0, offset 0
        writedata = 8'hAA;
        #10;
        write = 0;

        // Read from the cache (hit)
        read = 1;
        address = 8'b00000000; // Block 0, offset 0
        #10;
        read = 0;

        // Write to the cache (another block)
        write = 1;
        address = 8'b00000100; // Block 1, offset 0
        writedata = 8'hBB;
        #10;
        write = 0;

        // Read from the cache (miss and then hit)
        read = 1;
        address = 8'b00000100; // Block 1, offset 0
        mem_readdata = 32'hDEADBEEF;
        mem_BUSY = 1;
        #20;
        mem_BUSY = 0;
        #10;
        read = 0;

        // Check if cache updates correctly on a miss
        write = 1;
        address = 8'b00001000; // Block 2, offset 0
        writedata = 8'hCC;
        mem_readdata = 32'hCAFEBABE;
        mem_BUSY = 1;
        #20;
        mem_BUSY = 0;
        #10;
        write = 0;

        // Final state
        #100;
        $stop;
    end
endmodule
