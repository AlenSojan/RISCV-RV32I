module data_mem #(
    parameter int DEPTH = 256
)(
    input  logic        clk,

    input  logic [31:0] addr,
    input  logic [31:0] write_data,

    input  logic        mem_read,
    input  logic        mem_write,

    output logic [31:0] read_data
);

    logic [31:0] mem [0:DEPTH-1];

    // Read
    always_comb begin
        if (mem_read)
            read_data = mem[addr[31:2]];
        else
            read_data = 32'd0;
    end

    // Write
    always_ff @(posedge clk) begin
        if (mem_write)
            mem[addr[31:2]] <= write_data;
    end

endmodule
