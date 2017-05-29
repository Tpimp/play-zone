#ifndef CGSERVER_H
#define CGSERVER_H

#include <QObject>
#include <QWebSocket>
#include "cgnetwork.h"
#include <QJsonDocument>
#include <QJsonObject>


class CGServer : public QObject
{
    Q_OBJECT
public:
    explicit CGServer(QObject *parent = 0);
    ~CGServer();
    static CGServer* globalServer();

signals:
    // Login
    void connectedToHost();
    void disconnectedFromServer(int reason = 0);
    void deniedUserCredentials();
    void userRegistered();
    void userDeniedRegister(QString reason);
    void userLoggedIn();
    void userLoggedOut();
    // Profile
    void userProfileData(QString &data, QString &last);
    void setUserData(QString &data, QString &last);
    void failedToSetUserData();
    // lobby
    void lobbyStartedMatchmaking(int type);
    void lobbyFoundMatch(QJsonObject opponent);

    // game related
    void opponentMoved(QJsonObject move);
    void gameSynchronized(int state);
    void gameFinished(int result, QJsonObject move, QString fen, QString last);

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
