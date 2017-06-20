#include "cgprofile.h"
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "cgserver.h"

CGProfile::CGProfile(QQuickItem *parent) : QQuickItem(parent)
{
    mServer = CGServer::globalServer();
    connect(mServer, &CGServer::setProfileData,this,&CGProfile::setUserProfile);
    //connect(mServer, &CGServer::failedToSetUserData,this,&CGProfile::failedToSaveChanges);
    connect(mServer, &CGServer::refreshUserData , this, &CGProfile::refreshData);
}

bool CGProfile::isValid()
{
    return mValid;
}

bool CGProfile::isLoggedIn()
{
    return mLoggedIn;
}

bool CGProfile::isBanned()
{
    return mBanned;
}

QString CGProfile::name()
{
    return mUsername;
}

bool CGProfile::boldLines()
{
    return mBoldLines;
}


int CGProfile::elo()
{
    return mElo;
}

QString CGProfile::country()
{
    return mCountry;
}

void CGProfile::setCountry(QString country)
{
    if(country.compare(mCountry) != 0){
        mCountry = country;
        mServer->updateProfile(serializeProfile());
        emit countryChanged(country);
    }
}

void CGProfile::setStartSound(bool on)
{
    mStartSound = on;
}

int CGProfile::language()
{
    return mLanguage;
}

int CGProfile::pieceSet()
{
    return mPieceSet;
}

bool CGProfile::playStartSound()
{
    return mStartSound;
}

bool CGProfile::useCoordinates()
{
    return mCoordinates;
}

bool CGProfile::arrows()
{
    return mArrows;
}

QString CGProfile::avatar()
{
    return mAvatar;
}

bool CGProfile::autoPromote()
{
    return mAutoPromote;
}

QString CGProfile::boardLight()
{
    return mBoardLight;
}

QString CGProfile::boardDark()
{
    return mBoardDark;
}

QString CGProfile::boardTexture()
{
    return mBoardTexture;
}

QString CGProfile::boardBackground()
{
    return mBoardBackground;
}

quint64 CGProfile::cgdata()
{
    return mCGBitField;
}

quint64 CGProfile::gamesPlayed()
{
    return mGamesPlayed;
}

quint64 CGProfile::id()
{
    return mId;
}

quint64 CGProfile::gamesWon()
{
    return mGamesWon;
}

void CGProfile::refreshData(QString data){
    QJsonDocument doc = QJsonDocument::fromJson(data.toLocal8Bit());
    QJsonObject user = doc.object();
    if(user.contains(CG_AR)){
        bool arrows = user.value(CG_AR).toBool();
        if(arrows != mArrows){
            mArrows = arrows;
            emit arrowsChanged(arrows);
        }
    }
    if(user.contains(CG_AP)){
        bool ap = user.value(CG_AP).toBool();
        if(ap != mAutoPromote){
            mAutoPromote = ap;
            emit autoPromoteChanged(ap);
        }
    }
    if(user.contains(CG_BAN)){
        bool ban = user.value(CG_BAN).toBool();
        if(ban != mBanned){
            mBanned = ban;
            emit bannedChanged(ban);
        }
    }
    if(user.contains(CG_BT)){
        QString bt = user.value(CG_BT).toString();
        if(bt.compare(mBoardTexture) != 0){
            mBoardTexture = bt;
            emit boardTextureChanged(bt);
        }
    }
    if(user.contains(CG_BF)){
        quint64 bitfield  = quint64(user.value(CG_BF).toDouble());
        if(bitfield != mCGBitField){
            mCGBitField = bitfield;
            emit cgDataChanged(bitfield);
        }
    }
    if(user.contains(CG_CO)){
        bool coords = user.value(CG_CO).toBool();
        if(coords != mCoordinates){
            mCoordinates = coords;
            emit coordinatesChanged(coords);
        }
    }
    if(user.contains(CG_CF)){
        QString country = user.value(CG_CF).toString();
        if(country.compare(mCountry) != 0){
            mCountry = country;
            emit countryChanged(country);
        }
    }
    if(user.contains(CG_LANG)){
        int language = user.value(CG_LANG).toInt();
        if(language != mLanguage){
            mLanguage = language;
            emit languageChanged(language);
        }
    }
    if(user.contains(CG_SND)){
        bool sound = user.value(CG_SND).toBool();
        if(sound != mStartSound){
            mStartSound = sound;
            emit startSoundChanged(sound);
        }
    }
    if(user.contains(CG_PS)){
        int piece = user.value(CG_PS).toInt();
        if(piece != mPieceSet){
            mPieceSet = piece;
            emit pieceSetChanged(piece);
        }
    }
    if(user.contains(CG_AV)){
        QString avatar = user.value(CG_AV).toString();
        if(avatar.compare(mAvatar) != 0){
            mAvatar = avatar;
            emit avatarChanged(avatar);
        }
    }
    if(user.contains(CG_E)){
        int elo = user.value(CG_E).toInt();
        if(elo != mElo){
            mElo = elo;
            emit eloChanged(elo);
        }
    }
    if(user.contains(CG_TOTL)){
        quint64  total = quint64(user.value(CG_TOTL).toDouble());
        if(total != mGamesPlayed){
            mGamesPlayed = total;
            emit gamesPlayedChanged(mGamesPlayed);
        }
    }
    if(user.contains(CG_WON)){
        quint64 won = quint64(user.value(CG_WON).toDouble());
        if(won != mGamesWon){
            mGamesWon = won;
            emit gamesWonChanged(won);
        }
    }
    if(user.contains(CG_AV)){
        QString avatar = user.value(CG_AV).toString();
        if(avatar.compare(mAvatar) != 0){
            mAvatar = avatar;
            emit avatarChanged(avatar);
        }
    }
    if(user.contains(CG_UN)){
        QString name = user.value(CG_UN).toString();
        if(name.compare(mUsername) != 0){
            mUsername = name;
            emit nameChanged(name);
        }
    }
    if(user.contains(CG_ID)){
        quint64 id = quint64(user.value(CG_ID).toDouble());
        if(id != mId){
            mId = id;
            emit playerIDChanged(id);
        }
    }

}



void CGProfile::setAvatar(QString avatar)
{
    if(mAvatar.compare(avatar) != 0){
        mAvatar = avatar;
        mServer->updateProfile(serializeProfile());
        emit avatarChanged(avatar);
    }
}


QJsonObject CGProfile::getRecentPGN()
{
    QJsonDocument doc = QJsonDocument::fromJson(mRecentGame.value("snap").toString().toLocal8Bit());
    QJsonObject pgn = doc.object();
    return pgn;
}

void CGProfile::setRecentMatch(QString recent)
{
    QJsonDocument doc = QJsonDocument::fromJson(recent.toLocal8Bit());
    mRecentGame = doc.object();
}

void CGProfile::setUserProfile(QString data)
{
    QJsonDocument doc = QJsonDocument::fromJson(data.toLocal8Bit());
    QJsonObject user = doc.object();
    if(user.contains(CG_AR)){
        bool arrows = user.value(CG_AR).toBool();
        if(arrows != mArrows){
            mArrows = arrows;
            emit arrowsChanged(arrows);
        }
    }
    if(user.contains(CG_AP)){
        bool ap = user.value(CG_AP).toBool();
        if(ap != mAutoPromote){
            mAutoPromote = ap;
            emit autoPromoteChanged(ap);
        }
    }
    if(user.contains(CG_BAN)){
        bool ban = user.value(CG_BAN).toBool();
        if(ban != mBanned){
            mBanned = ban;
            emit bannedChanged(ban);
        }
    }
    if(user.contains(CG_BT)){
        QString bt = user.value(CG_BT).toString();
        if(bt.compare(mBoardTexture) != 0){
            mBoardTexture = bt;
            emit boardTextureChanged(bt);
        }
    }
    if(user.contains(CG_BF)){
        quint64 bitfield  = quint64(user.value(CG_BF).toDouble());
        if(bitfield != mCGBitField){
            mCGBitField = bitfield;
            emit cgDataChanged(bitfield);
        }
    }
    if(user.contains(CG_CO)){
        bool coords = user.value(CG_CO).toBool();
        if(coords != mCoordinates){
            mCoordinates = coords;
            emit coordinatesChanged(coords);
        }
    }
    if(user.contains(CG_CF)){
        QString country = user.value(CG_CF).toString();
        if(country.compare(mCountry) != 0){
            mCountry = country;
            emit countryChanged(country);
        }
    }
    if(user.contains(CG_LANG)){
        int language = user.value(CG_LANG).toInt();
        if(language != mLanguage){
            mLanguage = language;
            emit languageChanged(language);
        }
    }
    if(user.contains(CG_SND)){
        bool sound = user.value(CG_SND).toBool();
        if(sound != mStartSound){
            mStartSound = sound;
            emit startSoundChanged(sound);
        }
    }
    if(user.contains(CG_PS)){
        int piece = user.value(CG_PS).toInt();
        if(piece != mPieceSet){
            mPieceSet = piece;
            emit pieceSetChanged(piece);
        }
    }
    if(user.contains(CG_AV)){
        QString avatar = user.value(CG_AV).toString();
        if(avatar.compare(mAvatar) != 0){
            mAvatar = avatar;
            emit avatarChanged(avatar);
        }
    }
    if(user.contains(CG_E)){
        int elo = user.value(CG_E).toInt();
        if(elo != mElo){
            mElo = elo;
            emit eloChanged(elo);
        }
    }
    if(user.contains(CG_TOTL)){
        quint64  total = quint64(user.value(CG_TOTL).toDouble());
        if(total != mGamesPlayed){
            mGamesPlayed = total;
            emit gamesPlayedChanged(mGamesPlayed);
        }
    }
    if(user.contains(CG_WON)){
        quint64 won = quint64(user.value(CG_WON).toDouble());
        if(won != mGamesWon){
            mGamesWon = won;
            emit gamesWonChanged(won);
        }
    }
    if(user.contains(CG_UN)){
        QString name = user.value(CG_UN).toString();
        if(name.compare(mUsername) != 0){
            mUsername = name;
            emit nameChanged(name);
        }
    }
    if(user.contains(CG_ID)){
        quint64 id = quint64(user.value(CG_ID).toDouble());
        if(id != mId){
            mId = id;
            emit playerIDChanged(id);
        }
    }
}

void CGProfile::setBoardTexture(QString texture)
{
    mBoardTexture = texture;
}

void CGProfile::setBoardBackground(QString background)
{
    mBoardBackground = background;
}



QJsonObject CGProfile::serializeProfile()
{
    QJsonObject obj;
    obj[CG_AV] = mAvatar;
    obj[CG_AP] = mAutoPromote;
    obj[CG_AR] = mArrows;
    obj[CG_BF] = double(mCGBitField);
    obj[CG_BT] = mBoardTexture;
    obj[CG_CF] = mCountry;
    obj[CG_CO] = mCoordinates;
    obj[CG_E] = mElo;
    obj[CG_ID] = double(mId);
    obj[CG_LANG] = mLanguage;
    obj[CG_PS] = mPieceSet;
    obj[CG_SND] = mStartSound;
    obj[CG_WON] = double(mGamesWon);
    obj[CG_TOTL] = double(mGamesPlayed);
    obj[CG_UN] = mUsername;
    return obj;
}

qreal CGProfile::winRatio()
{
    return qreal(mGamesWon)/qreal(mGamesPlayed) * qreal(100);
}

CGProfile::~CGProfile()
{

}
