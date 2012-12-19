#ifndef VLCMANAGER_H
#define VLCMANAGER_H

#include <stdlib.h>
#include <stdio.h>
#include <vlc/vlc.h>

#include "utils/trace.h"
#include "utils/types.h"

int streamFile( const char *filename );
int destroyVlc( void );
int playStream( const char *name );
int pauseStream( const char *name );

#endif // VLCMANAGER_H
