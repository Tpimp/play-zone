#ifndef CGLOGIN_H
#define CGLOGIN_H

#include <QQuickItem>
#include "cgserver.h"
class CGLogin : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGLogin)
public:
    CGLogin(QQuickItem* parent=nullptr);
    ~CGLogin();
signals:
    void readyForLogin();
    void disconnectedFromServer();
    void failedToConnectToServer();
    void userCredentialsDenied();
    void userLoggedIn();
    void profileData(QString data);
public slots:
    void connectToServer(QString ip, int port);
    void sendAuthentication(QString name, QString password);

protected:
    CGServer*  mServer;
    QString     mUsername;

};

#endif // CGLOGIN_H
