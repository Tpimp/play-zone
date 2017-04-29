#include "cgflags_plugin.h"
#include "cgflag.h"

#include <qqml.h>
#include <QQmlContext>
#include "cgflagdata.h"
void CGFlagsPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    CGFlagProvider* provider = new CGFlagProvider();
    engine->rootContext()->setContextProperty("AvailableCountries",provider->availableCountries());
    engine->addImageProvider("flags",provider);
}



void CGFlagsPlugin::registerTypes(const char *uri)
{
    // @uri com.chessgames.CGFlag

    Q_ASSERT(QLatin1String(uri) == QLatin1String("CGFlags"));
    qmlRegisterType<CGFlagData>(uri,1,0,"CGFlagData");
}

