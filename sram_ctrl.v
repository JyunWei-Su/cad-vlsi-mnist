`timescale 1ns / 1ns

module sram_ctrl(
    input clk,
    input rst,
    input en,
    input write,
    input read,
    input [18:0] addr,
    input [15:0] data_in,
	output reg [15:0] data_out,

	inout  [15:0] sram_data,
	output [18:0] sram_addr,
    output reg    sram_oe,
    output reg	  sram_ce,
    output reg	  sram_we,
    output reg	  sram_ub,
    output reg	  sram_lb
);

reg	we_n; //write enable activy low
reg[15:0] data_wr;

assign sram_addr = addr;
assign sram_data = we_n ? 16'bz : data_wr;

always @ ( posedge clk )
	if(rst) begin
        sram_oe <= 1'b1;
        sram_we <= 1'b1;
        sram_ce <= 1'b1;
        sram_ub <= 1'b1;
        sram_lb <= 1'b1;
		we_n <= 1'b1;

	end
	else if ( en ) begin
		if( write == 1'b1 && read == 1'b0 ) begin // write
			sram_oe <= 1'b1;
			sram_ce <= 1'b0;
			sram_we <= 1'b0;
			sram_ub <= 1'b0;
			sram_lb <= 1'b0;
			we_n <= 1'b0;
		end
		else if( read == 1'b1 && write == 1'b0 ) begin // read
			sram_oe <= 1'b0;
			sram_ce <= 1'b0;
			sram_we <= 1'b1;        
			sram_ub <= 1'b0;
			sram_lb <= 1'b0;
			we_n <= 1'b1;
		end
		else begin
			sram_oe <= 1'b1;
			sram_ce <= 1'b1;
			sram_we <= 1'b1;        
			sram_ub <= 1'b1;
			sram_lb <= 1'b1;
            we_n <= 1'b1;			
		end
    end else begin
        sram_oe <= 1'b1;
        sram_ce <= 1'b1;
        sram_we <= 1'b1;
        sram_ub <= 1'b1;
        sram_lb <= 1'b1;
        we_n <= 1'b1;
    end

always @( negedge clk )  // write need 2 T
    if( rst )
        data_wr <= 16'b0;
	else if( write == 1'b1 && read == 1'b0 )
		data_wr <= data_in;

always @( negedge clk ) // read need 1 T
	if( rst )
		data_out <= 16'b0;
	else if( read == 1'b1 && write == 1'b0 )
		data_out <= sram_data;	

endmodule
