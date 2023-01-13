`timescale 1ns / 1ps

module hl_mac_tb();
    
reg clk;                     

reg [7:0] hl_input_buf;
reg [7:0] hl_weight_buf;
reg [31:0] psum;
wire [31:0] hl_mac_result;

initial begin
    clk = 0;
    psum <= 31'b0;
    hl_input_buf <= 8'd0; hl_weight_buf <= 8'sd0;
    #5 hl_input_buf <= 8'd130; hl_weight_buf <= -8'sd30;
    #10 hl_input_buf <= 8'd52; hl_weight_buf <= 8'sd70;
    #10 hl_input_buf <= 8'd25; hl_weight_buf <= 8'sd60;
    #10 hl_input_buf <= 8'd255; hl_weight_buf <= 8'sd50;
    #10 hl_input_buf <= 8'd10; hl_weight_buf <= 8'sd40;
    #10 hl_input_buf <= 8'd20; hl_weight_buf <= -8'sd128;
    #10 hl_input_buf <= 8'd30; hl_weight_buf <= 8'sd127;
    #10 hl_input_buf <= 8'd40; hl_weight_buf <= -8'sd90;
    #10 hl_input_buf <= 8'd90; hl_weight_buf <= 8'sd110;
    #10 hl_input_buf <= 8'd10; hl_weight_buf <= 8'sd40;
    #10 hl_input_buf <= 8'd20; hl_weight_buf <= -8'sd128;
    #10 hl_input_buf <= 8'd30; hl_weight_buf <= 8'sd127;
    #10 hl_input_buf <= 8'd40; hl_weight_buf <= -8'sd90;
    #10 hl_input_buf <= 8'd90; hl_weight_buf <= 8'sd110;
    #10 hl_input_buf <= 8'd30; hl_weight_buf <= 8'sd127;
    #10 hl_input_buf <= 8'd40; hl_weight_buf <= -8'sd90;
    #10 hl_input_buf <= 8'd90; hl_weight_buf <= 8'sd110;
    #10 hl_input_buf <= 8'd10; hl_weight_buf <= 8'sd40;
    #10 hl_input_buf <= 8'd20; hl_weight_buf <= -8'sd128;
    #10 hl_input_buf <= 8'd30; hl_weight_buf <= 8'sd127;
    #10 hl_input_buf <= 8'd40; hl_weight_buf <= -8'sd90;
    #10 hl_input_buf <= 8'd90; hl_weight_buf <= 8'sd110;
    
end


always #(5) clk = ~clk;
  
always @(posedge clk) begin
    psum <= hl_mac_result;
end    

// hidden layer PE
PE_hl_mac HL_MAC(
    .ifmap(hl_input_buf),
    .weight(hl_weight_buf),
    .psum(psum),
    .ofmap(hl_mac_result)
);
    
endmodule