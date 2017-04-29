#include "cgweb_plugin.h"
#include "cgweb.h"

#include <qqml.h>



void CGWebPlugin::registerTypes(const char *uri)
{
    // @uri com.chessgames.web
    Q_ASSERT(QLatin1String(uri) == QLatin1String("CGWeb"));
    qmlRegisterType<CGWeb>(uri, 1, 0, "CGWebConnection");
}

