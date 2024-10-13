`default_nettype none

module piso_shifter #(
    parameter integer PARALLEL_DATA_BITS = 16*32,
    parameter integer SHIFT_AMOUNT       = 8,
    parameter DIRECTION = "RIGHT"
)(
    input wire clk_i,
    input wire rst_i,
    input wire load_i,
    input wire shift_i,
    input wire [PARALLEL_DATA_BITS-1 : 0] parallel_i,
    output wire [SHIFT_AMOUNT-1 : 0] serial_o
);
    reg [PARALLEL_DATA_BITS-1 : 0] registers_q, registers_d;

    generate
        if (DIRECTION == "RIGHT")
            assign serial_o = registers_d[0 +: SHIFT_AMOUNT];
        else // DIRECTION == "LEFT"
            assign serial_o = registers_d[PARALLEL_DATA_BITS-1 -: SHIFT_AMOUNT];
    endgenerate

    always @(*) begin
        registers_q = registers_d;
        if (DIRECTION == "RIGHT") begin    
            if (shift_i) registers_q = (registers_d >> SHIFT_AMOUNT);
        end 
        else begin // DIRECTION == "LEFT"
            if (shift_i) registers_q = (registers_d << SHIFT_AMOUNT);
        end
        if (load_i)  registers_q = parallel_i;
    end 

    always @(posedge clk_i) begin
        if(rst_i) registers_d <= 0;
        else      registers_d <= registers_q;
    end

endmodule
