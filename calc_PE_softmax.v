`timescale 1ns / 1ps

module PE_findamx(
    input clk,
    input rst,
    input [31:0] in_0,
    input [31:0] in_1,
    input [31:0] in_2,
    input [31:0] in_3,
    input [31:0] in_4,
    input [31:0] in_5,
    input [31:0] in_6,
    input [31:0] in_7,
    input [31:0] in_8,
    input [31:0] in_9,
    output reg [3:0] out //0~9
);

reg [2:0]count;

reg [31:0]A_data_a;
reg [31:0]A_data_b;
reg [31:0]A_rslt_temp;
wire [6:0]A_ignore;
wire A_agthb;

reg [31:0]B_data_a;
reg [31:0]B_data_b;
reg [31:0]B_rslt_temp;
wire [6:0]B_ignore;
wire B_agthb;

reg [31:0]C_data_a;
reg [31:0]C_data_b;
reg [31:0]C_rslt_temp;
wire [6:0]C_ignore;
wire C_agthb;

FP_AgthB A(
    .s_axis_a_tdata(A_data_a),
    .s_axis_a_tvalid(1'b1),
    .s_axis_b_tdata(A_data_b),
    .s_axis_b_tvalid(1'b1),
    .m_axis_result_tdata({A_ignore, A_agthb})
);
FP_AgthB B(
    .s_axis_a_tdata(B_data_a),
    .s_axis_a_tvalid(1'b1),
    .s_axis_b_tdata(B_data_b),
    .s_axis_b_tvalid(1'b1),
    .m_axis_result_tdata({B_ignore, B_agthb})
);
FP_AgthB C(
    .s_axis_a_tdata(C_data_a),
    .s_axis_a_tvalid(1'b1),
    .s_axis_b_tdata(C_data_b),
    .s_axis_b_tvalid(1'b1),
    .m_axis_result_tdata({C_ignore, C_agthb})
);

always @ (posedge clk)begin
    if(rst)begin
        count <= 3'd0;
    end
    else count <= count + 1'b1;
end

always @ (posedge clk)begin
    if(rst) out <= 4'hf;
    else begin
        case(count)
        3'b000: begin // compare Layer 1
            A_data_a <= in_0;
            A_data_b <= in_1;
            B_data_a <= in_2;
            B_data_b <= in_3;
            C_data_a <= in_4;
            C_data_b <= in_5;
        end
        3'b001: begin
            A_rslt_temp <= A_agthb ? in_0 : in_1;
            B_rslt_temp <= B_agthb ? in_2 : in_3;
            C_rslt_temp <= C_agthb ? in_4 : in_5;
        end
        3'b010: begin // compare Layer 2
            A_data_a <= A_rslt_temp;
            A_data_b <= B_rslt_temp;
            B_data_a <= C_rslt_temp;
            B_data_b <= in_6;
            C_data_a <= in_7;
            C_data_b <= in_8;
        end
        3'b011: begin
            A_rslt_temp <= A_agthb ? A_rslt_temp : B_rslt_temp;
            B_rslt_temp <= B_agthb ? C_rslt_temp : in_6;
            C_rslt_temp <= C_agthb ? in_7 : in_8;
        end
        3'b100: begin // compare Layer 3
            A_data_a <= A_rslt_temp;
            A_data_b <= B_rslt_temp;
            B_data_a <= C_rslt_temp;
            B_data_b <= in_9;
        end
        3'b101: begin
            A_rslt_temp <= A_agthb ? A_rslt_temp : B_rslt_temp;
            B_rslt_temp <= B_agthb ? C_rslt_temp : in_9;
        end
        3'b110: begin // compare Layer 4
            C_data_a <= A_rslt_temp;
            C_data_b <= B_rslt_temp;
        end
        3'b111: begin
            if(C_agthb && A_rslt_temp == in_0) out <= 4'd0;
            else if(C_agthb && A_rslt_temp == in_1) out <= 4'd1;
            else if(C_agthb && A_rslt_temp == in_2) out <= 4'd2;
            else if(C_agthb && A_rslt_temp == in_3) out <= 4'd3;
            else if(C_agthb && A_rslt_temp == in_4) out <= 4'd4;
            else if(C_agthb && A_rslt_temp == in_5) out <= 4'd5;
            else if(C_agthb && A_rslt_temp == in_6) out <= 4'd6;
            else if(~C_agthb && B_rslt_temp == in_7) out <= 4'd7;
            else if(~C_agthb && B_rslt_temp == in_8) out <= 4'd8;
            else if(~C_agthb && B_rslt_temp == in_9) out <= 4'd9;
            else out <= 4'hF;
        end
        endcase
    end
end
 
endmodule
