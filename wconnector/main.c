#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pthread.h>

#include "audio.h"

#define IP_SERVER   "127.0.0.1"
//#define IP_SERVER   "192.168.1.12"
#define BUFF_SIZE   4
#define DATA_SIZE   8192

static audio_fifo_t g_audiofifo;

static int countPackets = 0;
static FILE *f;

audio_fifo_data_t *buff;
size_t size = DATA_SIZE + sizeof( *buff );

int play( audio_fifo_data_t *data )
{

    audio_fifo_t *af = &g_audiofifo;
    audio_fifo_data_t *afd;

    afd = ( audio_fifo_data_t * )malloc( size );

    memcpy( afd , data , size );

//    afd->channels = data->channels;
//    afd->rate = data->rate;
//    afd->nsamples = data->nsamples;

//    memcpy( afd->samples , data->samples , DATA_SIZE );

    printf("Playing music...\n");
    printf("Channels:\t %d\n" , afd->channels );
    printf("Rate:\t\t %d\n" , afd->rate );
    printf("NSamples:\t %d\n" , afd->nsamples );
    printf("Samples:\t %d\n" , afd->samples[0] );

//    f = fopen("/home/raphio/client.txt" , "a" );


//    fprintf( f, "Playing music...\n");
//    fprintf( f, "Channels:\t %d\n" , afd->channels );
//    fprintf( f, "Rate:\t\t %d\n" , afd->rate );
//    fprintf( f, "NSamples:\t %d\n" , afd->nsamples );
//    fprintf( f, "Samples:\t %d\n" , afd->samples[0] );

//    fclose( f );

    if( afd->nsamples == 0 )
    {
        pthread_mutex_unlock( &af->mutex );
        return 0;
    }

    if( af->qlen > afd->rate )
        return 0;

    TAILQ_INSERT_TAIL( &af->q , afd , link );
    af->qlen += afd->nsamples;

    pthread_cond_signal( &af->cond );
    pthread_mutex_unlock( &af->mutex );

    return afd->nsamples;
}

int main( void )
{

    int sock;
    struct sockaddr_in serverAddr;

    char message[] = "PLAYER:PLAY:zae";
    char packetControl[6];
    int16_t *tmp;

    ssize_t b;

    audio_init( &g_audiofifo );

    buff = ( audio_fifo_data_t * )malloc( size );

    sock = socket( AF_INET , SOCK_STREAM , 0 );

    if( sock < 0 )
    {
        printf("Cannot create socket...\n");

        return -1;
    }

    printf("Socket has been created.\n");

    serverAddr.sin_addr.s_addr = inet_addr( IP_SERVER );
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons( 1337 );

    if( connect( sock , ( struct sockaddr * )&serverAddr , sizeof( struct sockaddr ) ) < 0 )
    {
        printf("Cannot connect to the server...\n");

        return -1;
    }

    tmp = ( int16_t * )malloc( DATA_SIZE );

    while( 1 )
    {
        memset( tmp , 0 , DATA_SIZE );
        memset( packetControl , 0 , 6 );
        memset( buff , 0 , size );

        b = recv( sock , packetControl , sizeof( packetControl ) , MSG_WAITALL );

        if( strstr( packetControl , "START" ) != NULL )
        {
            printf("###################### %s #################\n" , packetControl );

            b = 0;

//            while( b != size )
//                b += recv( sock , buff + b , size - b , 0 );


            b = recv( sock , &buff->channels , sizeof( int ) , MSG_WAITALL );

////            buff->channels = 2;

            b = recv( sock , &buff->rate , sizeof( int ) , MSG_WAITALL );

////            buff->rate = 44100;

            b = recv( sock , &buff->nsamples , sizeof( int ) , MSG_WAITALL );

////            buff->nsamples = 2048;

            b = 0;

//            while( b != DATA_SIZE )
//                b += recv( sock , tmp + b , DATA_SIZE - b , MSG_WAITALL );

            b = recv( sock , tmp , DATA_SIZE , MSG_WAITALL );

            memcpy( buff->samples , tmp , DATA_SIZE );

//            f = fopen("/home/raphio/client.txt" , "a" );


//            fprintf( f, "Playing music...\n");
//            fprintf( f, "Channels:\t %d\n" , buff->channels );
//            fprintf( f, "Rate:\t\t %d\n" , buff->rate );
//            fprintf( f, "NSamples:\t %d\n" , buff->nsamples );
//            fprintf( f, "Samples:\t %d\n" , buff->samples[0] );

//            fclose( f );

//            memcpy( buff->samples , ( int16_t * )strtok( datastr , ":") , )


//            b = 0;
//            while( b < size )
//                b += recv( sock , buff + b , size - b , 0 );

            if( b > 0 )
            {

                countPackets++;

                printf("######### %d packets received ! ######\n\t\t SIZE:%d\tBYTES:%d\n" , countPackets , size , b );

                play( buff );
            }
            else
            {
                printf("Cannot receive data.\n");
            }
        }
        else if( strstr( packetControl , "STOP" ) != NULL )
        {
            printf("###################### %s #################\n" , packetControl );

            continue;
        }
        else
        {
            continue;
        }
    }



    printf("\n");
    return 0;
}

