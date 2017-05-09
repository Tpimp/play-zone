#include "cgengine.h"
#include <QJsonDocument>
#include <QJsonValue>
#include <QDebug>
CGEngine::CGEngine(QQuickItem* parent) : QQuickItem(parent)
{

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

bool CGEngine::makeMove(int from, int to,QJsonObject move_data)
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
            emit pieceMoved(56,59);
        }
        else
        {
            emit pieceMoved(0,3);
        }
    }
    if(flags.contains('k')){ // king side castle
        if(from > 8)
        {
            emit pieceMoved(63,61);
        }
        else
        {
            emit pieceMoved(7,5);
        }
    }
    if(flags.contains('b'))
    {
        emit pushingPawn(from,to);
    }
    if(flags.contains('p'))
    {
        emit pieceMoved(from,to);
        emit promotion(to);
        return true;
    }
    emit pieceMoved(from,to);
    return true;
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

CGEngine::~CGEngine()
{

}
