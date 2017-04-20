TEMPLATE = subdirs
CONFIG+=ordered
SUBDIRS =   src/CGWeb \
            src/CGNetwork \
            src/CGApp \
            app
app.depends = src/CGWeb \
            src/CGNetwork \
            src/CGApp
