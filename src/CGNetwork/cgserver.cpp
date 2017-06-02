#include "cgserver.h"
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
    mSocket.close(QWebSocketProtocol::CloseCodeGoingAway,"Logout");
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
                QJsonArray plyr = param.array();
                QString profile_data = plyr.at(0).toString();
                QString last = plyr.at(1).toString();

                emit userProfileData( profile_data,last);
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
            QJsonObject player_data( params.at(0).toObject());
            /*
            QString name(obj.value("name").toString());
            int elo(obj.value("elo").toInt());
            bool color(obj.value("color").toBool());
            QString country(obj.value("flag").toString());
            QString avatar(obj.value("avatar").toString());
            quint64 game_id(obj.value("id").toDouble());*/
            emit lobbyFoundMatch(player_data);
        }
        case SEND_SYNC:{
            if(params.count() > 0){
                int state(params.at(0).toInt());
                emit gameSynchronized(state);
            }
            break;
        }
        case SEND_MOVE:{
            if(params.count() > 0){
                emit opponentMoved(params.at(0).toObject());
            }
            break;
        }
        case SEND_RESULT:{
            if(params.count() >= 1){
                QString result(params.at(0).toString());
                QJsonDocument doc = QJsonDocument::fromJson(result.toLocal8Bit());
                QJsonObject obj = doc.object();
                int resulti = obj.value("result").toInt();
                QJsonObject move = obj.value("move").toObject();
                QString fen = obj.value("fen").toString();
                QString last = obj.value("game").toString();
                emit gameFinished(resulti,move,fen,last);
            }
            break;
        }
        case SEND_DRAW:{
            if(params.count() >= 1){
                int response(params.at(0).toInt());
                emit recievedDrawResponse(response);
            }
            break;
        }
        case SET_USER_DATA:{
            if(params.count() > 0){
                QString user_data = params.at(0).toString();
                QString last;
                emit setUserData(user_data,last);
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
