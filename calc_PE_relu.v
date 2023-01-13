`timescale 1ns / 1ps

module PE_relu(
    input [31:0] in, //int32
    output [31:0] out
    );

    assign out = in[31] ? 32'b0 : in;
 
endmodule
