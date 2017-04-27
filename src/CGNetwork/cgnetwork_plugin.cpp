#include "cgnetwork_plugin.h"
#include "cglobby.h"
#include "cggame.h"
#include "cglogin.h"
#include "cgprofile.h"

#include <qqml.h>
#include "cgprofile.h"
#include "cgserver.h"

static QObject *cgServerSingletonFactory(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine)
    Q_UNUSED(engine)

    return qobject_cast<QObject*>(CGServer::globalServer());
}


void CGNetworkPlugin::registerTypes(const char *uri)
{
    // @uri com.mycompany.qmlcomponents

    Q_ASSERT(QLatin1String(uri) == QLatin1String("CGNetwork"));
//    QString uri_lobby = QString::fromLocal8Bit(uri);
//    uri_lobby.append(".lobby");
//    QString uri_game = QString::fromLocal8Bit(uri);
//    uri_game.append(".game");
//    QString uri_login = QString::fromLocal8Bit(uri);
//    uri_login.append(".login");
//    QString uri_profile = QString::fromLocal8Bit(uri);
//    uri_profile.append(".profile");
//    QString uri_server = QString::fromLocal8Bit(uri);
//    uri_server.append(".server");
    qmlRegisterType<CGLogin>(uri, 1, 0, "CGLogin");
    qmlRegisterType<CGProfile>(uri, 1, 0, "CGProfile");
    qmlRegisterType<CGLobby>(uri, 1, 0, "CGLobby");
    qmlRegisterType<CGGame>(uri, 1, 0, "CGGame");

    qmlRegisterSingletonType<CGServer>(uri, 1, 0, "CGServer",cgServerSingletonFactory);


}

