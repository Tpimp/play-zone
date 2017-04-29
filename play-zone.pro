TEMPLATE = subdirs
CONFIG+=    ordered
SUBDIRS =   src/CGWeb \
            src/CGNetwork \
            src/CGApp \
            src/CGFlags \
            app \

app.depends = src/CGWeb \
            src/CGNetwork \
            src/CGFlags \
            src/CGApp
