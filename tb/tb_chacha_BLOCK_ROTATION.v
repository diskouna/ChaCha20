`timescale 1ns/1ps
`default_nettype none 

module tb_chacha_BLOCK_ROTATION();
    
    wire  [16*32-1 : 0]  BLOCK_o;
    reg  [16*32-1 : 0]   BLOCK_i;
    reg rotate_i;

    chacha_BLOCK_ROTATION DUT (
        .rotate_i (rotate_i),
        .BLOCK_i (BLOCK_i),
        .BLOCK_o (BLOCK_o)
    );
   
    task print_block(input [16*32-1 : 0] BLOCK);
         integer i;
         begin
            #10;
            $display("--------------------------------------");
            for (i = 0; i < 16; i = i + 1) begin 
                $write("%08x ", BLOCK[i*32 +: 32]);
                if (i % 4 == 3) $write("\n"); 
            end 
            $display("--------------------------------------");
        end
    endtask

    initial begin
        BLOCK_i <= {32'd15, 32'd14, 32'd13, 32'd12, 32'd11, 32'd10, 32'd9, 32'd8, 32'd7, 32'd6, 32'd5, 32'd4, 32'd3, 32'd2, 32'd1, 32'd0};     
        
        #10;
        rotate_i <= 1'b1; 
        print_block(BLOCK_i);
        print_block(BLOCK_o);
         
    end
endmodule
