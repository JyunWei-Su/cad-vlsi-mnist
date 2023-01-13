`timescale 1ns / 1ps

module PE_hl_mac_x56(
    input clk,
    input calc,
    input write_weight,
    input [7:0] ifmap, // uint8
    input [7:0] weight, // int8
    input [5:0] weight_id, // 0~55
    output reg [31:0] ofmap, //int32
    output reg complete
    );
    
    wire [31:0] buf_mul_wire [0:55];
    
    reg [1:0] state_count;
    reg [7:0] weight_buf [0:55];
    reg [31:0] buf_mul [0:55];
    reg [31:0] acc_L1 [0:13];
    reg [31:0] acc_L2 [0:3];

    
    genvar i;   
    generate
    for( i = 0; i < 6'd56; i = i + 1 )
    begin: PE
        PE_hl_mul(
            .ifmap(ifmap),
            .weight(weight_buf[i]),
            .ofmap(buf_mul_wire[i])
        );
    end
    endgenerate
    
    always @( posedge clk ) begin
        if (write_weight) begin
            weight_buf[weight_id] <= weight;
        end else if (~calc) begin
            ofmap <= 32'b0;
            complete <= 1'b0;
            state_count <= 2'b00;
        end else begin // calc start
            case(state_count)
                2'b00: begin
                    state_count <= state_count + 1'b1;
                    buf_mul[0] <= buf_mul_wire[0];
                    buf_mul[1] <= buf_mul_wire[1];
                    buf_mul[2] <= buf_mul_wire[2];
                    buf_mul[3] <= buf_mul_wire[3];
                    buf_mul[4] <= buf_mul_wire[4];
                    buf_mul[5] <= buf_mul_wire[5];
                    buf_mul[6] <= buf_mul_wire[6];
                    buf_mul[7] <= buf_mul_wire[7];
                    buf_mul[8] <= buf_mul_wire[8];
                    buf_mul[9] <= buf_mul_wire[9];
                    buf_mul[10] <= buf_mul_wire[10];
                    buf_mul[11] <= buf_mul_wire[11];
                    buf_mul[12] <= buf_mul_wire[12];
                    buf_mul[13] <= buf_mul_wire[13];
                    buf_mul[14] <= buf_mul_wire[14];
                    buf_mul[15] <= buf_mul_wire[15];
                    buf_mul[16] <= buf_mul_wire[16];
                    buf_mul[17] <= buf_mul_wire[17];
                    buf_mul[18] <= buf_mul_wire[18];
                    buf_mul[19] <= buf_mul_wire[19];
                    buf_mul[20] <= buf_mul_wire[20];
                    buf_mul[21] <= buf_mul_wire[21];
                    buf_mul[22] <= buf_mul_wire[22];
                    buf_mul[23] <= buf_mul_wire[23];
                    buf_mul[24] <= buf_mul_wire[24];
                    buf_mul[25] <= buf_mul_wire[25];
                    buf_mul[26] <= buf_mul_wire[26];
                    buf_mul[27] <= buf_mul_wire[27];
                    buf_mul[28] <= buf_mul_wire[28];
                    buf_mul[29] <= buf_mul_wire[29];
                    buf_mul[30] <= buf_mul_wire[30];
                    buf_mul[31] <= buf_mul_wire[31];
                    buf_mul[32] <= buf_mul_wire[32];
                    buf_mul[33] <= buf_mul_wire[33];
                    buf_mul[34] <= buf_mul_wire[34];
                    buf_mul[35] <= buf_mul_wire[35];
                    buf_mul[36] <= buf_mul_wire[36];
                    buf_mul[37] <= buf_mul_wire[37];
                    buf_mul[38] <= buf_mul_wire[38];
                    buf_mul[39] <= buf_mul_wire[39];
                    buf_mul[40] <= buf_mul_wire[40];
                    buf_mul[41] <= buf_mul_wire[41];
                    buf_mul[42] <= buf_mul_wire[42];
                    buf_mul[43] <= buf_mul_wire[43];
                    buf_mul[44] <= buf_mul_wire[44];
                    buf_mul[45] <= buf_mul_wire[45];
                    buf_mul[46] <= buf_mul_wire[46];
                    buf_mul[47] <= buf_mul_wire[47];
                    buf_mul[48] <= buf_mul_wire[48];
                    buf_mul[49] <= buf_mul_wire[49];
                    buf_mul[50] <= buf_mul_wire[40];
                    buf_mul[51] <= buf_mul_wire[51];
                    buf_mul[52] <= buf_mul_wire[52];
                    buf_mul[53] <= buf_mul_wire[53];
                    buf_mul[54] <= buf_mul_wire[54];
                    buf_mul[55] <= buf_mul_wire[55];
                end
                2'b01: begin
                    state_count <= state_count + 1'b1;
                    acc_L1[0] <= (buf_mul[0] + buf_mul[1]) + (buf_mul[2] + buf_mul[3]);
                    acc_L1[1] <= (buf_mul[4] + buf_mul[5]) + (buf_mul[6] + buf_mul[7]);
                    acc_L1[2] <= (buf_mul[8] + buf_mul[9]) + (buf_mul[10] + buf_mul[11]);
                    acc_L1[3] <= (buf_mul[12] + buf_mul[13]) + (buf_mul[14] + buf_mul[15]);
                    acc_L1[4] <= (buf_mul[16] + buf_mul[17]) + (buf_mul[18] + buf_mul[19]);
                    acc_L1[5] <= (buf_mul[20] + buf_mul[21]) + (buf_mul[22] + buf_mul[23]);
                    acc_L1[6] <= (buf_mul[24] + buf_mul[25]) + (buf_mul[26] + buf_mul[27]);
                    acc_L1[7] <= (buf_mul[28] + buf_mul[29]) + (buf_mul[30] + buf_mul[31]);
                    acc_L1[8] <= (buf_mul[32] + buf_mul[33]) + (buf_mul[34] + buf_mul[35]);
                    acc_L1[9] <= (buf_mul[36] + buf_mul[37]) + (buf_mul[38] + buf_mul[39]);
                    acc_L1[10] <= (buf_mul[40] + buf_mul[41]) + (buf_mul[42] + buf_mul[43]);
                    acc_L1[11] <= (buf_mul[44] + buf_mul[45]) + (buf_mul[46] + buf_mul[47]);
                    acc_L1[12] <= (buf_mul[48] + buf_mul[49]) + (buf_mul[50] + buf_mul[51]);
                    acc_L1[13] <= (buf_mul[52] + buf_mul[53]) + (buf_mul[54] + buf_mul[55]);
                end
                2'b10:begin
                    state_count <= state_count + 1'b1;
                    acc_L2[0] <= (acc_L1[0] + acc_L1[1]) + (acc_L1[2] + acc_L1[3]);
                    acc_L2[1] <= (acc_L1[4] + acc_L1[5]) + acc_L1[6] ;
                    acc_L2[0] <= (acc_L1[7] + acc_L1[8]) + (acc_L1[9] + acc_L1[10]);
                    acc_L2[3] <= (acc_L1[11] + acc_L1[12]) + acc_L1[13] ;
                end
                2'b11:begin
                    complete <= 1'b1;
                    ofmap <= (acc_L2[0] + acc_L2[1]) + (acc_L2[2] + acc_L2[3]);
                end
                    
            endcase
        end
    end
    
endmodule
