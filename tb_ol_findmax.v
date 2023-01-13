`timescale 1ns / 1ps

module ol_findmax_tb();

reg clk;                     
reg [31:0] ol_buf [0:9];
wire [3:0] result_wire;
reg rst;

reg [2:0]count;

initial begin
    clk = 1'b0;
    rst = 1'b1;
    count <= 3'd7;
    // max: 9
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h42C80000;
    #5 rst <= 1'b0;
    // max: 8
    #80;
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42C80000;
    ol_buf[9] <= 32'h42B40000;
    // max: 7
    #80;
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42C80000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h42A00000;
    // max: 6
    #80;
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h42C80000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h428C0000;
    // max: 5
    #80;
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42C80000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h42700000;
    // max: 4
    #80;
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42C80000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h42480000;
    // max: 3
    #80;
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42C80000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h42200000;
    // max: 2
    #80;
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h42C80000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h41F00000;
    // max: 1
    #80;
    ol_buf[0] <= 32'h41200000;
    ol_buf[1] <= 32'h42C80000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h41A00000;
    // max: 0
    #80;
    ol_buf[0] <= 32'h42C80000;
    ol_buf[1] <= 32'h41A00000;
    ol_buf[2] <= 32'h41F00000;
    ol_buf[3] <= 32'h42200000;
    ol_buf[4] <= 32'h42480000;
    ol_buf[5] <= 32'h42700000;
    ol_buf[6] <= 32'h428C0000;
    ol_buf[7] <= 32'h42A00000;
    ol_buf[8] <= 32'h42B40000;
    ol_buf[9] <= 32'h41200000;
    
end

always #(5) clk = ~clk;

always @(posedge clk) begin
    count <= count + 1'b1;
    
end

PE_findamx FINDMAX(
    .clk(clk),
    .rst(rst),
    .in_0(ol_buf[0]),
    .in_1(ol_buf[1]),
    .in_2(ol_buf[2]),
    .in_3(ol_buf[3]),
    .in_4(ol_buf[4]),
    .in_5(ol_buf[5]),
    .in_6(ol_buf[6]),
    .in_7(ol_buf[7]),
    .in_8(ol_buf[8]),
    .in_9(ol_buf[9]),
    .out(result_wire)
);
    
endmodule