`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2020 18:38:25
// Design Name: 
// Module Name: gpu_axi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gpu_axi #
(
	parameter integer C_M_AXI_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_DATA_WIDTH = 32,
	parameter  C_M_TARGET_SLAVE_BASE_ADDR = 32'h00100000,
	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 32,
	parameter integer C_M_AXI_NUMBER_OF_BURST = 25,
	parameter integer C_BITS_WIDTH_FOR_NUMB_OF_BURST = 5,

    parameter integer C_M_AXI_ID_WIDTH	= 1,
    parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
    parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
    parameter integer C_M_AXI_WUSER_WIDTH	= 0,
    parameter integer C_M_AXI_RUSER_WIDTH	= 0,
    parameter integer C_M_AXI_BUSER_WIDTH	= 0
)
(
	input wire [15:0] out_x,
	input wire [15:0] out_y,
    input wire ack_out,
	input wire ack_in,
	input wire [7:0] R_out,
	input wire [7:0] G_out,
	input wire [7:0] B_out,

    input wire  M_AXI_ACLK,
	input wire  M_AXI_ARESETN,

	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
	output wire [7 : 0] M_AXI_AWLEN,
	output wire [2 : 0] M_AXI_AWSIZE, 
	output wire [1 : 0] M_AXI_AWBURST,
	output wire  M_AXI_AWVALID,
    input wire  M_AXI_AWREADY,

    output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
    output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
    output wire  M_AXI_WLAST,
    output wire  M_AXI_WVALID,
    input wire  M_AXI_WREADY,

    input wire [1 : 0] M_AXI_BRESP,
    input wire  M_AXI_BVALID,
    output wire  M_AXI_BREADY, 

///////////////////////////////////////
	input wire  INIT_AXI_TXN,
	output wire  TXN_DONE,
	output reg  ERROR,

	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
	output wire  M_AXI_AWLOCK,
	output wire [3 : 0] M_AXI_AWCACHE,
	output wire [2 : 0] M_AXI_AWPROT,
	output wire [3 : 0] M_AXI_AWQOS,
	output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
	output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,

	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
	input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,

	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
	output wire [7 : 0] M_AXI_ARLEN,
	output wire [2 : 0] M_AXI_ARSIZE,
	output wire [1 : 0] M_AXI_ARBURST,
	output wire  M_AXI_ARLOCK,
	output wire [3 : 0] M_AXI_ARCACHE,
	output wire [2 : 0] M_AXI_ARPROT,
	output wire [3 : 0] M_AXI_ARQOS,
	output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
	output wire  M_AXI_ARVALID,
	input wire  M_AXI_ARREADY,

	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
	input wire [1 : 0] M_AXI_RRESP,
	input wire  M_AXI_RLAST,
	input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
	input wire  M_AXI_RVALID,
	output wire  M_AXI_RREADY
	);

	//FUNCTIONS//////////////////////////////////////
	/////////////////////////////////////////////////
	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2                
	function integer clogb2 (input integer bit_depth);              
	begin                                                           
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
			bit_depth = bit_depth >> 1;                                 
	end                                                           
	endfunction

	//LOCALPARAMS///////////////////////////////////
	////////////////////////////////////////////////
	localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);
	localparam HOR_BLANK_START = 1920;

	//VARIABLES////////////////////////////////////
	///////////////////////////////////////////////
	wire [C_TRANSACTIONS_NUM+2:0] burst_size_bytes;
	reg [C_M_AXI_ADDR_WIDTH-1:0] write_addr_reg; wire [C_M_AXI_ADDR_WIDTH-1:0] next_write_addr_reg;
	reg valid_reg; wire next_valid_reg;
	reg [C_M_AXI_DATA_WIDTH-1:0] data_reg; wire [C_M_AXI_DATA_WIDTH-1:0] next_data_reg;
	
	// I/O CCONNECTIONS ASSIGNEMENTS////////////////
	////////////////////////////////////////////////
	assign M_AXI_AWBURST = 2'b01;
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign burst_size_bytes	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
	assign M_AXI_AWADDR = write_addr_reg;
	assign M_AXI_AWVALID = valid_reg;
	assign M_AXI_WDATA = data_reg;
	assign M_AXI_WSTRB = {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST = 1'b0;
	assign M_AXI_WVALID = valid_reg;
	assign M_AXI_BREADY = 1'b1;

	assign TXN_DONE = 1'b0;
	assign M_AXI_AWID	= 'b0;
	assign M_AXI_AWLOCK	= 1'b0;
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;

	assign M_AXI_WUSER	= 'b0;

	assign M_AXI_ARID	= 'b0;
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR;
	assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	assign M_AXI_ARCACHE	= 4'b0010;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARUSER	= 'b1;
	assign M_AXI_ARVALID	= 0;
	assign M_AXI_RREADY	= 0;
	
	//MAIN CODE////////////////////////////////////
	///////////////////////////////////////////////
	always@(posedge M_AXI_ACLK)
	begin
	   ERROR <= 0;
	end

	always@(posedge M_AXI_ACLK)                                                             	                                                                     
		if (M_AXI_ARESETN == 0)                                         
		begin                                                          
			write_addr_reg <=  C_M_TARGET_SLAVE_BASE_ADDR;
			valid_reg <= 1'b0;
			data_reg <= 0;                                   
		end else                
        begin                                                          
			write_addr_reg <= next_write_addr_reg;
			valid_reg <= next_valid_reg;
			data_reg <= next_data_reg;                            
		end

	assign next_write_addr_reg = (out_y<<<9)+(out_y<<<8)+(out_y<<<5)+out_x;
	assign next_valid_reg = ack_out;
	assign next_data_reg = {16'd0 ,R_out[7:3], G_out[7:2], B_out[7:3]};
        
endmodule
