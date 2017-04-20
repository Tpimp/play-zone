#include "cgnetwork_plugin.h"
#include "cglobby.h"
#include "cggame.h"
#include "cglogin.h"
#include "cgprofile.h"

#include <qqml.h>
#include "cgserver.h"

static QObject *cgServerSingletonFactory(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine)
    Q_UNUSED(engine)

    return qobject_cast<QObject*>(CG_SERVER_S());
}
void CGNetworkPlugin::registerTypes(const char *uri)
{
    // @uri com.mycompany.qmlcomponents
    QString uri_lobby = QString::fromLocal8Bit(uri);
    uri_lobby.append(".lobby");
    QString uri_game = QString::fromLocal8Bit(uri);
    uri_game.append(".game");
    QString uri_login = QString::fromLocal8Bit(uri);
    uri_login.append(".login");
    QString uri_server = QString::fromLocal8Bit(uri);
    uri_server.append(".server");
    qmlRegisterType<CGLobby>(uri_lobby.toLocal8Bit().data(), 1, 0, "CGLobby");
    qmlRegisterType<CGGame>(uri_game.toLocal8Bit().data(), 1, 0, "CGGame");
    qmlRegisterType<CGLogin>(uri_login.toLocal8Bit().data(), 1, 0, "CGLogin");
    qmlRegisterSingletonType<CGServer>(uri_server.toLocal8Bit().data(), 1, 0, "CGServer",cgServerSingletonFactory);
}

