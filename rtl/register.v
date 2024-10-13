`default_nettype none

module register #(
    parameter integer DATA_BITS = 32
)(
    input  wire                   clk_i,
    input  wire                   rst_i,
    input  wire                   load_i,
    input  wire [DATA_BITS-1 : 0] data_i,
    output reg [DATA_BITS-1 : 0]  data_o
);

    always @(posedge clk_i) begin
        if (rst_i)       data_o <= 0;
        else if (load_i) data_o <= data_i;
    end

endmodule

