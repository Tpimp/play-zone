#include "cgavatars_plugin.h"
#include "cgavatar.h"
#include "cgavatardata.h"
#include <qqml.h>
#include <QQmlContext>
void CGAvatarsPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(uri)
    CGAvatarProvider* provider = new CGAvatarProvider();
    engine->rootContext()->setContextProperty("Avatars",provider->availableAvatars());
    engine->addImageProvider("avatars",provider);
}



void CGAvatarsPlugin::registerTypes(const char *uri)
{
    // @uri com.chessgames.avatars
    Q_UNUSED(uri);
    Q_ASSERT(QLatin1String(uri) == QLatin1String("CGAvatars"));
    qmlRegisterType<CGAvatarData>(uri,1,0,"CGAvatarData");
}

