#ifndef CGAUTHENTICATIONTHREAD_H
#define CGAUTHENTICATIONTHREAD_H
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

enum WEB_API_AUTHENTICATE_STATES
{
    WEB_API_DISCONNECTED = 0,
    WEB_API_REQUESTING,
    WEB_API_RECIEVED,
    WEB_API_WAITING_REPLY,
    WEB_API_FINISHED
};


class CGWebAuthenticator : public QObject
{
    Q_OBJECT
public:
    CGWebAuthenticator(QObject *parent, QString name, QString password);
    QByteArray hashUserData(QString name, QString pass);
    ~CGWebAuthenticator();

signals:
    void checkingConnection();
    void connectedCGWeb();
    void userAuthenticated(QString user, QString email, bool premium, QString color_light, QString color_dark, QString avatar);
    void userDeniedDoesNotExist();
    void userDeniedNetworkError();
    void userDeniedPasswordError(QString username, QString avatar_url);
    void onExit();

public slots:
    void startVerification();

private:
    // Members
    QString m_name;
    QString m_password;
    WEB_API_AUTHENTICATE_STATES m_state;
    WEB_API_AUTHENTICATE_STATES m_task;
    bool    m_running;
    QString m_urlCGApi;
    QNetworkAccessManager  * m_accessManager;

    //Methods

    // SENDER methods
    void attemptConnect();
    void sendAuthenticationRequest();

    //RECIEVER methods
    void handleConnectionReply(QNetworkReply * reply);
    void handleAuthenticationReply(QNetworkReply * reply);
    bool isAuthenticated(QByteArray & user_data);

private slots:
    void  replyFinished(QNetworkReply* reply);


};

#endif // CGAUTHENTICATIONTHREAD_H
