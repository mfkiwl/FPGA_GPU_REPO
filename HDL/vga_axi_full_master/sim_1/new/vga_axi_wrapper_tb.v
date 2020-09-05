`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2020 21:46:56
// Design Name: 
// Module Name: vga_axi_wrapper_tb
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


module vga_axi_wrapper_tb #
(
	parameter integer BRAM_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_DATA_WIDTH = 32,
	parameter  C_M_TARGET_SLAVE_BASE_ADDR = 32'h00000000,
	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 32,
	parameter integer C_M_AXI_NUMBER_OF_BURST = 25,
	parameter integer C_BITS_WIDTH_FOR_NUMB_OF_BURST = 5,
    parameter PIXEL_WIDTH = 16,

    ///////////////////////////
    ///////////////////////////
    parameter integer C_M_AXI_ID_WIDTH	= 1,
    parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
    parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
    parameter integer C_M_AXI_WUSER_WIDTH	= 0,
    parameter integer C_M_AXI_RUSER_WIDTH	= 0,
    parameter integer C_M_AXI_BUSER_WIDTH	= 0
)
();
    reg axi_clk = 0;
    reg vga_clk = 0;
    reg reset = 1;
    reg finish_simulation = 0;
    
    wire [1:0] m_axi_arburst;
	wire [C_M_AXI_ADDR_WIDTH-1:0] m_axi_araddr;
	wire [7:0] m_axi_arlen;
	wire [2:0] m_axi_arsize;
    reg m_axi_arready = 0;
    wire m_axi_arvalid;
    
    reg [C_M_AXI_DATA_WIDTH-1:0] m_axi_rdata = 0;
	reg [1:0] m_axi_rresp = 0;
    reg m_axi_rlast = 0;
    wire m_axi_rready;
    reg m_axi_rvalid = 0;

    wire hsync;
    wire vsync;
    wire [4:0] red;
    wire [5:0] green;
    wire [4:0] blue;
	
	integer i;

    //axi_clk and simulation control
    initial begin
        #100;
        axi_clk = 0;
        #2;
        while (!finish_simulation)
            #2 axi_clk <= ~axi_clk;
    end

    //vga_clk and simulation control
    initial begin
        #100;
        vga_clk = 0;
        #4;
        while (!finish_simulation)
            #4 vga_clk <= ~vga_clk;
    end
    
    task drive_reset;
    begin
        @(posedge axi_clk);
        reset <= 0;
        repeat (10) @(posedge axi_clk);
        reset <= 1;
        @(posedge axi_clk);
    end
    endtask

    task read;
    begin
        @(posedge axi_clk);
        @(posedge axi_clk);
        @(posedge axi_clk);
        m_axi_arready <= 1'b1;
        @(posedge axi_clk);
        m_axi_arready <= 1'b0;
        @(posedge axi_clk);
        @(posedge axi_clk);
        @(posedge axi_clk);
        @(posedge axi_clk);
        @(posedge axi_clk);
        @(posedge axi_clk);
        for (i = 0; i < C_M_AXI_BURST_LEN-1; i = i+1)
        begin
            @(posedge axi_clk);
            begin
                m_axi_rdata = i;
                m_axi_rlast = 0;
                m_axi_rvalid = 1'b1;
            end
        end
        @(posedge axi_clk);
        begin
            m_axi_rdata = 2;
            m_axi_rlast = 1'b1;
            m_axi_rvalid = 1'b1;
        end
        @(posedge axi_clk);
        begin
            m_axi_rdata = 0;
            m_axi_rlast = 1'b0;
            m_axi_rvalid = 1'b0;
        end
        @(posedge axi_clk);
        @(posedge axi_clk);
        @(posedge axi_clk);
        
    end
    endtask

    vga_axi_wrapper #
    (
        .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH),
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
        // Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
        .C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
        .C_M_AXI_NUMBER_OF_BURST(C_M_AXI_NUMBER_OF_BURST),
        .C_BITS_WIDTH_FOR_NUMB_OF_BURST(C_BITS_WIDTH_FOR_NUMB_OF_BURST),
        .PIXEL_WIDTH(PIXEL_WIDTH),
    
        ///////////////////////////
        ///////////////////////////
        .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
    ) vga_axi_wrapper_inst
    (
        .vga_clk(vga_clk),
        .M_AXI_ACLK(axi_clk),
        .M_AXI_ARESETN(reset),
        //
        .M_AXI_ARBURST(m_axi_arburst),
        .M_AXI_ARADDR(m_axi_araddr),
        .M_AXI_ARLEN(m_axi_arlen),
        .M_AXI_ARSIZE(m_axi_arsize),
        .M_AXI_ARREADY(m_axi_arready),
        .M_AXI_ARVALID(m_axi_arvalid),
        //
        .M_AXI_RDATA(m_axi_rdata),
        .M_AXI_RRESP(m_axi_rresp),
        .M_AXI_RLAST(m_axi_rlast),
        .M_AXI_RREADY(m_axi_rready),
        .M_AXI_RVALID(m_axi_rvalid),
        //
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),

        ////////////////////////////
        ////////////////////////////
        .INIT_AXI_TXN(),
        .TXN_DONE(),
        .ERROR(),
        .M_AXI_AWID(),
        .M_AXI_AWADDR(),
        .M_AXI_AWLEN(),
        .M_AXI_AWSIZE(),
        .M_AXI_AWBURST(),
        .M_AXI_AWLOCK(),
        .M_AXI_AWCACHE(),
        .M_AXI_AWPROT(),
        .M_AXI_AWQOS(),
        .M_AXI_AWUSER(),
        .M_AXI_AWVALID(),
        .M_AXI_AWREADY(),
        .M_AXI_WDATA(),
        .M_AXI_WSTRB(),

        .M_AXI_WLAST(),
        .M_AXI_WUSER(),
        .M_AXI_WVALID(),
        .M_AXI_WREADY(),
        .M_AXI_BID(),

        .M_AXI_BRESP(),
        .M_AXI_BUSER(),
        .M_AXI_BVALID(),
        .M_AXI_BREADY(),

        .M_AXI_ARID(),
        .M_AXI_ARLOCK(),
        .M_AXI_ARCACHE(),
        .M_AXI_ARPROT(),
        .M_AXI_ARQOS(),
        .M_AXI_ARUSER(),

        .M_AXI_RID(),
        .M_AXI_RUSER()
    );

    initial begin
        drive_reset;
        repeat (C_M_AXI_NUMBER_OF_BURST)
        begin
            read;
        end
        repeat (C_M_AXI_NUMBER_OF_BURST)
        begin
            read;
        end
        repeat (C_M_AXI_NUMBER_OF_BURST)
        begin
            read;
        end
    end

endmodule
