#include "spotifyManager.h"

static sp_session_callbacks spSessionCallbacks;


static void notify_main_thread( sp_session *session );
static void log_message( sp_session *session , const char *data );
static int initPlaylist( void );

int launchSpotifyManager( void )
{
    TRACE_2( SPOTIFYMANAGER , "launchSpotifyManager()");

    sp_session_config spconfig;
    sp_error error;

    int next_timeout = 0;

    memset( &spconfig , 0 , sizeof( spconfig ) );
    memset( &spSessionCallbacks , 0 , sizeof( spSessionCallbacks ) );

    spSessionCallbacks.logged_in = &logged_in;
    spSessionCallbacks.notify_main_thread = &notify_main_thread;
    spSessionCallbacks.end_of_track = &end_of_track;
    spSessionCallbacks.music_delivery = &music_delivery;
    spSessionCallbacks.metadata_updated = &metadata_updated;

    spconfig.api_version = SPOTIFY_API_VERSION;
    spconfig.cache_location = "/home/raphio/tmp";
    spconfig.settings_location = "/home/raphio/tmp";
    spconfig.application_key = g_appkey;
    spconfig.application_key_size = g_appkey_size;
    spconfig.user_agent = "wmusic";
    spconfig.callbacks = &spSessionCallbacks;

    error = sp_session_create( &spconfig , &g_session );

    if( error != SP_ERROR_OK )
    {
        TRACE_ERROR( SPOTIFYMANAGER , "Fail to create session, reason: %s" , sp_error_message( error ) );
    }
    else
    {
        TRACE_2( SPOTIFYMANAGER , "Success to create session");
    }

    if( g_session != NULL )
    {
        if( signin( g_session , USERNAME , PASSWORD ) == CONNECTION_OK )
        {
            launchServer();
            initPlaylist();

            running = 1;
            playing = 0;

            while( running )
            {
                pthread_mutex_lock( &mutexSession );

                sp_session_process_events( g_session , &next_timeout );

                pthread_mutex_unlock( &mutexSession );

                if( ( login == 1 ) && ( playing == 0 ) )
                {
                    TRACE_INFO( SPOTIFYMANAGER , "Ready to be used !");

                    TRACE_3( SPOTIFYMANAGER , "Let's play the music !");

                    playing = 1;
                }
            }
        }
        else
        {
            return CONNECTION_ERROR;
        }
    }

    return CONNECTION_OK;
}

static void notify_main_thread( sp_session *session )
{
    TRACE_2( SPOTIFYMANAGER , "notify_main_thread().");
}

static void log_message( sp_session *session , const char *data )
{
    TRACE_2( SPOTIFYMANAGER , "log_message().");
}

static int initPlaylist( void )
{
    TRACE_2( SPOTIFYMANAGER , "initPlaylist().");

    int status = PC_SUCCESS;

    if( getPlaylistContainer( g_session ) == PC_ERROR )
    {
        TRACE_ERROR( SPOTIFYMANAGER , "Fail to get the playlist container.");

        status = PC_ERROR;
    }
    else if( createPlaylist("mainPlaylist") == PC_ERROR )
    {
        TRACE_ERROR( SPOTIFYMANAGER , "Fail to create the playlist.");

        status = PC_ERROR;
    }
    else
    {
        TRACE_3( SPOTIFYMANAGER , "Success to initialize the playlist manager.");
    }

    return status;
}
