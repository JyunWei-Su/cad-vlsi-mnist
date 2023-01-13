`timescale 1ns / 1ps

module mnist_top(
    input clk,
    input rst_n,
    
    output [7:0]LD1,
    output reg [7:0]LD2,
    
    input btn_s0,
    input btn_s1,
    input btn_s2,
    input btn_s3,
    input btn_s4,
    
    input [7:0]switch, // SW0~Sw7
    input [7:0]dip,    // dip0~dip7
    
    input rx_pin_jb1,
    output tx_pin_jb0,
    //output tx_buf_not_full,
    
    // 7-seg display
    output [3:0]seg_h_an, // DN0 (DK 1-4) => B3, B2
    output [7:0]seg_h_code,
    output [3:0]seg_l_an, // DN1 (DK 5-8) => B1, B0
    output [7:0]seg_l_code,
    
    // SRAM
    inout  [15:0] sram_data,
    output [18:0] sram_addr,
    output sram_oe_r,
    output sram_ce_r,
    output sram_we_r,
    output sram_ub_r,
    output sram_lb_r
    );
    
    parameter IDLE = 5'h0, CMD_S0 = 5'h1, CMD_S1 = 5'h2, DEBUG_SRAM = 5'h3, // 00
              CALC_HL_START = 5'h4, CALC_HL_READ_BIAS = 5'h5, CALC_HL_MAC_START = 5'h6, CALC_HL_MAC = 5'h7, // 01
              CALC_OL_START = 5'h8, CALC_OL_READ_BIAS = 5'h9, CALC_OL_MAC_START = 5'ha, CALC_OL_MAC = 5'hb,
              DATA_IN_S0 = 5'hc, DATA_IN_S1 = 5'hd, DATA_IN_S2 = 5'he, DATA_IN_S3 = 5'hf, // 11
              CALC_SOFTMAX_START = 5'h10, CALC_SOFTMAX_WAIT = 5'h11, FINAL = 5'h12;
              
    parameter ADDR_IMG_RESET=19'h0000F, ADDR_IMG_END=19'h00630, ADDR_IDLE = 19'h00000, // F0
              ADDR_HLW_RESET=19'h00FFF, ADDR_HLW_END=19'h19800, // hl weight int8    64*784  (0xC400) F1
              ADDR_HLB_RESET=19'h19FFF, ADDR_HLB_END=19'h1A200, // hl bias   int32   64*4    (0x0100) F2
              ADDR_OLW_RESET=19'h1AFFF, ADDR_OLW_END=19'h1C400, // ol weight float32 10*64*4 (0x0A00) F3
              ADDR_OLB_RESET=19'h1CFFF, ADDR_OLB_END=19'h1D050, // ol bias   float32 10*4    (0x0028) F4
              ADDR_RST_RESET=19'h1EFFD, ADDR_RST_END=19'h1EFFF;
    
    //data size count (byte)
    //parameter DSC_IMG = 1'b0, DSC_HLW = 1'b0, DSC_HLB = 1'b1, DSC_OLW = 1'b1, DSC_OLB = 1'b1;
    parameter PID_IMG = 4'd0, PID_HLW = 4'd1, PID_HLB = 4'd2, PID_OLW = 4'd3, PID_OLB = 4'd4,
              PID_RST = 4'd5, PID_NONE = 4'd6;
    
    // control signal
    wire rst_btn_c = ~rst_n;
    wire rst, rx_pin_in, read_sig, write_sig;
    reg uart_read_byte;
    reg sram_enable, sram_read_byte, sram_write_byte;
    
    // data reg./ wire.
    wire rx_buf_not_empty;
    wire rx_buf_full;
    wire tx_buf_not_full;
    reg [7:0] tx_data;
    wire [7:0] rx_wire;
    reg [7:0] rx_data;
    reg [3:0] resultt;
    reg [18:0] data_addr_ptr;
    reg [18:0] data_addr_end;
    reg [15:0] sram_write_data;
    wire [15:0] sram_read_data;
    
    // fsm
    reg [4:0]now_state;
    reg [4:0]nxt_state;
    //reg size_count;
    //reg size_check;

    // calc buf
    reg [31:0] hl_buf [0:63];
    reg [31:0] ol_buf [0:9];
    reg [7:0]hl_input_buf;
    reg [7:0]hl_weight_buf;
    wire [31:0] hl_mac_result;
    wire [31:0] hl_buf_relu;
    reg [31:0]ol_input_buf;
    reg [31:0]ol_weight_buf;
    wire [31:0] ol_mac_result;
    wire [3:0] result_wire;
    reg [3:0] result;
    
    
    // calc count
    reg [1:0]byte_count;
    reg [5:0]hl_bias_count; // read 0~63
    reg [16:0]hl_mac_count;
    reg [10:0]hl_ifmap_count;
    reg [3:0]ol_bias_count; // read 0~9
    reg [9:0]ol_mac_count;
    reg [5:0]ol_ifmap_count;
    reg [2:0]ol_step_count;
    reg rst_max;
    
    // led 1
    assign LD1[7] = tx_buf_not_full;
    assign LD1[6] = rx_buf_not_empty;
    assign LD1[5] = rx_buf_full;
    assign LD1[3] = now_state[3];
    assign LD1[2] = now_state[2];
    assign LD1[1] = now_state[1];
    assign LD1[0] = now_state[0];

    // state reg.
    always @( posedge clk or posedge rst) begin
        if( rst ) now_state <= IDLE;
        else now_state <= nxt_state;
    end

    // next state logic
    always @( posedge clk or posedge rst) begin
        if( rst ) nxt_state <= IDLE;
        else begin
            case (now_state)
            IDLE: begin
                if(rx_buf_not_empty) nxt_state <= CMD_S0;
                else if (btn_s2) nxt_state <= DEBUG_SRAM;
                else if (btn_s1) nxt_state <= CALC_HL_START;
                else nxt_state <= IDLE;
            end
            
            CMD_S0:begin
                nxt_state <= CMD_S1;
            end
            CMD_S1: begin
                if(rx_wire[7:4] == 4'hF && rx_wire[3:0] < PID_NONE) nxt_state <= DATA_IN_S0;
                else nxt_state <= IDLE;
            end
            
            DATA_IN_S0: begin
                if(rx_buf_not_empty) nxt_state <= DATA_IN_S1;
                else nxt_state <= DATA_IN_S0;
            end
            DATA_IN_S1: begin
                nxt_state <= DATA_IN_S2;
            end
            DATA_IN_S2: nxt_state <= DATA_IN_S3;
            DATA_IN_S3: begin
                if(data_addr_ptr < data_addr_end) nxt_state <= DATA_IN_S0;
                else nxt_state <= IDLE;
            end
            
            CALC_HL_START: nxt_state <= CALC_HL_READ_BIAS;
            CALC_HL_READ_BIAS: begin
                if(data_addr_ptr > ADDR_HLB_END) nxt_state <= CALC_HL_MAC;
                else nxt_state <= CALC_HL_READ_BIAS;
            end
            CALC_HL_MAC_START: nxt_state <= CALC_HL_MAC;
            CALC_HL_MAC: begin
                if(hl_mac_count >= 16'hC400) nxt_state <= CALC_OL_START;
                else nxt_state <= CALC_HL_MAC;
            end
            
            CALC_OL_START: nxt_state <= CALC_OL_READ_BIAS;
            CALC_OL_READ_BIAS: begin
                if(data_addr_ptr > ADDR_OLB_END) nxt_state <= CALC_OL_MAC;
                else nxt_state <= CALC_OL_READ_BIAS;
            end
            CALC_OL_MAC_START: nxt_state <= CALC_OL_MAC;
            CALC_OL_MAC: begin
                if(ol_mac_count >= 10'h280) nxt_state <= CALC_SOFTMAX_START;
                else nxt_state <= CALC_HL_MAC;
            end
            CALC_SOFTMAX_START: nxt_state <= CALC_SOFTMAX_START;
            CALC_SOFTMAX_WAIT: if(ol_step_count == 3'b111) nxt_state <= FINAL;
            FINAL: nxt_state <= IDLE;
            
            DEBUG_SRAM: nxt_state <= DEBUG_SRAM;
            default: nxt_state <= IDLE;
            endcase
        end
    end
    
    // data flow
    always @( posedge clk ) begin
        case (now_state)
        IDLE: begin
            if(rx_buf_not_empty) uart_read_byte <= 1'b1;
            else uart_read_byte <= 1'b0;
            sram_enable <= 1'b0;
            sram_read_byte <= 1'b0;
            sram_write_byte <= 1'b0;
            data_addr_ptr <= ADDR_IDLE;
        end
        
        CMD_S0:begin
            uart_read_byte <= 1'b0;
        end
        CMD_S1: begin
            uart_read_byte <= 1'b0;
            if(rx_wire[7:4] == 4'hF) begin
                case(rx_wire[3:0])
                    PID_IMG: begin data_addr_ptr <= ADDR_IMG_RESET; data_addr_end <= ADDR_IMG_END; end
                    PID_HLB: begin data_addr_ptr <= ADDR_HLB_RESET; data_addr_end <= ADDR_HLB_END; end
                    PID_HLW: begin data_addr_ptr <= ADDR_HLW_RESET; data_addr_end <= ADDR_HLW_END; end
                    PID_OLB: begin data_addr_ptr <= ADDR_OLB_RESET; data_addr_end <= ADDR_OLB_END; end
                    PID_OLW: begin data_addr_ptr <= ADDR_OLW_RESET; data_addr_end <= ADDR_OLW_END; end
                    PID_RST: begin data_addr_ptr <= ADDR_RST_RESET; data_addr_end <= ADDR_RST_END; end
                    default: begin data_addr_ptr <= ADDR_IDLE;      data_addr_end <= ADDR_IDLE;    end
                endcase
            end
            else data_addr_ptr <= ADDR_IDLE;
        end
        
        DATA_IN_S0: begin
            if(rx_buf_not_empty) begin
                uart_read_byte <= 1'b1;
                data_addr_ptr <= data_addr_ptr + 1'b1;
            end
            else uart_read_byte <= 1'b0;
            sram_enable <= 1'b0;
            sram_write_byte <= 1'b0;
        end
        DATA_IN_S1: begin
            uart_read_byte <= 1'b1;
        end
        DATA_IN_S2: begin
            uart_read_byte <= 1'b0;
            sram_write_data <= {8'h00, rx_wire};
            if(data_addr_end == ADDR_RST_END) resultt <= rx_wire[3:0];
        end
        DATA_IN_S3: begin
            uart_read_byte <= 1'b0;
            sram_enable <= 1'b1;
            sram_write_byte <= 1'b1;
        end
        
        CALC_HL_START: begin
            data_addr_ptr <= ADDR_HLB_RESET + 3'd4;
            sram_enable <= 1'b1;
            sram_read_byte <= 1'b1;
            byte_count <= 2'b00;
            hl_bias_count <= 6'd0;
        end
        CALC_HL_READ_BIAS: begin
            case(byte_count)
                2'b00: hl_buf[hl_bias_count][31:24] <= sram_read_data;
                2'b01: hl_buf[hl_bias_count][23:16] <= sram_read_data;
                2'b10: hl_buf[hl_bias_count][15:8] <= sram_read_data;
                2'b11: hl_buf[hl_bias_count][7:0] <= sram_read_data;
            endcase
            if(byte_count == 2'b11) hl_bias_count <= hl_bias_count + 1'b1;
            byte_count <= byte_count + 1'b1;
            data_addr_ptr <= data_addr_ptr + 2'd2;
        end
        CALC_HL_MAC_START: begin
            data_addr_ptr <= ADDR_IMG_RESET + 3'd4;
            sram_enable <= 1'b1;
            sram_read_byte <= 1'b1;
            byte_count <= 2'b00;
            hl_mac_count <= 16'd0;
            hl_bias_count <= 6'd0;
        end
        CALC_HL_MAC: begin
            case(byte_count)
                2'b00: begin
                    hl_input_buf <= sram_read_data;
                    data_addr_ptr <= ADDR_HLB_RESET + 2'd0 + hl_mac_count << 1; // read weight
                end
                2'b01: begin
                    hl_weight_buf <= sram_read_data;
                end
                2'b10: begin
                    data_addr_ptr <= ADDR_HLB_RESET + 2'd0 + hl_ifmap_count << 1; // read input
                    hl_buf[hl_bias_count] <= hl_mac_result;
                end
            endcase
            if(byte_count == 2'b10)begin
                byte_count <= 2'b00;
                hl_mac_count <= hl_mac_count + 1'b1;
                if (hl_ifmap_count == 11'd783)begin
                    hl_ifmap_count <= 11'd0;
                    hl_bias_count <= hl_bias_count + 1'b1;
                end
                else hl_ifmap_count <= hl_ifmap_count +1'b1;
            end
            else byte_count <= byte_count + 1'b1;
            
        end

        CALC_OL_START: begin
            data_addr_ptr <= ADDR_OLB_RESET + 3'd4;
            sram_enable <= 1'b1;
            sram_read_byte <= 1'b1;
            byte_count <= 2'b00;
            ol_bias_count <= 6'd0;
        end
        CALC_OL_READ_BIAS: begin
            case(byte_count)
                2'b00: ol_buf[ol_bias_count][31:24] <= sram_read_data;
                2'b01: ol_buf[ol_bias_count][23:16] <= sram_read_data;
                2'b10: ol_buf[ol_bias_count][15:8] <= sram_read_data;
                2'b11: ol_buf[ol_bias_count][7:0] <= sram_read_data;
            endcase
            if(byte_count == 2'b11) ol_bias_count <= ol_bias_count + 1'b1;
            byte_count <= byte_count + 1'b1;
            data_addr_ptr <= data_addr_ptr + 2'd2;
        end
        CALC_OL_MAC_START: begin
            data_addr_ptr <= ADDR_OLW_RESET + 3'd4;
            sram_enable <= 1'b1;
            sram_read_byte <= 1'b1;
            byte_count <= 2'b00;
            ol_mac_count <= 16'd0;
            ol_bias_count <= 6'd0;
            ol_step_count <= 3'b0;
        end
        CALC_OL_MAC: begin
            case(byte_count)
                2'b00: begin
                    ol_weight_buf <= sram_read_data;
                    data_addr_ptr <= ADDR_HLB_RESET + 2'd0 + ol_mac_count << 1; // read weight
                    byte_count <= byte_count + 1'b1;
                end
                2'b01: begin 
                    ol_input_buf <= hl_buf_relu;
                    byte_count <= byte_count + 1'b1;
                end
                2'b10: begin //cal //wait 8 clk
                    if(ol_step_count == 3'b111) byte_count <= byte_count + 1'b1;
                    ol_step_count <= ol_step_count + 1'b1;
                end
                2'b11:begin
                    byte_count <= 2'b00;
                    ol_mac_count <= ol_mac_count + 1'b1;
                    if (ol_ifmap_count == 6'd63)begin
                        ol_ifmap_count <= 6'd0;
                        ol_bias_count <= ol_bias_count + 1'b1;
                    end
                    else ol_ifmap_count <= ol_ifmap_count +1'b1;
                end
            endcase
            
        end
        CALC_SOFTMAX_START: ol_step_count <= 3'd0;
        CALC_SOFTMAX_WAIT: ol_step_count <= ol_step_count + 1'b1;
        FINAL: result <= result_wire;
        DEBUG_SRAM: begin
            sram_enable <= 1'b1;
            sram_read_byte <= 1'b1;
            if (btn_s0) data_addr_ptr <= ADDR_HLW_RESET;
            else if (btn_s1) data_addr_ptr <= ADDR_HLB_RESET;
            else if (btn_s3) data_addr_ptr <= ADDR_OLW_RESET;
            else if (btn_s4) data_addr_ptr <= ADDR_OLB_RESET;
            else if(read_sig) data_addr_ptr <= data_addr_ptr + 2'd2;
        end
        default:begin
            uart_read_byte <= 1'b0;
            sram_read_byte <= 1'b0;
        end
        endcase 
    end

    input_signal_processing sig_processing(
        .clk( clk ),
        .rst_btn_c( rst_btn_c ),
        .rst( rst ),
        
        .rx_pin_jb1( rx_pin_jb1 ),
        .rx_pin_in( rx_pin_in ),
        
        .get_btn_d( btn_s2 ),
        .read_sig( read_sig ),
        
        .send_btn_r( btn_s0 ),
        .write_sig( write_sig )
             
    );//en_sw15( en_sw15 ) .en_sig_ld15(  )
    
    // hidden layer PE
    PE_hl_mac HL_MAC(
        .ifmap(hl_input_buf),
        .weight(hl_weight_buf),
        .psum(hl_buf[hl_bias_count]),
        .ofmap(hl_mac_result)
    );

    // hidden layer ReLU
    PE_relu HL_RELU(
        .in(hl_buf[ol_ifmap_count]),
        .out(hl_buf_relu)
    );

    // output layer PE
    PE_ol_mac OL_MAC(
        .clk(clk),
        .ifmap(ol_input_buf),
        .weight(ol_weight_buf),
        .psum(ol_buf[ol_bias_count]),
        .ofmap(ol_mac_result)
    );
    
    PE_findamx (
        .clk(clk),
        .rst(rst_max),
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

    // sram module
    sram_ctrl sram(
        .clk( clk ),
        .rst( rst ),
        .en( sram_enable ),
        .write( sram_write_byte ),
        .read( sram_read_byte ),
        .addr( data_addr_ptr ),
        .data_in( sram_write_data ),
        .data_out( sram_read_data ),
    
        .sram_data(sram_data),
        .sram_addr(sram_addr),
        .sram_oe(sram_oe_r),
        .sram_ce(sram_ce_r),
        .sram_we(sram_we_r),
        .sram_ub(sram_ub_r),
        .sram_lb(sram_lb_r)
    );

    // uart module
    uart_module uart(
        .clk( clk ),
        .rst( rst ),
        .en( 1'b1 ),
        .rx_read( uart_read_byte ),
        .rx_pin_in( rx_pin_in ),
        .rx_get_data( rx_wire ),
        .rx_buf_not_empty( rx_buf_not_empty ),
        .rx_buf_full( rx_buf_full ),
        
        .tx_write( write_sig ),
        .tx_pin_out( tx_pin_jb0 ),
        .tx_send_data( tx_data ),
        .tx_buf_not_full( tx_buf_not_full )
    );
    
    // 7-seg display
    seg7_module seg7(
        .clk( clk ),
        .rst( rst ),
        .b3_data( dip[7] ? ol_buf[switch[3:0]][31:24] : 8'b0),
        .b2_data( dip[7] ? ol_buf[switch[3:0]][23:16] : 8'b0),
        .b1_data( dip[7] ? ol_buf[switch[3:0]][15:8]  : 8'b0),
        .b0_data( dip[7] ? ol_buf[switch[3:0]][7:0]  : {4'b0, result}),
        .seg_h_an( seg_h_an ),
        .seg_h_code( seg_h_code ),
        .seg_l_an( seg_l_an ),
        .seg_l_code( seg_l_code )
    );
    
endmodule
