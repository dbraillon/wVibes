#include "threadManager.h"

static int countThreads = 0;

void createThread( void *routine , void *arg )
{
    TRACE_2( THREADMANAGER , "createThread()");

    pthread_t newThread;

    if( arg == NULL )
    {
        pthread_create( &newThread , NULL , ( void * ) routine , NULL );

        countThreads++;
    }
    else
    {
        pthread_create( &newThread , NULL , ( void * ) routine , arg );

        countThreads++;
    }

    TRACE_1( THREADMANAGER , "Current number of threads: %d." , countThreads );
}
