#ifndef CGWEB_H
#define CGWEB_H

#include <QQuickItem>
#include <QString>
#include <QThread>
#include "cgwebauthenticator.h"
class QNetworkAccessManager;
class CGWeb : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGWeb)

public:
    CGWeb(QQuickItem *parent = 0);
    ~CGWeb();

public slots:
    void requestCGLoginVerify(QString name, QString password);

signals:
    void checkingConnection();
    void connectedToCGWeb();
    void userCGDeniedPasswordError();
    void userCGDeniedDoesNotExist();
    void userCGVerified(QString user, QString email, bool premium, QString color_light, QString color_dark, QString avatar);
    void disconnectedFromCGWeb();

protected:
    bool                     m_authenticating;
    // Methods
    QThread*                 m_thread;
    CGWebAuthenticator*      m_authenticator;
protected slots:
    void finishedVerification();

};

#endif // CGWEB_H
