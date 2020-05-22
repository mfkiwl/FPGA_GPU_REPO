`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2020 12:28:58
// Design Name: 
// Module Name: matrix_mult_tb
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


module matrix_4x4_mult_tb();

reg clock;
reg valid_in;
wire ready_out;
reg [11:0] a_in;
reg [11:0] b_in;
reg ready_in;
wire valid_out;
wire [3:0][11:0] cC1;
wire [3:0][11:0] cC2;
wire [3:0][11:0] cC3;
wire [3:0][11:0] cC4;

reg [0:15][11:0] A = {12'd1, 12'd1, 12'd1, 12'd1,
                     12'd2, 12'd2, 12'd2, 12'd2,
                     12'd3, 12'd3, 12'd3, 12'd3,
                     12'd4, 12'd4, 12'd4, 12'd4};
                     
reg [0:15][11:0] B = {12'd1, 12'd1, 12'd1, 12'd1,
                     12'd2, 12'd2, 12'd2, 12'd2,
                     12'd3, 12'd3, 12'd3, 12'd3,
                     12'd4, 12'd4, 12'd4, 12'd4};                     

//Instantiation
matrix_4x4_mult matrix_4x4_mult_rtl(
    .clk(clock), 
    .valid_in(valid_in),
    .a_in(a_in),
    .b_in(b_in),
    .ready_out(ready_out),
    
    .ready_in(ready_in),
    .valid_out(valid_out),
    .cC1(cC1),
    .cC2(cC2),
    .cC3(cC3),
    .cC4(cC4)
    );
    
task send_data(input [0:15][11:0] A, input [0:15][11:0] B);
begin
    while(ready_out == 0)
    begin
        @(posedge clock);
    end
    $display("\nNew processing started");
    @(posedge clock)
    begin
        valid_in <= 1'b0;
        ready_in <= 1'b1;
    end
    @(posedge clock)
    begin
        valid_in <= 1'b1;
        ready_in <= 1'b0;
    end
    /////C1
    @(posedge clock)
    begin
        a_in <= A[0];
        b_in <= B[0];
    end
    @(posedge clock)
    begin
        a_in <= A[4];
        b_in <= B[4];
    end
    @(posedge clock)
    begin
        a_in <= A[8];
        b_in <= B[8];
    end
    @(posedge clock)
    begin
        a_in <= A[12];
        b_in <= B[12];
    end
    //////C2
    @(posedge clock)
    begin
        a_in <= A[1];
        b_in <= B[1];
    end
    @(posedge clock)
    begin
        a_in <= A[5];
        b_in <= B[5];
    end
    @(posedge clock)
    begin
        a_in <= A[9];
        b_in <= B[9];
    end
    @(posedge clock)
    begin
        a_in <= A[13];
        b_in <= B[13];
    end
    /////C3
    @(posedge clock)
    begin
        a_in <= A[2];
        b_in <= B[2];
    end
    @(posedge clock)
    begin
        a_in <= A[6];
        b_in <= B[6];
    end
    @(posedge clock)
    begin
        a_in <= A[10];
        b_in <= B[10];
    end
    @(posedge clock)
    begin
        a_in <= A[14];
        b_in <= B[14];
    end
    ////C4
    @(posedge clock)
    begin
        a_in <= A[3];
        b_in <= B[3];
    end
    @(posedge clock)
    begin
        a_in <= A[7];
        b_in <= B[7];
    end
    @(posedge clock)
    begin
        a_in <= A[11];
        b_in <= B[11];
    end
    @(posedge clock)
    begin
        a_in <= A[15];
        b_in <= B[15];
    end
    @(posedge clock);
    begin
        valid_in <= 1'b0;
    end
    @(posedge clock);
    @(posedge clock);
end
endtask  

task display_matrices_A_and_B(input [0:15][11:0] A, input [0:15][11:0] B);
begin
        $display("Macierz A ");
        $display(A[0], A[1], A[2], A[3]);
        $display(A[4], A[5], A[6], A[7]);
        $display(A[8], A[9], A[10], A[11]);
        $display(A[12], A[13], A[14], A[15]);
        
        $display("Macierz B ");
        $display(B[0], B[1], B[2], B[3]);
        $display(B[4], B[5], B[6], B[7]);
        $display(B[8], B[9], B[10], B[11]);
        $display(B[12], B[13], B[14], B[15]);
end
endtask

task display_matrix_C(input [3:0][11:0] cC1, input [3:0][11:0] cC2, input [3:0][11:0] cC3, input [3:0][11:0] cC4);
begin
        $display("Macierz wynikowa C = AxB ");
        $display(cC1[0], cC2[0], cC3[0], cC4[0]);
        $display(cC1[1], cC2[1], cC3[1], cC4[1]);
        $display(cC1[2], cC2[2], cC3[2], cC4[2]);
        $display(cC1[3], cC2[3], cC3[3], cC4[3]);
end
endtask

task wait_for_valid_out();
    while(valid_out == 0)
    begin
        @(posedge clock);
    end
endtask
  
//Clock generator stimuli
initial
begin
    clock <= 1'b1;
end
always
    #5 clock <= ~clock;
    
//Signals stimuli
initial
begin
    #20
    A = {12'd1, 12'd1, 12'd1, 12'd1,
         12'd2, 12'd2, 12'd2, 12'd2,
         12'd3, 12'd3, 12'd3, 12'd3,
         12'd4, 12'd4, 12'd4, 12'd4};
                     
    B = {12'd1, 12'd1, 12'd1, 12'd1,
         12'd2, 12'd2, 12'd2, 12'd2,
         12'd3, 12'd3, 12'd3, 12'd3,
         12'd4, 12'd4, 12'd4, 12'd4}; 
    send_data(A, B);
    wait_for_valid_out();
    display_matrices_A_and_B(A, B);
    display_matrix_C(cC1, cC2, cC3, cC4);
    
    A = {12'd1, 12'd1, 12'd1, 12'd1,
         12'd1, 12'd1, 12'd1, 12'd1,
         12'd1, 12'd1, 12'd1, 12'd1,
         12'd1, 12'd1, 12'd1, 12'd1};
                     
    B = {12'd1, 12'd0, 12'd0, 12'd0,
         12'd0, 12'd1, 12'd0, 12'd0,
         12'd0, 12'd0, 12'd1, 12'd0,
         12'd0, 12'd0, 12'd0, 12'd1}; 
    send_data(A, B);
    wait_for_valid_out();
    display_matrices_A_and_B(A, B);
    display_matrix_C(cC1, cC2, cC3, cC4);
end
endmodule