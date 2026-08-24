module regfile (
    input  logic        clk,

    // Read ports
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,

    // Write port
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data,
    input  logic        rd_we
);

    logic [31:0] registers [0:31];

    // Combinational reads
    always_comb begin
        if (rs1_addr == 5'd0)
            rs1_data = 32'd0;
        else
            rs1_data = registers[rs1_addr];

        if (rs2_addr == 5'd0)
            rs2_data = 32'd0;
        else
            rs2_data = registers[rs2_addr];
    end

    // Synchronous write
    always_ff @(posedge clk) begin
        if (rd_we && (rd_addr != 5'd0))
            registers[rd_addr] <= rd_data;
    end

endmodule
