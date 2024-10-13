`default_nettype none

module adder #(
    parameter integer DATA_BITS = 32
)(
    input  wire                         carry_i,
    input  wire [DATA_BITS-1 : 0]       a_i,
    input  wire [DATA_BITS-1 : 0]       b_i,
    output wire [DATA_BITS-1 : 0]       c_o,
    output wire                         carry_o
);

    assign {carry_o, c_o} = a_i + b_i + carry_i;

endmodule
