#ifndef CGGAME_H
#define CGGAME_H

#include <QQuickItem>
class CGServer;
class CGGame : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGGame)
public:
    CGGame(QQuickItem* parent = nullptr);
    Q_INVOKABLE bool canMakeMove();
    Q_INVOKABLE void startNewGame(QString opponent, QString country, int elo, bool arewhite);
    ~CGGame();

signals:
    void opponentForfeit();
    void opponentMove(QString move);

public slots:
    void processGameMessage(int func, QByteArray data);
    void makeMove(QString move);
protected:
    int       mOpponentElo;
    QString   mOpponent;
    QString   mOpponentCountry;
    bool      mCurrentTurn;
    bool      mPlayerColor;
    CGServer *mServer;
};

#endif // CGGAME_H
