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
signals:
    void connectedToHost();
    void disconnectedFromServer();
    void userProfileData(QString data);
    void deniedUserCredentials();
    void userLoggedIn();
    void userLoggedOut();


public slots:
    void connectToHost(QString address, int port);
    void socketErrored(QAbstractSocket::SocketError err);
    void disconnectFromHost();
    void writeMessage(QByteArray message);

protected:
    QWebSocket  mSocket;

protected slots:
    void parseServerMessage(QByteArray message);
};

Q_GLOBAL_STATIC(CGServer, CG_SERVER_S)

#endif // CGSERVER_H
