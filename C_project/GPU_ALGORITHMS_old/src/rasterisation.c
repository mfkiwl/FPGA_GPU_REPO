#include "../inc/bresenham.h"
#include "stdlib.h"
#include "stdio.h"

typedef enum { START, HIGH_SLOPE, LOW_SLOPE, FINISH } Bresebham_state;

typedef enum { GET_LIMITS, GET_LIMITS_2, DRAW_LINE } Triangle_state;

int LineLimiter(const int x1, const int y1, const int x2, const int y2, int *array_x)
 {
     int index = 0;
     // zmienne pomocnicze
     int d, dx, dy, ai, bi, xi;
     int x = x1, y = y1;
     // ustalenie kierunku rysowania
     if (x1 < x2){
         xi = 1;
         dx = x2 - x1;
     }
     else{
         xi = -1;
         dx = x1 - x2;
     }
         dy = y2 - y1;

     // pierwszy piksel
     array_x[index] = x;
     index++;
     // oœ wiod¹ca OX
     if (dx > dy){
         ai = (dy - dx) * 2;
         bi = dy * 2;
         d = bi - dx;
         // pêtla po kolejnych x
         while (x != x2){
             // test wspó³czynnika
             x+= xi;
             array_x[index] = x;

             if (d >= 0)
             {
                d += ai;
                index++;

             }
             else
             {
                 d += bi;
                 //index++;
             }

         }
     }
     // oœ wiod¹ca OY
     else{
         ai = ( dx - dy ) * 2;
         bi = dx * 2;
         d = bi - dy;
         // pêtla po kolejnych y
         while (y != y2){
             // test wspó³czynnika
             y++;
             if (d >= 0)
             {
                 x += xi;
                 d += ai;
             }
             else
             {
                 d += bi;
             }
             array_x[index] = x;
             index++;
         }
     }
     return index;
 }

void ModifiedBresenham(const int x1, const int y1, const int x2, const int y2, int *x_limit){

    static Bresebham_state status= START;

    static int d, dx, dy, ai, bi, xi;
    static int x, y;

    while(1){

    switch( status ){

        case START:
            x = x1;
            y = y1;

            if (x1 < x2){
                xi = 1;
                dx = x2 - x1;
            }
            else{
                xi = -1;
                dx = x1 - x2;
            }
            dy = y2 - y1;

            break;
        case HIGH_SLOPE:



            break;
        case LOW_SLOPE:

            break;
        case FINISH:

            break;
        }

    }
}


void Triangle_rasterize_fsm(int lower_x, int lower_y, int mid_x, int mid_y, int upper_x, int upper_y, int color, int x_grad, int y_grad , FILE *fp){

        int y, x, index = 0;
        int index2 = 0;
        int pix_num = 0;
        int upper_limit, lower_limit;
        int line1[300];
        int line2[300];
        int line3[300];

        unsigned char R;
        unsigned char G;
        unsigned char B;

        Triangle_state state;
        //fprintf(fp,"%d, %d, #%x\n", lower_x, lower_y, color);
        //index++;
        R = (color>> 16)&0xFF;
        G = (color>> 8)&0xFF;
        B = color & 0xFF;
        y = lower_y;
        LineLimiter(lower_x, lower_y, upper_x, upper_y, line1);
        LineLimiter(lower_x, lower_y, mid_x,   mid_y,   line2);
        LineLimiter(mid_x,   mid_y,   upper_x, upper_y, line3);
        if(lower_y == mid_y) state = GET_LIMITS_2;
        else state = GET_LIMITS;
        while(1){
            switch( state ){

                case GET_LIMITS:
                    {

                        if( line1[index] > line2[index]){
                            upper_limit = line1[index];
                            lower_limit = line2[index];
                        }
                        else{
                            upper_limit = line2[index];
                            lower_limit = line1[index];
                        }
                        state = DRAW_LINE;
                        x = lower_limit;
                        y++;
                        index++;
                        break;
                    }
               case GET_LIMITS_2:
                    {
                        if(y > upper_y) return;
                        if( line1[index2 + index] >line3[index2]){
                            upper_limit = line1[index2 + index];
                            lower_limit = line3[index2];

                        }
                        else{
                            upper_limit = line3[index2];
                            lower_limit = line1[index2+index];
                        }
                        state = DRAW_LINE;
                        x = lower_limit;
                        y++;
                        index2++;

                        break;
                    }
                case DRAW_LINE:
                {
                   if( !R&&!G&&!B )  fprintf(fp,"%d, %d, #000000", x, y);
                   if( R < 16)       fprintf(fp,"%d, %d, #0%x\n", x, y, (int)(R<<16|G<<8|B));
                   else     fprintf(fp,"%d, %d, #%x\n", x, y, (int)(R<<16|G<<8|B));

                        if(x == upper_limit){
                            if( R > x_grad ) R-=x_grad;
                            if( G > x_grad ) G-=x_grad;
                            if( B > x_grad ) B-=x_grad;

                            if( y < mid_y) state = GET_LIMITS;
                            else{
                                state = GET_LIMITS_2;
                            }
                        }
                        x++;
                        break;
                    }
            default:
                printf("%d", state);
                printf("ERROR");
                return;
                break;

            }
        }
}
