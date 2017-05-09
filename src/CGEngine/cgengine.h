#ifndef CGENGINE_H
#define CGENGINE_H

#include <QObject>
#include <QQuickItem>
#include <QJsonArray>
#include <QJsonObject>
class CGEngine : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGEngine)
public:
    CGEngine(QQuickItem *parent = nullptr);
    ~CGEngine();

signals:
    void pieceCreated(QString type, QString color, int tile);
    void pieceMoved(int tile_from, int tile_to);
    void pieceCaptured(int tile);
    void enPassant(int tile_from,int tile_to, int tile_destroy);
    void gotPieceInfo(int tile);
    void promotion(int tile);
    void refreshPiece(QString type,QString color, int tile);
    void pushingPawn(int from, int to);
    void clearTile(int tile);

public slots:
    void resetBoard(QJsonArray json_board);
    bool makeMove(int from, int to, QJsonObject move_data);
    void refresh(QJsonObject data, int tile);

};

#endif // CGENGINE_H
