#ifndef PLAYLISTMANAGER_H
#define PLAYLISTMANAGER_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <libspotify/api.h>

#include "utils/types.h"
#include "utils/trace.h"

void tracks_added( sp_playlist *pl , sp_track *const *tracks , int num_tracks , int position , void *userdata );
void tracks_moved( sp_playlist *pl , const int *tracks , int num_tracks , int new_position , void *userdata );
void tracks_removed( sp_playlist *pl , const int *tracks , int num_tracks , void *userdata );
void playlist_metadata_updated( sp_playlist *pl , void *userdata );

int getPlaylistContainer( sp_session *session );
int createPlaylist( const char *name );
int addTracksMainPlaylist( sp_session *session , sp_track *track );
sp_track *getNextTrack( void );

#endif // PLAYLISTMANAGER_H
