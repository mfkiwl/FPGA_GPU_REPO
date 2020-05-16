#ifndef BRESENHAM_H_INCLUDED
#define BRESENHAM_H_INCLUDED

int BresenhamLine(const int x1, const int y1, const int x2, const int y2, int *array_x, int *array_y);
int BresenhamCircle(const int x0, const int y0, const int r, int *array_x, int *array_y);
int BresenhamEllipse(const int x0, const int y0, const int a, const int b, int *array_x, int *array_y);

#endif // BRESENHAM_H_INCLUDED
