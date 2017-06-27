#ifndef CGGAME_H
#define CGGAME_H

#include <QQuickItem>
#include <QJsonObject>
#include <QTime>
#include <QTimer>

class CGServer;
class CGGame : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGGame)
public:
    CGGame(QQuickItem* parent = nullptr);
    Q_INVOKABLE void makeMove(int from, int to, QString fen, QString promote, int elapsed, double latency);
    Q_INVOKABLE void sendDraw(int draw);
    Q_INVOKABLE void sendSync(double latency);
    Q_INVOKABLE void sendResult(int result, QString game);

    Q_INVOKABLE void calculateSyncClock(quint64 time);
    Q_INVOKABLE void calculatePlayerClock(bool color, quint64 time);


    Q_INVOKABLE QString blacksTime();
    Q_INVOKABLE QString whitesTime();
    Q_INVOKABLE int     playerTimeElapsed();
    Q_INVOKABLE void    startPlayerTimer();
    Q_INVOKABLE int     adjustPlayerTimer(bool color);
    Q_INVOKABLE int stopPlayerTimer(bool color);
    ~CGGame();

signals:
    void opponentForfeit();
    void opponentMove(QJsonObject move);
    void gameSynchronized(int state, double time);
    void gameFinished(QJsonObject  game_result);
    void drawResponse(int response);
    void playerTimerExpired(bool color);
    void syncPlayerClock(bool color, QString time);
    void syncClock(QString time);
    void updatePlayerClock();

protected:
    quint64 mWhiteClock;
    quint64 mBlackClock;
    QTime   mTurnTimer;
    QTimer  mUpdateTimer;

    // TODO:  clean up integration of clock fix qml, add set text on signals

    CGServer *mServer;
};

#endif // CGGAME_H
