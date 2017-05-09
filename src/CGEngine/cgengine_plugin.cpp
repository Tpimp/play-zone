#include "cgengine_plugin.h"
#include "cgtimer.h"
#include "pieceprovider.h"
#include <qqml.h>
#include <QQmlContext>
#include <QVariant>
#include "cgengine.h"

void CGEnginePlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    // TODO: add support for dynamic piece sizing
    PieceProvider* provider = new PieceProvider(135,135);
    engine->rootContext()->setContextProperty("PieceTable",provider->getPieceLocation());
    engine->addImageProvider("pieces",provider);
}


void CGEnginePlugin::registerTypes(const char *uri)
{

    Q_ASSERT(QLatin1String(uri) == QLatin1String("CGEngine"));
    qmlRegisterType<CGTimer>(uri, 1, 0, "CGTimer");
    qmlRegisterType<CGEngine>(uri, 1, 0, "CGEngine");
}

