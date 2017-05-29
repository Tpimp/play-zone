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
    Q_INVOKABLE QByteArray getPassword();
signals:
    void serverReady();
    void disconnectedFromServer(int reason);
    void failedToConnectToServer();
    void userCredentialsDenied();
    void userLoggedIn();
    void userDeniedRegister(QString reason);
    void userRegistered();
public slots:
    void disconnectFromServer();
    void setServerAddress(QString ip, int port);
    void login(QString name, QString password);
    void attemptRegisterUser(QString name, QString password, QString email);

protected:
    CGServer*  mServer;
    QString    mUsername;
    QByteArray mHashedPass;
    QString    mEmail;
    QString    mConnectionString;
    bool       mConnected;
    int        mTries;
protected slots:
    void       attemptRegistration();
    void       connectedToHost();
    void       loginToHost();

};

#endif // CGLOGIN_H
