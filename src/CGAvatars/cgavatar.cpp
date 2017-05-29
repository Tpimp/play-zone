#include "cgavatar.h"
#include <QJsonArray>
#include <QJsonDocument>
#include <QByteArray>
#include <QString>
#include <QDebug>

CGAvatarProvider::CGAvatarProvider()
    : QQuickImageProvider(QQuickImageProvider::Image), mPath(":/Avatars.JSON")
{
    Q_INIT_RESOURCE(avatars);
    QFile input_file(mPath);
    input_file.open(QIODevice::ReadOnly);
    QByteArray avatar_data = input_file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(avatar_data);
    mAvatars = doc.array();
}
QJsonArray CGAvatarProvider::availableAvatars()
{
    return mAvatars;
}

QImage CGAvatarProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize)
    if(!mAvatars.contains(id))
    {
        qDebug() << "Invalid avatar requested with name " << id;
        return QImage();
    }
    int width(256);
    int height(256);
    if(size){
        *size = QSize(width,height);
    }
    QString load_path(":/images/");
    load_path.append(id);
    load_path.append(".png");
    QImage image_out(load_path);
    return image_out;
}

CGAvatarProvider::~CGAvatarProvider()
{

}
