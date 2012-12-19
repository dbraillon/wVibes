#include "searchManager.h"

static void searchComplete( sp_search *search , void *userdata );

void search( sp_session *session , char *query )
{
    TRACE_2( SEARCHMANAGER , "search( __session__ , %s )." , query );

    pthread_mutex_lock( &mutexSession );

    sp_search_create( session , query , 0 , 100 , 0 , 100 , 0 , 100 , 0 , 100 , SP_SEARCH_STANDARD , &searchComplete , NULL );

    pthread_mutex_unlock( &mutexSession );
}

static void searchComplete( sp_search *search , void *userdata )
{
    TRACE_2( SEARCHMANAGER , "searchComplete()");

    int i = 0;
    int j = 0;
    int k = 0;
    int trackDur;
    int searchCount;
    int sizeToBeSend;

    char duration[32];
    char start[] = "<results>";
    char stop[] = "</results>";
    char *toBeSend;

    sp_track *currentTrack;
    sp_artist *currentArtist;
    sp_album *currentAlbum;

//    pthread_mutex_lock( &mutexSession );

    if( sp_search_error( search ) == SP_ERROR_OK )
    {
        TRACE_3( SEARCHMANAGER , "Query: %s" , sp_search_query( search ) );

        searchCount = sp_search_num_tracks( search );

        sizeToBeSend = 512 * searchCount;

        toBeSend = ( char * )malloc( sizeToBeSend );

        memset( toBeSend , 0 , sizeToBeSend );

        strcat( toBeSend , start );

        for( i = 0 ; i <  searchCount ; i++ )
        {
            currentTrack = sp_search_track( search , i );
            currentArtist = sp_search_artist( search , j );
            currentAlbum = sp_search_album( search , k );

            if( ( currentTrack == NULL )
                    || ( currentArtist == NULL )
                    || ( currentAlbum == NULL ) )
            {
                TRACE_WARNING( SEARCHMANAGER , "currentTrack or currentArtist or currentAlbum is NULL.");

                continue;
            }

            trackDur = trackDuration( currentTrack );

            sprintf( duration , "%d" , trackDur );

            strcat( toBeSend , "<result><uri>");

            strcat( toBeSend , trackUri( currentTrack ) );
            strcat( toBeSend , "</uri><track>");
            strcat( toBeSend , printTrack( currentTrack ) );
            strcat( toBeSend , "</track><artist>");
            strcat( toBeSend , printArtist( currentArtist ) );
            strcat( toBeSend , "</artist><time>");
            strcat( toBeSend , duration );
            strcat( toBeSend , "</time><album>");
            strcat( toBeSend , printAlbum( currentAlbum ) );
            strcat( toBeSend , "</album>");

            strcat( toBeSend , "</result>");

            j++;
            k++;

        }

        strcat( toBeSend , stop );

        sendVoid( toBeSend , sizeToBeSend );

        free( toBeSend );
    }

    sp_search_release( search );

//    pthread_mutex_unlock( &mutexSession );
}

const char *printAlbum( sp_album *album )
{
    TRACE_2( SEARCHMANAGER , "printAlbum()");

//    pthread_mutex_lock( &mutexSession );

    const char *albumName;

    albumName = sp_album_name( album );

    TRACE_3( SEARCHMANAGER , "Album:\t\t %s" , albumName );

//    pthread_mutex_unlock( &mutexSession );

    return albumName;
}

const char *printArtist( sp_artist *artist )
{
    TRACE_2( SEARCHMANAGER , "printArtist()");

//    pthread_mutex_lock( &mutexSession );

    const char *artistName;

    artistName = sp_artist_name( artist );

    TRACE_3( SEARCHMANAGER , "Artist:\t\t %s" , artistName );

//    pthread_mutex_unlock( &mutexSession );

    return artistName;
}

const char *printTrack( sp_track *track )
{
    TRACE_2( SEARCHMANAGER , "printTrack()");

//    pthread_mutex_lock( &mutexSession );

    const char *trackName;

    trackName = sp_track_name( track );

    TRACE_3( SEARCHMANAGER , "Track:\t\t %s" , trackName );

//    pthread_mutex_unlock( &mutexSession );

    return trackName;
}

int trackDuration( sp_track *track )
{
    TRACE_2( SEARCHMANAGER , "trackDuration()");

//    pthread_mutex_lock( &mutexSession );

    int duration = sp_track_duration( track );

//    pthread_mutex_unlock( &mutexSession );

    return duration;
}

char *trackUri( sp_track *track )
{
    TRACE_2( SEARCHMANAGER , "trackUri()");

//    pthread_mutex_lock( &mutexSession );

    char uri[255];

    memset( uri , 0 , 255 );

    sp_link_as_string( sp_link_create_from_track( track , 0 ) , uri , 255 );

//    pthread_mutex_unlock( &mutexSession );

    return uri;
}
