`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 		R&C
// Engineer:		Andrei Sholudev
// 
// Module Name:    	tb_jitter
// Project Name:		Strack-S
// Target Devices:	Spartan 6 
// Tool versions:		14.7 
// Description: 
//		
//		tb_jitter
//
// Revision history: 
// Rev 0.01 - File Created
// Rev 1.0 	- ?	
//////////////////////////////////////////////////////////////////////////////////

module tb_jitter(

    );
    

    reg m00_axis_aclk;
    localparam real AXI_CLK_FREQ = 100000000;
    localparam real AXI_CLK_PERIOD = 1000000000/AXI_CLK_FREQ;    
    localparam JITTER_PS = 50;        
    
    initial begin       
        m00_axis_aclk = 0;
       //forever #(AXI_CLK_PERIOD/2) m00_axis_aclk = ~m00_axis_aclk;                 
        //forever #(AXI_CLK_PERIOD/2 + $dist_uniform(seed,-JITTER,JITTER)/100.0) m00_axis_aclk = ~m00_axis_aclk;
        forever begin            
            #(AXI_CLK_PERIOD/2 +  $itor($random%(JITTER_PS))/$itor(1000)) m00_axis_aclk = ~m00_axis_aclk;
        end                 
    end
		 

endmodule

