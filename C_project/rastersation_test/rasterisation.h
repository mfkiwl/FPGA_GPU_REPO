#ifndef RASTERISATION_H_INCLUDED
#define RASTERISATION_H_INCLUDED

void Triangle_rasterize_fsm(int lower_x, int lower_y, int mid_x, int mid_y, int upper_x, int upper_y, int color, int x_grad, int y_grad , HDC hdc);
void sort_verticles( int x_a, int y_a, int x_b, int y_b, int x_c, int y_c, int *lower_x, int *lower_y, int *mid_x, int *mid_y, int *upper_x, int *upper_y );

#endif // RASTERISATION_H_INCLUDED
