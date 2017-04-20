#ifndef CGCHESSGAMES_H
#define CGCHESSGAMES_H

#include <QQuickItem>

class CGChessGames : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGChessGames)

public:
    CGChessGames(QQuickItem *parent = 0);
    ~CGChessGames();
};

#endif // CGCHESSGAMES_H
