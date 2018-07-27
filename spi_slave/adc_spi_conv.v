`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		R&C
// Engineer:		Andrei Sholudev
// 
// Module Name:    	adc spi converter
// Project Name:		Strack-S
// Target Devices:	Spartan 6 
// Tool versions:		14.7 
// Description: 
//		
//		spi wrapper
//
// Revision history: 
// Rev 0.01 - File Created
// Rev 1.0 	- ?	
//////////////////////////////////////////////////////////////////////////////////
module adc_spi_conv(
	input wire clk,
	input wire reset,
	input wire spi_en,
	
	//input interface
	input wire sck,
	input wire csn,	
	input wire mosi,
	
	//output interface
	output wire adc_sck,
	output wire	adc_csn,
	output wire adc_miso,
	inout wire	adc_sdio
  );
	 
	 //declarations
	 wire 		rx_bit_valid;
	 reg 			csn_r;
	 reg 			sck_r;
	 reg [0:0] 	state;
	 reg [3:0] 	bit_cnt;
	 wire			local_reset;
	 reg 			buf_t;
	 //------------

	 always @ (posedge clk) begin
		sck_r <= sck;
		csn_r <= csn;			
	 end
	 
	 assign local_reset = reset | csn | !spi_en;
	 
	 //sample on rising edge
	 assign rx_bit_valid = sck & ~sck_r;

	always @ (posedge clk) begin
		if(local_reset) begin			
			state	<= 0;
			buf_t <= 1;	//in highZ	
		end else
			case(state)
				0: begin
					buf_t <= 0;	//tx mode
					if(rx_bit_valid & mosi && bit_cnt == 0)
						state <= state + 1;
				end
				1: begin										
						if(bit_cnt == 15)
							buf_t <= 1;	//in highZ						
				end
			endcase					
	end	
	
	
	always @ (posedge clk) begin
		if(local_reset) bit_cnt <= 0;
		else if(rx_bit_valid) bit_cnt <= bit_cnt + 1;
	end
	

		
		assign adc_sck  = (spi_en) ?  sck  : 1'b1;
		assign adc_csn  = (spi_en) ?  csn  : 1'b1;
		assign adc_mosi = (spi_en) ?  mosi : 1'b1;
		
		IOBUF iobuf_sdio (.IO(adc_sdio),.O(adc_miso),.I(adc_mosi),.T(buf_t));
  

endmodule
