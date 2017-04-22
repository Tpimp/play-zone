#include "cggame.h"

CGGame::CGGame(QQuickItem * parent) : QQuickItem(parent)
{
    mServer = CG_SERVER_S();
    //connect(mServer, &CGServer::gameMessageReceived, this, &CGGame::processGameMessage);
}


void CGGame::processGameMessage(int func, QByteArray data)
{

}

CGGame::~CGGame()
{

}
