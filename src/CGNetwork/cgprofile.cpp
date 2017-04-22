#include "cgprofile.h"
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
CGProfile::CGProfile(QQuickItem *parent) : QQuickItem(parent)
{
    mServer = CG_SERVER_S();
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

int CGProfile::flag()
{
    return mUserData.countryFlag;
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

bool CGProfile::isValid()
{
    return mUserData.isValid;
}

void CGProfile::setUserProfile(QString data)
{
    CG_User::setUserStruct(mUserData,data);
    emit profileSet();
}
void CGProfile::requestUpdateProfile(QString name, QString pass)
{
    QCryptographicHash hasher(QCryptographicHash::Sha256);
    hasher.addData(pass.toLocal8Bit());
    QByteArray hpass = hasher.result().toHex();

    QJsonObject obj;
    QJsonArray array;
    obj["T"] = SET_USER_DATA;
    // name, pass, data
    array.append(name);
    QString pass_str = QString::fromLatin1(hpass,hpass.size());
    array.append(pass_str);
    array.append(CG_User::serializeUser(mUserData));
    obj["P"] = array;
    QJsonDocument doc;
    doc.setObject(obj);
    QByteArray output = doc.toBinaryData();
    mServer->writeMessage(output);
}

CGProfile::~CGProfile()
{

}
