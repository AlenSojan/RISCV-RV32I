`include "includes_top.sv"
module top(
    input logic clk,
    input logic reset_n
);

//PC
    logic [31:0] pc;
    logic [31:0] pc_next;
    logic [31:0] pc_plus4;

    pc pc_inst (
        .clk(clk),
        .reset_n(reset_n),
        .pc_next(pc_next),
        .pc(pc)
    );


//PC MUX
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;
    logic [1:0]  pc_sel;

    //BRANCH LOGIC  

        assign branch_target = pc + immediate;
        assign jal_target    = pc + immediate;
        assign jalr_target   = (rs1_data + immediate) & 32'hffff_fffe;

    //PC PLUS 4
        assign pc_plus4 = pc + 32'd4;

    //PC SELECTION LOGIC
        always_comb begin
            if (jump) begin
                pc_sel = 2'b10; // Jump
            end else if (jalr) begin
                pc_sel = 2'b11; // JALR
            end else if (branch) begin
                pc_sel = 2'b01; // Branch taken
            end else begin
                pc_sel = 2'b00; // Default to PC + 4
            end
        end

    
    pc_mux pc_mux_inst (
        .pc_plus4(pc_plus4),
        .branch_target(branch_target),
        .jal_target(jal_target),
        .jalr_target(jalr_target),
        .pc_sel(pc_sel),
        .pc_next(pc_next)
    );

//Instruction Memory
    logic [31:0] instr;

    instr_mem instr_mem_inst (
        .addr(pc),
        .instr(instr)
    );

//Decoder
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [4:0]  rd_addr;

    logic [31:0] immediate;

    logic [3:0]  alu_control;
    logic        alu_src;

    logic        reg_write;

    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;

    logic        branch;
    logic        jump;
    logic        jalr;

    decoder decoder_inst (
        .instr(instr),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .immediate(immediate),
        .alu_control(alu_control),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .jalr(jalr)
    );
//Register File
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    logic [31:0] rd_data;

    reg_file reg_file_inst (
        .clk(clk),
        .reset_n(reset_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

//ALU
    logic [31:0] alu_result;

    alu alu_inst (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .immediate(immediate),
        .alu_control(alu_control),
        .alu_src(alu_src),
        .alu_result(alu_result)
    );

//Data Memory
    logic [31:0] mem_read_data;

    data_mem data_mem_inst (
        .clk(clk),
        .addr(alu_result),
        .write_data(rs2_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(mem_read_data)
    );

    // Writeback MUX
        always_comb begin
            if (mem_to_reg)
                rd_data = mem_read_data;
            else
                rd_data = alu_result;
        end

endmodule
