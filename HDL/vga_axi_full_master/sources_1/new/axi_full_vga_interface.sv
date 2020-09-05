`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2020 00:41:30
// Design Name: 
// Module Name: axi_full_vga_interface
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


module axi_full_vga_interface #
(
	parameter integer BRAM_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_DATA_WIDTH = 32,
	parameter  C_M_TARGET_SLAVE_BASE_ADDR = 32'h00000000,
	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 32,
	parameter integer C_M_AXI_NUMBER_OF_BURST = 25,
	parameter integer C_BITS_WIDTH_FOR_NUMB_OF_BURST = 5,
	parameter PIXEL_WIDTH = 16
)
(
	input wire  M_AXI_ACLK,
	input wire  M_AXI_ARESETN,
	//
	input wire  VGA_READY,
	output wire AXI_VGA_READY,
	//
    output wire [1:0] M_AXI_ARBURST,
	output wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,
	output wire [7:0] M_AXI_ARLEN,
	output wire [2:0] M_AXI_ARSIZE,
	input wire  M_AXI_ARREADY,
	output wire  M_AXI_ARVALID,
    //
	input wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_RDATA,
	input wire [1:0] M_AXI_RRESP,
	input wire  M_AXI_RLAST,
	output wire  M_AXI_RREADY,
	input wire  M_AXI_RVALID,
	//
	output wire [PIXEL_WIDTH-1:0] DATA_OUT_1,
	output wire WE_1,
	output wire [BRAM_ADDR_WIDTH-1:0] BRAM_WRADDR_1,
	output wire [PIXEL_WIDTH-1:0] DATA_OUT_2,
	output wire WE_2,
	output wire [BRAM_ADDR_WIDTH-1:0] BRAM_WRADDR_2
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

	localparam IDLE = 3'd0;
	localparam SEND_RADDR = 3'd1;
	localparam UPDATE_BURST_COUNTER = 3'd2;
	localparam READ_AND_SEND_TO_BRAM_1 = 3'd3;
	localparam WAIT_FOR_READ_1 = 3'd4;
	localparam READ_AND_SEND_TO_BRAM_2 = 3'd5;
	localparam WAIT_FOR_READ_2 = 3'd6;

	//VARIABLES////////////////////////////////////
	///////////////////////////////////////////////
    reg axi_vga_ready_reg; reg next_axi_vga_ready_reg;
	reg [C_M_AXI_ADDR_WIDTH-1:0] araddr_reg; reg [C_M_AXI_ADDR_WIDTH-1:0] next_araddr_reg;
	reg arvalid_reg; reg next_arvalid_reg;
	reg rready_reg; reg next_rready_reg;
	reg [PIXEL_WIDTH-1:0] data_buff_1_reg; reg [PIXEL_WIDTH-1:0] next_data_buff_1_reg;
	reg we_1_reg; reg next_we_1_reg;
	reg [BRAM_ADDR_WIDTH-1:0] bram_wraddr_1_reg; reg [BRAM_ADDR_WIDTH-1:0] next_bram_wraddr_1_reg;
	reg [PIXEL_WIDTH-1:0] data_buff_2_reg; reg [PIXEL_WIDTH-1:0] next_data_buff_2_reg;
	reg we_2_reg; reg next_we_2_reg;
	reg [BRAM_ADDR_WIDTH-1:0] bram_wraddr_2_reg; reg [BRAM_ADDR_WIDTH-1:0] next_bram_wraddr_2_reg;
	//Burst size in bytes
	wire [C_TRANSACTIONS_NUM+2:0] burst_size_bytes;
	reg [C_BITS_WIDTH_FOR_NUMB_OF_BURST-1:0] burst_counter; reg [C_BITS_WIDTH_FOR_NUMB_OF_BURST-1:0] next_burst_counter;
	reg [2:0] state; reg [2:0] next_state;
	reg bram_flag; reg next_bram_flag;
	//wires


	// I/O CCONNECTIONS ASSIGNEMENTS////////////////
	////////////////////////////////////////////////
	assign AXI_VGA_READY = axi_vga_ready_reg;
	assign M_AXI_ARBURST = 2'b01;
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + araddr_reg;
	assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign M_AXI_ARVALID = arvalid_reg;
	assign M_AXI_RREADY	= rready_reg;
	assign burst_size_bytes	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
	assign DATA_OUT_1 = data_buff_1_reg;
	assign WE_1 = we_1_reg;
	assign BRAM_WRADDR_1 = bram_wraddr_1_reg;
	assign DATA_OUT_2 = data_buff_2_reg;
	assign WE_2 = we_2_reg;
	assign BRAM_WRADDR_2 = bram_wraddr_2_reg;

	//MAIN CODE////////////////////////////////////
	///////////////////////////////////////////////
	always@(posedge M_AXI_ACLK)                                                             	                                                                     
		if (M_AXI_ARESETN == 0)                                         
		begin                                                          
			state <= IDLE; 
			axi_vga_ready_reg <= 1'b0;
			araddr_reg <= 0;
			arvalid_reg <= 1'b0;
			rready_reg <= 1'b0;
			data_buff_1_reg <= 0;
			we_1_reg <= 1'b0;
			bram_wraddr_1_reg <= {BRAM_ADDR_WIDTH{1'b1}};
			data_buff_2_reg <= 0;
			we_2_reg <= 1'b0;
			bram_wraddr_2_reg <= {BRAM_ADDR_WIDTH{1'b1}};
			burst_counter <= 0;
			bram_flag <= 1'b0;                                     
		end else                
		begin                                                          
			state <= next_state;
			axi_vga_ready_reg <= next_axi_vga_ready_reg;
			araddr_reg <= next_araddr_reg;
			arvalid_reg <= next_arvalid_reg;
			rready_reg <= next_rready_reg;
			data_buff_1_reg <= next_data_buff_1_reg;
			we_1_reg <= next_we_1_reg;
			bram_wraddr_1_reg <= next_bram_wraddr_1_reg;
			data_buff_2_reg <= next_data_buff_2_reg;
			we_2_reg <= next_we_2_reg;
			bram_wraddr_2_reg <= next_bram_wraddr_2_reg;
			burst_counter <= next_burst_counter;
			bram_flag <= next_bram_flag;                              
		end


	always@*
		case(state)
			default: begin
				next_state = IDLE;
				next_axi_vga_ready_reg = 1'b0;
				next_araddr_reg = 0;
				next_arvalid_reg = 1'b0;
				next_rready_reg = 1'b0;
				next_data_buff_1_reg = 0;
				next_we_1_reg = 1'b0;
				next_bram_wraddr_1_reg = {BRAM_ADDR_WIDTH{1'b1}};
				next_data_buff_2_reg = 0;
				next_we_2_reg = 1'b0;
				next_bram_wraddr_2_reg = {BRAM_ADDR_WIDTH{1'b1}};
				next_burst_counter = 0;
				next_bram_flag = 1'b0;
			end
			IDLE: begin
				next_state = (VGA_READY) ? SEND_RADDR : IDLE;
				next_axi_vga_ready_reg = 1'b0;
				next_araddr_reg = 0;
				next_arvalid_reg = 1'b0;
				next_rready_reg = 1'b0;
				next_data_buff_1_reg = 0;
				next_we_1_reg = 1'b0;
				next_bram_wraddr_1_reg = {BRAM_ADDR_WIDTH{1'b1}};
				next_data_buff_2_reg = 0;
				next_we_2_reg = 1'b0;
				next_bram_wraddr_2_reg = {BRAM_ADDR_WIDTH{1'b1}};
				next_burst_counter = 0;
				next_bram_flag = bram_flag;
			end
			SEND_RADDR: begin
				next_state = (M_AXI_ARREADY) ? UPDATE_BURST_COUNTER : SEND_RADDR;
				next_axi_vga_ready_reg = 1'b0;
				next_araddr_reg = araddr_reg;
				next_arvalid_reg = 1'b1;
				next_rready_reg = 1'b0;
				next_data_buff_1_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_1_reg = 1'b0;
				next_bram_wraddr_1_reg = bram_wraddr_1_reg;
				next_data_buff_2_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_2_reg = 1'b0;
				next_bram_wraddr_2_reg = bram_wraddr_2_reg;
				next_burst_counter = burst_counter;
				next_bram_flag = bram_flag;
			end
			UPDATE_BURST_COUNTER: begin
				next_state = (bram_flag) ? READ_AND_SEND_TO_BRAM_2 : READ_AND_SEND_TO_BRAM_1;
				next_axi_vga_ready_reg = 1'b0;
				next_araddr_reg = araddr_reg + burst_size_bytes;
				next_arvalid_reg = 1'b0;
				next_rready_reg = 1'b0;
				next_data_buff_1_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_1_reg = (M_AXI_RVALID && (!bram_flag)) ? 1'b1 : 1'b0;
				next_bram_wraddr_1_reg = (!bram_flag) ? bram_wraddr_1_reg : 0;
				next_data_buff_2_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_2_reg = (M_AXI_RVALID && bram_flag) ? 1'b1 : 1'b0;
				next_bram_wraddr_2_reg = (bram_flag) ? bram_wraddr_2_reg : 0;
				next_burst_counter = (burst_counter == C_M_AXI_NUMBER_OF_BURST) ? 0 : burst_counter + 1;
				next_bram_flag = bram_flag;			
			end
			READ_AND_SEND_TO_BRAM_1: begin
				next_state = (M_AXI_RVALID) ? ((M_AXI_RLAST) ? ((burst_counter == C_M_AXI_NUMBER_OF_BURST) ? IDLE : SEND_RADDR) : READ_AND_SEND_TO_BRAM_1) : WAIT_FOR_READ_1;
				next_axi_vga_ready_reg = ((burst_counter == C_M_AXI_NUMBER_OF_BURST)&&M_AXI_RLAST) ? 1'b1 : 1'b0;
				next_araddr_reg = araddr_reg;
				next_arvalid_reg = 1'b0;
				next_rready_reg = 1'b1;
				next_data_buff_1_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_1_reg = (M_AXI_RVALID) ? 1'b1 : 1'b0;
				next_bram_wraddr_1_reg = (M_AXI_RVALID) ? bram_wraddr_1_reg + 1 : bram_wraddr_1_reg;
			    next_data_buff_2_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_2_reg = 1'b0;
				next_bram_wraddr_2_reg = bram_wraddr_2_reg;
				next_burst_counter = burst_counter;
				next_bram_flag = ((burst_counter == C_M_AXI_NUMBER_OF_BURST)&&M_AXI_RLAST) ? !bram_flag : bram_flag;			
			end
			WAIT_FOR_READ_1: begin
				next_state = (M_AXI_RVALID) ? READ_AND_SEND_TO_BRAM_1 : WAIT_FOR_READ_1;
				next_axi_vga_ready_reg = 1'b0;
				next_araddr_reg = araddr_reg;
				next_arvalid_reg = 1'b0;
				next_rready_reg = 1'b1;
                next_data_buff_1_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_1_reg = (M_AXI_RVALID) ? 1'b1 : 1'b0;
				next_bram_wraddr_1_reg = (M_AXI_RVALID) ? bram_wraddr_1_reg + 1 : bram_wraddr_1_reg;
				next_data_buff_2_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_2_reg = 1'b0;
				next_bram_wraddr_2_reg = bram_wraddr_2_reg;
				next_burst_counter = burst_counter;
				next_bram_flag = bram_flag;			
			end
			READ_AND_SEND_TO_BRAM_2: begin
				next_state = (M_AXI_RVALID) ? ((M_AXI_RLAST) ? ((burst_counter == C_M_AXI_NUMBER_OF_BURST) ? IDLE : SEND_RADDR) : READ_AND_SEND_TO_BRAM_2) : WAIT_FOR_READ_2;
				next_axi_vga_ready_reg = ((burst_counter == C_M_AXI_NUMBER_OF_BURST)&&M_AXI_RLAST) ? 1'b1 : 1'b0;
				next_araddr_reg = araddr_reg;
				next_arvalid_reg = 1'b0;
				next_rready_reg = 1'b1;
                next_data_buff_1_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_1_reg = 1'b0;
				next_bram_wraddr_1_reg = bram_wraddr_1_reg;
                next_data_buff_2_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_2_reg = (M_AXI_RVALID) ? 1'b1 : 1'b0;
				next_bram_wraddr_2_reg = (M_AXI_RVALID) ? bram_wraddr_2_reg + 1 : bram_wraddr_2_reg;
				next_burst_counter = burst_counter;
				next_bram_flag = ((burst_counter == C_M_AXI_NUMBER_OF_BURST)&&M_AXI_RLAST) ? !bram_flag : bram_flag;			
			end
			WAIT_FOR_READ_2: begin
				next_state = (M_AXI_RVALID) ? READ_AND_SEND_TO_BRAM_2 : WAIT_FOR_READ_2;
				next_axi_vga_ready_reg = 1'b0;
				next_araddr_reg = araddr_reg;
				next_arvalid_reg = 1'b0;
				next_rready_reg = 1'b1;
				next_data_buff_1_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_1_reg = 1'b0;
				next_bram_wraddr_1_reg = bram_wraddr_1_reg;
                next_data_buff_2_reg = M_AXI_RDATA[PIXEL_WIDTH-1:0];
				next_we_2_reg = (M_AXI_RVALID) ? 1'b1 : 1'b0;
				next_bram_wraddr_2_reg = (M_AXI_RVALID) ? bram_wraddr_2_reg + 1 : bram_wraddr_2_reg;
				next_burst_counter = burst_counter;
				next_bram_flag = bram_flag;			
			end
		endcase                                                                                           

endmodule
