`default_nettype none

module mux2to1 #(
    parameter integer DATA_BITS = 32
)(
    input  wire                   sel_i,
    input  wire [DATA_BITS-1 : 0] in_0_i,
    input  wire [DATA_BITS-1 : 0] in_1_i,
    output wire [DATA_BITS-1 : 0] out_o
);

    assign out_o = sel_i ? in_1_i : in_0_i;
 
endmodule
