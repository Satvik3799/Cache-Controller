`timescale 1ns/100ps

module tb_cache_controller;

    // Inputs
    reg [31:0] current_instruction;
    reg clock;
    reg reset;
    reg [127:0] inst_readdata;
    reg inst_BUSY;

    // Outputs
    wire inst_read;
    wire [31:0] output_instr;
    wire [5:0] inst_address;
    wire BUSY;

    // Instantiate the Unit Under Test (UUT)
    cache_controller DUT (
        .current_instruction(current_instruction), 
        .clock(clock), 
        .reset(reset), 
        .inst_readdata(inst_readdata), 
        .inst_BUSY(inst_BUSY), 
        .inst_read(inst_read), 
        .output_instr(output_instr), 
        .inst_address(inst_address), 
        .BUSY(BUSY)
    );

    initial begin
        // Initialize Inputs
        current_instruction = 0;
        clock = 0;
        reset = 1;
        inst_readdata = 0;
        inst_BUSY = 0;

        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;

        // stimulus 
        current_instruction = 32'h00000100;
        #20;

        current_instruction = 32'h00000200;
        #20;

        inst_BUSY = 1;
        #20;

        inst_BUSY = 0;
        inst_readdata = 128'hAABBCCDDEEFF00112233445566778899;
        #20;

        current_instruction = 32'h00000300;
        #20;

        current_instruction = 32'h00000300;
        #20;

        current_instruction = 32'h00000300;
        #20;

        $finish;
    end

    always #10 clock = ~clock;

endmodule
