#pragma once

#include <QQmlExtensionPlugin>



class CGWebPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.chessgames.plugins.web")

public:
    void registerTypes(const char *uri);
};
