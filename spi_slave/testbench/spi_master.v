`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:43:46 07/24/2018 
// Design Name: 
// Module Name:    spi_master 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_master(
		input wire 		clk,
		input wire 		reset,
		
		input wire 		  send_en,
		input wire  	  cmd,
		input wire [6:0] addr,
		input wire [7:0] data,
		output reg 	  spi_done,
		
		output wire		sck,
		output reg 		csn,
		output wire		mosi,
		input wire 	   miso
    );
	 
	 
	 wire falling_edge;
	 wire rising_edge;
	 reg [2:0] state;
	 reg [15:0] data_shr_tx;
	 reg [7:0] bit_cnt;
	 reg [7:0] rx_data;
	 reg cmd_r;
	 reg [7:0] sck_shr;
	 
	 always @ (posedge clk) begin
		if(reset)
			state <= 0;			
		else
			case (state)
				0: begin
						csn <= 1;	
						bit_cnt <= 0;
						if(send_en) begin
							state <= state + 1;
							csn <= 0;
							cmd_r <= cmd;
							if(cmd == 0) //wr
								data_shr_tx <= {cmd,addr,data};
							else
								data_shr_tx <= {cmd,addr,8'h00};
						end
				end
				
				1: state <= state + 1;			
				
				2: begin
						if(falling_edge) begin
							data_shr_tx <= data_shr_tx << 1;	
							bit_cnt <= bit_cnt + 1;													
							if(bit_cnt == 15)
								state <= state + 1;		
						end
					end
				3: begin
						//if(falling_edge)
							state <= state + 1;	
					end
				4: begin
							state <= 0;	
				end
			endcase
	 end
	 
	 
	 always @ (posedge clk) begin
		if(state == 0) sck_shr <= 8'b00001111;
		else sck_shr <= {sck_shr[6:0],sck_shr[7]};
	 end
	 
	  assign falling_edge = sck_shr[7] & ~sck_shr[6];
	  assign rising_edge = ~sck_shr[7] & sck_shr[6];
	  
	 
	 always @ (posedge clk) begin
			if(rising_edge && cmd_r && bit_cnt > 7)
				rx_data <= {rx_data[6:0],miso};			
	 end
	 
	always @ (posedge clk) 
		spi_done <= (state == 4); 

 
	 
	 assign sck = sck_shr[7];
	 assign mosi = data_shr_tx[15];
	 
	 
endmodule
