#include "pieceprovider.h"

PieceProvider::PieceProvider(int piece_width, int piece_height)
    : QQuickImageProvider(QQuickImageProvider::Image), m_width(piece_width),m_height(piece_height)
{
    m_table.insert("kb","0");
    m_table.insert("qb","1");
    m_table.insert("nb","2");
    m_table.insert("bb","3");
    m_table.insert("rb","4");
    m_table.insert("pb","5");
    m_table.insert("kw","6");
    m_table.insert("qw","7");
    m_table.insert("nw","8");
    m_table.insert("bw","9");
    m_table.insert("rw","10");
    m_table.insert("pw","11");
}

QImage PieceProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    int index = id.indexOf('#');
    QString location;
    QString id_copy(id);
    if(index){
        location = id.right(id.length() - (index)-1);
        id_copy.chop(id.length() - index);
    }
    id_copy.prepend(":/images/");
    QImage img(id_copy);
    if(location.length() > 0){
        int loc = location.toInt();
        return img.copy(m_width*loc,0,m_width,m_height);
    }
    return img;
}


QVariantMap PieceProvider::getPieceLocation()
{
    return m_table;
}
