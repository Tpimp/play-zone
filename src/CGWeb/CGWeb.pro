include(../../defaults.pri)
TEMPLATE = lib
TARGET = CGWeb
QT += core qml quick network
CONFIG += plugin c++11

win32:CONFIG += win
win64:CONFIG += win

win:TARGET = $$qtLibraryTarget($$TARGET)
unix:!mac:TARGET = $$qtLibraryTarget($$TARGET)
mac:TARGET = $$replace(TARGET,"lib","")
uri = com.chessgames.web



# Input
SOURCES += cgweb_plugin.cpp \
    cgweb.cpp \
    cgwebauthenticator.cpp

HEADERS += \
    cgweb_plugin.h \
    cgweb.h \
    json_definitions.h \
    cgwebauthenticator.h

DISTFILES = qmldir

CONFIG(debug, debug|release) {
    buildtype = debug
} else {
    buildtype = release
}

path_to_deploy = $$clean_path( $$_PRO_FILE_PWD_/../../app/chessgames )
#message(deploying CGWeb plugin to $$path_to_deploy/plugins/com/chessgames/web/ )

win:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/$${buildtype}/CGWebd.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/web/CGWeb.dll)
unix:!mac:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/*.so) $$shell_path($$path_to_deploy/plugins/com/chessgames/web/)
mac:copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/*.dylib) $$shell_path($$path_to_deploy/plugins/com/chessgames/web/)

first.depends = $(first) copydata
export(first.depends)
export(copydata.commands)

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$shell_path($$path_to_deploy/plugins/com/chessgames/web/qmldir)
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    win:copy_qmldir.commands = $(MKDIR) -p $$shell_path($$path_to_deploy/plugins/com/chessgames/web) || $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    unix:copy_qmldir.commands = $(MKDIR) $$shell_path($$path_to_deploy/plugins/com/chessgames/web) && $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
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

win:QMAKE_CLEAN += /s /f /q -r $$shell_path($$path_to_deploy/plugins/com/chessgames/web/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/web/qmldir)
unix:QMAKE_CLEAN += $$shell_path($$path_to_deploy/plugins/com/chessgames/web/*)
