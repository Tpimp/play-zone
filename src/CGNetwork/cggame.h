#ifndef CGGAME_H
#define CGGAME_H

#include <QQuickItem>
#include <QJsonObject>
class CGServer;
class CGGame : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGGame)
    Q_PROPERTY(quint64 gameID READ gameID WRITE setGameID NOTIFY gameIDChanged MEMBER mGameID)
public:
    CGGame(QQuickItem* parent = nullptr);
    Q_INVOKABLE void startNewGame(QString opponent, QString country, int elo, bool arewhite, quint64 id);
    Q_INVOKABLE int  gameID();
    Q_INVOKABLE void makeMove(int from, int to, QString fen, QString promote);
    Q_INVOKABLE void sendDraw(int draw);
    Q_INVOKABLE void sendSync();
    Q_INVOKABLE void sendResult(int result, QJsonObject move, QString fen, QString game);
    ~CGGame();

signals:
    void opponentForfeit();
    void opponentMove(QJsonObject move);
    void gameSynchronized(int state);
    void gameFinished(int result, QJsonObject move, QString fen, QString game);
    void gameIDChanged(quint64 id);
    void drawResponse(int response);

public slots:
    void setGameID(quint64 id);
protected:
    int       mOpponentElo;
    QString   mOpponent;
    QString   mOpponentCountry;
    quint64   mGameID;
    CGServer *mServer;
};

#endif // CGGAME_H
