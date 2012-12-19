#include "playlistManager.h"

static sp_playlistcontainer *plc;
static sp_playlist *mainPlaylist;
static sp_session *currentSession;

static int countTrack = 0;

void tracks_added( sp_playlist *pl , sp_track *const *tracks , int num_tracks , int position , void *userdata )
{
    TRACE_2( PLAYLISTMANAGER , "track_added()");

    sp_playlist_add_tracks( pl , tracks , num_tracks , position , currentSession );

    countTrack++;
}

void tracks_moved( sp_playlist *pl , const int *tracks , int num_tracks , int new_position , void *userdata )
{
    TRACE_2( PLAYLISTMANAGER , "tracks_moved()");

    sp_playlist_reorder_tracks( pl , tracks , num_tracks , new_position );
}

void tracks_removed( sp_playlist *pl , const int *tracks , int num_tracks , void *userdata )
{
    TRACE_2( PLAYLISTMANAGER , "tracks_removed()");

    sp_playlist_remove_tracks( pl , tracks , num_tracks );

    countTrack--;
}

void playlist_metadata_updated( sp_playlist *pl , void *userdata )
{
    TRACE_2( PLAYLISTMANAGER , "playlist_metadata_updated()");
}

int getPlaylistContainer( sp_session *session )
{
    TRACE_2( PLAYLISTMANAGER , "getPlaylistContainer()");

    int status = PC_SUCCESS;

    pthread_mutex_lock( &mutexSession );

    plc = sp_session_playlistcontainer( session );

    if( plc == NULL )
    {
        TRACE_ERROR( PLAYLISTMANAGER , "Fail to retrieve the playlistcontainer.");

        status = PC_ERROR;
    }
    else
    {
        TRACE_3( PLAYLISTMANAGER , "Success to retrieve the playlistcontainer");

        currentSession = session;
    }

    pthread_mutex_unlock( &mutexSession );

    return status;
}

int createPlaylist( const char *name )
{
    TRACE_2( PLAYLISTMANAGER , "createPlaylist( %s )" , name );

    int status = PC_SUCCESS;

    pthread_mutex_lock( &mutexSession );

    mainPlaylist = sp_playlistcontainer_add_new_playlist( plc , name );

    if( mainPlaylist == NULL )
    {
        TRACE_ERROR( PLAYLISTMANAGER , "Fail to create the new playlist : %s" , name );

        status = PC_ERROR;
    }
    else
    {
        TRACE_3( PLAYLISTMANAGER , "Success to create the new playlist : %s" , name );
    }

    pthread_mutex_unlock( &mutexSession );

    return status;
}

int addTracksMainPlaylist( sp_session *session , sp_track *track )
{
    TRACE_2( PLAYLISTMANAGER , "addTracksMainPlaylist()");

    int status = PC_SUCCESS;

    sp_error error;

//    pthread_mutex_lock( &mutexSession );

    error = sp_playlist_add_tracks( mainPlaylist , &track , 1 , countTrack , session );

    if( error != SP_ERROR_OK )
    {
        TRACE_ERROR( PLAYLISTMANAGER , "Fail to add track to the main playlist : %s." , sp_error_message( error ) );

        status = PC_ERROR;
    }
    else
    {
        TRACE_3( PLAYLISTMANAGER , "Success to add track to the main playlist.");
    }

//    pthread_mutex_unlock( &mutexSession );


    countTrack++;

    return status;
}

sp_track *getNextTrack( void )
{
    TRACE_2( PLAYLISTMANAGER , "getNextTrack().");

    return sp_playlist_track( mainPlaylist , 0 );
}
