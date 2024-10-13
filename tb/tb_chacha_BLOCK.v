`timescale 1ns/1ps
`default_nettype none

module tb_chacha_BLOCK();

    reg clk_i, rst_i;
    reg [8*32-1 : 0] key_i;
    reg [3*32-1 : 0] nonce_i;
    reg [32-1   : 0] counter_i;
    reg start_i;

    wire done_o, ready_o;
    wire [16*32-1 : 0] keystream_o;

    chacha_BLOCK #(.ROUND_COUNT(10)) DUT (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .key_i(key_i),
        .nonce_i(nonce_i),
        .counter_i(counter_i),   
        .keystream_o(keystream_o),
        .start_i(start_i),
        .done_o(done_o),   
        .ready_o(ready_o)
    );

    task print_block(input [16*32-1 : 0] BLOCK);
         integer i;
         begin
            #10;
            $display("--------------------------------------");
            for (i = 0; i < 16; i = i + 1) begin 
                $write("%08x ", BLOCK[16*32-1 - i*32 -: 32]);
                if (i % 4 == 3) $write("\n"); 
            end 
            $display("--------------------------------------");
        end
    endtask
    
    initial begin
        clk_i = 1'b0;
        forever begin
            #10;
            clk_i = ~clk_i;
        end
    end
    
    initial begin
        rst_i <= 1'b1;
        #30;
        rst_i <= 1'b0;
    end
    
    initial begin
        start_i   <= 1'b1;
        counter_i <= 32'h00000001; 
        key_i     <= 256'h03020100_07060504_0b0a0908_0f0e0d0c_13121110_17161514_1b1a1918_1f1e1d1c;
        nonce_i   <= 96'h09000000_4a000000_00000000;
        
        wait (done_o == 1'b1);
        print_block(keystream_o); 
        $finish;
    end
endmodule
