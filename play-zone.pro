TEMPLATE = subdirs
CONFIG+=    ordered
SUBDIRS =   src/CGWeb \
            src/CGNetwork \
            src/CGApp \
            src/CGFlags \
            src/CGEngine \
            app \

app.depends = src/CGWeb \
            src/CGNetwork \
            src/CGFlags \
            src/CGEngine \
            src/CGApp


