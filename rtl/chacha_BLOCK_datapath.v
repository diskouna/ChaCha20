`default_nettype none

`define BLOCK_WORD(BLOCK, index) (BLOCK[(index)*32 +: 32])
 
module chacha_BLOCK_datapath #(
    parameter integer ROUND_COUNT = 10  // 10 double QUARTER_ROUND
)(
    input wire                clk_i,
    input wire                rst_i,
    input wire [8*32-1 : 0]   key_i,     // WORD_0, WORD_1, ..., WORD_
    input wire [3*32-1 : 0]   nonce_i,
    input wire [1*32-1 : 0]   counter_i,
   
    output wire [16*32-1 : 0]   keystream_o,
    
    input  wire               init_block_i,
    input  wire               rotate_block_i,
    input  wire               rotate_direction_i,
    input  wire               set_qr_input_i,     
    input  wire               get_qr_output_i,  
    input  wire               init_counter_i,
    input  wire               incr_counter_i,  
    output wire               last_round_o
);

    localparam [31 : 0] CONST_1 = 32'h61707865;
    localparam [31 : 0] CONST_2 = 32'h3320646e;
    localparam [31 : 0] CONST_3 = 32'h79622d32;
    localparam [31 : 0] CONST_4 = 32'h6b206574;
    
    // INPUT signals
    wire [16*32-1 : 0] INITIAL_BLOCK_q, PREVIOUS_OUTPUT_BLOCK_q;
    wire [16*32-1 : 0] INPUT_BLOCK_q, INPUT_BLOCK_d;    
    
    // OUTPUT signals
    wire [16*32-1 : 0] OUTPUT_BLOCK_pre_rot;
    wire [16*32-1 : 0] OUTPUT_BLOCK_q, OUTPUT_BLOCK_d;

    // ROUND COUNTER
    wire [$clog2(ROUND_COUNT+1)-1 : 0] round_counter; 

    assign INITIAL_BLOCK_q = {CONST_1, CONST_2, CONST_3, CONST_4,
                                          key_i,
                                 counter_i, nonce_i
                             };
        
    assign PREVIOUS_OUTPUT_BLOCK_q = OUTPUT_BLOCK_d; 
    
    mux2to1 #(.DATA_BITS(32*16)) INPUT_MUX_inst (
        .sel_i(init_block_i),
        .in_0_i(PREVIOUS_OUTPUT_BLOCK_q),
        .in_1_i(INITIAL_BLOCK_q),
        .out_o(INPUT_BLOCK_q)
    );
        
    register #(.DATA_BITS(32*16)) INPUT_REG_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .load_i(set_qr_input_i),
        .data_i(INPUT_BLOCK_q),
        .data_o(INPUT_BLOCK_d)
    );
    
    genvar i;
    generate 
        for (i=0; i < 4; i = i + 1) begin         
            chacha_QUARTER_ROUND qr_inst (
                .d_i(INPUT_BLOCK_d[32*(0 + i) +: 32]), 
                .c_i(INPUT_BLOCK_d[32*(4  + i) +: 32]),
                .b_i(INPUT_BLOCK_d[32*(8 + i) +: 32]), 
                .a_i(INPUT_BLOCK_d[32*(12 + i) +: 32]),

                .d_o(OUTPUT_BLOCK_pre_rot[32*(0 + i) +: 32]),  
                .c_o(OUTPUT_BLOCK_pre_rot[32*(4  + i) +: 32]),
                .b_o(OUTPUT_BLOCK_pre_rot[32*(8 + i) +: 32]),  
                .a_o(OUTPUT_BLOCK_pre_rot[32*(12 + i) +: 32])
            );

        end
    endgenerate

    chacha_BLOCK_ROTATION blk_rot_inst (
        .rotate_i(rotate_block_i),
        .direction_i (rotate_direction_i),
        .BLOCK_i(OUTPUT_BLOCK_pre_rot),
        .BLOCK_o(OUTPUT_BLOCK_q)
    );

    register #(.DATA_BITS(32*16)) OUTPUT_REG_inst (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .load_i(get_qr_output_i),
        .data_i(OUTPUT_BLOCK_q),
        .data_o(OUTPUT_BLOCK_d)
    );

    assign keystream_o = OUTPUT_BLOCK_d;
   
    counter #(.DATA_BITS($clog2(ROUND_COUNT+1))) ROUND_COUNTER_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .init_i(init_counter_i),
        .incr_i(incr_counter_i),
        .counter_o(round_counter)
    ); 
    
    comparator #(.DATA_BITS($clog2(ROUND_COUNT+1))) COMP_inst (
        .a_i(ROUND_COUNT), 
        .b_i(round_counter),
        .a_eq_b_o(last_round_o)
    );

endmodule
