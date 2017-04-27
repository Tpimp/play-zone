#include "cgweb.h"
#include <QNetworkAccessManager>
#include <QQmlEngine>
#include <QCryptographicHash>
CGWeb::CGWeb(QQuickItem *parent):
    QQuickItem(parent),  m_authenticating(false), m_authenticator(this)
{
    connect(&m_authenticator, &CGWebAuthenticator::checkingConnection,
            this, &CGWeb::checkingConnection);
    connect(&m_authenticator, &CGWebAuthenticator::connectedCGWeb,
            this, &CGWeb::connectedToCGWeb);
    connect(&m_authenticator, &CGWebAuthenticator::userAuthenticated,
            this, &CGWeb::userCGVerified);
    connect(&m_authenticator, &CGWebAuthenticator::userDeniedDoesNotExist,
            this, &CGWeb::userCGDeniedDoesNotExist);
    connect(&m_authenticator, &CGWebAuthenticator::userDeniedPasswordError,
            this, &CGWeb::userCGDeniedPasswordError);
    connect(&m_authenticator, &CGWebAuthenticator::onExit,
            this, &CGWeb::finishedVerification);
}



void CGWeb::requestCGLoginVerify(QString name, QString password)
{

    if(m_authenticating)
        return;

    m_authenticating = true;
    m_authenticator.setCredentials(name,password);
    m_authenticator.startVerification();

}


void CGWeb::finishedVerification()
{
    m_authenticating = false;
    emit disconnectedFromCGWeb();

}


CGWeb::~CGWeb()
{
}
