TEMPLATE = app
CONFIG += console
CONFIG -= qt

SOURCES += main.c \
    audio.c \
    alsa-audio.c

unix:!macx:!symbian: LIBS += -lasound

target.path = /home/pi/Development
INSTALLS += target

HEADERS += \
    queue.h \
    audio.h
