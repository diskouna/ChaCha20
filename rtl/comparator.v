`default_nettype none

module comparator #(
    parameter integer DATA_BITS = 32
)(
    input  wire [DATA_BITS-1 : 0]   a_i,
    input  wire [DATA_BITS-1 : 0]   b_i,
    output wire                 a_eq_b_o
);
    assign a_eq_b_o = (a_i == b_i);

endmodule
