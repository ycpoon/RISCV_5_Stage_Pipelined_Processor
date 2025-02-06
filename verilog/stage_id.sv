/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  stage_id.sv                                         //
//                                                                     //
//  Description :  instruction decode (ID) stage of the pipeline;      //
//                 decode the instruction fetch register operands, and //
//                 compute immediate operand (if applicable)           //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`include "sys_defs.svh"
`include "ISA.svh"

// Decode an instruction: generate useful datapath control signals by matching the RISC-V ISA
// This module is purely combinational
module decoder (
    input INST  inst,
    input logic valid, // when low, ignore inst. Output will look like a NOP

    output ALU_OPA_SELECT opa_select,
    output ALU_OPB_SELECT opb_select,
    output logic          has_dest, // if there is a destination register
    output ALU_FUNC       alu_func,
    output logic          mult, rd_mem, wr_mem, cond_branch, uncond_branch,
    output logic          csr_op, // used for CSR operations, we only use this as a cheap way to get the return code out
    output logic          halt,   // non-zero on a halt
    output logic          illegal // non-zero on an illegal instruction
);

    // Note: I recommend using an IDE's code folding feature on this block
    always_comb begin
        // Default control values (looks like a NOP)
        // See sys_defs.svh for the constants used here
        opa_select    = OPA_IS_RS1;
        opb_select    = OPB_IS_RS2;
        alu_func      = ALU_ADD;
        has_dest      = `FALSE;
        csr_op        = `FALSE;
        mult          = `FALSE;
        rd_mem        = `FALSE;
        wr_mem        = `FALSE;
        cond_branch   = `FALSE;
        uncond_branch = `FALSE;
        halt          = `FALSE;
        illegal       = `FALSE;

        if (valid) begin
            casez (inst)
                `RV32_LUI: begin
                    has_dest   = `TRUE;
                    opa_select = OPA_IS_ZERO;
                    opb_select = OPB_IS_U_IMM;
                end
                `RV32_AUIPC: begin
                    has_dest   = `TRUE;
                    opa_select = OPA_IS_PC;
                    opb_select = OPB_IS_U_IMM;
                end
                `RV32_JAL: begin
                    has_dest      = `TRUE;
                    opa_select    = OPA_IS_PC;
                    opb_select    = OPB_IS_J_IMM;
                    uncond_branch = `TRUE;
                end
                `RV32_JALR: begin
                    has_dest      = `TRUE;
                    opa_select    = OPA_IS_RS1;
                    opb_select    = OPB_IS_I_IMM;
                    uncond_branch = `TRUE;
                end
                `RV32_BEQ, `RV32_BNE, `RV32_BLT, `RV32_BGE,
                `RV32_BLTU, `RV32_BGEU: begin
                    opa_select  = OPA_IS_PC;
                    opb_select  = OPB_IS_B_IMM;
                    cond_branch = `TRUE;
                    // stage_ex uses inst.b.funct3 as the branch function
                end
                `RV32_MUL, `RV32_MULH, `RV32_MULHSU, `RV32_MULHU: begin
                    has_dest   = `TRUE;
                    mult       = `TRUE;
                    // stage_ex uses inst.r.funct3 as the mult function
                end
                `RV32_LB, `RV32_LH, `RV32_LW,
                `RV32_LBU, `RV32_LHU: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    rd_mem     = `TRUE;
                    // stage_ex uses inst.r.funct3 as the load size and signedness
                end
                `RV32_SB, `RV32_SH, `RV32_SW: begin
                    opb_select = OPB_IS_S_IMM;
                    wr_mem     = `TRUE;
                    // stage_ex uses inst.r.funct3 as the store size
                end
                `RV32_ADDI: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                end
                `RV32_SLTI: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    alu_func   = ALU_SLT;
                end
                `RV32_SLTIU: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    alu_func   = ALU_SLTU;
                end
                `RV32_ANDI: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    alu_func   = ALU_AND;
                end
                `RV32_ORI: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    alu_func   = ALU_OR;
                end
                `RV32_XORI: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    alu_func   = ALU_XOR;
                end
                `RV32_SLLI: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    alu_func   = ALU_SLL;
                end
                `RV32_SRLI: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    alu_func   = ALU_SRL;
                end
                `RV32_SRAI: begin
                    has_dest   = `TRUE;
                    opb_select = OPB_IS_I_IMM;
                    alu_func   = ALU_SRA;
                end
                `RV32_ADD: begin
                    has_dest   = `TRUE;
                end
                `RV32_SUB: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_SUB;
                end
                `RV32_SLT: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_SLT;
                end
                `RV32_SLTU: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_SLTU;
                end
                `RV32_AND: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_AND;
                end
                `RV32_OR: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_OR;
                end
                `RV32_XOR: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_XOR;
                end
                `RV32_SLL: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_SLL;
                end
                `RV32_SRL: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_SRL;
                end
                `RV32_SRA: begin
                    has_dest   = `TRUE;
                    alu_func   = ALU_SRA;
                end
                `RV32_CSRRW, `RV32_CSRRS, `RV32_CSRRC: begin
                    csr_op = `TRUE;
                end
                `WFI: begin
                    halt = `TRUE;
                end
                default: begin
                    illegal = `TRUE;
                end
        endcase // casez (inst)
        end // if (valid)
    end // always

endmodule // decoder


module stage_id (
    input              clock,           // system clock
    input              reset,           // system reset
    input IF_ID_PACKET if_id_reg,
    input              wb_regfile_en,   // Reg write enable from WB Stage
    input REG_IDX      wb_regfile_idx,  // Reg write index from WB Stage
    input DATA         wb_regfile_data, // Reg write data from WB Stage
    input              take_branch,

    output ID_EX_PACKET id_packet,
    output              load_data_hazard
);

    assign id_packet.inst = if_id_reg.inst;
    assign id_packet.PC   = if_id_reg.PC;
    assign id_packet.NPC  = if_id_reg.NPC;
    assign id_packet.valid = if_id_reg.valid;

    logic has_dest_reg;
    assign id_packet.dest_reg_idx = (has_dest_reg) ? if_id_reg.inst.r.rd : `ZERO_REG;

    // Hazard Register Storage for comparison
    logic [4:0] hazard_reg [0:2];
    logic [2:0] hazard_reg_valid;
    logic [2:0] is_load;
    logic load_data_hazard_1, load_data_hazard_2;

    always_ff @(posedge clock) begin
        if(take_branch) begin
            hazard_reg_valid[0] <= 1'b0;
            hazard_reg_valid[1] <= 1'b0;
            hazard_reg_valid[2] <= 1'b0;
        end else begin
            hazard_reg[0] <= has_dest_reg ? if_id_reg.inst.r.rd : `ZERO_REG;
            hazard_reg_valid[0] <= (if_id_reg.valid && !load_data_hazard && has_dest_reg && (if_id_reg.inst.r.rd != 5'd0)) ? 1'b1 : 1'b0;
            is_load[0] <= (has_dest_reg && id_packet.rd_mem) ? 1'b1 : 1'b0;

            hazard_reg[1] <= hazard_reg[0];
            hazard_reg_valid[1] <= hazard_reg_valid[0];
            is_load[1] <= is_load[0];

            hazard_reg[2] <= hazard_reg[1];
            hazard_reg_valid[2] <= hazard_reg_valid[1];
            is_load[2] <= is_load[1];
        end
    end

    // Check if rs1 and rs2 are used
    logic is_rs1_used, is_rs2_used;
    assign is_rs1_used = id_packet.cond_branch || (id_packet.opa_select == OPA_IS_RS1);
    assign is_rs2_used = id_packet.cond_branch || id_packet.wr_mem || (id_packet.opb_select == OPB_IS_RS2);

    // Comparisons to identify forwarding and hazard (rs1)
    always_comb begin
        if(is_rs1_used && hazard_reg_valid[0] && (hazard_reg[0] == if_id_reg.inst.r.rs1)) begin
            id_packet.rs1_forward_valid = 1'b1;
            id_packet.rs1_forward_dis = 1'b0;
            load_data_hazard_1 = is_load[0] ? 1'b1 : 1'b0;
        end else if (is_rs1_used && hazard_reg_valid[1] && (hazard_reg[1] == if_id_reg.inst.r.rs1)) begin
            id_packet.rs1_forward_valid = 1'b1;
            id_packet.rs1_forward_dis = 1'b1;
            load_data_hazard_1 = 1'b0;
        end else begin
            id_packet.rs1_forward_valid = 1'b0;
            id_packet.rs1_forward_dis = 1'b0;
            load_data_hazard_1 = 1'b0;
        end
    end

    // Comparisons to identify forwarding and hazard (rs2)
    always_comb begin
        if(is_rs2_used && hazard_reg_valid[0] && (hazard_reg[0] == if_id_reg.inst.r.rs2)) begin
            id_packet.rs2_forward_valid = 1'b1;
            id_packet.rs2_forward_dis = 1'b0;
            load_data_hazard_2 = is_load[0] ? 1'b1 : 1'b0;
        end else if (is_rs2_used && hazard_reg_valid[1] && (hazard_reg[1] == if_id_reg.inst.r.rs2)) begin
            id_packet.rs2_forward_valid = 1'b1;
            id_packet.rs2_forward_dis = 1'b1;
            load_data_hazard_2 = 1'b0;
        end else begin
            id_packet.rs2_forward_valid = 1'b0;
            id_packet.rs2_forward_dis = 1'b0;
            load_data_hazard_2 = 1'b0;
        end
    end

    // Load Data Hazard 
    assign load_data_hazard = load_data_hazard_1 || load_data_hazard_2;

    // Instantiate the register file
    regfile regfile_0 (
        .clock  (clock),
        .read_idx_1 (if_id_reg.inst.r.rs1),
        .read_idx_2 (if_id_reg.inst.r.rs2),
        .write_en   (wb_regfile_en),
        .write_idx  (wb_regfile_idx),
        .write_data (wb_regfile_data),

        .read_out_1 (id_packet.rs1_value),
        .read_out_2 (id_packet.rs2_value)

    );

    // Instantiate the instruction decoder
    decoder decoder_0 (
        // Inputs
        .inst  (if_id_reg.inst),
        .valid (if_id_reg.valid),

        // Outputs
        .opa_select    (id_packet.opa_select),
        .opb_select    (id_packet.opb_select),
        .alu_func      (id_packet.alu_func),
        .has_dest      (has_dest_reg),
        .mult          (id_packet.mult),
        .rd_mem        (id_packet.rd_mem),
        .wr_mem        (id_packet.wr_mem),
        .cond_branch   (id_packet.cond_branch),
        .uncond_branch (id_packet.uncond_branch),
        .csr_op        (id_packet.csr_op),
        .halt          (id_packet.halt),
        .illegal       (id_packet.illegal)
    );

endmodule // stage_id
