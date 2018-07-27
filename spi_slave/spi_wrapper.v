`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		R&C
// Engineer:		Andrei Sholudev
// 
// Module Name:    	spi wrapper
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

module spi_wrapper(
		input wire 			clk,
		input wire 			reset,
		
		input wire [1:0] spi_sel,
		
		//slave input interface from CPU
		input wire 			sck,
		input wire 			csn,
		input wire 			mosi,
		(* IOB="TRUE" *)
		output reg 			miso,
		
		//user interface to fabric
		output wire			rx_wr_en,
		output wire [6:0] rx_addr,
		output wire [7:0] rx_data,
		input wire  [7:0] tx_data,
		
		//RFIC SPI interface		
		output wire    	rfic_sck,
		output wire			rfic_csn,
		output wire			rfic_mosi,
		input wire			rfic_miso,
		
		//ADC1 SPI interface		
		output wire 		adc1_sck,
		output wire 		adc1_csn,
		inout  wire			adc1_sdio,
		//ADC2 SPI interface		
		output wire 		adc2_sck,
		output wire 		adc2_csn,
		inout  wire			adc2_sdio

    );
	 
	 
	 //declarations
	 (* IOB="TRUE" *) 
	 reg sck_r;
	 (* IOB="TRUE" *) 
	 reg csn_r;
	 (* IOB="TRUE" *) 
	 reg mosi_r;
	 (* IOB="TRUE" *) 
	 reg [1:0] spi_sel_r;
	 
	 wire fpga_sel;
	 wire rfic_sel;
	 wire adc1_sel;
	 wire adc2_sel;
	 //------------
	 
	 //spi selection
	 assign fpga_sel = (spi_sel_r == 2'b00);
	 assign rfic_sel = (spi_sel_r == 2'b01);
	 assign adc1_sel = (spi_sel_r == 2'b10);
	 assign adc2_sel = (spi_sel_r == 2'b11);
	
	 
	 
	//lock into pads 
	 always @ (posedge clk) begin
		spi_sel_r <= spi_sel;
		sck_r  <= sck;
		csn_r  <= csn;
		mosi_r <= mosi;
		miso <= miso_mux;
	 end
	 
	 	 
	
	 
	 
	//fpga SPI slave controller
	spi_phy 
		fpga_spi_inst (
		 .clk			(clk), 
		 .reset		(reset), 
		 .spi_en		(fpga_sel), 
		 
		 //user interface
		 .rx_wr_en	(rx_wr_en), 
		 .rx_addr	(rx_addr), 
		 .rx_data	(rx_data), 
		 .tx_data	(tx_data), 
		 
		 //spi phy
		 .sck			(sck_r), 
		 .csn			(csn_r), 
		 .mosi		(mosi_r), 
		 .miso		(fpga_miso)
		 );
		 
		
	adc_spi_conv
		adc1_spi_inst
		(
		 .clk 		(clk),
		 .reset 		(reset),
		 .spi_en		(adc1_sel),
		 //input interface
		 .sck			(sck_r), 
		 .csn			(csn_r), 
		 .mosi		(mosi_r), 
		 
		 //output interface
		 .adc_sck	(adc1_sck),
		 .adc_csn	(adc1_csn),
		 .adc_miso	(adc1_miso),
		 .adc_sdio	(adc1_sdio)
		);


	adc_spi_conv
		adc2_spi_inst
		(
		 .clk 		(clk),
		 .reset 		(reset),
		 .spi_en		(adc2_sel),
		 //input interface
		 .sck			(sck_r), 
		 .csn			(csn_r), 
		 .mosi		(mosi_r), 
		 
		 //output interface
		 .adc_sck	(adc2_sck),
		 .adc_csn	(adc2_csn),
		 .adc_miso	(adc2_miso),
		 .adc_sdio	(adc2_sdio)
		);
			

		//rfic select
		assign rfic_sck  = (rfic_sel) ?  sck_r  : 1'b1;
		assign rfic_csn  = (rfic_sel) ?  csn_r  : 1'b1;
		assign rfic_mosi = (rfic_sel) ?  mosi_r : 1'b1;
		
	
		assign miso_mux = (fpga_sel) ? fpga_miso :
								(rfic_sel) ? rfic_miso :
								(adc1_sel) ? adc1_miso : adc2_miso;
								
		
			
endmodule
