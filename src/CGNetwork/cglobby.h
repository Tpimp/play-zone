#ifndef CGLOBBY_H
#define CGLOBBY_H

#include <QQuickItem>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
class CGServer;
class CGLobby : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGLobby)

public:
    CGLobby(QQuickItem *parent = 0);

    ~CGLobby();

signals:
    void matchedWithPlayer(QJsonObject opponent);

public slots:
   void lobbyMessage(QString lobby, QString message);
   void joinMatchMaking(int type);
   void matchedPlayer(QString name, int elo, QString country, QString avatar, bool color, int id);

protected:
    CGServer*   mServer;
};

#endif // CGLOBBY_H
