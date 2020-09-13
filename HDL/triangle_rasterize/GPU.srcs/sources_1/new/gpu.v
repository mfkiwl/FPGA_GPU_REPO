`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2020 19:51:04
// Design Name: 
// Module Name: gpu
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


module gpu #
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
	output wire  ERROR,

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
	
	wire [15:0] out_x;
	wire [15:0] out_y;
    wire ack_out;
	wire ack_in;
	wire [7:0] R_out;
	wire [7:0] G_out;
	wire [7:0] B_out;

    wire pp_req;
    
    wire [15:0]upper_x;
    wire [15:0]upper_y;
    wire [15:0]upper_z;
    wire [15:0]mid_x;
    wire [15:0]mid_y;
    wire [15:0]mid_z;
    wire [15:0]lower_x;
    wire [15:0]lower_y; 
    wire [15:0]lower_z;
    
    wire [7:0]grad_in;
    wire [23:0]base_color;

	gpu_axi #
    (
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),

        .C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
        .C_M_AXI_NUMBER_OF_BURST(C_M_AXI_NUMBER_OF_BURST),
        .C_BITS_WIDTH_FOR_NUMB_OF_BURST(C_BITS_WIDTH_FOR_NUMB_OF_BURST),

        .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
    ) gpu_axi_inst
    (

        .out_x(out_x),
        .out_y(out_y),
        .ack_out(ack_out),
        .ack_in(ack_in),
        .R_out(R_out),
        .G_out(G_out),
        .B_out(B_out),
        .M_AXI_ACLK(M_AXI_ACLK),
        .M_AXI_ARESETN(M_AXI_ARESETN),

        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWLEN(M_AXI_AWLEN),
        .M_AXI_AWSIZE(M_AXI_AWSIZE), 
        .M_AXI_AWBURST(M_AXI_AWBURST),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),

        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        .M_AXI_WLAST(M_AXI_WLAST),
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY),

        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(M_AXI_BREADY), 

        .INIT_AXI_TXN(INIT_AXI_TXN),
        .ERROR(ERROR),
        .TXN_DONE(TXN_DONE),
        .M_AXI_AWID(M_AXI_AWID),
        .M_AXI_AWLOCK(M_AXI_AWLOCK),
        .M_AXI_AWCACHE(M_AXI_AWCACHE),
        .M_AXI_AWPROT(M_AXI_AWPROT),
        .M_AXI_AWQOS(M_AXI_AWQOS),
        .M_AXI_AWUSER(M_AXI_AWUSER),
        .M_AXI_WUSER(M_AXI_WUSER),

        .M_AXI_BID(M_AXI_BID),
        .M_AXI_BUSER(M_AXI_BUSER),

        .M_AXI_ARID(M_AXI_ARID),
        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARLEN(M_AXI_ARLEN),
        .M_AXI_ARSIZE(M_AXI_ARSIZE),
        .M_AXI_ARBURST(M_AXI_ARBURST),
        .M_AXI_ARLOCK(M_AXI_ARLOCK),
        .M_AXI_ARCACHE(M_AXI_ARCACHE),
        .M_AXI_ARPROT(M_AXI_ARPROT),
        .M_AXI_ARQOS(M_AXI_ARQOS),
        .M_AXI_ARUSER(M_AXI_ARUSER),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),

        .M_AXI_RID(M_AXI_RID),
        .M_AXI_RDATA(M_AXI_RDATA),
        .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RLAST(M_AXI_RLAST),
        .M_AXI_RUSER(M_AXI_RUSER),
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY)
	);

    basic_cell basic_cell_inst(
        .clk(M_AXI_ACLK),
        .rst(!M_AXI_ARESETN),
        .pp_req(pp_req),
        .upper_x(upper_x),
        .upper_y(upper_y),
        .upper_z(upper_z),
        .mid_x(mid_x),
        .mid_y(mid_y),
        .mid_z(mid_z),
        .lower_x(lower_x),
        .lower_y(lower_y), 
        .lower_z(lower_z),
    
        .grad_in(grad_in),
        .base_color(base_color),
        
        .out_x(out_x),
        .out_y(out_y),    
        .ack_out(ack_out),
               
        .R_out(R_out),
        .G_out(G_out),
        .B_out(B_out), 
        .ack_in(ack_in)
    );

    gpu_initial gpu_initial_inst(
        .pp_req(pp_req),
        
        .upper_x(upper_x),
        .upper_y(upper_y),
        .upper_z(upper_z),
        .mid_x(mid_x),
        .mid_y(mid_y),
        .mid_z(mid_z),
        .lower_x(lower_x),
        .lower_y(lower_y), 
        .lower_z(lower_z),
        
        .grad_in(grad_in),
        .base_color(base_color)
    );
	
	
	
endmodule
