#ifndef CGSERVER_H
#define CGSERVER_H

#include <QObject>
#include <QWebSocket>



class CGServer : public QObject
{
    Q_OBJECT
public:
    explicit CGServer(QObject *parent = 0);
    ~CGServer();
signals:

public slots:
    void connectToHost(QString address, int port);

protected:
    QWebSocket  mSocket;
};

Q_GLOBAL_STATIC(CGServer, CG_SERVER_S)

#endif // CGSERVER_H
