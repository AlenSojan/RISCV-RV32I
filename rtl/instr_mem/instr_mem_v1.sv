module instr_mem #(
    parameter int DEPTH = 256
)(
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] mem [0:DEPTH-1];

    always_comb begin
        instr = mem[addr[31:2]];
    end

endmodule
