#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "applicationloader.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    ApplicationLoader loader(engine,&app);
    // local files provided with last "update/original" might be stale
    loader.setCachePath(app.applicationDirPath() +"/chessgames/");
    // connect to server and begin verifying version
    loader.connectToHttpServer("http://192.168.3.105", "chessgames");
    // tells loader to load the application manifest
    loader.loadApplicationLocal("chessgames.JSON"); // will load from the local cache
    return app.exec();
}
