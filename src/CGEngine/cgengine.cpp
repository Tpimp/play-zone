#include "cgengine.h"
#include <QJsonDocument>
#include <QJsonValue>
#include <QDebug>

const char* const CGEngine::mNames[] =  {"a8","b8", "c8", "d8", "e8", "f8", "g8", "h8",
                                      "a7","b7", "c7", "d7", "e7", "f7", "g7", "h7",
                                      "a6","b6", "c6", "d6", "e6", "f6", "g6", "h6",
                                      "a5","b5", "c5", "d5", "e5", "f5", "g5", "h5",
                                      "a4","b4", "c4", "d4", "e4", "f4", "g4", "h4",
                                      "a3","b3", "c3", "d3", "e3", "f3", "g3", "h3",
                                      "a2","b2", "c2", "d2", "e2", "f2", "g2", "h2",
                                      "a1","b1", "c1", "d1", "e1", "f1", "g1", "h1"};

CGEngine::CGEngine(QQuickItem* parent) : QQuickItem(parent)
{

}


bool CGEngine::checkValidMove(QJsonArray moves, QString tile)
{
    if(moves.isEmpty()){
        return false;
    }
    for(QJsonValue val : moves){
        if(val.toString().contains(tile)){
            return true;
        }
    }
    return false;
}

QString CGEngine::getName(int index){
    if(index >= 0 && index < 64){
        return mNames[index];
    }
    return QString();
}

void CGEngine::resetBoard(QJsonArray json_board)
{
    //QJsonDocument  doc = QJsonDocument::fromJson(json_board.toLocal8Bit());
   // QJsonArray board_array = doc.array();
    int index(0);
    for(QJsonValue group:json_board)
    {
        QJsonArray group_array = group.toArray();
        if(group_array.count() >0){
            for(QJsonValue piece_val: group.toArray()){
                if(!piece_val.isNull()){
                    QJsonObject piece = piece_val.toObject();
                    QString type = piece["type"].toString();
                    QString color = piece["color"].toString();
                    emit pieceCreated(type,color,index);
                }
                index++;
            }
        }
        else
        {
            index++;
        }
    }
}

bool CGEngine::makeMove(int from, int to,QJsonObject move_data, QString promote)
{
    if(move_data.isEmpty()){
        return false;
    }
    QString flags = move_data["flags"].toString();
    if(flags.contains('c'))
    {
        // there was a capture
        emit pieceCaptured(to);
    }
    if(flags.contains('e'))
    {
        int mod_to = to %8;
        int mod_from = from %8;
        if(from > to){
            if(mod_to > mod_from){
                emit enPassant(from,to,from+1);
            }
            else{
                emit enPassant(from,to,from-1);
            }
        }
        else{
            if(mod_from > mod_to){
                emit enPassant(from,to,to+1);
            }
            else{
                emit enPassant(from,to,to-1);
            }
        }
    }
    if(flags.contains('q')){ // queen side castle
        if(from > 8)
        {
            emit pieceMoved(56,59,"");
        }
        else
        {
            emit pieceMoved(0,3,"");
        }
    }
    if(flags.contains('k')){ // king side castle
        if(from > 8)
        {
            emit pieceMoved(63,61,""); // white
        }
        else
        {
            emit pieceMoved(7,5,""); // black
        }
    }
    if(flags.contains('b'))
    {
        emit pushingPawn(from,to);
    }
    if(flags.contains('p'))
    {
        emit pieceMoved(from,to,promote);
        emit promotion(to,promote);
        return true;
    }
    emit pieceMoved(from,to,"");
    return true;
}

void CGEngine::isInCheck( int index){
    emit playerCheck(index);
}

void CGEngine::handleGameOver(bool is_draw, bool is_checkmate, bool is_stalemate, bool is_threefold, bool insufficient_material)
{
    if(is_draw){
        if(is_threefold){
            emit gameOverDraw(2);
        }
        else if(insufficient_material){
            emit gameOverDraw(1);
        }
        else{
            emit gameOverDraw(0);
        }
    }
    else if(is_checkmate){
        emit gameOverCheckmate();
    }
    else if (is_stalemate){
        emit gameOverStaleMate();
    }
}


void CGEngine::refresh(QJsonObject data, int tile)
{
    if(data.isEmpty()){
        emit clearTile(tile);
    }
    else{
        emit refreshPiece(data["type"].toString(),data["color"].toString(),tile);
    }
}

void CGEngine::setCellSize(int size){
    mCellSize = size;
}

CGEngine::~CGEngine()
{

}
