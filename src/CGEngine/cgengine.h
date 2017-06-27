#ifndef CGENGINE_H
#define CGENGINE_H

#include <QObject>
#include <QQuickItem>
#include <QJsonArray>
#include <QJsonObject>
#include "pgnj.h"

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
    Q_INVOKABLE void isInCheck(int index, bool checkmate);
    Q_INVOKABLE void clearBoard();

    Q_INVOKABLE void handleGameOver(bool is_draw, bool is_checkmate, bool is_stalemate,
                                    bool is_threefold, bool insufficient_material, bool turn);

    Q_INVOKABLE void startNewGame(QJsonObject white, QJsonObject black, QJsonObject conditions,
                                  QJsonObject timedate);


    // Game review methods
    Q_INVOKABLE void startReviewGame(QJsonArray history, QString final_fen = "", bool start_last = true);
    Q_INVOKABLE void moveReviewFirst();
    Q_INVOKABLE void moveReviewBack();
    Q_INVOKABLE void moveReviewForward();
    Q_INVOKABLE void moveReviewLast();
    Q_INVOKABLE void setBoardToFEN(QString fen);

signals:
    void pieceCreated(QString type, QString color, int tile);
    void pieceMoved(int tile_from, int tile_to, QString promote);
    void pieceCaptured(int tile);
    void enPassant(int tile_from,int tile_to, int tile_destroy);
    void gotPieceInfo(int tile);
    void promotion(int tile, QString promote, QString color);
    void refreshPiece(QString type,QString color, int tile);
    void pushingPawn(int from, int to);
    void clearTile(int tile);
    void playerCheck(int index);
    void playerCheckmate(int index);
    void gameOverCheckmate(int result);
    void gameOverDraw(int type);
    void gameOverStaleMate();
    void removePiece(int index);
    void playersMove(bool white);
    void enPassantAvailable(QString tile);
    void halfMoveChanged(int halfmove);
    void plyCountChanged(int plycount);
    void moveTowardsLast();
    void moveTowardsFirst();

    // game review signalss
    void moveIndexChanged(int index);
    void reachedFront();
    void reachedBack();


public slots:
    void resetBoard(QJsonArray json_board);
    bool makeMove(int from, int to, QJsonObject move_data, QString promote);
    void refresh(QJsonObject data, int tile);
    bool makeAnimatedMove(QJsonObject move_data, QString promote);


protected:
    int  mCellSize;
    PGNj mGame;
    QJsonArray mGameHistory;
    int         mReviewIndex;
    static const char* const mNames[];
    int  getIndex(QString cell);
    void makeReviewMove(QJsonObject move);
    void undoReviewMove(QJsonObject move);

};

#endif // CGENGINE_H
