#ifndef CGFLAGPROVIDER_H
#define CGFLAGPROVIDER_H

#include <QQuickImageProvider>
#include <QUrl>
#include <QString>
#include <QJsonArray>
#include <QFile>

class CGAvatarProvider : public QQuickImageProvider
{

public:
    CGAvatarProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    QJsonArray availableAvatars();
    ~CGAvatarProvider();
protected:
    QString     mPath;
    QJsonArray  mAvatars;
};

#endif // CGFLAG_H
