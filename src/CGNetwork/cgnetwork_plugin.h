#pragma once

#include <QQmlExtensionPlugin>
class CGNetworkPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.chessgames.plugins.network")
public:
    void registerTypes(const char *uri);
};

