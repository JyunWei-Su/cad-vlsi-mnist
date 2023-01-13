`timescale 1ns / 1ps

module seg7_num_encode(
    input clk,
    input rst,
    input [3:0]in_num,
    output reg [7:0]out_code
    );
    
    // .gfedcba
    parameter _0  = 8'b1011_1111,  _1 = 8'b1000_0110,  _2 = 8'b1101_1011,  _3 = 8'b1100_1111,
              _4  = 8'b1110_0110,  _5 = 8'b1110_1101,  _6 = 8'b1111_1101,  _7 = 8'b1000_0111,
              _8  = 8'b1111_1111,  _9 = 8'b1110_1111, _10 = 8'b1111_0111, _11 = 8'b1111_1100,
              _12 = 8'b1011_1001, _13 = 8'b1101_1110, _14 = 8'b1111_1001, _15 = 8'b1111_0001;
 
    always @( posedge clk or posedge rst )
    begin
        if( rst )
            out_code <= _0;
        else
            case( in_num )
                4'd0:  out_code <= _0;
                4'd1:  out_code <= _1;
                4'd2:  out_code <= _2;
                4'd3:  out_code <= _3;
                4'd4:  out_code <= _4;
                4'd5:  out_code <= _5;
                4'd6:  out_code <= _6;
                4'd7:  out_code <= _7;
                4'd8:  out_code <= _8;
                4'd9:  out_code <= _9;
                4'd10: out_code <= _10;
                4'd11: out_code <= _11;
                4'd12: out_code <= _12;
                4'd13: out_code <= _13;
                4'd14: out_code <= _14;
                4'd15: out_code <= _15;
                default: out_code <= _0;
            endcase
    end
endmodule
