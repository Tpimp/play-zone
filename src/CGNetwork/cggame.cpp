#include "cggame.h"
#include "cgserver.h"
CGGame::CGGame(QQuickItem * parent) : QQuickItem(parent)
{
    mServer = CGServer::globalServer();
    //connect(mServer, &CGServer::gameMessageReceived, this, &CGGame::processGameMessage);
}


void CGGame::processGameMessage(int func, QByteArray data)
{

}

CGGame::~CGGame()
{

}
