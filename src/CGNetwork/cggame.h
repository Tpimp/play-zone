#ifndef CGGAME_H
#define CGGAME_H

#include <QQuickItem>
#include "cgserver.h"
class CGGame : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGGame)
public:
    CGGame(QQuickItem* parent = nullptr);
    ~CGGame();
signals:

public slots:
    void processGameMessage(int func, QByteArray data);
protected:
    CGServer *mServer;
};

#endif // CGGAME_H
