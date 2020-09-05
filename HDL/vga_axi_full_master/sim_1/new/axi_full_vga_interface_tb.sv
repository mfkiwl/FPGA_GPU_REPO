`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2020 02:35:13
// Design Name: 
// Module Name: axi_full_vga_interface_tb
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

module axi_full_vga_interface_tb #
(
	parameter integer BRAM_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_DATA_WIDTH = 32,
	parameter  C_M_TARGET_SLAVE_BASE_ADDR = 32'h00000000,
	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 32,
	parameter integer C_M_AXI_NUMBER_OF_BURST = 25,
	parameter integer C_BITS_WIDTH_FOR_NUMB_OF_BURST = 5
)
();

    reg clock = 0; 
    reg reset = 1;
    reg finish_simulation = 0;
    
    reg vga_ready = 0;
    wire axi_vga_ready;
    
    wire [1 : 0] m_axi_arburst;
	wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr;
	wire [7 : 0] m_axi_arlen;
	wire [2 : 0] m_axi_arsize;
    reg m_axi_arready = 0;
    wire m_axi_arvalid;
    
    reg [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata = 0;
	reg [1 : 0] m_axi_rresp = 0;
    reg m_axi_rlast = 0;
    wire m_axi_rready;
    reg m_axi_rvalid = 0;
    wire [C_M_AXI_DATA_WIDTH-1:0] data_out_1;
    wire we_1;
	wire [BRAM_ADDR_WIDTH-1:0] bram_wraddr_1;
    wire [C_M_AXI_DATA_WIDTH-1:0] data_out_2;
	wire we_2;
	wire [BRAM_ADDR_WIDTH-1:0] bram_wraddr_2;
	
	integer i;
    
    
    // 245.76 Mhz clock and simulation control
    initial begin
        #100;
        clock = 0;
        #2.0345;
        while (!finish_simulation)
            #2.0345 clock <= ~clock;
    end
    
    task drive_reset;
    begin
        @(posedge clock);
        reset <= 0;
        repeat (10) @(posedge clock);
        reset <= 1;
        @(posedge clock);
    end
    endtask 
    
    task initiate_read;
    begin
        @(posedge clock);
        vga_ready = 1'b1;
        @(posedge clock);
        vga_ready = 1'b0;
        @(posedge clock);
    end
    endtask
    
    task read;
    begin
        @(posedge clock);
        m_axi_arready <= 1'b1;
        @(posedge clock);
        m_axi_arready <= 1'b0;
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        for (i = 0; i < C_M_AXI_BURST_LEN-1; i = i+1)
        begin
            @(posedge clock);
            begin
                m_axi_rdata = i;
                m_axi_rlast = 0;
                m_axi_rvalid = 1'b1;
            end
        end
        @(posedge clock);
        begin
            m_axi_rdata = 2;
            m_axi_rlast = 1'b1;
            m_axi_rvalid = 1'b1;
        end
        @(posedge clock);
        begin
            m_axi_rdata = 0;
            m_axi_rlast = 1'b0;
            m_axi_rvalid = 1'b0;
        end
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        
    end
    endtask
    
    axi_full_vga_interface axi_full_vga_interface_inst
(
    .M_AXI_ACLK(clock),
    .M_AXI_ARESETN(reset),
	//
    .VGA_READY(vga_ready),
    .AXI_VGA_READY(axi_vga_ready),
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
	.DATA_OUT_1(data_out_1),
	.WE_1(we_1),
	.BRAM_WRADDR_1(bram_wraddr_1),
    .DATA_OUT_2(data_out_2),
	.WE_2(we_2),
	.BRAM_WRADDR_2(bram_wraddr_2)
);
    
    initial begin
        drive_reset;
        initiate_read;
        repeat (C_M_AXI_NUMBER_OF_BURST)
        begin
            read;
        end
        initiate_read;
        repeat (C_M_AXI_NUMBER_OF_BURST)
        begin
            read;
        end
        initiate_read;
        repeat (C_M_AXI_NUMBER_OF_BURST)
        begin
            read;
        end
        initiate_read;
        repeat (C_M_AXI_NUMBER_OF_BURST)
        begin
            read;
        end
        initiate_read;
        repeat (C_M_AXI_NUMBER_OF_BURST)
        begin
            read;
        end
    end

endmodule
