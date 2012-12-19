#include "vlcManager.h"

static libvlc_instance_t *vlcInstance = NULL;
static libvlc_media_t *vlcMedia = NULL;
//static libvlc_media_player_t *vlcMediaPlayer = NULL;

static int initVlc( void )
{
    TRACE_2( VLCMANAGER , "initVlc");

    int status = PC_SUCCESS;

    vlcInstance = libvlc_new( 0 , NULL );

    if( vlcInstance == NULL )
    {
        TRACE_ERROR( VLCMANAGER , "Fail to create a new vlc instance.");

        status = PC_ERROR;
    }

    return status;
}

int streamFile( const char *filename )
{
    TRACE_2( VLCMANAGER , "streamFile( %s )" , filename );

    int status = PC_SUCCESS;
//    char opt[] = ":sout= #transcode{vcodec=none,acodec=vorb,ab=128,channels=2,samplerate=44100}:rtp{dst=244.2.2.2,port=1337,mux=ts,ttl=1} :sout-all :sout-keep";
//    char opt[] = "#transcode{vcodec=none,acodec=vorb,ab=128,channels=2,samplerate=44100}";

    if( vlcInstance == NULL )
        initVlc();

    vlcMedia = libvlc_media_new_path( vlcInstance , filename );

    if( vlcMedia != NULL )
    {

        libvlc_vlm_add_broadcast( vlcInstance , "rtpStreaming" , filename , "#rtp{dst=224.2.2.2,port=1337,ttl=10}" , 0 , NULL , 1 , 0 );


        libvlc_vlm_play_media( vlcInstance , "rtpStreaming");

        TRACE_1( VLCMANAGER , "Start diffuse the stream.");

//        libvlc_media_add_option( vlcMedia , opt );

//        vlcMediaPlayer = libvlc_media_player_new_from_media( vlcMedia );

//        if( vlcMediaPlayer != NULL )
//        {
//            libvlc_media_release( vlcMedia );
////            libvlc_media_player_play( vlcMediaPlayer );

//            TRACE_1( VLCMANAGER , "Start diffuse the stream.");
//        }
//        else
//        {
//            TRACE_ERROR( VLCMANAGER , "Fail to start the stream diffusion.");
//        }

    }
    else
    {
        TRACE_ERROR( VLCMANAGER , "Fail to create a new media from the path: %s" , filename );
    }

    return status;
}


int destroyVlc( void )
{
    TRACE_2( VLCMANAGER , "destroyVlc()");

    int status = PC_SUCCESS;

    if( vlcInstance != NULL )
        libvlc_release( vlcInstance );

    return status;
}

int playStream( const char *name )
{
    TRACE_2( VLCMANAGER , "playStream( %s )" , name );

    int status = PC_SUCCESS;

    libvlc_vlm_play_media( vlcInstance , name );

    return status;
}

int pauseStream( const char *name )
{
    TRACE_2( VLCMANAGER , "pauseStream( %s )" , name );

    int status = PC_SUCCESS;

    libvlc_vlm_pause_media( vlcInstance , name );

    return status;
}
