`default_nettype none

module chacha_ADDER_SERIALIZER (
    input   wire               clk_i,
    input   wire               rst_i,
    input   wire               input_valid_i,
    input   wire [16*32-1 : 0] INITIAL_BLOCK_i,
    input   wire [16*32-1 : 0] FINAL_BLOCK_i,
    output  wire [8-1 : 0]     keystream_o,
    output  reg                keystream_valid_o   
);

    // DATAPATH
    reg  load_block, shift_word;
    wire [31 : 0] initial_block_word;
    wire [31 : 0] final_block_word;
    wire [31 : 0] added_word;
    
    wire [$clog2(16+1)-1 : 0] counter;
    reg init_counter;
    reg incr_counter;
    wire end_of_block;

    piso_shifter #(
        .PARALLEL_DATA_BITS (16*32),    
        .SHIFT_AMOUNT (32),
        .DIRECTION("LEFT")
    ) INITIAL_BLOCK_shifter_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .load_i(load_block),
        .shift_i(shift_word),
        .parallel_i(INITIAL_BLOCK_i),
        .serial_o(initial_block_word)        
    );

    piso_shifter #(
        .PARALLEL_DATA_BITS (16*32),    
        .SHIFT_AMOUNT(32),
        .DIRECTION("LEFT")
    ) FINAL_BLOCK_shifter_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .load_i(load_block),
        .shift_i(shift_word),
        .parallel_i(FINAL_BLOCK_i),
        .serial_o(final_block_word)        
    );
    
    adder #(
        .DATA_BITS (32)
    ) WORD_ADDER_inst (
        .carry_i (1'b0),
        .a_i (initial_block_word),
        .b_i (final_block_word),
        .c_o (added_word),
        .carry_o ()
    );
    
    reg load_word;
    reg shift_byte;
    
    piso_shifter #(
        .PARALLEL_DATA_BITS(32),    
        .SHIFT_AMOUNT(8)
    ) BYTE_shifter_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .load_i(load_word),
        .shift_i(shift_byte),
        .parallel_i(added_word),
        .serial_o(keystream_o)        
    );

    counter #(
        .DATA_BITS($clog2(16+1)),
        .INITIAL_VALUE(5'd1)
    ) WORD_COUNTER_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .init_i(init_counter),
        .incr_i(incr_counter),
        .counter_o(counter)
    );

    wire [2 : 0] byte_counter;
    reg init_byte_counter;
    reg incr_byte_counter;
    wire end_of_word;

    counter #(
        .DATA_BITS($clog2(4+1)),
        .INITIAL_VALUE(3'd1)
    ) BYTE_COUNTER_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .init_i(init_byte_counter),
        .incr_i(incr_byte_counter),
        .counter_o(byte_counter)
    );
    
    assign end_of_word  = byte_counter[2];
    assign end_of_block = counter[5];

    // FSM
    localparam [1 : 0] IDLE_bit       = 2'd0,
                       SHIFT_WORD_bit = 2'd1,
                       SHIFT_BYTE_bit = 2'd2;
     
    localparam [2 : 0] IDLE      = (1'b1 << IDLE_bit),
                      SHIFT_WORD = (1'b1 << SHIFT_WORD_bit),
                      SHIFT_BYTE = (1'b1 << SHIFT_BYTE_bit);
    
    reg [2 : 0] cur_state, nxt_state;
    
    always @(posedge clk_i) begin
        if (rst_i)  cur_state <= IDLE;
        else        cur_state <= nxt_state;
    end    

    always @(*) begin
        load_block = 1'b0;
        shift_word = 1'b0;
        load_word = 1'b0;
        shift_byte = 1'b0;
        init_counter = 1'b0;
        incr_counter = 1'b0;
        init_byte_counter = 1'b0;
        incr_byte_counter = 1'b0;
        keystream_valid_o = 1'b0;

        nxt_state = cur_state;
        case(1'b1)
            cur_state[IDLE_bit]: begin
                load_block = 1'b1;
                init_counter = 1'b1;
                if (input_valid_i) nxt_state = SHIFT_WORD;
            end

            cur_state[SHIFT_WORD_bit]: begin
                shift_word = 1'b1;
                incr_counter = 1'b1;

                load_word = 1'b1;
                init_byte_counter = 1'b1;

                nxt_state = SHIFT_BYTE;
            end
            
            cur_state[SHIFT_BYTE_bit]: begin
                if (end_of_word) begin
                    if (end_of_block) nxt_state = IDLE;
                    else  begin
                        shift_word = 1'b1;
                        incr_counter = 1'b1;

                        load_word = 1'b1;
                        init_byte_counter = 1'b1;
                    end
                end
                else begin
                    shift_byte = 1'b1;
                    incr_byte_counter = 1'b1; 
                end
            end

            default : nxt_state = IDLE; 
        endcase
    end

endmodule
