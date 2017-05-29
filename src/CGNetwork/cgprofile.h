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
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn)
    Q_PROPERTY(bool isBanned READ isBanned)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(int elo READ elo)
    Q_PROPERTY(QString flag READ flag WRITE setCountry NOTIFY countryChanged)
    Q_PROPERTY(int pieceSet  READ pieceSet)
    Q_PROPERTY(int language READ language)
    Q_PROPERTY(bool soundOn READ soundOn )
    Q_PROPERTY(bool useCoordinates READ useCoordinates )
    Q_PROPERTY(bool arrows READ arrows )
    Q_PROPERTY(bool autoPromote READ autoPromote )
    Q_PROPERTY(QString boardTheme READ boardTheme )
    Q_PROPERTY(QString avatar READ avatar  WRITE setAvatar NOTIFY avatarChanged)
    Q_PROPERTY(int cgdata READ cgdata)
    Q_PROPERTY(bool isValid READ isValid )
    Q_PROPERTY(bool color READ color WRITE setColor MEMBER mColor)

public:
    CGProfile(QQuickItem * parent = nullptr);
    ~CGProfile();

    // profile specific control methods
    Q_INVOKABLE bool isLoggedIn();
    Q_INVOKABLE bool isBanned();
    Q_INVOKABLE bool isValid();

    // login
    Q_INVOKABLE QString name();
    Q_INVOKABLE void setName(QString name);
    Q_INVOKABLE void setPassword(QByteArray byte);

    // player stats
    Q_INVOKABLE int elo();
    Q_INVOKABLE int gamesPlayed();
    Q_INVOKABLE qreal winRatio();

    // profile attributes
    Q_INVOKABLE QString flag();
    Q_INVOKABLE int cgdata();
    Q_INVOKABLE QString avatar();
    Q_INVOKABLE bool color(); //background?

    // application level
    Q_INVOKABLE int language();
    Q_INVOKABLE bool soundOn();

    // board specific
    Q_INVOKABLE int pieceSet();
    Q_INVOKABLE bool useCoordinates();
    Q_INVOKABLE bool arrows();
    Q_INVOKABLE bool autoPromote();
    Q_INVOKABLE QString boardTheme();


    // setters
    Q_INVOKABLE void setCountry(QString country);
    Q_INVOKABLE void setColor(bool color);
    Q_INVOKABLE void setAvatar(QString avatar);

signals:
    void profileSet();
    void profileChangesSaved(QString data);
    void receivedLastMatch(QString match);
    void failedToSaveChanges();
    void countryChanged(QString country);
    void avatarChanged(QString avatar);
    void nameChanged(QString name);


public slots:
    void setUserProfile(QString &data, QString &last);
    void requestUpdateProfile();

protected:
    bool       mColor;
    QByteArray mPass;
    CGServer  *mServer;
    CG_User    mUserData;
};

#endif // CGPROFILE_H
