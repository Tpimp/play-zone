#include "cggame.h"
#include "cgserver.h"
CGGame::CGGame(QQuickItem * parent) : QQuickItem(parent)
{
    mServer = CGServer::globalServer();
    //connect(mServer, &CGServer::gameMessageReceived, this, &CGGame::processGameMessage);
}


bool CGGame::canMakeMove()
{
    return mPlayerColor == mCurrentTurn;
}


void CGGame::makeMove(QString move)
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SEND_MOVE;
    array.append(type);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mServer->writeMessage();
}

void CGGame::startNewGame(QString opponent, QString country, int elo, bool arewhite)
{
    mCurrentTurn = true;
    mPlayerColor = arewhite;
    mOpponentElo = elo;
    mOpponent = opponent;
    mOpponentCountry = country;
}

void CGGame::processGameMessage(int func, QByteArray data)
{

}

CGGame::~CGGame()
{

}
