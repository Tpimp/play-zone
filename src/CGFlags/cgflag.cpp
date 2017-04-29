#include "cgflag.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QByteArray>
#include <QDebug>

CGFlagProvider::CGFlagProvider()
    : QQuickImageProvider(QQuickImageProvider::Image), mFlags(":/FlagMap.JSON")
{
    Q_INIT_RESOURCE(flags);
    QFile input_file(mFlags);
    input_file.open(QIODevice::ReadOnly);
    QByteArray flag_data = input_file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(flag_data);
    QJsonObject obj = doc.object();
    mFlagMap = obj.toVariantMap();

}
QStringList CGFlagProvider::availableCountries()
{
    return mFlagMap.keys();
}

QImage CGFlagProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    if(!mFlagMap.contains(id))
    {
        qDebug() << "Invalid flag requested for country " << id;
        return QImage();
    }
    int width(203);
    int height(202);
    if(size){
        *size = QSize(width,height);
    }
    QImage image_out(requestedSize.width() > 0 ? requestedSize : QSize(width,height),QImage::Format_RGB666);
    QVariantMap flag_data = mFlagMap[id].toMap();
    int id_int = flag_data.value("id").toInt();
    QString set = ":/images/";
    set.append(flag_data.value("set").toString());
    set.append(".png");
    QImage loaded(set);
    int right_offset = ((id_int%5 )* 244) +37;
    int vertical_offset = ((id_int/5) * 244) + 37;
    QImage flag_image = loaded.copy( right_offset ,  vertical_offset,width,height);
    //flag_image.save("C:/Users/Christopher/Documents/GitHub/build-play-zone-Desktop_5_8-Debug/app/debug/test.png");
    return flag_image;
}

CGFlagProvider::~CGFlagProvider()
{

}
