`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		R&C
// Engineer:		Andrei Sholudev
// 
// Module Name:    	spi slave physical layer
// Project Name:		Strack-S
// Target Devices:	Spartan 6 
// Tool versions:		14.7 
// Description: 
//		
//		spi slave physical layer: 
//			: 1 bit - wr/rd, 7 bits - address, 8 bits - data
//			: rx on rising edge
//
// Revision history: 
// Rev 0.01 - File Created
// Rev 1.0 	- ?	
//////////////////////////////////////////////////////////////////////////////////
module spi_phy(
		
		input wire 			clk,
		input wire 			reset,
		
		output reg 			rx_wr_en,
		output reg [6:0] 	rx_addr,
		output reg [7:0] 	rx_data,
		input wire [7:0] 	tx_data,
		
		input wire 			spi_en,
		input wire 			sck,
		input wire 			csn,
		input wire 			mosi,
		output wire 		miso
    );
	 
	 //declarations
	 wire 		spi_activate;
	 wire 		rx_bit_valid;
	 wire 		tx_bit_valid;
	 reg 			csn_r;
	 reg 			sck_r;
	 reg [1:0] 	state;
	 reg [7:0] 	tx_data_r;
	 reg 			operation;
	 reg [3:0] 	bit_cnt;
	 reg [7:0] 	temp_r;
	 //------------
	 

	 
	 
	 always @ (posedge clk) begin
		sck_r <= sck;
		csn_r <= csn;			
	 end
	 
	 
	 //sample on rising edge
	 assign rx_bit_valid = sck & ~sck_r;
	 //send on falling edge
	 assign tx_bit_valid = ~sck & sck_r;
	 //activate on falling edge of cs
	 assign spi_activate = ~csn & csn_r;
	 
	 //spi slave state machine
	 always @ (posedge clk) begin
		if(reset | csn | !spi_en) begin
			state <= 0;
			rx_wr_en <= 0;
			bit_cnt <= 0;
		end				
		else begin
				case(state)
				0: begin
					if(rx_bit_valid) begin
						operation <= mosi;
						state <= state + 1;
					end				
				end
				1: begin
						if(rx_bit_valid) begin
							temp_r <= {temp_r[6:0],mosi};						
							bit_cnt <= bit_cnt + 1;
							if(bit_cnt == 6)
								rx_addr <= {temp_r[5:0],mosi};
							if(bit_cnt == 14) begin
								state <= state + 1;	
								rx_data <= {temp_r[6:0],mosi};	
							end
						end
					end
				2: begin				
						state <= state + 1;			
						if(operation == 0)
							rx_wr_en <= 1;
					end
				3: rx_wr_en <= 0;
			endcase
		end
	 end
	 
	 	 
		 always @ (posedge clk) begin
			if(bit_cnt == 7) tx_data_r <= tx_data;
			else if(tx_bit_valid) tx_data_r <= {tx_data_r[6:0],1'b0};			
		 end
		 
		assign miso = tx_data_r[7];

endmodule
