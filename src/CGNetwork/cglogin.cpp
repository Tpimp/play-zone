#include "cglogin.h"
#include <QCryptographicHash>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include "cgserver.h"

CGLogin::CGLogin(QQuickItem *parent) : QQuickItem(parent), mTries(0)
{
    mServer = CGServer::globalServer();
    connect(mServer, &CGServer::userLoggedIn, this,&CGLogin::userLoggedIn);
    connect(mServer, &CGServer::deniedUserCredentials, this,&CGLogin::userCredentialsDenied);
    connect(mServer,&CGServer::disconnectedFromServer, this, &CGLogin::disconnectedFromServer);
    connect(mServer, &CGServer::userRegistered,this, &CGLogin::userRegistered);
    connect(mServer, &CGServer::userDeniedRegister,this,&CGLogin::userDeniedRegister);
    connect(mServer,&CGServer::currentPing, this, &CGLogin::currentPing);
}



void CGLogin::attemptRegisterUser(QString name, QString password, QString email,QString data)
{
    QCryptographicHash hasher(QCryptographicHash::Sha3_256);
    hasher.addData(password.toLocal8Bit());
    //mUsername = name;
    //mEmail = email;
    QByteArray hpass = hasher.result().toHex();
    mServer->registerToServer(name,hpass,email,data);

}





void CGLogin::disconnectFromServer()
{
    mServer->disconnectFromHost();
}




void CGLogin::login(QString name, QString password)
{
    QCryptographicHash hasher(QCryptographicHash::Sha3_256);
    hasher.addData(password.toLocal8Bit());
    mServer->loginToServer(name,hasher.result().toHex());

}

void CGLogin::setConnection(QString ip, int port)
{
    mServer->setConnectionString(ip,port);
}

CGLogin::~CGLogin()
{

}
