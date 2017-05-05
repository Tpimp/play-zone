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
                QString data_str = params.at(1).toString();
                emit userProfileData(data_str);
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
