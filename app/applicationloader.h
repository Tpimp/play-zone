#ifndef APPLICATIONLOADER_H
#define APPLICATIONLOADER_H

#include <QObject>
#include <QQmlApplicationEngine>
#include <QHostAddress>
#include "updateserverinterface.h"
#include <QString>
#include <QStringList>
#include <QMap>
#include <QVariantMap>

typedef struct BindingManifest{
    QString               name;
    qreal                 version;
    QString               root;
    //QMap<QString,QString> map;
    //QStringList           libs;
    QMap<QString,QString> plugins;
    QVariantMap           globals;
    QStringList           resources;
    QStringList           qml;
}BindingManifest;

/*******************************************************
 * Application loader has the ability to load qt/qml
 * applications from a series of qml files + dynamic
 * libraries. Their binding is defined through an
 * application Binding Manifest File.
 *
 * A BMF describes the module and its exports.
 *  Name: Exported name of Application in Qml.
 *  root: Root Qml file to feed the engine
 *  version: Describes the version of the module
 *  libs: Names of native libraries to bind
 *  resources: List of Qrc files to bind for module
 *  qml: List of raw qml files to bind
 *  plugins: List of plugins to load
 *
 ******************************************************/

class ApplicationLoader : public QObject
{
    Q_OBJECT
public:
    explicit ApplicationLoader(QQmlApplicationEngine &engine, QObject *parent = 0);
    ~ApplicationLoader();

    void setCachePath(QString path);
    void connectToHttpServer(QString domain, QString app_name);
    void connectToWebSocketServer(QString ip, quint16 port);

    // Interface functions for base Qml to call
    Q_INVOKABLE void beginUpdateProcess();
    Q_INVOKABLE bool isUptoDate();
    bool importQmlPlugin(QString plugin_path, QString name);
    void loadApplicationLocal(QString manifest_path);

signals:
    void updateAvailable();
    void updateStatusChange(bool active, int total_c, int current, QString task);


protected:
    QQmlApplicationEngine&     mEngine;
    QString                    mCachePath;
    BindingManifest            mBoundManifest;
    UpdateServerInterface *    mServer;

    // BMF functions
    static void loadManifestFile(BindingManifest & manifest, QString file_name);
    void requestCurrentBMF();
    void clearApplication();
    void loadManifestComponents();


protected slots: // connected to the server


};

#endif // APPLICATIONLOADER_H
