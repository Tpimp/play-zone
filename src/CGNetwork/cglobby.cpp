#include "cglobby.h"
#include "cgserver.h"
CGLobby::CGLobby(QQuickItem *parent):
    QQuickItem(parent)
{
    mServer = CGServer::globalServer();
    //connect(mServer,&CGServer::userProfileData, this, &CGLobby::);
}


void CGLobby::lobbyMessage(QString lobby, QString message)
{

}

CGLobby::~CGLobby()
{
}
