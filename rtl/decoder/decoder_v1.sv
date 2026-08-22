module decoder(
    // Instruction
    input  logic [31:0] instr,

    // Register addresses
    output logic [4:0]  rs1_addr,
    output logic [4:0]  rs2_addr,
    output logic [4:0]  rd_addr,

    // Immediate
    output logic [31:0] immediate,

    // ALU control
    output logic [3:0]  alu_control,
    output logic        alu_src,

    // Register file control
    output logic        reg_write,

    // Memory control
    output logic        mem_read,
    output logic        mem_write,
    output logic        mem_to_reg,

    // Control flow
    output logic        branch,
    output logic        jump,
    output logic        jalr
);

    typedef enum logic [6:0] {
    UDEF          = 7'b000_0000,

    // I-type
    I_TYPE        = 7'b001_0011,  // ALU immediate
    I_TYPE_LOAD   = 7'b000_0011,  // Loads
    I_TYPE_JALR   = 7'b110_0111,  // JALR

    // R-type
    R_TYPE        = 7'b011_0011,

    // S-type
    S_TYPE        = 7'b010_0011,

    // B-type
    B_TYPE        = 7'b110_0011,

    // U-type
    U_TYPE_LUI    = 7'b011_0111,
    U_TYPE_AUIPC  = 7'b001_0111,

    // J-type
    J_TYPE        = 7'b110_1111,

    // Other RV32I instructions
    I_TYPE_FENCE  = 7'b000_1111,
    I_TYPE_SYSTEM = 7'b111_0011
  } instr_type_e;

  always_comb begin
    // Default values
    rs1_addr     = 5'd0;
    rs2_addr     = 5'd0;
    rd_addr      = 5'd0;
    immediate    = 32'd0;
    alu_control  = 4'd0;
    alu_src      = 1'b0;
    reg_write    = 1'b0;
    mem_read     = 1'b0;
    mem_write    = 1'b0;
    mem_to_reg   = 1'b0;
    branch       = 1'b0;
    jump         = 1'b0;
    jalr         = 1'b0;

    case (instr[6:0])
        I_TYPE: begin
            rd_addr     = instr[11:7];
            rs1_addr    = instr[19:15];
            immediate    = {{20{instr[31]}}, instr[31:20]}; // Sign-extend immediate
            alu_src      = 1'b1;
            alu_control  = 4'd0; // ALU control signals for I-type instructions
        end

        I_TYPE_LOAD: begin
            rd_addr     = instr[11:7];
            rs1_addr    = instr[19:15];
            immediate    = {{20{instr[31]}}, instr[31:20]}; // Sign-extend immediate
            alu_src      = 1'b1;
            mem_read     = 1'b1;
        end

        I_TYPE_JALR: begin
            rd_addr     = instr[11:7];
            rs1_addr    = instr[19:15];
            immediate    = {{20{instr[31]}}, instr[31:20]}; // Sign-extend immediate
            alu_src      = 1'b1;
            jalr         = 1'b1;
        end

        R_TYPE: begin
            rd_addr     = instr[11:7];
            rs1_addr    = instr[19:15];
            rs2_addr    = instr[24:20];
            alu_src      = 1'b0;
            alu_control  = {instr[30],instr[14:12]}; //ALU control signals for R-type instructions
        end

        S_TYPE: begin
            rs1_addr    = instr[19:15];
            rs2_addr    = instr[24:20];
            immediate    = {{20{instr[31]}}, instr[31:25],instr[11:7]}; // Sign-extend immediate
            mem_write    = 1'b1;
        end

        B_TYPE: begin
            rs1_addr    = instr[19:15];
            rs2_addr    = instr[24:20];
            immediate    = {{20{instr[31]}}, instr[31:25],instr[11:7]}; // Sign-extend immediate
            branch       = 1'b1;
        end

        U_TYPE_LUI: begin
            rd_addr    = instr[11:7];
            immediate  = {instr[31:12], 12'd0}; // Upper immediate
        end

        U_TYPE_AUIPC: begin
            rd_addr    = instr[11:7];
            immediate  = {instr[31:12], 12'd0}; // Upper immediate
        end

        J_TYPE: begin
            rd_addr    = instr[11:7];
            immediate  = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // Sign-extend immediate
            jump       = 1'b1;
        end

        I_TYPE_FENCE: begin
            rd_addr    = instr[11:7];
            rs1_addr   = instr[19:15];
            immediate  = {{20{instr[31]}}, instr[31:20]}; // Sign-extend immediate
            alu_src    = 1'b1;
            alu_control = 4'd0; // ALU control signals for I-type instructions
        end

        I_TYPE_SYSTEM: begin
            rd_addr    = instr[11:7];
            rs1_addr   = instr[19:15];
            immediate  = {{20{instr[31]}}, instr[31:20]}; // Sign-extend immediate
            alu_src    = 1'b1;
            alu_control = 4'd0; // ALU control signals for I-type instructions
        end
    endcase
end

endmodule
