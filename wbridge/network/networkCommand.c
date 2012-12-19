#include "networkCommand.h"

static networkCommand_t networkCmd[] =
{

    {"PLAYER#LOAD"       ,   &loadMusic      ,   NULL           },
    {"PLAYER#PLAY"       ,   &playMusic      ,   NULL           },
    {"PLAYER#PAUSE"      ,   &pauseMusic     ,   NULL           },
    {"SEARCH#BASIC"      ,   &search         ,   NULL           },
    {"SEARCH#ARTIST"     ,   &search         ,   "artist:"      },
    {"SEARCH#ALBUM"      ,   &search         ,   "album:"       },
    {"SEARCH#TRACK"      ,   &search         ,   "track:"       },
    {"SEARCH#WHATSNEW"   ,   &search         ,   "tag:new"      }
};


static int *searchAction( char *command , char *arg2 )
{
    TRACE_2( NETWORKCOMMAND , "searchAction( %s )." , command );

    int i = 0;

    for( i = 0 ; i < COUNT_COMMAND ; i++ )
    {
        if( strstr( command , networkCmd[i].command ) != NULL )
        {
            TRACE_1( NETWORKCOMMAND , "Command found, id: %d" , i );

            if( networkCmd[i].specificArg != NULL )
                memcpy( arg2 , networkCmd[i].specificArg , strlen( networkCmd[i].specificArg ) );

            return networkCmd[i].executeCommand;
        }
    }

    return -1;
}


void doAction( char *command )
{
    TRACE_2( NETWORKCOMMAND , "doAction( %s )." , command );

    char query[MAX_QUERY_LENGTH];

    char *arg = strrchr( command , '#' );
    char arg2[255];

    memset( query , 0 , MAX_QUERY_LENGTH );
    memset( arg2 , 0 , 255 );

    int ( *execute )( sp_session* , char* ) = searchAction( command , arg2 );

    if( *execute == -1 )
    {
        TRACE_ERROR( NETWORKCOMMAND , "Command is not supported.");

        return;
    }

    if( arg2[0] != 0 )
    {
        strcat( query , arg2 );
        strcat( query , arg + 1 );
    }
    else
    {
        strcat( query , arg + 1 );
    }

    TRACE_1( NETWORKCOMMAND , "Execute query : %s" , query );

    execute( g_session , query );
}
