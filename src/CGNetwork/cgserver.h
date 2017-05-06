#ifndef CGSERVER_H
#define CGSERVER_H

#include <QObject>
#include <QWebSocket>
#include "cgnetwork.h"


class CGServer : public QObject
{
    Q_OBJECT
public:
    explicit CGServer(QObject *parent = 0);
    ~CGServer();
    static CGServer* globalServer();

signals:
    void connectedToHost();
    void disconnectedFromServer(int reason = 0);
    void userProfileData(QString &data);
    void deniedUserCredentials();
    void userRegistered();
    void userDeniedRegister(QString reason);
    void userLoggedIn();
    void userLoggedOut();
    void setUserData();
    void failedToSetUserData();

    void lobbyStartedMatchmaking(int type);
    void lobbyFoundMatch(QString  name, int elo, QString country, QString avatar, bool arewhite);


public slots:
    void connectToHost(QString address, int port);
    void connectToHost(QString url);
    void socketErrored(QAbstractSocket::SocketError err);
    void disconnectFromHost();
    void writeMessage(QByteArray message);

protected:
    QWebSocket  mSocket;

protected slots:
    void parseServerMessage(QByteArray message);
    void handleDisconnect();
};

#endif // CGSERVER_H
