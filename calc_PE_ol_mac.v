`timescale 1ns / 1ps

module PE_ol_mac(
    input clk,
    input [31:0] ifmap, // int32
    input [31:0] weight, // float32
	input [31:0] psum, //float32
    output [31:0] ofmap //float32
    );
    
    wire [31:0]ifmap_fp32;
    
    INT32_to_FLOAT32 INT2FLOAT(
        .aclk(clk),
        .s_axis_a_tdata(ifmap),
        .s_axis_a_tvalid(1'b1),
        .m_axis_result_tdata(ifmap_fp32)
    );
    
    FP_MAC fp_mac(
        .aclk(clk),
        .s_axis_a_tdata(weight),
        .s_axis_a_tvalid(1'b1),
        .s_axis_b_tdata(ifmap_fp32),
        .s_axis_b_tvalid(1'b1),
        .s_axis_c_tdata(psum),
        .s_axis_c_tvalid(1'b1),
        .m_axis_result_tdata(ofmap)
    );
    
endmodule
