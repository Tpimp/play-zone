#ifndef CGPROFILE_H
#define CGPROFILE_H

#include <QQuickItem>
#include "cgserver.h"

class CGProfile : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGProfile)
public:
    CGProfile(QQuickItem * parent = nullptr);
    ~CGProfile();
signals:

public slots:

protected:
    CGServer  *mServer;
};

#endif // CGPROFILE_H
