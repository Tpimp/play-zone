#pragma once

#include <QQmlExtensionPlugin>

class CGAppPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.chessgames.plugins.app")

public:
    void registerTypes(const char *uri);
};
