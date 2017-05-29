TEMPLATE = subdirs

SUBDIRS =   src/CGWeb \
            src/CGNetwork \
            src/CGApp \
            src/CGFlags \
            src/CGEngine \
            src/CGAvatars \
            app \

app.depends = src/CGWeb \
            src/CGNetwork \
            src/CGFlags \
            src/CGAvatars \
            src/CGEngine \
            src/CGApp


