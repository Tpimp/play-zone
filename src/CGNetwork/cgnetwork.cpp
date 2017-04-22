#include "cgnetwork.h"
#include <QJsonDocument>
#include <QJsonObject>
static const char CG_L[] = "LI";  // Logged in
static const char CG_BAN[] = "BA";// Banned
static const char CG_UN[] = "UN"; // Username
static const char CG_E[] = "EL";  // Elo
static const char CG_CF[] = "CF"; // Country flag
static const char CG_PS[] = "PS"; // Piece Set
static const char CG_LANG[] ="LA";// Language
static const char CG_SND[] = "SN"; // sound
static const char CG_CO[] = "CO"; // Co-ordinates
static const char CG_AR[] = "AR"; // Arrows
static const char CG_AP[] ="AP"; // Auto Promote
static const char CG_BT[] ="BT"; // Board Theme
static const char CG_BF[] ="BF"; // Bit Field

QString CG_User::serializeUser(const CG_User &user)
{
    QString out;
    if(user.isValid){
        QJsonObject obj;
        obj[CG_AR] =user.arrows;
        obj[CG_AP] = user.autoPromote;
        obj[CG_BAN] = user.banned;
        obj[CG_BT] = user.boardTheme;
        obj[CG_BF] = int(user.cgbitfield);
        obj[CG_CO] = user.coordinates;
        obj[CG_CF] = user.countryFlag;
        obj[CG_E] = user.elo;
        obj[CG_LANG] = user.language;
        QJsonDocument doc;
        doc.setObject(obj);
        out = doc.toJson();
    }
    return out;
}

void CG_User::setUserStruct(CG_User & user, QString json_settings)
{

    QJsonDocument doc = QJsonDocument::fromJson(json_settings.toLocal8Bit());
    QJsonObject obj = doc.object();
    // get data out of obj
    user.username = obj.value(CG_UN).toString();
    user.arrows = obj.value(CG_AR).toBool();
    user.autoPromote = obj.value(CG_AP).toBool();
    user.banned = obj.value(CG_BAN).toBool();
    user.boardTheme = obj.value(CG_BT).toString();
    user.cgbitfield = quint32(obj.value(CG_BF).toInt());
    user.coordinates = obj.value(CG_CO).toBool();
    user.countryFlag = obj.value(CG_CF).toInt();
    user.elo = obj.value(CG_E).toInt();
    user.language = obj.value(CG_LANG).toInt();
    user.isValid = true;
}
