#include "cgapp_plugin.h"
#include "cgchessgames.h"

#include <qqml.h>

void CGAppPlugin::registerTypes(const char *uri)
{
    // @uri com.mycompany.qmlcomponents
    qmlRegisterType<CGChessGames>(uri, 1, 0, "CGChessGames");
}

