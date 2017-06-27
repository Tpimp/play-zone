#include "cggame.h"
#include "cgserver.h"
#include <QJsonArray>
#include <QJsonDocument>

CGGame::CGGame(QQuickItem * parent) : QQuickItem(parent), mWhiteClock(0), mBlackClock(0)
{
    mServer = CGServer::globalServer();
    //connect(mServer, &CGServer::gameMessageReceived, this, &CGGame::processGameMessage);
    connect(mServer, &CGServer::opponentMoved, this, &CGGame::opponentMove);
    connect(mServer, &CGServer::gameSynchronized, this, &CGGame::gameSynchronized);
    connect(mServer, &CGServer::gameFinished, this, &CGGame::gameFinished);
    connect(mServer, &CGServer::recievedDrawResponse, this, &CGGame::drawResponse);
    connect(&mUpdateTimer, &QTimer::timeout, this, &CGGame::updatePlayerClock);
    mUpdateTimer.setInterval(90);
    mUpdateTimer.setTimerType(Qt::PreciseTimer);
    mUpdateTimer.setSingleShot(false);
}

int CGGame::adjustPlayerTimer(bool color)
{
    quint64 elapsed = mTurnTimer.elapsed();
    QString time;
    quint64 starttime;
    if(color){
        if(elapsed >= mWhiteClock){ // timeout
            starttime = 0;
            emit syncPlayerClock(true,"00:00");
            emit playerTimerExpired(true);
            return elapsed;
        }
        starttime = (mWhiteClock-elapsed);
    }
    else{
        if(elapsed >= mBlackClock){ // timeout
            emit syncPlayerClock(false,"00:00");
            emit playerTimerExpired(false);
            return elapsed;
        }
        starttime = (mBlackClock-elapsed);
    }
    quint64 minutes = (starttime/60000);
    quint64 seconds = ((starttime-(60000*minutes))/1000);
    QTextStream stream(&time);
    if(minutes < 10){
        stream << "0";
    }
    stream << minutes << ":";
    if(seconds < 10){
        stream << "0";
    }
    stream << seconds;// << "." << millis;
    emit syncPlayerClock(color,time);
    return elapsed;
}

int CGGame::playerTimeElapsed()
{
    return mTurnTimer.elapsed();
}

QString CGGame::blacksTime()
{
    quint64 minutes = (mBlackClock/60000);
    quint64 seconds = ((mBlackClock-(60000*minutes))/1000);
    quint64 millis = (mBlackClock - ((60000*minutes) + (1000*seconds)));
    QString out;
    QTextStream stream(&out);
    if(minutes < 10){
        stream << "0";
    }
    stream << minutes << ":";
    if(seconds < 10){
        stream << "0";
    }
    if(millis > 0){
        seconds += 1;
    }
    stream << seconds;// << "." << millis;
    return out;
}

void CGGame::calculatePlayerClock(bool color, quint64 time)
{
    quint64 minutes = (time/60000);
    quint64 seconds = ((time - (60000*minutes)) /1000);
    quint64 millis = (time - ((60000*minutes) + (1000*seconds)));
    QString out;
    QTextStream stream(&out);
    if(minutes < 10){
        stream << "0";
    }
    stream << minutes << ":";
    if(seconds < 10){
        stream << "0";
    }
    if(millis > 0){
        seconds += 1;
    }
    stream << seconds;// << "." << millis;
    if(color){
        mWhiteClock = time;
    }
    else{
        mBlackClock = time;
    }
    emit syncPlayerClock(color,out);
}

void CGGame::calculateSyncClock(quint64 time)
{
    mWhiteClock = time;
    mBlackClock = time;
    quint64 minutes = (time/60000);
    quint64 seconds = ((time - (60000*minutes)) /1000);
    QString out;
    QTextStream stream(&out);
    if(minutes < 10){
        stream << "0";
    }
    stream << minutes << ":";
    if(seconds < 10){
        stream << "0";
    }
    stream << seconds;// << "." << millis;
    emit syncClock(out);
}

void CGGame::makeMove(int from, int to, QString fen, QString promote, int elapsed, double latency)
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SEND_MOVE;
    array.append(from);
    array.append(to);
    array.append(fen);
    array.append(promote);
    array.append(elapsed);
    array.append(latency);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    mServer->writeMessage(doc.toBinaryData());
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

void CGGame::sendResult(int result, QString game)
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SEND_RESULT;
    array.append(result);
    array.append(double(mWhiteClock));
    array.append(double(mBlackClock));
    array.append(game);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    mServer->writeMessage( doc.toBinaryData());
}

void CGGame::sendSync(double latency)
{
    QJsonObject obj;
    obj["T"] = SEND_SYNC;
    QJsonArray array;
    array.append(latency);
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    mServer->writeMessage( doc.toBinaryData());
}

int CGGame::stopPlayerTimer(bool color)
{
    mUpdateTimer.stop();
    quint64 elapsed = mTurnTimer.elapsed();
    QString time;
    if(color){
        if(elapsed >= mWhiteClock){ // timeout
            mWhiteClock = 0;
            return elapsed;
        }
        mWhiteClock -= elapsed;
        time = whitesTime();
    }
    else{
        if(elapsed >= mBlackClock){ // timeout
            mBlackClock = 0;
            return elapsed;
        }
        mBlackClock -= elapsed;
        time = blacksTime();
    }
    emit syncPlayerClock(color,time);
    return elapsed;
}

void CGGame::startPlayerTimer()
{
    mUpdateTimer.stop();
    mTurnTimer.start();
    mUpdateTimer.start();
}

QString CGGame::whitesTime(){
    quint64 minutes = (mWhiteClock/60000);
    quint64 seconds = ((mWhiteClock- (60000*minutes)) /1000);
    quint64 millis = (mWhiteClock - ((60000*minutes) + (1000*seconds)));
    QString out;
    QTextStream stream(&out);
    if(minutes < 10){
        stream << "0";
    }
    stream << minutes << ":";
    if(seconds < 10){
        stream << "0";
    }
    if(millis > 0){
        seconds += 1;
    }
    stream << seconds;// << "." << millis;
    return out;
}




CGGame::~CGGame()
{

}
