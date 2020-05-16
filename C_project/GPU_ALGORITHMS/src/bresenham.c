#include "bresenham.h"

int BresenhamLine(const int x1, const int y1, const int x2, const int y2, int *array_x, int *array_y)
 {
     int index = 0;
     // zmienne pomocnicze
     int d, dx, dy, ai, bi, xi, yi;
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
     // ustalenie kierunku rysowania
     if (y1 < y2){
         yi = 1;
         dy = y2 - y1;
     }
     else{
         yi = -1;
         dy = y1 - y2;
     }
     // pierwszy piksel
     array_x[index] = x;
     array_y[index] = y;
     index++;
     // oœ wiod¹ca OX
     if (dx > dy){
         ai = (dy - dx) * 2;
         bi = dy * 2;
         d = bi - dx;
         // pêtla po kolejnych x
         while (x != x2){
             // test wspó³czynnika
             if (d >= 0)
             {
                 x += xi;
                 y += yi;
                 d += ai;
             }
             else
             {
                 d += bi;
                 x += xi;
             }
             array_x[index] = x;
             array_y[index] = y;
             index++;
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
             if (d >= 0)
             {
                 x += xi;
                 y += yi;
                 d += ai;
             }
             else
             {
                 d += bi;
                 y += yi;
             }
             array_x[index] = x;
             array_y[index] = y;
             index++;
         }
     }
     return index;
 }

 int BresenhamEllipse(const int x0, const int y0, const int a, const int b, int *array_x, int *array_y){

    int a2, b2, d, deltaA, deltaB, x, y, index = 0, limit;
    a2 = a*a;
    b2 = b*b;

    d      = 4*b2 - 4*b*a2 + a2;
    deltaA = 4*3*b2;
    deltaB = 4*(3*b2 - 2*a2*b + 2*a2);

    x = 0;
    y = b;

    limit = (a2*a2)/(a2+b2);

    while( x*x < limit){

        array_x[index] = x0+x;
        array_y[index] = y0+y;
        index++;

        array_x[index] = x0-x;
        array_y[index] = y0+y;
        index++;

        array_x[index] = x0+x;
        array_y[index] = y0-y;
        index++;

        array_x[index] = x0-x;
        array_y[index] = y0-y;
        index++;

        array_x[index] = x0+y;
        array_y[index] = y0+x;
        index++;

        array_x[index] = x0-y;
        array_y[index] = y0+x;
        index++;

        array_x[index] = x0+y;
        array_y[index] = y0-x;
        index++;

        array_x[index] = x0-y;
        array_y[index] = y0-x;
        index++;

        if( d > 0 ){
            d      += deltaB;
            deltaA += 4*2*b2;
            deltaB += 4*(2*b2 + 2*a2);
            x ++;
            y --;
        }
        else {
            d      += deltaA;
            deltaA += 4*2*b2;
            deltaB += 4*2*b2;

            x ++;
        }
    }
    return index;

 }


int BresenhamCircle(const int x0, const int y0, const int r, int *array_x, int *array_y)
{
    int d, x, y, deltaA, deltaB, index =0;
    d = 5-4*r;
    x = 0;
    y = r;
    deltaA = (-2*r+5)*4;
    deltaB = 3*4;
    while (x < y){

        array_x[index] = x0-x;
        array_y[index] = y0-y;
        index++;

        array_x[index] = x0-x;
        array_y[index] = y0+y;
        index++;

        array_x[index] = x0+x;
        array_y[index] = y0-y;
        index++;

        array_x[index] = x0+x;
        array_y[index] = y0+y;
        index++;

        array_x[index] = x0-y;
        array_y[index] = y0-x;
        index++;

        array_x[index] = x0-y;
        array_y[index] = y0+x;
        index++;

        array_x[index] = x0+y;
        array_y[index] = y0-x;
        index++;

        array_x[index] = x0+y;
        array_y[index] = y0+x;
        index++;

        if (d > 0){
            d += deltaA;
            y -= 1;
            x += 1;
            deltaA += 4*4;
            deltaB += 2*4;
        }
        else {
            d += deltaB;
            x += 1;
            deltaA += 2*4;
            deltaB += 2*4;
        }
    }
    return index;

}
