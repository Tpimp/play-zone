#ifndef CGLOBBY_H
#define CGLOBBY_H

#include <QQuickItem>
class CGServer;
class CGLobby : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGLobby)

public:
    CGLobby(QQuickItem *parent = 0);
    ~CGLobby();


public slots:
   void lobbyMessage(QString lobby, QString message);

protected:
    CGServer*   mServer;
};

#endif // CGLOBBY_H
