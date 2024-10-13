`default_nettype none
/*
 BLOCK_i                           BLOCK_o
    0  1  2  3  (rotate_i==1'b1)  0  1  2  3        
    4  5  6  7       --->         5  6  7  4    
    8  9 10 11                   10 11  8  9  
   12 13 14 15                   15 12 13 14
*/

module chacha_BLOCK_ROTATION (
    input  wire                rotate_i, 
    input  wire                direction_i,
    input  wire [16*32-1 : 0]  BLOCK_i,
    output reg  [16*32-1 : 0]  BLOCK_o
);

    wire [4*32-1 : 0] ROW_0, ROW_1, ROW_2, ROW_3;
    
    assign ROW_0 = BLOCK_i[0*4*32 +: 4*32];
    assign ROW_1 = BLOCK_i[1*4*32 +: 4*32];
    assign ROW_2 = BLOCK_i[2*4*32 +: 4*32];
    assign ROW_3 = BLOCK_i[3*4*32 +: 4*32];
    
    always @(*) begin
        BLOCK_o = BLOCK_i;
        if (rotate_i) begin 
            if (direction_i == 1'b1) begin 
                BLOCK_o[0*4*32 +: 4*32] = ROW_0;                                     // ROW_0 >>> 0 * 32
                BLOCK_o[1*4*32 +: 4*32] = {ROW_1[0 +: 1*32], ROW_1[4*32-1 -: 3*32]}; // ROW_1 >>> 1 * 32
                BLOCK_o[2*4*32 +: 4*32] = {ROW_2[0 +: 2*32], ROW_2[4*32-1 -: 2*32]}; // ROW_2 >>> 2 * 32
                BLOCK_o[3*4*32 +: 4*32] = {ROW_3[0 +: 3*32], ROW_3[4*32-1 -: 1*32]}; // ROW_3 >>> 3 * 32
            end 
            else begin
                BLOCK_o[0*4*32 +: 4*32] = ROW_0;                                     // ROW_0 <<< 0 * 32
                BLOCK_o[1*4*32 +: 4*32] = {ROW_1[0 +: 3*32], ROW_1[4*32-1 -: 1*32]}; // ROW_1 <<< 1 * 32
                BLOCK_o[2*4*32 +: 4*32] = {ROW_2[0 +: 2*32], ROW_2[4*32-1 -: 2*32]}; // ROW_2 <<< 2 * 32
                BLOCK_o[3*4*32 +: 4*32] = {ROW_3[0 +: 1*32], ROW_3[4*32-1 -: 3*32]}; // ROW_3 <<< 3 * 32
            end
        end
    end 

endmodule
