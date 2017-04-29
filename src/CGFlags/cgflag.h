#ifndef CGFLAGPROVIDER_H
#define CGFLAGPROVIDER_H

#include <QQuickImageProvider>
#include <QUrl>
#include <QString>
#include <QVariantMap>
#include <QStringList>
#include <QFile>

class CGFlagProvider : public QQuickImageProvider
{

public:
    CGFlagProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    QStringList availableCountries();
    ~CGFlagProvider();
protected:
    QString     mFlags;
    QVariantMap mFlagMap;
};

#endif // CGFLAG_H
