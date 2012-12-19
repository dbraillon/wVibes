#include <stdio.h>
#include <stdlib.h>

#include "spotify/spotifyManager.h"
#include "utils/types.h"

int main( void )
{

    if( launchSpotifyManager() == CONNECTION_ERROR )
    {
        TRACE_ERROR( SPOTIFYMANAGER , "Connection to Spotify failed.");

        return PC_ERROR;
    }

    printf("\n");
    return 0;
}

