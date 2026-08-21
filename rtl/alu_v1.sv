 module alu (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] immediate,
    input  logic [3:0]  alu_control,
    input  logic        alu_src,

    output logic [31:0] alu_result  
);

  typedef enum logic [3:0] {
    ADD  = 4'b0000,
    SUB  = 4'b1000,
    SLL  = 4'b0001,
    SLT  = 4'b0010,
    SLTU = 4'b0011,
    XOR  = 4'b0100,
    SRL  = 4'b0101,
    SRA  = 4'b1101,
    OR   = 4'b0110,
    AND  = 4'b0111
} alu_op_t;

  logic [31:0] imme_rs;
  
  always_comb begin         //imme selection between rs2 and immediate using alu_src signal
    if(alu_src)
       imme_rs = immediate;
    else
      imme_rs = rs2_data;
  end

  always_comb begin
        case (alu_control)
            ADD:  alu_result = rs1_data + imme_rs;
            SUB:  alu_result = rs1_data - imme_rs;
            SLL:  alu_result = rs1_data << imme_rs[4:0];
            SLT:  alu_result = ($signed (rs1_data) < $signed (imme_rs)) ? 32'd1 : 32'd0;
            SLTU: alu_result = (rs1_data < imme_rs) ? 32'd1 : 32'd0;
            SRL:  alu_result = rs1_data >> imme_rs[4:0];
            SRA:  alu_result = $signed (rs1_data) >>> imme_rs[4:0];
            AND:  alu_result = rs1_data & imme_rs;
          	OR:   alu_result = rs1_data | imme_rs;
          	XOR:  alu_result = rs1_data ^ imme_rs;
            
            default: alu_result = 32'd0; 
        endcase
  end
endmodule
