`default_nettype none

module chacha_BLOCK_fsm (
    input  wire  clk_i,
    input  wire  rst_i,

    input  wire  start_i,
    output reg   done_o,   
    output reg   ready_o, 
    //input  wire  ready_i,
    output reg   init_block_o,
    output reg   rotate_block_o,
    output reg   rotate_direction_o,
    output reg   set_qr_input_o,     
    output reg   get_qr_output_o,    
    output reg   init_counter_o,
    output reg   incr_counter_o,
    input  wire  last_round_i
);
    
    localparam [2 : 0] IDLE_bit       = 3'd0,
                       COL_ROUND_bit  = 3'd1,
                       DIAG_ROUND_bit = 3'd2,
                       DONE_bit       = 3'd3,
                       WAIT1_bit = 3'd4,
                       WAIT2_bit = 3'd5;
    
    localparam [5 : 0] IDLE       = (1'b1 << IDLE_bit),
                       COL_ROUND  = (1'b1 << COL_ROUND_bit),
                       DIAG_ROUND = (1'b1 << DIAG_ROUND_bit),
                       DONE       = (1'b1 << DONE_bit),
                       WAIT1       = (1'b1 << WAIT1_bit),
                       WAIT2       = (1'b1 << WAIT2_bit);

   reg [5 : 0] cur_state, nxt_state;

   always @(posedge clk_i)
        if (rst_i) cur_state <= IDLE;
        else       cur_state <= nxt_state;
   
   always @(*) begin
       done_o          = 1'b0;
       ready_o         = 1'b0;
       init_block_o    = 1'b0;
       rotate_block_o   = 1'b0;
       rotate_direction_o = 1'b0;
       set_qr_input_o  = 1'b0;     
       get_qr_output_o = 1'b0;    
       init_counter_o  = 1'b0;
       incr_counter_o  = 1'b0;

       nxt_state = cur_state;
       case(1'b1)
            cur_state[IDLE_bit]: begin
                ready_o = 1'b1;
                init_block_o = 1'b1;
                set_qr_input_o = 1'b1;
                init_counter_o = 1'b1;                
                if (start_i) nxt_state = COL_ROUND;
            end

            cur_state[COL_ROUND_bit]: begin
                incr_counter_o = 1'b1;
                rotate_block_o = 1'b1;
                rotate_direction_o = 1'b1; 
                get_qr_output_o = 1'b1;
                nxt_state = WAIT1;
            end             
            
            cur_state[WAIT1_bit]:  begin
                set_qr_input_o = 1'b1;
                nxt_state = DIAG_ROUND;
            end
            
            cur_state[DIAG_ROUND_bit]: begin
                rotate_block_o = 1'b1;
                rotate_direction_o = 1'b0;
                get_qr_output_o = 1'b1;
                nxt_state = WAIT2;
            end
            
            cur_state[WAIT2_bit]:  begin
                set_qr_input_o = 1'b1;
                if (last_round_i) nxt_state = DONE;
                else              nxt_state = COL_ROUND;
            end
            
            cur_state[DONE_bit]: begin
                done_o = 1'b1;
                nxt_state = IDLE;
            end

            default : nxt_state = IDLE;
        endcase
   end

endmodule