#include "cglobby.h"
#include "cgserver.h"

CGLobby::CGLobby(QQuickItem *parent):
    QQuickItem(parent)
{
    mServer = CGServer::globalServer();
    connect(mServer,&CGServer::lobbyFoundMatch, this, &CGLobby::matchedWithPlayer);
}


void CGLobby::lobbyMessage(QString lobby, QString message)
{

}


void CGLobby::joinMatchMaking(int type)
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = JOIN_MATCHMAKING;
    array.append(type);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mServer->writeMessage(output);
}

void CGLobby::matchedPlayer(QString name, int elo, QString country, QString avatar, bool color, int id)
{
    if(!avatar.contains('.')){
        avatar.prepend("image://avatars/");
    }
    //emit matchedWithPlayer(name,elo,country,avatar,color,id);
}

CGLobby::~CGLobby()
{

}
