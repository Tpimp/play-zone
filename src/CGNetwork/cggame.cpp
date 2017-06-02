#include "cggame.h"
#include "cgserver.h"
#include <QJsonArray>
#include <QJsonDocument>

CGGame::CGGame(QQuickItem * parent) : QQuickItem(parent)
{
    mServer = CGServer::globalServer();
    //connect(mServer, &CGServer::gameMessageReceived, this, &CGGame::processGameMessage);
    connect(mServer, &CGServer::opponentMoved, this, &CGGame::opponentMove);
    connect(mServer, &CGServer::gameSynchronized, this, &CGGame::gameSynchronized);
    connect(mServer, &CGServer::gameFinished, this, &CGGame::gameFinished);
    connect(mServer, &CGServer::recievedDrawResponse, this, &CGGame::drawResponse);
}


int CGGame::gameID()
{
    return mGameID;
}

void CGGame::makeMove(int from, int to, QString fen, QString promote)
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SEND_MOVE;
    array.append(from);
    array.append(to);
    array.append(fen);
    array.append(promote);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    mServer->writeMessage( doc.toBinaryData());
}


void CGGame::sendDraw(int draw){
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SEND_DRAW;
    array.append(draw);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    mServer->writeMessage( doc.toBinaryData());
}

void CGGame::sendResult(int result, QJsonObject move, QString fen, QString game)
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SEND_RESULT;
    array.append(result);
    array.append(move);
    array.append(fen);
    array.append(game);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    mServer->writeMessage( doc.toBinaryData());
}

void CGGame::sendSync()
{
    QJsonObject obj;
    obj["T"] = SEND_SYNC;
    obj["P"] = QJsonValue();
    QJsonDocument doc;
    doc.setObject(obj);
    mServer->writeMessage( doc.toBinaryData());
}

void CGGame::setGameID(quint64 id)
{
    if(mGameID != id){
        mGameID = id;
        emit gameIDChanged(id);
    }
}

void CGGame::startNewGame(QString opponent, QString country, int elo, bool arewhite, quint64 id)
{
    mOpponentElo = elo;
    mOpponent = opponent;
    mOpponentCountry = country;
    mGameID = id;
}



CGGame::~CGGame()
{

}
