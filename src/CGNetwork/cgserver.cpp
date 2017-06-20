#include "cgserver.h"
#include <QDataStream>
#include <QJsonArray>
//Q_DECLARE_METATYPE(QAbstractSocket::SocketError)


Q_GLOBAL_STATIC(CGServer, CG_SERVER_S)
CGServer::CGServer(QObject *parent) : QObject(parent),mConnected(false)
{
    mSocket.setReadBufferSize(4964000000);
    //qRegisterMetaType(QAbstractSocket::SocketError);

    connect(&mSocket, static_cast<void(QWebSocket::*)(QAbstractSocket::SocketError)>(&QWebSocket::error),
            this, &CGServer::socketErrored);
    connect(&mSocket, &QWebSocket::disconnected, this, &CGServer::handleDisconnect);
    connect(&mSocket, &QWebSocket::binaryMessageReceived, this, &CGServer::parseServerMessage);
    connect(&mSocket, &QWebSocket::pong, this, &CGServer::pongReceived );
}

CGServer* CGServer::globalServer()
{
    return CG_SERVER_S;
}
void CGServer::connectToLogin()
{
    disconnect(&mSocket,&QWebSocket::connected,0,0);
    connect(&mSocket, &QWebSocket::connected, this, &CGServer::loginWithCredentials);
    connectToHost();
}

void CGServer::connectToRegister()
{
    disconnect(&mSocket,&QWebSocket::connected,0,0);
    connect(&mSocket, &QWebSocket::connected, this, &CGServer::registerWithCredentials);
    connectToHost();
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
void CGServer::connectToHost()
{
    qDebug() << "Opening socket connection to host: " << mConnectionString;
    mSocket.open(QUrl(mConnectionString));
}

bool CGServer::connected()
{
    mHeartBeat.start(500,this);
    mConnected = true;
    return mConnected;
}

void CGServer::disconnectFromHost()
{
    mConnected = false;
    mSocket.close(QWebSocketProtocol::CloseCodeGoingAway,"Logout");
}



void CGServer::handleDisconnect()
{
    mConnected = false;
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

                emit setProfileData( profile_data);
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
            emit lobbyFoundMatch(player_data);
        }
        case SEND_SYNC:{
            if(params.count() > 0){
                int state(params.at(0).toInt());
                quint64 time(params.at(1).toDouble());
                emit gameSynchronized(state,time);
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
                emit refreshUserData(user_data);
            }
            else{
                //emit failedToSetUserData("");
            }
            break;
        }
        case REFRESH_USER_DATA:{
            if(params.count() >= 1){
                QString user_str = params.at(0).toString();
                QJsonDocument doc2 = QJsonDocument::fromJson(user_str.toLocal8Bit());
                QJsonArray data = doc2.array();
                QString user_data = data.at(0).toString();
                QString recent = data.at(1).toString();
                emit refreshUserData(user_data);
            }
        }
        default: break;
    }

}


void CGServer::pongReceived(quint64 time, const QByteArray &message)
{
    if(time>1500){
        mSocket.ping();
    }
    else{
        mHeartBeat.start(1500-time,this);
    }
    mLatency = time;
    emit currentPing(time);
}

void CGServer::timerEvent(QTimerEvent *event){
    QByteArray array = QByteArray::number(mLatency);
    mSocket.ping(array);
    mHeartBeat.stop();
}

void CGServer::updateProfile(QJsonObject data)
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SET_USER_DATA;
    // name, pass, data
    array.append(mConnectionName);
    QString str_pass = QString::fromLatin1(mHashedPassword,mHashedPassword.size());
    array.append(str_pass);
    array.append(data);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mSocket.sendBinaryMessage(output);
}

void CGServer::loginToServer(QString name, QByteArray hashed_password){
    mConnectionName = name;
    mHashedPassword = hashed_password;
    if(mConnected){
        QJsonObject obj;
        // type
        obj["T"] = VERIFY_USER;
        QJsonArray array;
        array.append(name);
        QString str_pass = QString::fromLatin1(mHashedPassword,mHashedPassword.size());
        array.append(str_pass);
        obj["P"] = array;
        QJsonDocument doc;
        doc.setObject(obj);
        QByteArray output = doc.toBinaryData();
        mSocket.sendBinaryMessage(output);
    }
    else{
        connectToLogin();
    }
}

void CGServer::registerToServer(QString name, QByteArray password, QString email, QString data)
{
    mConnectionName = name;
    mHashedPassword = password;
    mConnectionEmail = email;
    mConnectionData = data;
    if(mConnected){
        QJsonObject obj;
        obj["T"] = REGISTER_USER;
        QJsonArray array;
        array.append(name);
        QString str_pass = QString::fromLatin1(password,password.size());
        array.append(str_pass);
        array.append(email);
        array.append(data);
        obj["P"] = array;
        QJsonDocument doc;
        doc.setObject(obj);
        QByteArray output = doc.toBinaryData();
        mSocket.sendBinaryMessage(output);
    }
    else{
        connectToRegister();
    }
}

void CGServer::setConnectionString(QString ip, int port)
{
    QString url("ws://");
    url.append(ip);
    url.append(":");
    url.append(QString::number(port));
    mConnectionString = url;
}

void CGServer::loginWithCredentials()
{
    disconnect(&mSocket, &QWebSocket::connected, this, &CGServer::loginWithCredentials);
    connected();
    QJsonObject obj;
    // type
    obj["T"] = VERIFY_USER;
    QJsonArray array;
    array.append(mConnectionName);
    QString str_pass = QString::fromLatin1(mHashedPassword,mHashedPassword.size());
    array.append(str_pass);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mSocket.sendBinaryMessage(output);
}

void CGServer::registerWithCredentials()
{
    disconnect(&mSocket, &QWebSocket::connected, this, &CGServer::registerWithCredentials);
    connected();
    QJsonObject obj;
    obj["T"] = REGISTER_USER;
    QJsonArray array;
    array.append(mConnectionName);
    QString str_pass = QString::fromLatin1(mHashedPassword,mHashedPassword.size());
    array.append(str_pass);
    array.append(mConnectionEmail);
    array.append(mConnectionData);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mSocket.sendBinaryMessage(output);
}

void CGServer::socketErrored(QAbstractSocket::SocketError err)
{
    mConnected = false;
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
