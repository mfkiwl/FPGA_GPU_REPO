`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2020 20:59:11
// Design Name: 
// Module Name: vga_controller
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

module vga_controller #
(
    parameter integer BRAM_ADDR_WIDTH = 32,
    parameter PIXEL_WIDTH = 16
)
(
    //148.5Mhz - vga clock
    input wire vga_clk,
    input wire rst_n,

    input wire [PIXEL_WIDTH-1:0] data_in_1,
    output wire [BRAM_ADDR_WIDTH-1:0] raddr_1,
    output wire rden_1,

    input wire [PIXEL_WIDTH-1:0] data_in_2,
    output wire [BRAM_ADDR_WIDTH-1:0] raddr_2,
    output wire rden_2,
    
    output wire vga_ready,
    input wire axi_vga_ready,

    output wire hsync,
    output wire vsync,
    output wire [PIXEL_WIDTH-1:0] rgb_out
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
    localparam IDLE = 3'd0;
    localparam READ_AND_DISPLAY_BRAM_1 = 3'd1;
    localparam READ_AND_DISPLAY_BRAM_2 = 3'd2;

//    localparam HOR_TOTAL_TIME = 2200;
//    localparam HOR_BLANK_START = 1920;
//    localparam HOR_BLANK_TIME = 280;
//    localparam HOR_SYNC_START = 2008;
//    localparam HOR_SYNC_TIME = 44;
    
//    localparam VER_TOTAL_TIME = 1125;
//    localparam VER_BLANK_START = 1080;
//    localparam VER_BLANK_TIME = 45;
//    localparam VER_SYNC_START = 1084;
//    localparam VER_SYNC_TIME = 5;
    
//    localparam LEFT_BORDER = 0;
//    localparam RIGHT_BORDER = 1919;
//    localparam TOP_BORDER = 0;
//    localparam BOTTOM_BORDER = 1079;

    localparam HOR_TOTAL_TIME = 1056;
    localparam HOR_BLANK_START = 800;
    localparam HOR_BLANK_TIME = 256;
    localparam HOR_SYNC_START = 840;
    localparam HOR_SYNC_TIME = 128;
    
    localparam VER_TOTAL_TIME = 628;
    localparam VER_BLANK_START = 600;
    localparam VER_BLANK_TIME = 28;
    localparam VER_SYNC_START = 601;
    localparam VER_SYNC_TIME = 4;
    
    localparam LEFT_BORDER = 0;
    localparam RIGHT_BORDER = 799;
    localparam TOP_BORDER = 0;
    localparam BOTTOM_BORDER = 599;
    
    //VARIABLES////////////////////////////////////
	///////////////////////////////////////////////
    reg [BRAM_ADDR_WIDTH-1:0] raddr_1_reg; reg [BRAM_ADDR_WIDTH-1:0] next_raddr_1_reg;
    reg rden_1_reg; reg next_rden_1_reg;
    reg [BRAM_ADDR_WIDTH-1:0] raddr_2_reg; reg [BRAM_ADDR_WIDTH-1:0] next_raddr_2_reg;
    reg rden_2_reg; reg next_rden_2_reg;
    reg vga_ready_reg; reg next_vga_ready_reg;
    reg hblnk_reg; reg next_hblnk_reg;
    reg hsync_reg; reg next_hsync_reg;
    reg vblnk_reg; reg next_vblnk_reg;
    reg vsync_reg; reg next_vsync_reg;
    reg [PIXEL_WIDTH-1:0] rgb_reg; reg [PIXEL_WIDTH-1:0] next_rgb_reg;
    reg [2:0] state; reg [2:0] next_state;
    reg bram_flag; reg next_bram_flag;
    reg [11:0] hcount_reg; reg [11:0] next_hcount_reg;
    reg [11:0] vcount_reg; reg [11:0] next_vcount_reg;


    // I/O CCONNECTIONS ASSIGNEMENTS////////////////
	////////////////////////////////////////////////
    assign raddr_1 = raddr_1_reg;
    assign rden_1 = rden_1_reg;
    assign raddr_2 = raddr_2_reg;
    assign rden_2 = rden_2_reg;
    assign vga_ready = vga_ready_reg;
    assign hsync = hsync_reg;
    assign vsync = vsync_reg;
    assign rgb_out = rgb_reg;

    //MAIN CODE////////////////////////////////////
	///////////////////////////////////////////////
    always@(posedge vga_clk)
        if(!rst_n)
        begin
            state <= IDLE;
            bram_flag <= 1'b1;
            raddr_1_reg <= 0;
            rden_1_reg <= 1'b0;
            raddr_2_reg <= 0;
            rden_2_reg <= 1'b0;
            vga_ready_reg <= 1'b1;
            hblnk_reg <= 1'b0;
            hsync_reg <= 1'b0;
            vblnk_reg <= 1'b0;
            vsync_reg <= 1'b0;
            rgb_reg <= 0;
            hcount_reg <= 0;
            vcount_reg <= 0;
        end else
        begin
            state <= next_state;
            bram_flag <= next_bram_flag;
            raddr_1_reg <= next_raddr_1_reg;
            rden_1_reg <= next_rden_1_reg;
            raddr_2_reg <= next_raddr_2_reg;
            rden_2_reg <= next_rden_2_reg;
            vga_ready_reg <= next_vga_ready_reg;
            hblnk_reg <= next_hblnk_reg;
            hsync_reg <= next_hsync_reg;
            vblnk_reg <= next_vblnk_reg;
            vsync_reg <= next_vsync_reg;
            rgb_reg <= next_rgb_reg;
            hcount_reg <= next_hcount_reg;
            vcount_reg <= next_vcount_reg;
        end

    always@*
        case(state)
            default: begin
                next_state = IDLE;
                next_bram_flag = 1'b1;
                next_raddr_1_reg = 0;
                next_rden_1_reg = 1'b1;
                next_raddr_2_reg = 0;
                next_rden_2_reg = 1'b1;
                next_vga_ready_reg = 1'b1;
                next_hblnk_reg = 1'b0;
                next_hsync_reg = 1'b0;
                next_vblnk_reg = 1'b0;
                next_vsync_reg = 1'b0;
                next_rgb_reg = 0;
                next_hcount_reg = 0;
                next_vcount_reg = 0;
            end
            IDLE: begin
                next_state = (bram_flag) ? READ_AND_DISPLAY_BRAM_2 : READ_AND_DISPLAY_BRAM_1;
                next_bram_flag = bram_flag;
                next_raddr_1_reg = 0;
                next_rden_1_reg = (!bram_flag) ? 1'b1 : 1'b0;
                next_raddr_2_reg = 0;
                next_rden_2_reg = (bram_flag) ? 1'b1 : 1'b0;
                next_vga_ready_reg = vga_ready_reg;
                next_hblnk_reg = 1'b0; /////UWAGA tutaj
                next_hsync_reg = 1'b0;
                next_vblnk_reg = ((vcount_reg >= VER_BLANK_START) && (vcount_reg < (VER_BLANK_START + VER_BLANK_TIME))) ? 1 : 0;
                next_vsync_reg = ((vcount_reg >= VER_SYNC_START) && (vcount_reg < (VER_SYNC_START + VER_SYNC_TIME))) ? 1 : 0;
                next_rgb_reg = (bram_flag) ? data_in_2[PIXEL_WIDTH-1:0] : data_in_1[PIXEL_WIDTH-1:0]; 
                next_hcount_reg = 0;
                next_vcount_reg = vcount_reg;
            end
            READ_AND_DISPLAY_BRAM_1: begin
                next_state = (hcount_reg != HOR_TOTAL_TIME-1) ? READ_AND_DISPLAY_BRAM_1 : IDLE;
                next_bram_flag = (hcount_reg != HOR_TOTAL_TIME-1) ? bram_flag : !bram_flag;
                next_raddr_1_reg = (raddr_1_reg != HOR_BLANK_START) ? raddr_1_reg + 1 : raddr_1_reg;
                next_rden_1_reg = (raddr_1_reg != HOR_BLANK_START) ? 1'b1 : 1'b0;
                next_raddr_2_reg = 0;
                next_rden_2_reg = 1'b0;
                next_vga_ready_reg = (hcount_reg == HOR_TOTAL_TIME-1) ? 1'b1 : 1'b0;
                next_hblnk_reg = ((hcount_reg >= HOR_BLANK_START) && (hcount_reg < (HOR_BLANK_START + HOR_BLANK_TIME-1))) ? 1 : 0;
                next_hsync_reg = ((hcount_reg >= HOR_SYNC_START) && (hcount_reg < (HOR_SYNC_START + HOR_SYNC_TIME))) ? 1 : 0;  
                next_vblnk_reg = ((vcount_reg >= VER_BLANK_START) && (vcount_reg < (VER_BLANK_START + VER_BLANK_TIME))) ? 1 : 0;
                next_vsync_reg = ((vcount_reg >= VER_SYNC_START) && (vcount_reg < (VER_SYNC_START + VER_SYNC_TIME))) ? 1 : 0;
                next_rgb_reg = data_in_1[PIXEL_WIDTH-1:0]; 
                next_hcount_reg = (hcount_reg != HOR_TOTAL_TIME-1) ? hcount_reg + 1 : 0;
                next_vcount_reg = (hcount_reg != HOR_BLANK_START) ? vcount_reg : ((vcount_reg != VER_TOTAL_TIME) ? vcount_reg + 1 : 0);
            end
            READ_AND_DISPLAY_BRAM_2: begin
                next_state = (hcount_reg != HOR_TOTAL_TIME-1) ? READ_AND_DISPLAY_BRAM_2 : IDLE;
                next_bram_flag = (hcount_reg != HOR_TOTAL_TIME-1) ? bram_flag : !bram_flag;
                next_raddr_1_reg = 0;
                next_rden_1_reg = 1'b0;
                next_raddr_2_reg = (raddr_2_reg != HOR_BLANK_START) ? raddr_2_reg + 1 : raddr_2_reg;
                next_rden_2_reg = (raddr_2_reg != HOR_BLANK_START) ? 1'b1 : 1'b0;
                next_vga_ready_reg = (hcount_reg == HOR_TOTAL_TIME-1) ? 1'b1 : 1'b0;
                next_hblnk_reg = ((hcount_reg >= HOR_BLANK_START) && (hcount_reg < (HOR_BLANK_START + HOR_BLANK_TIME-1))) ? 1 : 0;
                next_hsync_reg = ((hcount_reg >= HOR_SYNC_START) && (hcount_reg < (HOR_SYNC_START + HOR_SYNC_TIME))) ? 1 : 0;  
                next_vblnk_reg = ((vcount_reg >= VER_BLANK_START) && (vcount_reg < (VER_BLANK_START + VER_BLANK_TIME))) ? 1 : 0;
                next_vsync_reg = ((vcount_reg >= VER_SYNC_START) && (vcount_reg < (VER_SYNC_START + VER_SYNC_TIME))) ? 1 : 0;
                next_rgb_reg = data_in_2[PIXEL_WIDTH-1:0];
                next_hcount_reg = (hcount_reg != HOR_TOTAL_TIME-1) ? hcount_reg + 1 : 0;
                next_vcount_reg = (hcount_reg != HOR_BLANK_START) ? vcount_reg : ((vcount_reg != VER_TOTAL_TIME) ? vcount_reg + 1 : 0);
            end
        endcase

endmodule
