#include "cglobby.h"

CGLobby::CGLobby(QQuickItem *parent):
    QQuickItem(parent)
{
    mServer = CG_SERVER_S();
    //connect(mServer,&CGServer::userProfileData, this, &CGLobby::);
}


void CGLobby::lobbyMessage(QString lobby, QString message)
{

}

CGLobby::~CGLobby()
{
}
