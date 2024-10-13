`default_nettype none

module chacha_BLOCK #(
    parameter integer ROUND_COUNT = 10 
)(
    input wire                clk_i,
    input wire                rst_i,
  
    input wire [8*32-1 : 0]   key_i, 
    input wire [3*32-1 : 0]   nonce_i,
    input wire [1*32-1 : 0]   counter_i,
   
    output wire [16*32-1 : 0]   keystream_o,
    input  wire  start_i,
    output wire   done_o,   
    output wire   ready_o
);

    wire   init_block;
    wire   rotate_block;
    wire   rotate_direction;
    wire   set_qr_input;     
    wire   get_qr_output;    
    wire   last_round;
    wire   init_counter;
    wire   incr_counter;

    chacha_BLOCK_fsm fsm_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(start_i),
        .done_o(done_o),
        .ready_o(ready_o),
        .init_block_o(init_block),
        .rotate_block_o(rotate_block),
        .rotate_direction_o(rotate_direction),
        .set_qr_input_o(set_qr_input),     
        .get_qr_output_o(get_qr_output),    
        .init_counter_o(init_counter),
        .incr_counter_o(incr_counter),
        .last_round_i(last_round)
    );

    chacha_BLOCK_datapath #(.ROUND_COUNT(ROUND_COUNT)) datapath_inst (    
        .clk_i(clk_i),
        .rst_i(rst_i),
        .key_i(key_i),     
        .nonce_i(nonce_i),
        .counter_i(counter_i),
        .keystream_o(keystream_o),
        .init_block_i(init_block),
        .rotate_block_i(rotate_block),
        .rotate_direction_i(rotate_direction),
        .set_qr_input_i(set_qr_input),     
        .get_qr_output_i(get_qr_output),    
        .init_counter_i(init_counter),
        .incr_counter_i(incr_counter),
        .last_round_o(last_round)
    );

endmodule
