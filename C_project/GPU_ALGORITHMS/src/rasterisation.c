#include "bresenham.h"

int BresenhamLineCut(const int x1, const int y1, const int x2, const int y2, int *array_x)
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

                array_x[index] = x;
                index++;
             }
             else
             {
                 d += bi;
                 x += xi;
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
                index++;
         }
     }
     return index;
 }

