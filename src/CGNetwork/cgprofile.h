#ifndef CGPROFILE_H
#define CGPROFILE_H

#include <QQuickItem>
#include "cgnetwork.h"
class CGServer;

class CGProfile : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(CGProfile)
    // start building the properties
    // profile settings
    Q_PROPERTY(QString mUsername READ name NOTIFY nameChanged)
    Q_PROPERTY(QString mCountry READ country WRITE setCountry NOTIFY countryChanged)
    Q_PROPERTY(int mElo READ elo NOTIFY eloChanged)
    Q_PROPERTY(int mPieceSet READ pieceSet NOTIFY pieceSetChanged)
    Q_PROPERTY(bool mAutoPromote READ autoPromote NOTIFY autoPromoteChanged)
    Q_PROPERTY(QString mAvatar READ avatar WRITE setAvatar NOTIFY avatarChanged)
    Q_PROPERTY(quint64 mCGBitField READ cgdata NOTIFY cgDataChanged)
    Q_PROPERTY(quint64 mGamesPlayed READ gamesPlayed NOTIFY gamesPlayedChanged)
    Q_PROPERTY(quint64 mGamesWon READ gamesWon NOTIFY gamesWonChanged)
    Q_PROPERTY(quint64 mId READ id NOTIFY playerIDChanged)

    // Status properties
    Q_PROPERTY(bool mLoggedIn READ isLoggedIn NOTIFY loginStatusChanged)
    Q_PROPERTY(bool mBanned READ isBanned NOTIFY bannedChanged)
    Q_PROPERTY(bool mValid READ isValid NOTIFY profileValidated)


    // application settings
    Q_PROPERTY(int mLanguage READ language NOTIFY languageChanged)
    Q_PROPERTY(bool mStartSound READ playStartSound WRITE setStartSound NOTIFY startSoundChanged)

    // TODO: add properties for all the different start sounds

    // board settings
    Q_PROPERTY(QString mBoardDark READ boardDark NOTIFY darkChanged)
    Q_PROPERTY(QString mBoardLight READ boardLight NOTIFY lightChanged)
    Q_PROPERTY(bool mCoordinates READ useCoordinates NOTIFY coordinatesChanged )
    Q_PROPERTY(bool mArrows READ arrows NOTIFY arrowsChanged NOTIFY arrowsChanged)
    Q_PROPERTY(QString mBoardTexture READ boardTexture WRITE setBoardTexture NOTIFY boardTextureChanged)
    Q_PROPERTY(QString mBoardBackground READ boardBackground WRITE setBoardBackground NOTIFY boardBackgroundChanged)
    Q_PROPERTY(bool mBoldLines READ boldLines NOTIFY boldLinesChanged)



public:
    CGProfile(QQuickItem * parent = nullptr);
    ~CGProfile();

    // profile specific control methods
    Q_INVOKABLE bool isLoggedIn();
    Q_INVOKABLE bool isBanned();
    Q_INVOKABLE bool isValid();

    // profile
    Q_INVOKABLE QString name();
    Q_INVOKABLE int elo();
    Q_INVOKABLE quint64 gamesPlayed();
    Q_INVOKABLE quint64 gamesWon();
    Q_INVOKABLE quint64 id();
    Q_INVOKABLE qreal winRatio();
    Q_INVOKABLE QJsonObject getRecentPGN();
    Q_INVOKABLE QString country();
    Q_INVOKABLE quint64 cgdata();
    Q_INVOKABLE QString avatar();
    Q_INVOKABLE int pieceSet();
    Q_INVOKABLE bool autoPromote();

    // application level
    Q_INVOKABLE int language();
    Q_INVOKABLE bool playStartSound();

    // board specific
    Q_INVOKABLE bool useCoordinates();
    Q_INVOKABLE bool arrows();
    Q_INVOKABLE bool boldLines();
    Q_INVOKABLE QString boardTexture();
    Q_INVOKABLE QString boardDark();
    Q_INVOKABLE QString boardLight();
    Q_INVOKABLE QString boardBackground();


    // setters
    Q_INVOKABLE void setCountry(QString country);
    Q_INVOKABLE void setAvatar(QString avatar);
    Q_INVOKABLE void setStartSound(bool on);
    Q_INVOKABLE void setBoardTexture(QString texture);
    Q_INVOKABLE void setBoardBackground(QString background);



signals:

    void profileChangesSaved();
    void failedToSaveChanges(QString reason);

    // individual property signals
    void countryChanged(QString country);
    void nameChanged(QString name);
    void boardDarkChanged(QString dark);
    void boardLightChanged(QString light);
    void avatarChanged(QString avatar);
    void loginStatusChanged(bool loggedin);
    void bannedChanged(bool changed);
    void autoPromoteChanged(bool autopromote);
    void validChanged(bool valid);
    void eloChanged(int elo);
    void languageChanged(int language);
    void idChanged(quint64 id);
    void pieceSetChanged(int piece);
    void cgDataChanged(quint64 field);
    void gamesPlayedChanged(quint64 played);
    void gamesWonChanged(quint64 won);
    void playerIDChanged(quint64 id);
    void profileValidated(bool valid);
    void startSoundChanged(bool start);
    void darkChanged(QString dark);
    void lightChanged(QString light);
    void coordinatesChanged(bool coordinates);
    void arrowsChanged(bool arrows);
    void boldLinesChanged(bool bold);
    void boardTextureChanged(QString texture);
    void boardBackgroundChanged(QString background);

    // match related signals
    void lastMatchChanged(QJsonObject match);


public slots:

    void setUserProfile(QString data);
    void setRecentMatch(QString recent);
    void refreshData(QString data);

protected:

    QJsonObject  serializeProfile();
    bool        mWaitingSet;
    QJsonObject mRecentGame;
    CGServer   *mServer;

    // user data
    QString     mUsername;
    QString     mCountry;
    QString     mBoardDark;
    QString     mBoardLight;
    // TODO: add light highlight and dark highlight
    QString     mAvatar;
    QString     mBoardBackground;
    QString     mBoardTexture;

    bool        mLoggedIn;
    bool        mBanned;
    bool        mArrows;
    bool        mBoldLines;
    bool        mAutoPromote;
    bool        mValid;
    bool        mCoordinates;

    // sounds (add toggle for all sounds)
    bool        mStartSound;
    bool        mMoveSound;
    bool        mInvalidMoveSound;
    bool        mDrawOfferSound;
    bool        mDrawAcceptSound;
    bool        mStalemateSound;
    bool        mDrawSound;
    bool        mCheckSound;

    int         mElo;
    int         mLanguage;

    quint64     mGamesPlayed;
    quint64     mGamesWon;
    quint64     mId;

    quint64     mCGBitField;

    int         mPieceSet;
};

#endif // CGPROFILE_H
