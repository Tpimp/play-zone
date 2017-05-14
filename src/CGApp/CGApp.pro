include(../../defaults.pri)
TEMPLATE = lib
TARGET = CGApp
QT += qml quick
CONFIG += plugin c++11

win32:TARGET = $$qtLibraryTarget($$TARGET)
win64:TARGET = $$qtLibraryTarget($$TARGET)
unix!mac:TARGET = $$qtLibraryTarget($$TARGET)
mac:TARGET = $$replace(TARGET,"lib","")
uri = com.chessgames.app

# Input
SOURCES += \
    cgapp_plugin.cpp \
    cgchessgames.cpp

HEADERS += \
    cgapp_plugin.h \
    cgchessgames.h

DISTFILES = qmldir

CONFIG(debug, debug|release) {
    buildtype = debug
} else {
    buildtype = release
}

path_to_deploy = $$clean_path( $$_PRO_FILE_PWD_/../../app/chessgames )
#message(deploying CGApp plugin to $$path_to_deploy/plugins/com/chessgames/app/ )

win32:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/$${buildtype}/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/app/)

win64:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/$${buildtype}/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/app/)

unix:!mac:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/*.so) $$shell_path($$path_to_deploy/plugins/com/chessgames/app/)

mac:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/*.dylib) $$shell_path($$path_to_deploy/plugins/com/chessgames/app/)


first.depends = $(first) copydata
export(first.depends)
export(copydata.commands)
QMAKE_EXTRA_TARGETS += first copydata

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$shell_path($$path_to_deploy/plugins/com/chessgames/app/qmldir)
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

win32:QMAKE_CLEAN += /s /f /q -r $$shell_path($$path_to_deploy/plugins/com/chessgames/app/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/app/qmldir)
win64:QMAKE_CLEAN += /s /f /q -Rr $$shell_path($$path_to_deploy/plugins/com/chessgames/app/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/app/qmldir)
unix:!mac:QMAKE_CLEAN += $$shell_path($$path_to_deploy/plugins/com/chessgames/app/*)


RESOURCES += \
    qml.qrc \
    images.qrc \
    fonts.qrc
