#ifndef CGTIMER_H
#define CGTIMER_H

#include <QQuickItem>
#include <QTimer>

class CGTimer : public QQuickItem
{
    Q_OBJECT
public:
    CGTimer();
    ~CGTimer();
signals:
    void gameCountdown(int count);
    void startGame();
    void updateClock(qreal time);
    void stoppedAt(qreal milli);
public slots:
    void startGameSync();
    void startGameClock(qreal current);
    void stopGameClock();

protected:
    QTimer m_gameTimer;
    quint64 m_sinceStart;
    qreal m_time;
};

#endif // CGTIMER_H
