`timescale 1ns / 1ps

module hl_relu_tb();
    
reg clk;                     

reg [31:0] hl_buf;
wire [31:0] hl_buf_relu;

initial begin
    clk = 0;
    hl_buf <= 32'd0;
    #5 hl_buf  <= 32'sd10;
    #10 hl_buf <= -32'sd20;
    #10 hl_buf <= -32'sd30;
    #10 hl_buf <= 32'sd40;
    #10 hl_buf <= 32'sd50;
    #10 hl_buf <= -32'sd60;
    #10 hl_buf <= -32'sd70;
    #10 hl_buf <= 32'sd80;
    #10 hl_buf <= 32'sd90;
    #10 hl_buf <= -32'sd100;
    #10 hl_buf <= -32'sd110;
    #10 hl_buf <= 32'sd120;
    #10 hl_buf <= 32'sd130;
    #10 hl_buf <= -32'sd140;
    #10 hl_buf <= -32'sd150;
    #10 hl_buf <= 32'sd160;
    #10 hl_buf <= 32'sd170;
    #10 hl_buf <= -32'sd180;
    #10 hl_buf <= -32'sd190;
    #10 hl_buf <= 32'sd200;
    #10 hl_buf <= 32'sd210;
end

always #(5) clk = ~clk;

PE_relu HL_RELU(
    .in(hl_buf),
    .out(hl_buf_relu)
);
    
endmodule