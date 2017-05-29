#include "cgprofile.h"
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "cgserver.h"
CGProfile::CGProfile(QQuickItem *parent) : QQuickItem(parent)
{
    mServer = CGServer::globalServer();
    connect(mServer, &CGServer::userProfileData,this,&CGProfile::setUserProfile);
    connect(mServer, &CGServer::setUserData,this,&CGProfile::setUserProfile);
    connect(mServer, &CGServer::failedToSetUserData,this,&CGProfile::failedToSaveChanges);
}

bool CGProfile::color()
{
    return mColor;
}

bool CGProfile::isLoggedIn()
{
    return mUserData.loggedIn;
}

bool CGProfile::isBanned()
{
    return mUserData.banned;
}

QString CGProfile::name()
{
    return mUserData.username;
}

int CGProfile::elo()
{
    return mUserData.elo;
}

QString CGProfile::flag()
{
    return mUserData.countryFlag;
}

void CGProfile::setCountry(QString country)
{
    if(country.compare(mUserData.countryFlag) != 0){
        mUserData.countryFlag = country;
        emit countryChanged(country);
    }
}

int CGProfile::language()
{
    return mUserData.language;
}

int CGProfile::pieceSet()
{
    return mUserData.pieceSet;
}

bool CGProfile::soundOn()
{
    return mUserData.sound;
}

bool CGProfile::useCoordinates()
{
    return mUserData.coordinates;
}

bool CGProfile::arrows()
{
    return mUserData.arrows;
}

QString CGProfile::avatar()
{
    return mUserData.avatar;
}

bool CGProfile::autoPromote()
{
    return mUserData.autoPromote;
}

QString CGProfile::boardTheme()
{
    return mUserData.boardTheme;
}

int CGProfile::cgdata()
{
    return mUserData.cgbitfield;
}

int CGProfile::gamesPlayed()
{
    return 0;
}

bool CGProfile::isValid()
{
    return mUserData.isValid;
}

void CGProfile::setName(QString name)
{
    if(mUserData.username.compare(name) != 0){
        mUserData.username = name;
        emit nameChanged(name);
    }
}

void CGProfile::setAvatar(QString avatar)
{
    if(avatar.compare(mUserData.avatar) != 0){
        mUserData.avatar = avatar;
        emit avatarChanged(avatar);
    }
}

void CGProfile::setColor(bool color)
{
    mColor = color;
}

void CGProfile::setUserProfile(QString &data, QString &last)

{
    CG_User::fromData(mUserData,data);
    if(!last.isEmpty()){
        qDebug() << "Profiles most recent match: " << last;
    }

    emit avatarChanged(mUserData.avatar);
    emit countryChanged(mUserData.countryFlag);
    emit profileSet();
}
void CGProfile::requestUpdateProfile()
{
    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SET_USER_DATA;
    // name, pass, data
    array.append(mUserData.username);
    array.append(QString::fromLatin1(mPass));
    array.append(CG_User::serializeUser(mUserData));
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mServer->writeMessage(output);
}


void CGProfile::setPassword(QByteArray byte)
{
    if(mPass != byte){
        mPass = byte;
    }
}

qreal CGProfile::winRatio()
{
    return 50.432;
}

CGProfile::~CGProfile()
{

}
