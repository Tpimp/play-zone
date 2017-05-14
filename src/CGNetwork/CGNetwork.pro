include(../../defaults.pri)
TEMPLATE = lib
TARGET = CGNetwork
QT += qml quick network websockets
CONFIG += plugin c++11

win32:TARGET = $$qtLibraryTarget($$TARGET)
win64:TARGET = $$qtLibraryTarget($$TARGET)
unix:!mac:TARGET = $$qtLibraryTarget($$TARGET)
mac:TARGET = $$replace(TARGET,"lib","")

uri = com.cheesgames.network

# Input
SOURCES += \
    cgnetwork_plugin.cpp \
    cglobby.cpp \
    cggame.cpp \
    cglogin.cpp \
    cgprofile.cpp \
    cgserver.cpp \
    cgnetwork.cpp

HEADERS += \
    cgnetwork_plugin.h \
    cglobby.h \
    cggame.h \
    cglogin.h \
    cgprofile.h \
    cgserver.h \
    cgnetwork.h

DISTFILES = qmldir

CONFIG(debug, debug|release) {
    buildtype = debug
} else {
    buildtype = release
}

path_to_deploy = $$clean_path( $$_PRO_FILE_PWD_/../../app/chessgames )
#message(deploying CGNetwork plugin to $$path_to_deploy/plugins/com/chessgames/network/ )


win32:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/$${buildtype}/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/network/)
win64:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/$${buildtype}/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/network/)
unix:!mac:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/*.so) $$shell_path($$path_to_deploy/plugins/com/chessgames/network/)
mac:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/*.dylib) $$shell_path($$path_to_deploy/plugins/com/chessgames/network/)


first.depends = $(first) copydata
export(first.depends)
export(copydata.commands)
QMAKE_EXTRA_TARGETS += first copydata

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$shell_path($$path_to_deploy/plugins/com/chessgames/network/qmldir)
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
unix {
    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}

win32:QMAKE_CLEAN += /s /f /q -r $$shell_path($$path_to_deploy/plugins/com/chessgames/network/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/network/qmldir)
win64:QMAKE_CLEAN += /s /f /q -r $$shell_path($$path_to_deploy/plugins/com/chessgames/network/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/network/qmldir)
unix:!mac:QMAKE_CLEAN += $$shell_path($$path_to_deploy/plugins/com/chessgames/network/*)


RESOURCES += \
    qml.qrc