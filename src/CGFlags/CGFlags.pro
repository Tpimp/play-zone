include(../../defaults.pri)
TEMPLATE = lib
TARGET = CGFlags
QT += core gui qml quick
CONFIG += plugin c++11

TARGET = $$qtLibraryTarget($$TARGET)
uri = com.chessgames.CGFlags

# Input
SOURCES += \
    cgflags_plugin.cpp \
    cgflag.cpp \
    cgflagdata.cpp

HEADERS += \
    cgflags_plugin.h \
    cgflag.h \
    cgflagdata.h

DISTFILES = qmldir \
    CountryPicker.qml

CONFIG(debug, debug|release) {
    buildtype = debug
} else {
    buildtype = release
}

path_to_deploy = $$clean_path( $$_PRO_FILE_PWD_/../../app/chessgames )
message(deploying CGFlags plugin to $$path_to_deploy/plugins/com/chessgames/flags/ )

copydata.commands = $(COPY_FILE) $$shell_path($$OUT_PWD/$${buildtype}/*.dll) $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/)
first.depends = $(first) copydata
export(first.depends)
export(copydata.commands)
QMAKE_EXTRA_TARGETS += first copydata

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$shell_path($$path_to_deploy/plugins/com/chessgames/flags/qmldir)
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

RESOURCES += \
    flags.qrc
