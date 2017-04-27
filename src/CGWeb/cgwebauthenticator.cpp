#include "cgwebauthenticator.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QGuiApplication>
#include "json_definitions.h"
#include <QSslConfiguration>
CGWebAuthenticator::CGWebAuthenticator(QObject * parent)
    : QObject(parent), m_urlCGApi( "http://www.chessgames.com/perl/user_api"),
      m_state(WEB_API_DISCONNECTED), m_task(WEB_API_DISCONNECTED), m_running(true), m_accessManager(this)
{
    connect(&m_accessManager, &QNetworkAccessManager::finished,
            this, &CGWebAuthenticator::replyFinished);
}

void CGWebAuthenticator::attemptConnect()
{
    emit checkingConnection();
    QNetworkRequest request; // fill out request for get of API page
    request.setUrl(QUrl(m_urlCGApi));
    request.setRawHeader("User-Agent", "CG_PlayZone_C");
   // request.setSslConfiguration(QSslConfiguration::defaultConfiguration());
    qDebug() << "Beginning network request";
    QNetworkReply *reply = m_accessManager.get(request);
    if(reply->error()!= 0)
    {
        qDebug() << "Request Errored " << reply->errorString();
    }
    m_state = WEB_API_WAITING_REPLY;
    m_task = WEB_API_DISCONNECTED;

}



void CGWebAuthenticator::handleAuthenticationReply(QNetworkReply *reply)
{
    QByteArray data(reply->readAll());
    isAuthenticated(data);
    m_state = WEB_API_FINISHED;
}

void CGWebAuthenticator::handleConnectionReply(QNetworkReply *reply)
{
    if(reply->error() == QNetworkReply::NoError)
    {
        emit connectedCGWeb();
        m_state = WEB_API_REQUESTING;
    }
    else
    {
        qDebug() << "User denied reply" << reply->rawHeaderList();
        emit userDeniedNetworkError();
        m_state = WEB_API_FINISHED;
        m_running = false;
    }
}

void CGWebAuthenticator::startVerification()
{
    qDebug() << "Starting authentication with " << m_name << " @ " << m_password;
    sendAuthenticationRequest();
}

bool CGWebAuthenticator::isAuthenticated(QByteArray &user_data)
{
    QJsonDocument doc;
    QJsonParseError error;
    doc = QJsonDocument::fromJson(user_data,&error);
    if((error.error > 0) && !error.errorString().isEmpty())
    {
        qDebug() << "Authentication parse error: \n" << error.errorString();
        return false;
    }
    QJsonObject obj;
    obj = doc.object();
    if(obj.contains(CGWEBERROR_ELEMENT))
    {
        if(obj[CGWEBERROR_ELEMENT].toInt() !=  0)
        {
            int error_value(obj[CGWEBERROR_ELEMENT].toInt());
            if(error_value == 1)
            {
                qDebug() << "Chess Games Web API Error. Please report to Play Zone developers.";
            }
            else if(error_value == 2)
            {
                emit userDeniedDoesNotExist();
            }
            else
            {
                if(obj.contains(CGUSERNAME_ELEMENT))
                    m_name = obj[CGUSERNAME_ELEMENT].toString();
                QString avatar;
                if(obj.contains(CGAVATAR_ELEMENT))
                    avatar = obj[CGAVATAR_ELEMENT].toString();
                emit userDeniedPasswordError(m_name,avatar);
            }
        }
        else // received the goods
        {
            QJsonObject user_obj;
            if(obj.contains("user"))
            {
                user_obj = obj[CGUSER_ELEMENT].toObject();
                bool premium(false);
                if(user_obj.contains(CGPREMIUM_ELEMENT))
                    premium = user_obj[CGPREMIUM_ELEMENT].toInt() == 1;
                if(user_obj.contains(CGPREMIUM_ELEMENT))
                    m_name = user_obj[CGPREMIUM_ELEMENT].toString();
                QString avatar;
                if(user_obj.contains(CGAVATAR_ELEMENT))
                    avatar = user_obj[CGAVATAR_ELEMENT].toString();
                QString light_c;
                if(user_obj.contains(CGCLRLIGHT_ELEMENT))
                    light_c = user_obj[CGCLRLIGHT_ELEMENT].toString();
                QString dark_c;
                if(user_obj.contains(CGCLRDARK_ELEMENT))
                    dark_c = user_obj[CGCLRDARK_ELEMENT].toString();
                QString email;
                if(user_obj.contains(USREMAIL_ELEMENT))
                    email = user_obj[USREMAIL_ELEMENT].toString();
                emit userAuthenticated(m_name,email,premium,light_c,dark_c,avatar);
                return true;
            }
        }
    }
    return false;
}

void CGWebAuthenticator::replyFinished(QNetworkReply *reply){
    switch(m_task)
    {
        case WEB_API_DISCONNECTED:{handleConnectionReply(reply); break;}
        case WEB_API_REQUESTING:{  handleAuthenticationReply(reply);break;}
        default: break;
    }
    switch(m_state)
    {
        case WEB_API_REQUESTING:{sendAuthenticationRequest();break;}
        case WEB_API_FINISHED:{
            qDebug() << "Exiting the CG Web Verification";
            emit onExit();
            break;
        }
        default: break;
    }
}

QByteArray CGWebAuthenticator::hashUserData(QString name, QString pass)
{
    QByteArray pre_hashed;
    pre_hashed.append(m_name.toUpper());
    pre_hashed.append(':');
    pre_hashed.append(m_password);
    QCryptographicHash hasher(QCryptographicHash::Sha256);
    hasher.addData(pre_hashed);
    return hasher.result().toHex();
}

void CGWebAuthenticator::sendAuthenticationRequest()
{
    //QNetworkRequest;
    // Generate password hash then continue with WEB_API authentication process.
    QByteArray hashed_data(hashUserData(m_name,m_password));
    QNetworkRequest request; // fill out request for get of API page

   // request.setSslConfiguration(QSslConfiguration::defaultConfiguration());
    request.setUrl(QUrl(m_urlCGApi));
    QUrlQuery postData;
    postData.addQueryItem("username",m_name);
    postData.addQueryItem("hashed_password",hashed_data);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded");


    request.setRawHeader("User-Agent", "CG_PlayZone_C");
    // build the raw header
    qDebug() << "Raw Header: " << request.rawHeaderList();
    QNetworkReply *reply = m_accessManager.post(request, postData.toString(QUrl::FullyEncoded).toUtf8());
    if(reply->error()!= 0)
    {
        qDebug() << "Request Errored " << reply->errorString();
    }

    m_state = WEB_API_WAITING_REPLY;
    m_task = WEB_API_REQUESTING;
}

void CGWebAuthenticator::setCredentials(QString name, QString password)
{
    m_name = name;
    m_password = password;
}

CGWebAuthenticator::~CGWebAuthenticator()
{
}
