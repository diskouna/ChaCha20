`default_nettype none

module counter #(
    parameter integer DATA_BITS = 32,
    parameter integer INITIAL_VALUE = 0
)(
    input  wire                           clk_i,
    input  wire                           rst_i,
    input  wire                           init_i,
    input  wire                           incr_i,
    output reg [DATA_BITS-1 : 0]          counter_o
);

    always @(posedge clk_i)
        if(rst_i)        counter_o <= INITIAL_VALUE;
        else if (init_i) counter_o <= INITIAL_VALUE;
        else if (incr_i) counter_o <= counter_o + 1'b1;

endmodule
