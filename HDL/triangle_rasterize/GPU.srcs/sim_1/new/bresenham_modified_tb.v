`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2020 20:06:07
// Design Name: 
// Module Name: bresenham_modified_tb
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


module bresenham_modified_tb(

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
    wire finish;
    


    
    Bresenham_modified draw_line
    (
        .req(req),
        .rst(rst),
        .clk(clk),
        .start_x(start_x),
        .start_y(start_y),
        .end_x(end_x),
        .end_y(end_y),
        .out_x(out_x),
        .ack(ack),
        .finish(finish)
        
        );
        
        localparam 
            
            TEST_SET_DATA       = 4'b0000,
            TEST_PROCESSING     = 4'b0001,
            TEST_SAVE_RESULTS   = 4'b0010,
            TEST_FINISH         = 4'b0011,
            TEST_RETRIGGER      = 4'b0100,
            TEST_TRIGGER_ON     = 4'b0101,
            TEST_NUMBER         = 2;     
            
            reg [15:0] vector_test_start_x[TEST_NUMBER:0];  
            reg [15:0] vector_test_start_y[TEST_NUMBER:0]; 
            reg [15:0] vector_test_end_x[TEST_NUMBER:0]; 
            reg [15:0] vector_test_end_y[TEST_NUMBER:0]; 
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
        
    vector_test_start_x[0] = 10;  
    vector_test_start_y[0] = 10; 
    vector_test_end_x[0]  = 100; 
    vector_test_end_y[0]   = 200; 
    
    vector_test_start_x[1]= 10;   
    vector_test_start_y[1]= 10; 
    vector_test_end_x[1]= 300; 
    vector_test_end_y[1]= 60; 
        
    vector_test_start_x[2]= 300; 
    vector_test_start_y[2]= 60; 
    vector_test_end_x[2]= 100; 
    vector_test_end_y[2]= 200; 
    
 /*   vector_test_start_x[0]= 0; 
    vector_test_start_y[0]= 0;  
    vector_test_end_x[0]= 0;  
    vector_test_end_y[0]= 0;  
    
    vector_test_start_x[0]= 0; 
    vector_test_start_y[0]= 0;  
    vector_test_end_x[0]= 0; 
    vector_test_end_y[0]= 0; 
     */
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
     //   OPEN_FILE;
        req = 0;
        test_num = 0;
        test_state = TEST_SET_DATA;
        
    end
    

    always @(posedge clk)
    begin
        
        case(test_state)
        
        TEST_SET_DATA: 
        begin
            $display("Test number %d, data in line start(%d, %d  ), line end(%d, %d )", test_num,  vector_test_start_x[test_num],  vector_test_start_y[test_num], vector_test_end_x[test_num], vector_test_end_y[test_num]);
           start_x = vector_test_start_x[test_num];
           start_y = vector_test_start_y[test_num];
           end_x = vector_test_end_x[test_num];
           end_y = vector_test_end_y[test_num]; 
           
           req = 1'b0;
           test_state = TEST_TRIGGER_ON;
        end
        
   
        TEST_PROCESSING:
        begin
            req = 1'b0;
            if( ack == 1'b1 ) test_state = TEST_SAVE_RESULTS;
            else test_state = TEST_PROCESSING;
        end
        TEST_SAVE_RESULTS:
        begin 
            req = 1'b0;
            $display("X = %d", out_x);
            //$fwriteb(file_ptr, "%d,%d\n", out_x, out_y);
            if( finish == 1'b1 ) test_state = TEST_FINISH;
            else test_state =  TEST_TRIGGER_ON; 
        end  
        TEST_RETRIGGER:
        begin 
            req = 1'b0;
            if( ack == 1'b0 ) test_state = TEST_PROCESSING;
            else test_state =  TEST_RETRIGGER; 
        end       
        TEST_TRIGGER_ON:
        begin 
            req = 1'b1;
            test_state =  TEST_RETRIGGER; 
        end     
         
        TEST_FINISH:
        begin 
            req = 1'b0;
            test_num = test_num + 1;
            if(test_num > TEST_NUMBER ) $finish;
            else test_state = TEST_SET_DATA;
            
        end
        endcase
        

        
    
    end
    
    
endmodule
