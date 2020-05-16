#include <stdio.h>
#include <stdlib.h>

#define ARRAY_SIZE 100000

#define PYTHON_SCRIPT "python ..\\..\\..\\..\\Python_files\\new_python_draw.py"

#define PATH_TO_TEXT_FILE "..\\..\\..\\..\\Other_data\\disp_data.txt"


void save_to_file(int *array_x, int *array_y, int num, FILE *fp);

int Triangle_rasterize(const int x0, const int y0,const int x1, const int y1, const int x2, const int y2, int *array_x, int *array_y);

void Triangle_rasterize2(int x0, int y0,int x1,int y1, int x2, int y2, int start_color, int grad , FILE *fp);

int main()
{
    int array_x[ARRAY_SIZE];
    int array_y[ARRAY_SIZE];
    int pix_num = 0;
    FILE *pixel_txt = fopen( PATH_TO_TEXT_FILE, "w" );
    if(pixel_txt == NULL){
        printf("FILE SYSTEM PROBLEM");
        return 666;
    }
      Triangle_rasterize2(10, 10, 300, 60, 100, 200, 0xffffff, 2, pixel_txt);
    fclose(pixel_txt);
    system(PYTHON_SCRIPT);
}


int Triangle_rasterize(int x0, int y0,int x1,int y1, int x2, int y2, int *array_x, int *array_y){

        int i, j, index = 0;
        int index2 = 0;
        int pix_num = 0;

        int left_limit_x[200];

        int right_limit_x[200];

        int upper_limit_x[200];

            BresenhamLineCut(x0, y0, x1, y1, left_limit_x);
            BresenhamLineCut(x0, y0, x2, y2, right_limit_x);
            BresenhamLineCut(x1, y1, x2, y2, upper_limit_x);
        printf("done\n");

        for(i = y0; i< y1; i++){
            for(j = right_limit_x[index]; j <= left_limit_x[index] ; j++ ){
                array_x[pix_num] = j;
                array_y[pix_num] = i;
                pix_num++;
            }
            index++;
        }

        for(i = y1; i<= y2; i++){

            for(j = right_limit_x[index2+index]; j <= upper_limit_x[index2] ; j++ ){
                array_x[pix_num] = j;
                array_y[pix_num] = i;
                pix_num++;
            }
            index2++;
        }

        return pix_num;
}

void Triangle_rasterize2(int x0, int y0,int x1,int y1, int x2, int y2, int start_color, int grad , FILE *fp){

        int i, j, index = 0;
        int index2 = 0;
        int pix_num = 0;

        int left_limit_x[200];

        int right_limit_x[200];

        int upper_limit_x[200];

        BresenhamLineCut(x0, y0, x1, y1, left_limit_x);
        BresenhamLineCut(x0, y0, x2, y2, right_limit_x);
        BresenhamLineCut(x1, y1, x2, y2, upper_limit_x);


        for(i = y0; i< y1; i++){
            for(j = right_limit_x[index]; j <= left_limit_x[index] ; j++ ){
                fprintf(fp,"%d, %d, #%x\n", j, i, start_color);
            }
            start_color -= grad;
            index++;
        }

        for(i = y1; i<= y2; i++){

            for(j = right_limit_x[index2+index]; j <= upper_limit_x[index2] ; j++ ){
                fprintf(fp,"%d, %d, #%x\n", j, i, start_color);
                start_color -= grad;
            }
            index2++;
        }
}



void save_to_file(int *array_x, int *array_y, int num, FILE *fp){
    int i;
    for(i = 0; i< num; i++){
        fprintf(fp,"%d,", array_x[i]);
    }
    fprintf(fp,"0\n");
    for(i = 0; i< num; i++){
        fprintf(fp,"%d,", array_y[i]);
    }
    fprintf(fp,"0\n");
}
