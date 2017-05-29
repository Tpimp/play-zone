#pragma once

#include <QQmlExtensionPlugin>

class CGAvatarsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.chessgames.plugins.avatars")

public:
    void registerTypes(const char *uri);
    void initializeEngine(QQmlEngine *engine, const char *uri);
};
