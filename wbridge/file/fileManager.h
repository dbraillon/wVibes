#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "utils/trace.h"
#include "utils/types.h"
#include "vlc/vlcManager.h"


int createFile( void );
int writeFile( void *data );

#endif // FILEMANAGER_H
