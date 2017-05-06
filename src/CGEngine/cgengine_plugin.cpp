#include "cgengine_plugin.h"
#include "cgtimer.h"
#include <qqml.h>

void CGEnginePlugin::registerTypes(const char *uri)
{

    Q_ASSERT(QLatin1String(uri) == QLatin1String("CGEngine"));
    // @uri com.chessgames.engine
    qmlRegisterType<CGTimer>(uri, 1, 0, "CGTimer");
}

