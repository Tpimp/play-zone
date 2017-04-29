#include "applicationloader.h"
#include <QList>
#include <QQmlError>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QQmlContext>
#include <QDir>
#include <QDebug>
#include <QTimer>

ApplicationLoader::ApplicationLoader(QQmlApplicationEngine &engine, QObject *parent)
    : QObject(parent), mEngine(engine), mServer(nullptr)
{
    mEngine.rootContext()->setContextProperty("CGUpdater", this);
}

void ApplicationLoader::connectToHttpServer(QString domain, QString app_name)
{

}

void ApplicationLoader::connectToWebSocketServer(QString ip, quint16 port)
{

}

bool ApplicationLoader::isUptoDate()
{
    return false;
}

void ApplicationLoader::beginUpdateProcess()
{

}

void ApplicationLoader::clearApplication()
{
    //for each component go down and clear them out
    mEngine.clearComponentCache();
}


bool ApplicationLoader::importQmlPlugin(QString plugin_path, QString name){
    QList<QQmlError> list;
    return mEngine.importPlugin(plugin_path,name, &list);
}

void ApplicationLoader::loadApplicationLocal(QString manifest_path)
{
    clearApplication();
    BindingManifest manifest;
    loadManifestFile(manifest, mCachePath + manifest_path);
    loadManifestComponents(manifest);
    mEngine.load(QUrl(manifest.root));
    QTimer::singleShot(1200,Qt::CoarseTimer,this, &ApplicationLoader::ready);
}

void ApplicationLoader::loadManifestComponents(BindingManifest & manifest)
{
    for(QString name : manifest.plugins.keys()){
        QList<QQmlError> list;
        QString full = mCachePath + manifest.plugins.value(name);
        mEngine.importPlugin(full,name,&list);
    }
    for(QString key : manifest.globals.keys())
    {
        mEngine.rootContext()->setContextProperty(key,manifest.globals.value(key));
    }
   // mEngine.addImportPath(mCachePath);
}

void ApplicationLoader::loadManifestFile(BindingManifest &manifest, QString file_name)
{
    QFile file(file_name);
    file.open(QIODevice::ReadOnly);
    if(file.isOpen()){
        QByteArray data = file.readAll();
        if(data.length() > 2){
            QJsonDocument doc = QJsonDocument::fromJson(data);
            QJsonObject obj = doc.object();
            // parse globals first
            // convert obj to manifest struct
            if(obj.contains("globals")){
                manifest.globals = obj["globals"].toObject().toVariantMap();
            }
            QVariantMap  plugins = obj["plugins"].toObject().toVariantMap();
            for(QString key : plugins.keys()){
                manifest.plugins.insert(key,plugins.value(key).toString());
            }
            int var_count = plugins.count();
            for(int index(0); index < var_count/2;index+=2){

            }
            manifest.name = obj["name"].toString();
            QVariantList  qml = obj["qml"].toArray().toVariantList();
            for(QVariant var : qml){
                manifest.qml.append(var.toString());
            }
            QVariantList  resources = obj["resources"].toArray().toVariantList();
            for(QVariant var : resources){
                manifest.resources.append(var.toString());
            }
            manifest.version = obj["version"].toDouble();
            manifest.root = obj["root"].toString();
        }
    }
}


void ApplicationLoader::requestCurrentBMF()
{

}


void ApplicationLoader::setCachePath(QString path)
{
    QStringList paths = mEngine.importPathList();
    if(paths.contains(mCachePath)){
        paths.removeAll(mCachePath);
    }
    mCachePath = path;
    mEngine.addImportPath(mCachePath);
}


void ApplicationLoader::validateRelocateUpdate()
{

}

ApplicationLoader::~ApplicationLoader()
{

}
