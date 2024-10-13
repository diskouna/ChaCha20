`default_nettype none

module onehot_comparator #(
    parameter integer DATA_BITS = 32
)(
    input  wire [$clog2(DATA_BITS)-1 : 0]  a_bit_i,
    input  wire [DATA_BITS-1]              a_i,
    input  wire [DATA_BITS-1]              b_i,
    output wire                            a_eq_b_o
);

    assign a_eq_b_o = (a_i[a_bit_i] == b_i[a_bit_i]);

endmodule
