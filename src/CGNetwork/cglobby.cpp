#include "cglobby.h"
#include "cgserver.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

CGLobby::CGLobby(QQuickItem *parent):
    QQuickItem(parent)
{
    mServer = CGServer::globalServer();
    //connect(mServer,&CGServer::userProfileData, this, &CGLobby::);
}


void CGLobby::lobbyMessage(QString lobby, QString message)
{

}

void CGLobby::joinMatchMaking(int type)
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = JOIN_MATCHING;
    array.append(type);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mServer->writeMessage(output);
}

CGLobby::~CGLobby()
{

}
