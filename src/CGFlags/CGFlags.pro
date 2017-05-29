include(../../defaults.pri)
TEMPLATE = lib
TARGET = CGFlags
QT += core gui qml quick
CONFIG += plugin c++11

win32:TARGET = $$qtLibraryTarget($$TARGET)
win64:TARGET = $$qtLibraryTarget($$TARGET)
unix:!mac:TARGET = $$qtLibraryTarget($$TARGET)
mac:TARGET = $$replace(TARGET,"lib","")

uri = com.chessgames.flags

# Input
SOURCES += \
    cgflags_plugin.cpp \
    cgflag.cpp \
    cgflagdata.cpp

HEADERS += \
    cgflags_plugin.h \
    cgflag.h \
    cgflagdata.h

DISTFILES = qmldir

CONFIG(debug, debug|release) {
    buildtype = debug
} else {
    buildtype = release
}

path_to_deploy = $$clean_path( $$_PRO_FILE_PWD_/../../app/chessgames )
#message(deploying CGFlags plugin to $$path_to_deploy/plugins/com/chessgames/flags/ )

win32:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/$${buildtype}/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/)
win64:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/$${buildtype}/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/)
unix:!mac:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/*.so) $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/)
mac:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/*.dylib) $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/)



first.depends = $(first) copydata
export(first.depends)
export(copydata.commands)

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/qmldir)
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(MKDIR) $$shell_path($$path_to_deploy/plugins/com/chessgames/flags) && $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir first copydata
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
unix {
    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}


win32:QMAKE_CLEAN += /s /f /q -r $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/qmldir)
win64:QMAKE_CLEAN += /s /f /q -r $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/qmldir)
unix:QMAKE_CLEAN += $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/*)

RESOURCES += \
    flags.qrc
