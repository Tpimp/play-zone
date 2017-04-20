#include "cggame.h"

CGGame::CGGame(QQuickItem * parent) : QQuickItem(parent)
{
    mServer = CG_SERVER_S();
}

CGGame::~CGGame()
{

}
