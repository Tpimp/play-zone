#include "cgweb.h"
#include <QNetworkAccessManager>
#include <QQmlEngine>
#include <QCryptographicHash>
CGWeb::CGWeb(QQuickItem *parent):
    QQuickItem(parent), m_thread(nullptr),  m_authenticating(false)
{
    // By default, QQuickItem does not draw anything. If you subclass
    // QQuickItem to create a visual item, you will need to uncomment the
    // following line and re-implement updatePaintNode()

    // setFlag(ItemHasContents, true);
}



void CGWeb::requestCGLoginVerify(QString name, QString password)
{

    if(m_authenticating)
        return;
    m_thread = new QThread(this);

    m_authenticator = new CGWebAuthenticator( this, name, password);
    m_authenticator->moveToThread(m_thread);
    qDebug() << "Starting the Login Verification";

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
    m_authenticating = true;
    m_thread->start();
    m_authenticator->startVerification();

}


void CGWeb::finishedVerification()
{
    m_authenticating = false;
    emit disconnectedFromCGWeb();

}


CGWeb::~CGWeb()
{
    qDebug() <<"Closing CGWebApi";
    if(m_thread){
        m_thread->quit();
        m_thread->exit(0);
        m_thread->deleteLater();
    }
    if(m_authenticator){
        delete m_authenticator;
    }
}
