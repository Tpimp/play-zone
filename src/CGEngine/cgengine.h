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
    Q_INVOKABLE bool checkValidMove(QJsonArray moves, QString tile);
    Q_INVOKABLE QString getName(int index);
    Q_INVOKABLE void setCellSize(int size);
    Q_INVOKABLE void isInCheck(int index);
    Q_INVOKABLE void handleGameOver(bool is_draw, bool is_checkmate, bool is_stalemate,
                                    bool is_threefold, bool insufficient_material);

signals:
    void pieceCreated(QString type, QString color, int tile);
    void pieceMoved(int tile_from, int tile_to, QString promote);
    void pieceCaptured(int tile);
    void enPassant(int tile_from,int tile_to, int tile_destroy);
    void gotPieceInfo(int tile);
    void promotion(int tile, QString promote);
    void refreshPiece(QString type,QString color, int tile);
    void pushingPawn(int from, int to);
    void clearTile(int tile);
    void playerCheck(int index);
    void gameOverCheckmate();
    void gameOverDraw(int type);
    void gameOverStaleMate();

public slots:
    void resetBoard(QJsonArray json_board);
    bool makeMove(int from, int to, QJsonObject move_data, QString promote);
    void refresh(QJsonObject data, int tile);


protected:
    int  mCellSize;
    static const char* const mNames[];
};

#endif // CGENGINE_H
