#pragma once

#include <QQmlExtensionPlugin>

class CGFlagsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.chessgames.plugins.flags")

public:
    void registerTypes(const char *uri);
    void initializeEngine(QQmlEngine *engine, const char *uri);
};
