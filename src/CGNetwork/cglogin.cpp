#include "cglogin.h"
#include <QCryptographicHash>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
CGLogin::CGLogin(QQuickItem *parent) : QQuickItem(parent)
{
    mServer = CG_SERVER_S();
    connect(mServer,&CGServer::connectedToHost,this,&CGLogin::readyForLogin);
    connect(mServer, &CGServer::userLoggedIn, this,&CGLogin::userLoggedIn);
    connect(mServer, &CGServer::deniedUserCredentials, this,&CGLogin::userCredentialsDenied);
    connect(mServer,&CGServer::disconnectedFromServer, this, &CGLogin::disconnectedFromServer);
    connect(mServer, &CGServer::userProfileData, this, &CGLogin::profileData);
}


void CGLogin::connectToServer(QString ip, int port)
{
    mServer->connectToHost(ip,port);
}

void CGLogin::sendAuthentication(QString name, QString password)
{
    QCryptographicHash hasher(QCryptographicHash::Sha256);
    hasher.addData(password.toLocal8Bit());
    QByteArray hpass = hasher.result().toHex();

    QJsonObject obj;
    // type
    obj["T"] = VERIFY_USER;
    QJsonArray array;
    array.append(name);
    mUsername = name;
    QString str_pass = QString::fromLatin1(hpass,hpass.size());
    array.append(str_pass);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mServer->writeMessage(output);

}


CGLogin::~CGLogin()
{

}
