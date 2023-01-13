`timescale 1ns / 1ps

module sig_on_shot_pulse(
    input clk,
    input rst,
    input sig_in,
    output reg sig_out
    );
    
    reg sig_tmp;
    always @( posedge clk or posedge rst)
        if( rst ) begin
            sig_tmp <= 1'b0;
            sig_out <= 1'b0;
        end else begin
            sig_tmp <= sig_in;
            sig_out <= sig_tmp;
        end
endmodule
