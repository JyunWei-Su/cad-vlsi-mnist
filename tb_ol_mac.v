`timescale 1ns / 1ps

module ol_mac_tb();

reg clk;                     

reg [31:0] ol_input_buf;
reg [31:0] ol_weight_buf;
reg [31:0] ol_buf;
wire [31:0] ol_mac_result;

reg [2:0]count;

initial begin
    clk = 1'b0;
    count <= 3'd0;
    ol_buf <= 32'h00000000;
    ol_input_buf <= 32'd0; ol_weight_buf <= 32'h00000000;
    #1 ol_input_buf <= 32'd10; ol_weight_buf <= 32'h41A00000; // 10 * 20.0
    #74 ol_input_buf <= 32'd30; ol_weight_buf <= 32'h42200000; // 30 * 40.0
    #80 ol_input_buf <= -32'sd60; ol_weight_buf <= 32'h428C0000; // -60 * 70.0
    #80 ol_input_buf <= 32'd80; ol_weight_buf <= 32'h42B40000; // 80 * 90.0
    #80 ol_input_buf <= -32'sd10; ol_weight_buf <= 32'h41A00000; // -10 * 20.0
    #80 ol_input_buf <= 32'd30; ol_weight_buf <= 32'hC2200000; // 30 * -40.0
    #80 ol_input_buf <= -32'sd10; ol_weight_buf <= 32'h41A00000; // -10 * 20.0
    #80 ol_input_buf <= 32'd30; ol_weight_buf <= 32'hC2200000; // 30 * -40.0

end

always #(5) clk = ~clk;

always @(posedge clk) begin
    if(count == 3'b111) ol_buf <= ol_mac_result;
    count <= count + 1'b1;
    
end

// output layer PE
PE_ol_mac OL_MAC(
    .clk(clk),
    .ifmap(ol_input_buf),
    .weight(ol_weight_buf),
    .psum(ol_buf),
    .ofmap(ol_mac_result)
);
    
endmodule