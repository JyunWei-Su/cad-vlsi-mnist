`timescale 1ns / 1ps

module PE_hl_mac(
    input [7:0] ifmap, // uint8
    input [7:0] weight, // int8
	input [31:0] psum,
    output [31:0] ofmap
    );
    
    wire [31:0]temp;
    
	PE_hl_mul HL_MUL(
        .ifmap(ifmap),
        .weight(weight),
        .ofmap(temp)
    );
    
    assign ofmap = temp + psum;
endmodule
