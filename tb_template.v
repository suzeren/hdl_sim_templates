module tb_template ();    
    parameter integer C_S00_AXI_DATA_WIDTH	= 32;
	parameter integer C_S00_AXI_ADDR_WIDTH	= 4;
	
	    
    localparam real S_AXI_CLK_FREQ_HZ = 100_000_000; 
    localparam real S_AXI_CLK_PERIOD_NS = 1000000000 / S_AXI_CLK_FREQ_HZ;
	
	
	reg axi_lite_aclk;
    reg axi_lite_aresetn;
	
    initial begin
        axi_lite_aclk = 1'b0;
        #(S_AXI_CLK_PERIOD_NS/2);
        forever
           #(S_AXI_CLK_PERIOD_NS/2) axi_lite_aclk = ~axi_lite_aclk;
     end  


    initial begin
        #0;axi_lite_aresetn = 0;
        #400; axi_lite_aresetn = 1;
    end  	 
	
	
	 
	
	
	reg [C_S00_AXI_ADDR_WIDTH-1 : 0] axi_lite_araddr = 0;
    wire axi_lite_arready;
    reg axi_lite_arvalid = 0;
    reg [C_S00_AXI_ADDR_WIDTH-1 : 0] axi_lite_awaddr = 0;
    wire axi_lite_awready;
    reg axi_lite_awvalid = 0;
    reg axi_lite_bready = 0;
    wire [1:0]axi_lite_bresp;
    wire axi_lite_bvalid;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0]axi_lite_rdata;
    reg axi_lite_rready = 0;
    wire [1:0]axi_lite_rresp;
    wire axi_lite_rvalid;
    reg [C_S00_AXI_DATA_WIDTH-1 : 0] axi_lite_wdata = 0;
    wire axi_lite_wready;
    reg [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] axi_lite_wstrb = 4'hf;
    reg axi_lite_wvalid = 0;


	// axi template
   initial begin
        #100; axi_write(8'h10, 32'h01);
        #100; axi_write(8'h00, 32'h0);
    end  
	 

	//

	//place dut here
	
	
	//
	
	
	//place VIP here
	
	
	//
	
	
	
	task automatic axi_write;
        input [31 : 0] addr;
        input [31 : 0] data;
        begin
          axi_lite_wdata = data;
          axi_lite_awaddr = addr;
          axi_lite_awvalid = 1;
          axi_lite_wvalid = 1;
          
          wait(axi_lite_awready && axi_lite_wready);
      
          @(posedge axi_lite_aclk) #1;
          axi_lite_awvalid = 0;
          axi_lite_wvalid = 0;
          
          wait(axi_lite_bvalid);
          axi_lite_bready = 1;
          @(posedge axi_lite_aclk) #1;
          axi_lite_bready = 0;
        end
      endtask
	  
	  
      
      task automatic axi_read;
        input [31 : 0] addr;
        input [31 : 0] expected_data;
        begin
          axi_lite_araddr = addr;
          axi_lite_arvalid = 1;
          axi_lite_rready = 1;
          wait(axi_lite_arready);
          wait(axi_lite_rvalid);
      
          if (axi_lite_rdata != expected_data) begin
            $display("Error: Mismatch in AXI4 read at %x: ", addr,
              "expected %x, received %x",
              expected_data, axi_lite_rdata);
          end
      
          @(posedge axi_lite_aclk) #1;
          axi_lite_arvalid = 0;
          axi_lite_rready = 0;
        end
      endtask 
	  
endmodule	  