#include "fileManager.h"

int createFile( void )
{
    TRACE_2( FILEMANAGER , "createFile()");

    FILE *f = NULL;
    FILE *h = NULL;
    wavHeader_t wavH;

    int status = PC_SUCCESS;

    f = fopen("/home/raphio/test3.wav" , "wb+");
    h = fopen("/home/raphio/music.wav" , "rb");

    if( f == NULL || h == NULL )
    {
        TRACE_ERROR( FILEMANAGER , "f or h FILE is NULL");

        status = PC_ERROR;
    }
    else
    {
        fread( &wavH , sizeof( wavH ) , 1 ,  h );

        fwrite( &wavH , sizeof( wavH ) , 1 , f );

        fclose( f );
        fclose( h );
    }

    return status;
}

int writeFile( void *data )
{
    TRACE_2( FILEMANAGER , "writeFile()");

    static int firstTime = 0;
    int status = PC_SUCCESS;

    FILE *f = NULL;

    f = fopen("/home/raphio/test3.wav" , "ab");

    if( f == NULL )
    {
        TRACE_ERROR( FILEMANAGER , "f FILE is NULL");

        status = PC_ERROR;
    }
    else
    {
        fwrite( data , 8192 , 1 , f );

        fclose( f );

        if( firstTime++ == 0 )
            streamFile("/home/raphio/test3.wav");
    }

    return status;
}
