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


void CGEngine::clearBoard(){
    for(int index(0); index < 64; index++){
        emit clearTile(index);
    }
}

int CGEngine::getIndex(QString cell)
{
    if(cell.size()>=2){
        int col(-1);
        switch(cell.at(0).toLatin1()){
            case 'a':
                col = 0;
                break;
            case 'b':
                col = 1;
                break;
            case 'c':
                col = 2;
                break;
            case 'd':
                col = 3;
                break;
            case 'e':
                col = 4;
                break;
            case 'f':
                col = 5;
                break;
            case 'g':
                col = 6;
                break;
            case 'h':
                col = 7;
                break;
        }
        QString row_str = cell.right(1);
        int row = 8 - row_str.toInt();
        row *= 8;
        return row+ col;
    }
    return -1;
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
            emit clearTile(index);
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
        QString from_s = getName(from);
        QString to_s = getName(to);
        QString ep = to_s.at(0);
        ep.append(from_s.at(1));
        emit enPassant(from,to,getIndex(ep));
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
        emit promotion(to,promote,move_data.value("color").toString());
        return true;
    }
    emit pieceMoved(from,to,"");
    return true;
}

void CGEngine::makeReviewMove(QJsonObject move)
{
    // move from chess.js history
    // { color: 'b', from: 'e7', to: 'e5', flags: 'b', piece: 'p', san: 'e5' }
    makeMove(getIndex(move.value("from").toString()),getIndex(move.value("to").toString()),move,move.value("promotion").toString());
}

bool CGEngine::makeAnimatedMove( QJsonObject move_data,QString promote)
{
    int fromi = getIndex(move_data.value("from").toString());
    int toi = getIndex(move_data.value("to").toString());
    QString flags = move_data["flags"].toString();
    if(flags.contains('c'))
    {
        // there was a capture
        emit pieceCaptured(toi);
    }
    if(flags.contains('e'))
    {
        QString from_s = getName(fromi);
        QString to_s = getName(toi);
        QString ep = to_s.at(0);
        ep.append(from_s.at(1));
        emit enPassant(fromi,toi,getIndex(ep));
    }
    if(flags.contains('q')){ // queen side castle
        if(fromi > 8)
        {
            emit pieceMoved(56,59,"");
        }
        else
        {
            emit pieceMoved(0,3,"");
        }
    }
    if(flags.contains('k')){ // king side castle
        if(fromi > 8)
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
        emit pushingPawn(fromi,toi);
    }
    if(flags.contains('p'))
    {
        emit pieceMoved(fromi,toi,promote);
        emit promotion(toi,promote,move_data.value("color").toString());
        return true;
    }
    emit pieceMoved(fromi,toi,"");
    return true;
}

void CGEngine::isInCheck( int index, bool checkmate){
    if(checkmate){
        emit playerCheckmate(index);
    }
    else{
        emit playerCheck(index);
    }
}

void CGEngine::handleGameOver(bool is_draw, bool is_checkmate, bool is_stalemate,
                              bool is_threefold, bool insufficient_material, bool turn)
{
    if(is_draw){
        if(is_threefold){
            emit gameOverDraw(12);
        }
        else if(insufficient_material){
            emit gameOverDraw(13);
        }
        else{ // else 50 move rule
            emit gameOverDraw(11);
        }
    }
    else if(is_checkmate){
        if(turn){
            emit gameOverCheckmate(1);
        }
        else
        {
            emit gameOverCheckmate(-1);
        }
    }
    else if (is_stalemate){
        emit gameOverStaleMate();
    }
}


void CGEngine::moveReviewBack()
{
    if(mReviewIndex > 0){
        QJsonObject move = mGameHistory.at(--mReviewIndex).toObject();
        undoReviewMove(move);
        emit moveIndexChanged(mReviewIndex);
    }
}

void CGEngine::moveReviewFirst()
{
    if(mReviewIndex > 0){
        emit moveTowardsFirst();
    }
}

void CGEngine::moveReviewForward()
{
    int length = mGameHistory.count();
    int current = mReviewIndex;
    if(current < length){
        QJsonObject move = mGameHistory.at(mReviewIndex).toObject();
        makeReviewMove(move);
        mReviewIndex++;
        emit moveIndexChanged(mReviewIndex);
    }
}

void CGEngine::moveReviewLast()
{
    int length = mGameHistory.count();
    int current = mReviewIndex;
    if( current < length){
        emit moveTowardsLast();
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


void CGEngine::startNewGame(QJsonObject white, QJsonObject black, QJsonObject conditions, QJsonObject timedate)
{

}


void CGEngine::startReviewGame(QJsonArray history, QString final_fen,  bool start_last)
{
    mReviewIndex = 0;
    mGameHistory = history;
    // History object comes from chess.js pgn function
    // -> [{ color: 'w', from: 'e2', to: 'e4', flags: 'b', piece: 'p', san: 'e4' },
    //     { color: 'b', from: 'e7', to: 'e5', flags: 'b', piece: 'p', san: 'e5' },
    //     { color: 'w', from: 'f2', to: 'f4', flags: 'b', piece: 'p', san: 'f4' },
    //     { color: 'b', from: 'e5', to: 'f4', flags: 'c', piece: 'p', captured: 'p', san: 'exf4' }]

    if(final_fen.isEmpty() && start_last){
        // must iterate throught the moves
        setBoardToFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
        emit moveTowardsLast();
    }
    else if(!final_fen.isEmpty()){
        // set board to final fen and set index to final move
        setBoardToFEN(final_fen);
        mReviewIndex = mGameHistory.count();
        emit reachedBack();
    }
    else{
        setBoardToFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
        emit reachedFront();
    }
    emit moveIndexChanged(mReviewIndex);
}

void CGEngine::setBoardToFEN(QString fen){
    bool whites_turn(true);
    QString castles;
    QString enPassant_move;
    QString clock_str;
    int     halfmove_clock;
    int     move_index;
    int index(0);
    int tile_index(0);
    QChar tile('2');
    while(!tile.isSpace()){ // parse position data
        tile = fen.at(index);
        if(tile.isDigit()){
            QString d_str(tile);
            int digit = d_str.toInt();
            if(digit > 0 && digit < 9){
                for(int i(0); i < digit; i++){
                    emit clearTile(tile_index++);
                }
            }
        }
        else if(tile.isLetter()){ // found a piece
            QString type(tile.toLower());
            QString color;
            color = tile.isLower() ? 'b':'w';
            emit pieceCreated(type,color,tile_index++);
        }
        index++;
    }
    // parse move, castle items,enpassant, half clock, current move
    QChar move = fen.at(++index);
    if(move.toLatin1() == 'b'){
        whites_turn = false;
    }
    emit playersMove(whites_turn);
    index +=2; // move to castle
    tile = fen.at(index); // front of castle
    while(!tile.isSpace()){
        castles.append(tile);
        tile = fen.at(++index);
    }
    index += 1;
    tile = fen.at(index); // enpassant
    while(!tile.isSpace()){
        enPassant_move.append(tile);
        tile = fen.at(++index);
    }
    if(enPassant_move.compare("-") != 0){
        enPassantAvailable(enPassant_move);
    }
    index += 1;
    tile = fen.at(index); // halfmove
    char c = tile.toLatin1();
    halfmove_clock = atoi(&c);
    emit halfMoveChanged(halfmove_clock);
    index += 2; // move to move clock
    while(index < fen.length()){
        tile = fen.at(index++);
        clock_str.append(tile);
    }
    if(!clock_str.isEmpty()){
        move_index = clock_str.toInt();
        emit plyCountChanged(move_index);
    }
}

void CGEngine::undoReviewMove(QJsonObject move)
{
    // chess.js move
    //     { color: 'b', from: 'e7', to: 'e5', flags: 'b', piece: 'p', san: 'e5' }
    QString from_s = move.value("from").toString();
    QString to_s = move.value("to").toString();
    QString flags = move.value("flags").toString();
    QString rank_strf;
    int to = getIndex(to_s);
    int from = getIndex(from_s);
    rank_strf.append(from_s.at(1));
    int f_rank = rank_strf.toInt();
    QString color = move.value("color").toString();
    QString op_color;
    if(color.contains("w")){
        op_color = "b";
    }
    else{
        op_color = "w";
    }

    if(flags.contains('e'))  // reverse enPassant
    {
        QChar piece = move.value("captured").toString().at(0);
        QString type;
        type.append(piece.toLower());
        QString c_rank= to_s.at(0);
        c_rank.append(from_s.at(1));
        emit pieceCreated(type,op_color,getIndex(c_rank));
    }
    if(flags.contains('q')){ // queen side castle
        if( f_rank == 4)
        {
            emit pieceMoved(59,56,"");
        }
        else
        {
            emit pieceMoved(3,0,"");
        }
    }
    if(flags.contains('k')){ // king side castle
        if(f_rank == 1)
        {
            emit pieceMoved(61,63,""); // white
        }
        else
        {
            emit pieceMoved(5,7,""); // black
        }
    }
    if(flags.contains('p'))
    {
        emit removePiece(to);
        emit pieceCreated("p",color,to);
    }
    emit pieceMoved(to,from,"");
    if(flags.contains("c"))
    {
        // there was a capture
        QChar piece = move.value("captured").toString().at(0);
        QString type;
        type.append(piece);
        emit pieceCreated(type,op_color,to);
    }
}

CGEngine::~CGEngine()
{

}
