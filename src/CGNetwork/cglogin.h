#ifndef CGLOGIN_H
#define CGLOGIN_H

#include <QQuickItem>
class CGServer;
class CGLogin : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGLogin)
public:
    CGLogin(QQuickItem* parent=nullptr);
    ~CGLogin();
    Q_INVOKABLE void setConnection(QString ip, int port);
signals:
    //server/socket information
    void serverReady();
    void disconnectedFromServer(int reason);
    void failedToConnectToServer();

    // login
    void userCredentialsDenied();
    void userLoggedIn();

    // user register
    void userDeniedRegister(QString reason);
    void userRegistered();

    //server
    void currentPing(quint64 ping);

public slots:
    void disconnectFromServer();
    void login(QString name, QString password);
    void attemptRegisterUser(QString name, QString password, QString email, QString data);

protected:
    CGServer*  mServer;
    QString    mConnectionString;
    int        mTries;

};

#endif // CGLOGIN_H
