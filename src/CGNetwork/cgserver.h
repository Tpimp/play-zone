#ifndef CGSERVER_H
#define CGSERVER_H

#include <QObject>
#include <QWebSocket>
#include "cgnetwork.h"
#include <QJsonDocument>
#include <QJsonObject>
#include "cgprofile.h"
#include <QBasicTimer>

class CGServer : public QObject
{
    Q_OBJECT
public:
    explicit CGServer(QObject *parent = 0);
    ~CGServer();
    static CGServer* globalServer();void loginToServer(QString name, QByteArray hashed_password);
    void registerToServer(QString name, QByteArray password, QString email, QString data);
    Q_INVOKABLE void setConnectionString(QString ip, int port);
    bool connected();
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
    void setUserRecent(QString recent);
    void setProfileData(QString data);
//    void failedToSetUserData();
    void refreshUserData(QString user);

    // lobby
    void lobbyStartedMatchmaking(int type);
    void lobbyFoundMatch(QJsonObject opponent);

    // game related
    void opponentMoved(QJsonObject move);
    void gameSynchronized(int state, quint64 time);
    void gameFinished(QJsonObject  game_result);
    void recievedDrawResponse(int response);
    void currentPing(quint64 ping);

public slots:
    void connectToHost(QString address, int port);
    void connectToHost();
    void socketErrored(QAbstractSocket::SocketError err);
    void disconnectFromHost();
    void writeMessage(QByteArray message);
    void updateProfile(QJsonObject data);
    void pongReceived(quint64 time, const QByteArray &message);
    void timerEvent(QTimerEvent *event);
protected:
    QWebSocket  mSocket;
    QString     mConnectionName;
    QByteArray  mHashedPassword;
    QString     mConnectionEmail;
    QString     mConnectionString;
    QString     mConnectionData;
    QBasicTimer mHeartBeat;
    quint64     mLatency;
    bool        mConnected;
    void connectToLogin();
    void connectToRegister();

protected slots:
    void parseServerMessage(QByteArray message);
    void handleDisconnect();
    void loginWithCredentials();
    void registerWithCredentials();
};

#endif // CGSERVER_H
