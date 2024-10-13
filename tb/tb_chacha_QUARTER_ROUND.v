`timescale 1ns/1ps
`default_nettype none

module tb_chacha_QUARTER_ROUND();
    reg  [31 : 0] a_i, b_i, c_i, d_i;
    reg  [31 : 0] a_e, b_e, c_e, d_e;
    wire [31 : 0] a_o, b_o, c_o, d_o;
    
    chacha_QUARTER_ROUND DUT (
        .a_i(a_i),
        .b_i(b_i),
        .c_i(c_i),
        .d_i(d_i),
        .a_o(a_o),
        .b_o(b_o),
        .c_o(c_o),
        .d_o(d_o)
    );

    reg [5*8-1 : 0] STATUS;

    initial begin
        // TEST 1: 
        a_i = 32'h11111111;
        b_i = 32'h01020304;
        c_i = 32'h9b8d6f43;
        d_i = 32'h01234567;
        
        a_e = 32'hea2a92f4;
        b_e = 32'hcb1cf8ce;
        c_e = 32'h4581472e;
        d_e = 32'h5881c4bb;
        
        #10;
        STATUS = ({a_e, b_e, c_e, d_e} == {a_o, b_o, c_o, d_o}) ? "PASS" : "FAIL";
        #10;
        if (STATUS == "PASS")    
            $display("[TEST 1] PASS ");
        else begin
            $display("[TEST 1] FAIL");
            $display(" Expected : (0x%08x, 0x%08x, 0x%08x, 0x%08x), Got : (0x%08x, 0x%08x, 0x%08x, 0x%08x)", 
                            a_e, b_e, c_e, d_e, a_o, b_o, c_o, d_o);
        end
        // TEST 2:
        a_i = 32'h516461b1; 
        b_i = 32'h2a5f714c;
        c_i = 32'h53372767;
        d_i = 32'h3d631689;

        a_e = 32'hbdb886dc;
        b_e = 32'hcfacafd2;
        c_e = 32'he46bea80;
        d_e = 32'hccc07c79;
        
        #10;
        STATUS = ({a_e, b_e, c_e, d_e} == {a_o, b_o, c_o, d_o}) ?  "PASS" : "FAIL";
        #10;
        if (STATUS == "PASS")    
            $display("[TEST 2] PASS ");
        else begin
            $display("[TEST 2] FAIL");
            $display(" Expected : (0x%08x, 0x%08x, 0x%08x, 0x%08x), Got : (0x%08x, 0x%08x, 0x%08x, 0x%08x)", 
                            a_e, b_e, c_e, d_e, a_o, b_o, c_o, d_o);
        end
    end
                                                                                    
endmodule
