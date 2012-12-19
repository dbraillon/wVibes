#include "serverManager.h"

static int socketMulticast;
static int s_client[MAX_CLIENT];
static int countClients;

static struct sockaddr_in addrMulticast;

//static pthread_t serverStreamerThread;
static pthread_t serverCommanderThread;

int initMulticastSocket( void )
{
    TRACE_2( STREAMINGSERVER , "initMulticastSocket()");

    socketMulticast = socket( AF_INET , SOCK_DGRAM , 0 );

    if( socketMulticast < 0 )
    {
        TRACE_ERROR( STREAMINGSERVER , "Cannot create the multicast socket.");

        return PC_ERROR;
    }

    addrMulticast.sin_family = AF_INET;
    addrMulticast.sin_addr.s_addr = inet_addr( MULTICAST_ADDR );
    addrMulticast.sin_port = htons( MULTICAST_PORT );

    return PC_SUCCESS;
}

void launchServer( void )
{
    TRACE_2( SERVERMANAGER , "lanchServer()");

    TRACE_3( COMMANDERSERVER , "Start server on port %d..." , PORT_COMMANDER );

    pthread_create( &serverCommanderThread , NULL , ( void * )&createServer , NULL );

    initMulticastSocket();
}


/* Commander server */
void createServer( void )
{
    TRACE_2( COMMANDERSERVER , "createServer().");

    int s_server = socket( AF_INET , SOCK_STREAM , 0 );

    struct sockaddr_in serv_addr;

    if( s_server < 0 )
    {
        TRACE_ERROR( COMMANDERSERVER , "[-]Error to create socket.");

        pthread_exit( PC_ERROR );
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl( INADDR_ANY );
    serv_addr.sin_port = htons( PORT_COMMANDER );

    if( bind( s_server , ( struct sockaddr* )&serv_addr, sizeof( serv_addr ) ) < 0 )
    {
        TRACE_ERROR( COMMANDERSERVER , "[-]Error to bind on port: %d." , PORT_COMMANDER );

        pthread_exit( PC_ERROR );
    }

    if( listen( s_server , 10 ) < 0 )
    {
        TRACE_ERROR( COMMANDERSERVER , "[-]Error to listen to 10 connection.");

        pthread_exit( PC_ERROR );
    }

    while( 1 )
    {
        if( countClients < MAX_CLIENT )
        {
            s_client[countClients] = accept( s_server , NULL , NULL );

            if( s_client[countClients] > 0 )
            {

                TRACE_3( COMMANDERSERVER , "[!]New client connected.");

                createThread( &receivingThread , &s_client[countClients] );

                countClients++;
            }
        }
    }


    pthread_exit( PC_SUCCESS );
}


int closeServer( void )
{
    TRACE_2( STREAMINGSERVER , "close().");

    return PC_SUCCESS;
}

void receivingThread( void *socket )
{
    TRACE_2( COMMANDERSERVER , "receivingThread()");

    char buff[BUFF_SIZE];
    int ret;

//    countClients++;

    TRACE_3( COMMANDERSERVER , "[!]Receiving thread create !");

    while( 1 )
    {
        memset( buff , 0 , BUFF_SIZE );

        ret = recv( *( int *)socket , buff , BUFF_SIZE , 0 );

        if( ret > 0 )
        {
            TRACE_3( COMMANDERSERVER , "[+]Data: %s" , buff );

            if( strstr( buff , "DISC") != NULL )
            {
                disconnectClient( socket );

                break;
            }

            doAction( buff );
        }

    }

    TRACE_3( COMMANDERSERVER , "[!]Quitting receiving thread !");

    pthread_exit( NULL );
}

int disconnectClient( int *socket )
{
    TRACE_2( COMMANDERSERVER , "disconnectClient()");

    int status = PC_SUCCESS;

    countClients--;

    if( close( *socket ) < 0 )
    {
        TRACE_ERROR( COMMANDERSERVER , "Cannot close client socket.");

        status = PC_ERROR;
    }
    else
    {
        s_client[countClients] = 0;

        TRACE_3( COMMANDERSERVER , "Client disconnect.");
    }

    return status;
}

void sendData( audio_fifo_data_t *data , size_t size )
{
    TRACE_2( COMMANDERSERVER , "sendData().");

    ssize_t b;

    if( s_client[countClients - 1] != 0 )
    {
        b = write( s_client[countClients - 1] , data , size );

        if( b < 0 )
        {
            TRACE_WARNING( STREAMINGSERVER , "Cannot write data to client.");
        }
    }

}

void sendControl( char *command )
{
    TRACE_2( COMMANDERSERVER , "sendControl( %s )." , command );

    if( s_client[countClients - 1] != 0 )
    {
        send( s_client[countClients - 1] , command , 6 , 0 );
    }
}


void sendVoid( void *data , size_t size )
{
    TRACE_2( COMMANDERSERVER , "sendDataMulticast()");

    ssize_t b = 0;

    if( s_client[countClients - 1] != 0 )
    {
        b = send( s_client[countClients - 1] , data , size , 0 );

        if( b < 0 )
            TRACE_WARNING( COMMANDERSERVER , "Fail to send data");
    }

}

void sendDataMulticast( audio_fifo_data_t *data , size_t size )
{
    TRACE_2( STREAMINGSERVER , "sendDataMulticast()");

    ssize_t b;

    b = sendto( socketMulticast , data , size , 0 , ( struct sockaddr * )&addrMulticast , sizeof( addrMulticast ) );

    if( b < 0 )
        TRACE_WARNING( STREAMINGSERVER , "Fail to send data");
}

void sendControlMulticast( char *command )
{
    TRACE_2( STREAMINGSERVER , "sendControlMulticast()");

    ssize_t b;

    b = sendto( socketMulticast , command , 6 , 0 , ( struct sockaddr * )&addrMulticast , sizeof( addrMulticast ) );

    if( b < 0 )
        TRACE_WARNING( STREAMINGSERVER , "Fail to send command: %s" , command );
}

void sendVoidMulticast( void *data , size_t size )
{
    TRACE_2( STREAMINGSERVER , "sendVoidMulticast()");

    ssize_t b;

    b = sendto( socketMulticast , data , size , 0 , ( struct sockaddr * )&addrMulticast , sizeof( addrMulticast ) );

    if( b < 0 )
        TRACE_WARNING( STREAMINGSERVER , "Fail to send void* data");
}
