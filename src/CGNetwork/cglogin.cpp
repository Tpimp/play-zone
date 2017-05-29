#include "cglogin.h"
#include <QCryptographicHash>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include "cgserver.h"

CGLogin::CGLogin(QQuickItem *parent) : QQuickItem(parent), mConnected(false), mTries(0)
{
    mServer = CGServer::globalServer();
    connect(mServer,&CGServer::connectedToHost,this,&CGLogin::connectedToHost);
    connect(mServer, &CGServer::userLoggedIn, this,&CGLogin::userLoggedIn);
    connect(mServer, &CGServer::deniedUserCredentials, this,&CGLogin::userCredentialsDenied);
    connect(mServer,&CGServer::disconnectedFromServer, this, &CGLogin::disconnectedFromServer);
    connect(mServer, &CGServer::userRegistered,this, &CGLogin::userRegistered);
    connect(mServer, &CGServer::userDeniedRegister,this,&CGLogin::userDeniedRegister);
}


void CGLogin::attemptRegistration()
{
    disconnect(mServer, &CGServer::connectedToHost, this, &CGLogin::attemptRegistration);
    QJsonObject obj;
    obj["T"] = REGISTER_USER;
    QJsonArray array;
    array.append(mUsername);
    QString str_pass = QString::fromLatin1(mHashedPass,mHashedPass.size());
    array.append(str_pass);
    array.append(mEmail);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mServer->writeMessage(output);
}

void CGLogin::attemptRegisterUser(QString name, QString password, QString email)
{
    QCryptographicHash hasher(QCryptographicHash::Sha256);
    hasher.addData(password.toLocal8Bit());
    mUsername = name;
    mEmail = email;
    mHashedPass = hasher.result().toHex();
    if(mConnected){
        QJsonObject obj;
        obj["T"] = REGISTER_USER;
        QJsonArray array;
        array.append(name);
        QString str_pass = QString::fromLatin1(mHashedPass,mHashedPass.size());
        array.append(str_pass);
        array.append(email);
        obj["P"] = array;
        QJsonDocument doc;
        doc.setObject(obj);
        QByteArray output = doc.toBinaryData();
        mServer->writeMessage(output);
    }
    else{ // else try to connect and set connection action to attemptRegistration
        connect(mServer, &CGServer::connectedToHost, this, &CGLogin::attemptRegistration);
        mServer->connectToHost(mConnectionString);
    }
}


void CGLogin::connectedToHost()
{
    mConnected = true;
}



void CGLogin::disconnectFromServer()
{
    mConnected = false;
    mServer->disconnectFromHost();
}

QByteArray CGLogin::getPassword()
{
    return mHashedPass;
}

void CGLogin::loginToHost()
{
    disconnect(mServer, &CGServer::connectedToHost, this, &CGLogin::loginToHost);
    QJsonObject obj;
    // type
    obj["T"] = VERIFY_USER;
    QJsonArray array;
    array.append(mUsername);
    QString str_pass = QString::fromLatin1(mHashedPass,mHashedPass.size());
    array.append(str_pass);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mServer->writeMessage(output);

}

void CGLogin::login(QString name, QString password)
{
    QCryptographicHash hasher(QCryptographicHash::Sha256);
    hasher.addData(password.toLocal8Bit());
    mUsername = name;
    mHashedPass = hasher.result().toHex();
    if(mConnected){
        QJsonObject obj;
        // type
        obj["T"] = VERIFY_USER;
        QJsonArray array;
        array.append(name);
        QString str_pass = QString::fromLatin1(mHashedPass,mHashedPass.size());
        array.append(str_pass);
        obj["P"] = array;
        QJsonDocument doc;
        doc.setObject(obj);
        QByteArray output = doc.toBinaryData();
        mServer->writeMessage(output);
    }
    else{
        connect(mServer, &CGServer::connectedToHost, this, &CGLogin::loginToHost);
        mServer->connectToHost(mConnectionString);
    }
}

void CGLogin::setServerAddress(QString ip, int port)
{
   // do connection stuff
   QString url("ws://");
   url.append(ip);
   url.append(":");
   url.append(QString::number(port));
   mConnectionString = url;
}

CGLogin::~CGLogin()
{

}
