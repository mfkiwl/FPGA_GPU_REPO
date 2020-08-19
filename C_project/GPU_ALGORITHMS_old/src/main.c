#include <stdio.h>
#include <stdlib.h>

#define ARRAY_SIZE 100000

#define PYTHON_SCRIPT "python ..\\..\\..\\..\\Python_files\\new_python_draw.py"

#define PATH_TO_TEXT_FILE "..\\..\\..\\..\\Other_data\\disp_data.txt"


void save_to_file(int *array_x, int *array_y, int num, FILE *fp);

void sort_verticles( int x_a, int y_a, int x_b, int y_b, int z_c, int z_b, int *lower_x, int *lower_y, int *mid_x, int *mid_y, int *upper_x, int *upper_y );

int Triangle_rasterize(const int x0, const int y0,const int x1, const int y1, const int x2, const int y2, int *array_x, int *array_y);

void Triangle_rasterize2(int lower_x, int lower_y, int mid_x, int mid_y, int upper_x, int uppe_y, int start_color, int x_grad, int y_grad , FILE *fp);

int main()
{
    int y_offset, x_offset;
    int lower_x, lower_y, mid_x, mid_y, upper_x, upper_y;
    FILE *pixel_txt = fopen( PATH_TO_TEXT_FILE, "w" );

    int line1[300];
    int line2[300];
    int line3[300];

    int i;

    y_offset = 0;
    x_offset = 0;
    sort_verticles( 300, 10, 10, 60, 100, 200, &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
   printf("start\n");
   Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xffffff, 2, 0, pixel_txt);
    printf("done\n");
    y_offset = 0;
    x_offset = 300;
    sort_verticles( 300, 60, 10, 10, 100, 200, &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
    Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xfffff0, 0, 0, pixel_txt);

    y_offset = 0;
    x_offset = 600;
    sort_verticles( 300, 100, 100, 100, 10, 10, &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
    Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xffff0f, 3, 0, pixel_txt);

    y_offset = 300;
    x_offset = 000;
    sort_verticles( 10, 10, 100, 200, 300, 10,  &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
    Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xfff0ff, 1, 0, pixel_txt);

    y_offset = 300;
    x_offset = 300;
    sort_verticles( 100, 200, 10, 10, 300, 60,  &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
    Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xff0fff, 0, 0, pixel_txt);

    y_offset = 300;
    x_offset = 600;
    sort_verticles( 100, 200,  300, 60, 10, 10, &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
   Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xf0ffff, 5, 0, pixel_txt);

    fclose(pixel_txt);
    system(PYTHON_SCRIPT);
}

void sort_verticles( int x_a, int y_a, int x_b, int y_b, int x_c, int y_c, int *lower_x, int *lower_y, int *mid_x, int *mid_y, int *upper_x, int *upper_y ){

    if( y_a > y_b){

        if( y_c > y_a){
            *upper_y = y_c;
            *upper_x = x_c;
            *mid_y   = y_a;
            *mid_x   = x_a;
            *lower_y = y_b;
            *lower_x = x_b;
        }
        else{
            if(y_b > y_c){
                *upper_y = y_a;
                *upper_x = x_a;
                *mid_y   = y_b;
                *mid_x   = x_b;
                *lower_y = y_c;
                *lower_x = x_c;
            }
            else{
                *upper_y = y_a;
                *upper_x = x_a;
                *mid_y   = y_c;
                *mid_x   = x_c;
                *lower_y = y_b;
                *lower_x = x_b;
            }
        }
    }

    else{

        if( y_c > y_b){
                *upper_y = y_c;
                *upper_x = x_c;
                *mid_y   = y_b;
                *mid_x   = x_b;
                *lower_y = y_a;
                *lower_x = x_a;
        }
        else {

            if( y_a > y_c){
                *upper_y = y_b;
                *upper_x = x_b;
                *mid_y   = y_a;
                *mid_x   = x_a;
                *lower_y = y_c;
                *lower_x = x_c;
            }
            else{
                *upper_y = y_b;
                *upper_x = x_b;
                *mid_y   = y_c;
                *mid_x   = x_c;
                *lower_y = y_a;
                *lower_x = x_a;
            }
        }
    }
}



void Triangle_rasterize2(int lower_x, int lower_y, int mid_x, int mid_y, int upper_x, int upper_y, int start_color, int x_grad, int y_grad , FILE *fp){

        int i, j, index = 0;
        int index2 = 0;
        int pix_num = 0;
        int color;
        int left_limit_x[300];
        int right_limit_x[300];
        int upper_limit_x[300];


            LineLimiter(lower_x, lower_y, mid_x, mid_y, left_limit_x);
            LineLimiter(lower_x, lower_y, upper_x, upper_y, right_limit_x);
            LineLimiter(mid_x, mid_y, upper_x, upper_y, upper_limit_x);


        for(i = lower_y; i< mid_y; i++){
            color = start_color;
            for(j = right_limit_x[index]; j <= left_limit_x[index] ; j++ ){
                fprintf(fp,"%d, %d, #%x\n", j, i, color);
                color -= x_grad;
            }
            start_color -= y_grad;
            index++;
        }

        for(i = mid_y; i<= upper_y; i++){
            color = start_color;
            for(j = right_limit_x[index2+index]; j <= upper_limit_x[index2] ; j++ ){
                fprintf(fp,"%d, %d, #%x\n", j, i, color);
                color -= x_grad;
            }
            start_color -= y_grad;
            index2++;
        }
}




