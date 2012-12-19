#ifndef TYPES_H
#define TYPES_H

#include <pthread.h>

#define PC_SUCCESS  0
#define PC_ERROR    -1


pthread_mutex_t mutexSession;

enum accountManagerState
{
    INVALID_LOGIN_INFO,
    NOT_PRENIUM,
    CONNECTION_ERROR,
    CONNECTION_OK
};

enum searchManagerState
{
    SEARCH_ERROR,
    SEARCH_OK
};

typedef struct wav_hdr
{
        char                     RIFF[4];        // RIFF Header
        int                      ChunkSize;      // RIFF Chunk Size
        char                     WAVE[4];        // WAVE Header
        char                     fmt[4];         // FMT header
        int                      Subchunk1Size;  // Size of the fmt chunk
        short int                AudioFormat;    // Audio format 1=PCM,6=mulaw,7=alaw, 257=IBM Mu-Law, 258=IBM A-Law, 259=ADPCM
        short int                NumOfChan;      // Number of channels 1=Mono 2=Stereo
        int                      SamplesPerSec;  // Sampling Frequency in Hz
        int                      bytesPerSec;    // bytes per second */
        short int                blockAlign;     // 2=16-bit mono, 4=16-bit stereo
        short int                bitsPerSample;  // Number of bits per sample
        char                     Subchunk2ID[4]; // "data"  string
        int                      Subchunk2Size;  // Sampled data length
}wavHeader_t;

//struct wavfile
//{
//    char        id[4];          // should always contain "RIFF"
//    int         totallength;    // total file length minus 8
//    char        wavefmt[8];     // should be "WAVEfmt "
//    int         format;         // 16 for PCM format
//    short       pcm;            // 1 for PCM format
//    short       channels;       // channels
//    int         frequency;      // sampling frequency
//    int         bytes_per_second;
//    short       bytes_by_capture;
//    short       bits_per_sample;
//    char        data[4];        // should always contain "data"
//    int         bytes_in_data;
//};

#endif // TYPES_H
