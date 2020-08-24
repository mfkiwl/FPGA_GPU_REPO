#include "matrix_op.h"
#include "rasterisation.h"
#include "stdio.h"
void perspective_projection( float* coordinates3d, float* normalized ){

    normalized[0] = C1*coordinates3d[0] + C2*coordinates3d[2];
    normalized[1] = C3*coordinates3d[1] + C4*coordinates3d[2];
    normalized[2] = C5*coordinates3d[2] + C6*coordinates3d[3];
    normalized[3] = coordinates3d[2];

    for( int i = 0; i < 3; i++) normalized[i] = normalized[i]/(normalized[3]*normalized[3]);
}

void normalized_to_2d( float *normalized, int *coordinates2d ){

    coordinates2d[0] = int(960*normalized[0] + 960);
    coordinates2d[1] = int(540*normalized[1] + 540);
    coordinates2d[2] = int(255*normalized[2]);
}

void array_pack( float lower_x, float lower_y, float lower_z, float mid_x, float mid_y, float mid_z, float upper_x, float upper_y, float upper_z, float *packed_coordinates ){

    //lower
    packed_coordinates[0] = lower_x;
    packed_coordinates[1] = lower_y;
    packed_coordinates[2] = lower_z;
    packed_coordinates[3] = 1.0;
    //mid
    packed_coordinates[4] = mid_x;
    packed_coordinates[5] = mid_y;
    packed_coordinates[6] = mid_z;
    packed_coordinates[7] = 1.0;
    //upper
    packed_coordinates[8] = upper_x;
    packed_coordinates[9] = upper_y;
    packed_coordinates[10] = upper_z;
    packed_coordinates[11] = 1.0;

}

void triangle_rasterize_3d(float lower_x, float lower_y, float lower_z, float mid_x, float mid_y, float mid_z,  float upper_x, float upper_y, float upper_z, int color, int x_grad, int y_grad , HDC hdc){
    float coordinates_array[12];
    float normalized_array[12];
    int   c2d_array[9];
    array_pack(lower_x, lower_y, lower_z, mid_x, mid_y, mid_z, upper_x, upper_y, upper_z, coordinates_array);
    perspective_projection( coordinates_array, normalized_array);
    perspective_projection( &(coordinates_array[4]), &(normalized_array[4]));
    perspective_projection( &(coordinates_array[8]), &(normalized_array[8]));
    printf("normalized");
    normalized_to_2d( normalized_array, c2d_array );
    normalized_to_2d( &(normalized_array[4]), &(c2d_array[3]) );
    normalized_to_2d( &(normalized_array[8]), &(c2d_array[6]) );
    printf("ready to disp");
    Triangle_rasterize_fsm( c2d_array[0] , c2d_array[1] , c2d_array[3], c2d_array[4], c2d_array[6], c2d_array[7], color, x_grad, y_grad, hdc);
}
