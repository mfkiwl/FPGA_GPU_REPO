`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.05.2020 16:10:17
// Design Name: 
// Module Name: draw_line_tb
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


module draw_line_tb(

    );
    
    reg clk;
    reg rst;
    reg req;
    wire ack;
    reg [15:0]start_x;
    reg [15:0]start_y;
    reg [15:0]end_x;
    reg [15:0]end_y; 
    wire [15:0] out_x;
    wire [15:0] out_y;
    
    BresenhamLine draw_line(
    
        .clk(clk),
        .rst(rst),
        .req(req),
        .start_x(start_x),
        .start_y(start_y),
        .end_x(end_x),
        .end_y(end_y),
        
        .out_x(out_x),
        .out_y(out_y),
        .ack(ack)
        
        );
        
        localparam 
            
            TEST_SET_DATA       = 4'b0000,
            TEST_PROCESSING     = 4'b0001,
            TEST_SAVE_RESULTS   = 4'b0011,
            TEST_FINISH         = 4'b0010;     
            
        
        integer file_ptr;
        integer file_open;
        integer test_num;
        
        reg [4:0] test_state;
        
        task OPEN_FILE;
            reg [10*8:1] file_name;
        begin
            file_name = {"dziadostwo", ".txt"};
            file_ptr = $fopen("C:\\Users\\Karol\\Desktop\\dziadostwo.txt", "wb"); 
            file_open = 1;
        end
        endtask
        
        task CLOSE_FILE;
        begin
            $fclose(file_ptr);
            file_open = 0;
        end
        endtask    
        
    initial
    begin 
        clk = 0;
        rst = 1;
        #1 rst = 0;
    end
    
    always 
    begin
        #5 clk = !clk;
    end
    
    initial
    begin
        OPEN_FILE;
        req = 0;
        test_state = TEST_SET_DATA;
        
    end
    


    always @(posedge clk)
    begin
        
        case(test_state)
        
        TEST_SET_DATA: 
        begin
           start_x <= 0;
           start_y <= 0;
           end_x <= 100;
           end_y <= 200; 
           test_num <= test_num + 1;
           test_state <= TEST_PROCESSING;
        end
        
        TEST_PROCESSING:
        begin
            req <= 1'b1;
            if( ack == 1'b1 ) test_state = TEST_SAVE_RESULTS;
            else test_state = TEST_PROCESSING;
        end
        TEST_SAVE_RESULTS:
        begin 
            req <= 1'b1;
            $display("X = %d, Y = %d", out_x, out_y);
            $fwriteb(file_ptr, "%d,%d\n", out_x, out_y);
            if( ack == 1'b1 ) test_state <= TEST_SAVE_RESULTS;
            else test_state <= TEST_FINISH;
        end     
        TEST_FINISH:
        begin 
            req <= 1'b0;
            CLOSE_FILE;
            $finish;
        end
        endcase
        

        
    
    end

endmodule
