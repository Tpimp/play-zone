#include "cgweb.h"
#include <QNetworkAccessManager>
#include <QQmlEngine>
#include <QCryptographicHash>
CGWeb::CGWeb(QQuickItem *parent):
    QQuickItem(parent), m_authenticator(nullptr)
{

}



void CGWeb::requestCGLoginVerify(QString name, QString password)
{
    m_authenticator = new CGWebAuthenticator();
    connect(m_authenticator, &CGWebAuthenticator::checkingConnection,
            this, &CGWeb::checkingConnection);
    connect(m_authenticator, &CGWebAuthenticator::connectedCGWeb,
            this, &CGWeb::connectedToCGWeb);
    connect(m_authenticator, &CGWebAuthenticator::userAuthenticated,
            this, &CGWeb::userCGVerified);
    connect(m_authenticator, &CGWebAuthenticator::userDeniedDoesNotExist,
            this, &CGWeb::userCGDeniedDoesNotExist);
    connect(m_authenticator, &CGWebAuthenticator::userDeniedPasswordError,
            this, &CGWeb::userCGDeniedPasswordError);
    connect(m_authenticator, &CGWebAuthenticator::onExit,
            this, &CGWeb::finishedVerification);
    m_authenticator->setCredentials(name,password);
    m_authenticator->startVerification();

}


void CGWeb::finishedVerification()
{
    disconnect(m_authenticator, &CGWebAuthenticator::checkingConnection,
            this, &CGWeb::checkingConnection);
    disconnect(m_authenticator, &CGWebAuthenticator::connectedCGWeb,
            this, &CGWeb::connectedToCGWeb);
    disconnect(m_authenticator, &CGWebAuthenticator::userAuthenticated,
            this, &CGWeb::userCGVerified);
    disconnect(m_authenticator, &CGWebAuthenticator::userDeniedDoesNotExist,
            this, &CGWeb::userCGDeniedDoesNotExist);
    disconnect(m_authenticator, &CGWebAuthenticator::userDeniedPasswordError,
            this, &CGWeb::userCGDeniedPasswordError);
    disconnect(m_authenticator, &CGWebAuthenticator::onExit,
            this, &CGWeb::finishedVerification);
    m_authenticator = nullptr;
    emit disconnectedFromCGWeb();

}


CGWeb::~CGWeb()
{
}
