include(../defaults.pri)
SRC_DIR = $$PWD

TEMPLATE = app
QT += qml quick
CONFIG += c++11

SOURCES += main.cpp \
    applicationloader.cpp \
    updateserverinterface.cpp
HEADERS += applicationloader.h\
    updateserverinterface.h

CONFIG(debug, debug|release) {
    buildtype = debug
} else {
    buildtype = release
}
win32:path_to_deploy = $$clean_path( $$OUT_PWD/$${buildtype}/chessgames )
win64:path_to_deploy = $$clean_path( $$OUT_PWD/$${buildtype}/chessgames )
unix:path_to_deploy = $$clean_path( $$OUT_PWD )
copydata.commands = $(COPY_DIR) $$shell_path($$_PRO_FILE_PWD_/chessgames) $$shell_path($$path_to_deploy)
first.depends = $(first) copydata
export(first.depends)
export(copydata.commands)
QMAKE_EXTRA_TARGETS += first copydata

TARGET = play-zone

# Additional import path used to resolve QML modules in Qt Creator's code model
#QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
#QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
#DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

#CONFIG(debug, debug|release) {
#    buildtype = debug
#} else {
#    buildtype = release
#}

#copydata.commands = $(COPY_DIR) $$shell_path($$PWD/chessgames) $$shell_path($$OUT_PWD/$${buildtype}/chessgames)
#first.depends = $(first) copydata
#export(first.depends)
#export(copydata.commands)
#QMAKE_EXTRA_TARGETS += first copydata


# Default rules for deployment.

DISTFILES += \
    chessgames/chessgames.JSON

RESOURCES +=


unix:QMAKE_CLEAN += path_to_deploy
