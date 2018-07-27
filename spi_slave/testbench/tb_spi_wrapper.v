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
//		spi slave wrapper testbench
//
// Revision history: 
// Rev 0.01 - File Created
// Rev 1.0 	- ?	
//////////////////////////////////////////////////////////////////////////////////

module tb_spi_wrapper;
	`define wr 1'b0
	`define rd 1'b1

    localparam real CLK_FREQ_HZ = 100_000_000; 
    localparam real CLK_FREQ_NS = 1000000000 / CLK_FREQ_HZ; 

    localparam real SPI_FREQ_HZ = 20_000_000; 
    localparam real SPI_FREQ_NS = 1000000000 / SPI_FREQ_HZ; 	 

	// Inputs
	reg clk;
	reg reset;
	reg sck;
	reg csn;
	reg mosi;
	wire miso;
	reg spi_done;
	reg [15:0] shift_r;
	reg [7:0] rx_shr;
	reg err;
	reg [1:0] spi_sel;
	//user interface to fabric
	wire		  rx_wr_en;
	wire [6:0] rx_addr;
	wire [7:0] rx_data;
	reg  [7:0] tx_data;
	
    initial begin
        clk = 1'b0;
        #(CLK_FREQ_NS/2);
        forever
           #(CLK_FREQ_NS/2) clk = ~clk;
     end	
	  
	  
	  
     initial begin
          reset = 1;          
          #100; reset = 0; 
			 #10; spi_sel = 0;			 
      end	  

	// Instantiate the device Under Test (UUT)
	spi_wrapper dut (
		 .clk(clk), 
		 .reset(reset), 		 
		 .spi_sel(spi_sel), 
		 
		 .sck(sck), 		 
		 .csn(csn), 
		 .mosi(mosi), 
		 .miso(miso), 
		 
		 .rx_wr_en(rx_wr_en), 
		 .rx_addr(rx_addr), 
		 .rx_data(rx_data), 
		 .tx_data(tx_data), 
		 
		 .rfic_sck(rfic_sck), 
		 .rfic_csn(rfic_csn), 
		 .rfic_mosi(rfic_mosi), 
		 .rfic_miso(rfic_miso), 
		 
		 .adc1_sck(adc1_sck), 
		 .adc1_csn(adc1_csn), 
		 .adc1_sdio(adc1_sdio), 
		 
		 .adc2_sck(adc2_sck), 
		 .adc2_csn(adc2_csn), 
		 .adc2_sdio(adc2_sdio)
		 );
	
		 //tbram
		 reg [7:0] ram [15:0];
		 
		 always @ (posedge clk) begin
			if(rx_wr_en) ram[rx_addr] <= rx_data;
			tx_data <= ram[rx_addr];
		 end	
		 //


     initial begin           
            #200; write_spi(7'h01, 8'h01);
            wait(spi_done); write_spi(7'h02, 8'h02);      
            wait(spi_done); write_spi(7'h03, 8'h03);
            wait(spi_done); write_spi(7'h04, 8'h04);
            wait(spi_done); write_spi(7'h05, 8'h05);
            wait(spi_done); write_spi(7'h06, 8'h06);
            wait(spi_done); write_spi(7'h07, 8'hFF);
            wait(spi_done); write_spi(7'h08, 8'h08);
				wait(spi_done); read_spi(7'h07, 8'hFF);
				wait(spi_done); read_spi(7'h06, 8'h06);
				wait(spi_done); read_spi(7'h08, 8'h08);
				wait(spi_done); read_spi(7'h05, 8'h05);
				$finish;
        end        
    


		 
        
        



		  task automatic write_spi;
          input [6:0]	addr;
          input [7:0] 	data;
			 
				begin
					spi_done = 0;
					csn = 0;
					sck = 0;
					mosi = `wr;
					shift_r = {`wr,addr,data};
					
					#(SPI_FREQ_NS/2);
					repeat (32) begin
						#(SPI_FREQ_NS/2); sck = ~sck;	
						if(!sck) begin
							shift_r = shift_r << 1;
							#1; mosi = shift_r[15];
						end
					end
					#(SPI_FREQ_NS/2);
					csn = 1;
					#(SPI_FREQ_NS/2);
					spi_done = 1;
					
				end
		  endtask 
		  
		  
		  
		  task automatic read_spi;
          input [6:0]	addr;
          input [7:0] 	expected_data;
			 
				begin
					spi_done = 0;
					csn = 0;
					sck = 0;
					mosi = `rd;
					shift_r = {`rd,addr,8'h00};
					
					#(SPI_FREQ_NS/2);
					repeat (32) begin
						#(SPI_FREQ_NS/2); sck = ~sck;	
						if(!sck) begin
							shift_r = shift_r << 1;
							#1; mosi = shift_r[15];							
						end
						else 
							rx_shr <= {rx_shr[6:0],miso};
					end
					#(SPI_FREQ_NS/2);
					csn = 1;
					#(SPI_FREQ_NS/2);
					spi_done = 1;
					
					
					if(rx_shr != expected_data)
						$display("Expected: %h != %h Received", rx_shr, expected_data);
					else
						$display("addr: %h : %h", addr, rx_shr);
				end
		  endtask
		  
		 

endmodule

