#ifndef PIECEPROVIDER_H
#define PIECEPROVIDER_H

#include <QQuickImageProvider>
#include <QImage>
#include <QVariantMap>

class PieceProvider : public QQuickImageProvider
{
public:
    PieceProvider(int piece_width, int piece_height);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    QVariantMap getPieceLocation();
protected:
    int m_height;
    int m_width;
    QVariantMap m_table;
};

#endif // PIECEPROVIDER_H
