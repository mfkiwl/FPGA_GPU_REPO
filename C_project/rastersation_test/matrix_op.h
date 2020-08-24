#ifndef MATRIX_OP_H_INCLUDED
#define MATRIX_OP_H_INCLUDED

#define MATRIX_ROWS 4
#define MATRIX_COLS 4

#define C1 0.5625F
#define C2 0.0F
#define C3 1.0F
#define C4 0.0F
#define C5 -2.0F
#define C6 -3.0F

#include "windows.h"

void perspective_projection( float* coordinates3d, float* coordinates2d );
void normalized_to_2d( float *normalized, int *coordinates2d );

void triangle_rasterize_3d(float lower_x, float lower_y, float lower_z, float mid_x, float mid_y, float mid_z,  float upper_x, float upper_y, float upper_z, int color, int x_grad, int y_grad , HDC hdc);


#endif // MATRIX_OP_H_INCLUDED
