#ifndef CGNETWORK_H
#define CGNETWORK_H
#include <QString>
class CG_User
{
public:
    bool     loggedIn = false;
    bool     banned = false;
    QString  username = "";
    int      elo = 0;
    QString  countryFlag = "United States";
    int      pieceSet = 0;
    int      language = 0;
    bool     sound = false;
    bool     coordinates = false;
    bool     arrows = false;
    bool     autoPromote = false;
    QString  boardTheme = "";
    quint32  cgbitfield = 0;
    bool     isValid = false;
    QString  avatar = "";
    CG_User& operator =(const CG_User & user)
    {
        loggedIn = user.loggedIn;
        banned = user.banned;
        username = user.username;
        elo = user.elo;
        countryFlag = user.countryFlag;
        pieceSet = user.pieceSet;
        language = user.language;
        sound = user.sound;
        coordinates = user.coordinates;
        arrows = user.arrows;
        autoPromote = user.autoPromote;
        boardTheme = user.boardTheme;
        cgbitfield = user.cgbitfield;
        isValid = user.isValid;
        avatar = user.avatar;
        return *this;
    }
    static void setUserStruct(CG_User & user, QString json_settings);
    static QString serializeUser(const CG_User &user);
};

// Server message types

// Login
static const int VERIFY_USER =  453;
static const int REGISTER_USER =  543;


// Profile
static const int SET_USER_DATA =  6895;

// Lobby
static const int SEND_MESSAGE =  4512;
static const int JOIN_LOBBY =  4321;
static const int LEAVE_LOBBY =  4231;
static const int FETCH_LOBBIES   =  4555;


// Game
static const int JOIN_MATCHING =  5541;
static const int CANCEL_MATCHING =  5451;
static const int SEND_GAME_MESSAGE =  5421;
static const int CHOOSE_COLOR =  5114;
static const int SEND_MOVE =  5345;
static const int SEND_READY_STATUS =  5123;
static const int EXIT_MATCHING =  5231;
static const int FORFEIT_MATCH =  5899;







#endif // CGNETWORK_H
