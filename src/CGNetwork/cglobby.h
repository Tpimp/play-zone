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

signals:
    void matchedWithAnotherPlayer(QString name, int elo, QString country, bool color);

public slots:
   void lobbyMessage(QString lobby, QString message);
   void joinMatchMaking(int type);

protected:
    CGServer*   mServer;
};

#endif // CGLOBBY_H
