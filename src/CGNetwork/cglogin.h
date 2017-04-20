#ifndef CGLOGIN_H
#define CGLOGIN_H

#include <QQuickItem>
#include "cgserver.h"
class CGLogin : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGLogin)
public:
    CGLogin(QQuickItem* parent=nullptr);
    ~CGLogin();
signals:

public slots:

protected:
    CGServer*  mServer;

};

#endif // CGLOGIN_H
