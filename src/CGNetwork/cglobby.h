#ifndef CGLOBBY_H
#define CGLOBBY_H

#include <QQuickItem>
#include "cgserver.h"
class CGLobby : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGLobby)

public:
    CGLobby(QQuickItem *parent = 0);
    ~CGLobby();

protected:
    CGServer*   mServer;
};

#endif // CGLOBBY_H
