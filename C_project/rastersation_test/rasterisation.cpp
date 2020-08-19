#include "windows.h"

typedef enum { START, HIGH_SLOPE, LOW_SLOPE, FINISH } Bresebham_state;

typedef enum { GET_LIMITS, GET_LIMITS_2, DRAW_LINE } Triangle_state;

int LineLimiter(const int x1, const int y1, const int x2, const int y2, int *array_x)
 {
     int index = 0;
     // zmienne pomocnicze
     int d, dx, dy, ai, bi, xi;
     int x = x1, y = y1;

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

     if (dx > dy){
         ai = (dy - dx) * 2;
         bi = dy * 2;
         d = bi - dx;
         while (x != x2){
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
             }
         }
     }

     else{
         ai = ( dx - dy ) * 2;
         bi = dx * 2;
         d = bi - dy;

         while (y != y2){

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
void Triangle_rasterize_fsm(int lower_x, int lower_y, int mid_x, int mid_y, int upper_x, int upper_y, int color, int x_grad, int y_grad , HDC hdc){

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
                   SetPixel( hdc, x, y, (int)(R<<16|G<<8|B) );


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
                return;
                break;

            }
        }
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

