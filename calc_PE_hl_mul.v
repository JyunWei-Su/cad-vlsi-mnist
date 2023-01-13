`timescale 1ns / 1ps

module PE_hl_mul(
    input [7:0] ifmap, // uint8
    input [7:0] weight, // int8
    output [31:0] ofmap //int32
    );
    
    wire minus;
    wire [7:0] complement;
    wire [31:0] mul_result;
    
    
    assign minus = weight[7];
    assign complement = ~weight + 1'b1;
    assign mul_result = ifmap * (minus ? complement : weight);
    assign ofmap = minus ? (~mul_result + 1'b1) : mul_result;

endmodule
