#ifndef PGNJ_H
#define PGNJ_H
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QJsonDocument>
#include <QList>



class PGNj
{
public:
    PGNj();

protected:
    QList<PGNj>   mRecords; // empty if contains a single record

    QJsonObject   mEvent;       // holds event information

    QJsonObject   mWhitePlayer; // holds white players details
    QJsonObject   mBlackPlayer; // hold black player details
    QJsonObject   mDateTime;    // stores regional time/date information (UTC format), start, finish, time control

    QJsonObject   mLocation;    // location information
    QJsonArray    mMoves;       // moves, ply count, move times etc.
    QJsonArray    mResult;      // result of the match
    QJsonObject   mComments;    // comments (commentator, annotator, playerW, playerB, etc.)
    QJsonArray    mTags;        // Quick reference tags ("blitz", "stalemate", etc.) for sorting and other things
    QJsonObject   mProperties;  // stores meta information (mode, etc.)

    QJsonObject   mPreConditions; // initial set-up changes (FEN) or handicaps can be described
};

#endif // PGNJ_H
