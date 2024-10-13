`default_nettype none

module chacha_QUARTER_ROUND (
    input wire [31 : 0]      a_i,
    input wire [31 : 0]      b_i,
    input wire [31 : 0]      c_i,
    input wire [31 : 0]      d_i,
   
    output reg [31 : 0]      a_o,
    output reg [31 : 0]      b_o,
    output reg [31 : 0]      c_o,
    output reg [31 : 0]      d_o
);

    always @(*) begin
        a_o = a_i; b_o = b_i; c_o = c_i; d_o = d_i;

        a_o = a_o + b_o; 
        d_o = d_o ^ a_o; 
        d_o = {d_o[0 +: (32-16)], d_o[31 -: 16]};  // d <<<= 16 
        
        c_o = c_o + d_o; 
        b_o = b_o ^ c_o; 
        b_o = {b_o[0 +: (32-12)], b_o[31 -: 12]};  // b <<<= 12
 
        a_o = a_o + b_o; 
        d_o = d_o ^ a_o; 
        d_o = {d_o[0 +: (32-8)], d_o[31 -: 8]};    // d <<<= 8

        c_o = c_o + d_o; 
        b_o = b_o ^ c_o; 
        b_o = {b_o[0 +: (32-7)], b_o[31 -: 7]};    // b <<<= 7
    end    

endmodule
