#if defined(UNICODE) && !defined(_UNICODE)
    #define _UNICODE
#elif defined(_UNICODE) && !defined(UNICODE)
    #define UNICODE
#endif
#include <stdio.h>
#include <tchar.h>
#include <windows.h>
#include "rasterisation.h"
#include "matrix_op.h"
/*  Declare Windows procedure  */
LRESULT CALLBACK WindowProcedure (HWND, UINT, WPARAM, LPARAM);

/*  Make the class name into a global variable  */
TCHAR szClassName[ ] = _T("SDUP GPU");

void window_setup( WNDCLASSEX *wincl, HINSTANCE hThisInstance,  HWND *hwnd ){
        /* The Window structure */
    wincl->hInstance = hThisInstance;
    wincl->lpszClassName = szClassName;
    wincl->lpfnWndProc = WindowProcedure;      /* This function is called by windows */
    wincl->style = CS_DBLCLKS;                 /* Catch double-clicks */
    wincl->cbSize = sizeof (WNDCLASSEX);

    /* Use default icon and mouse-pointer */
    wincl->hIcon = LoadIcon (NULL, IDI_APPLICATION);
    wincl->hIconSm = LoadIcon (NULL, IDI_APPLICATION);
    wincl->hCursor = LoadCursor (NULL, IDC_ARROW);
    wincl->lpszMenuName = NULL;                 /* No menu */
    wincl->cbClsExtra = 0;                      /* No extra bytes after the window class */
    wincl->cbWndExtra = 0;                      /* structure or the window instance */
    /* Use Windows's default colour as the background of the window */
    wincl->hbrBackground = (HBRUSH) COLOR_BACKGROUND;

    /* Register the window class, and if it fails quit the program */
    if (!RegisterClassEx (wincl))
        return;

        /* The class is registered, let's create the program*/
    *hwnd = CreateWindowEx (
           0,                   /* Extended possibilites for variation */
           szClassName,         /* Classname */
           _T("SDUP GPU Dziadostwo"),       /* Title Text */
           WS_OVERLAPPEDWINDOW, /* default window */
           CW_USEDEFAULT,       /* Windows decides the position */
           CW_USEDEFAULT,       /* where the window ends up on the screen */
           1920,                 /* The programs width */
           1080,                 /* and height in pixels */
           HWND_DESKTOP,        /* The window is a child-window to desktop */
           NULL,                /* No menu */
           hThisInstance,       /* Program Instance handler */
           NULL                 /* No Window Creation data */
           );
}

int WINAPI WinMain (HINSTANCE hThisInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR lpszArgument,
                     int nCmdShow)
{

    int y_offset, x_offset;
    int lower_x, lower_y, mid_x, mid_y, upper_x, upper_y;



    HWND hwnd;               /* This is the handle for our window */
    MSG messages;            /* Here messages to the application are saved */
    WNDCLASSEX wincl;        /* Data structure for the windowclass */

    window_setup( &wincl, hThisInstance, &hwnd );

    /* Make the window visible on the screen */

    ShowWindow (hwnd, nCmdShow);
    HDC hdc = GetDC( hwnd );

    y_offset = 0;
    x_offset = 0;
    sort_verticles( 300, 10, 10, 60, 100, 200, &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
    Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xffffff, 2, 0, hdc);

    triangle_rasterize_3d( 600, 10, 50, 310, 60, 50, 400, 200, 50, 0xffffff, 2, 0, hdc);
    triangle_rasterize_3d( 600, 10, 40, 310, 60, 40, 400, 200, 40, 0xffffff, 2, 0, hdc);
    triangle_rasterize_3d( 600, 10, 30, 310, 60, 30, 400, 200, 30, 0xffffff, 2, 0, hdc);
    triangle_rasterize_3d( 600, 10, 25, 310, 60, 25, 400, 200, 25, 0xffffff, 2, 0, hdc);

    //printf( "%d, %d, %d, %d, %d, %d\n", coordinates2d_btm[0] , coordinates2d_btm[1], coordinates2d_mid[0], coordinates2d_btm[1], coordinates2d_top[0], coordinates2d_top[1]);
  //  y_offset = 0;
  //  x_offset = 300;
  //  sort_verticles( 300, 60, 10, 10, 100, 200, &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
  //  Triangle_rasterize_fsm(coordinates2d_btm[0] , coordinates2d_btm[1], coordinates2d_mid[0], coordinates2d_mid[1], coordinates2d_top[0], coordinates2d_top[1], 0xfffff0, 0, 0, hdc);

  /*  y_offset = 0;
    x_offset = 600;
    sort_verticles( 300, 100, 100, 100, 10, 10, &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
    Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xffff0f, 3, 0, hdc);

    y_offset = 300;
    x_offset = 000;
    sort_verticles( 10, 10, 100, 200, 300, 10,  &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
    Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xfff0ff, 1, 0, hdc);

    y_offset = 300;
    x_offset = 300;
    sort_verticles( 100, 200, 10, 10, 300, 60,  &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
    Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xff0fff, 0, 0, hdc);

    y_offset = 300;
    x_offset = 600;
    sort_verticles( 100, 200,  300, 60, 10, 10, &lower_x, &lower_y, &mid_x, &mid_y, &upper_x, &upper_y );
   Triangle_rasterize_fsm(lower_x + x_offset , lower_y + y_offset, mid_x + x_offset, mid_y+ y_offset, upper_x + x_offset, upper_y + y_offset, 0xf0ffff, 5, 0, hdc);
*/
ReleaseDC( hwnd, hdc );



    /* Run the message loop. It will run until GetMessage() returns 0 */
    while (GetMessage (&messages, NULL, 0, 0))
    {
        /* Translate virtual-key messages into character messages */
        TranslateMessage(&messages);
        /* Send message to WindowProcedure */
        DispatchMessage(&messages);
    }


    /* The program return-value is 0 - The value that PostQuitMessage() gave */
    return messages.wParam;
}


/*  This function is called by the Windows function DispatchMessage()  */

LRESULT CALLBACK WindowProcedure (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)                  /* handle the messages */
    {
        case WM_DESTROY:
            PostQuitMessage (0);       /* send a WM_QUIT to the message queue */
            break;
        default:                      /* for messages that we don't deal with */
            return DefWindowProc (hwnd, message, wParam, lParam);
    }

    return 0;
}
