#include "cgweb_plugin.h"
#include "cgweb.h"

#include <qqml.h>

static QObject *cgWebApiSingletonFactory(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine)
    Q_UNUSED(engine)

    return new CGWeb();
}

void CGWebPlugin::registerTypes(const char *uri)
{
    // @uri com.chessgames.web
    Q_ASSERT(QLatin1String(uri) == QLatin1String("CGWebApi"));
    qmlRegisterSingletonType<CGWeb>(uri, 1, 0, "CGWebConnection",cgWebApiSingletonFactory);
}

