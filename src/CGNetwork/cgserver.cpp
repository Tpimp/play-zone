#include "cgserver.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDataStream>
#include <QJsonArray>
//Q_DECLARE_METATYPE(QAbstractSocket::SocketError)


Q_GLOBAL_STATIC(CGServer, CG_SERVER_S)
CGServer::CGServer(QObject *parent) : QObject(parent)
{
    mSocket.setReadBufferSize(4964000000);
    //qRegisterMetaType(QAbstractSocket::SocketError);
    connect(&mSocket, &QWebSocket::connected, this, &CGServer::connectedToHost);
    connect(&mSocket, static_cast<void(QWebSocket::*)(QAbstractSocket::SocketError)>(&QWebSocket::error),
            this, &CGServer::socketErrored);
    connect(&mSocket, &QWebSocket::disconnected, this, &CGServer::handleDisconnect);
    connect(&mSocket, &QWebSocket::binaryMessageReceived, this, &CGServer::parseServerMessage);

}

CGServer* CGServer::globalServer()
{
    return CG_SERVER_S;
}

void CGServer::connectToHost(QString address, int port)
{
    // do connection stuff
    QString url("ws://");
    url.append(address);
    url.append(":");
    url.append(QString::number(port));
    mSocket.open(QUrl(url));

}
void CGServer::connectToHost(QString url)
{
    mSocket.open(QUrl(url));
}
void CGServer::disconnectFromHost()
{
    mSocket.close();
}


void CGServer::handleDisconnect()
{
    emit disconnectedFromServer(0);
}



void CGServer::parseServerMessage(QByteArray message)
{
    QJsonDocument doc = QJsonDocument::fromBinaryData(message);
    QJsonObject obj = doc.object();
    // parse the message
    int target = obj["T"].toInt();
    QJsonArray params = obj["P"].toArray();
    // determine the function and paramaters needed
    switch(target)
    {
        case VERIFY_USER:{ // Game
            CG_User data;
            if(params.count() < 1){ // bad message
                qDebug() << "Error receiving User Verification";
                Q_ASSERT(params.count() < 1);
            }

            bool    verified = params.at(0).toBool();
            if(verified){
                QJsonDocument param = QJsonDocument::fromJson(params.at(1).toString().toLocal8Bit());
                QJsonObject plyr = param.object();
                quint32 id = quint32(plyr.value("id").toInt());
                int elo = plyr.value("elo").toInt();
                QString profile_data = plyr.value("data").toString();
                QString country = plyr.value("country").toString();
                QString last = plyr.value("last").toString();

                emit userProfileData(id,elo,country, profile_data,last);
                emit userLoggedIn();
            }
            else{
                emit deniedUserCredentials();
            }
            break;
        }
        case REGISTER_USER:{
            bool    added = params.at(0).toBool();
            if(added){
                emit userRegistered();
            }
            else{
                emit userDeniedRegister("User exists");
            }
            break;
        }
        case MATCHED_PLAYER:{
            QString player_data = params.at(0).toString();
            QJsonDocument doc = QJsonDocument::fromJson(player_data.toLocal8Bit());
            QJsonObject obj = doc.object();
            QString name = obj.value("name").toString();
            int elo = obj.value("elo").toInt();
            bool color = obj.value("color").toBool();
            QString country = obj.value("flag").toString();
            QString avatar = obj.value("avatar").toString();
            emit lobbyFoundMatch(name,elo,country,avatar,color);
        }
        case SET_USER_DATA:{
            bool    set = params.at(0).toBool();
            if(set){
                emit setUserData();
            }
            else{
                emit failedToSetUserData();
            }
            break;
        }
        default: break;
    }

}


void CGServer::socketErrored(QAbstractSocket::SocketError err)
{
    qDebug() << "Server socket errored "<< mSocket.errorString();
    emit disconnectedFromServer(3);
}


void CGServer::writeMessage(QByteArray message)
{
    mSocket.sendBinaryMessage(message);
}

CGServer::~CGServer()
{

}
