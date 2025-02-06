/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  stage_if.sv                                         //
//                                                                     //
//  Description :  instruction fetch (IF) stage of the pipeline;       //
//                 fetch instruction, compute next PC location, and    //
//                 send them down the pipeline.                        //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`include "sys_defs.svh"

module stage_if (
    input           clock,          // system clock
    input           reset,          // system reset
    input           if_valid,       // only go to next PC when true
    input           take_branch,    // taken-branch signal
    input ADDR      branch_target,  // target pc: use if take_branch is TRUE
    input MEM_BLOCK Imem_data,      // data coming back from Instruction memory
    input           data_hazard_stall,

    output IF_ID_PACKET if_packet,
    output ADDR         Imem_addr // address sent to Instruction memory
);

    ADDR PC_reg; // PC we are currently fetching

    always_ff @(posedge clock) begin
        if (reset) begin
            PC_reg <= 0;             // initial PC value is 0 (the memory address where our program starts)
        end else if (take_branch) begin
            PC_reg <= branch_target; // update to a taken branch (does not depend on valid bit)
        end else if (if_valid) begin
            if(data_hazard_stall) begin
                PC_reg <= PC_reg;
            end else begin
                PC_reg <= PC_reg + 4;    // or transition to next PC if valid
            end
        end
    end

    // address of the instruction we're fetching (64 bit memory lines)
    // mem always gives us 8=2^3 bytes, so ignore the last 3 bits
    assign Imem_addr = {PC_reg[31:3], 3'b0};

    // index into the word (32-bits) of memory that matches this instruction
    assign if_packet.inst = (if_valid) ? Imem_data.word_level[PC_reg[2]] : `NOP;

    assign if_packet.PC  = PC_reg;
    assign if_packet.NPC = PC_reg + 4; // pass PC+4 down pipeline w/instruction

    assign if_packet.valid = if_valid;

endmodule // stage_if
