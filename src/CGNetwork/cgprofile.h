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
    Q_PROPERTY(QString name READ name)
    Q_PROPERTY(int elo READ elo)
    Q_PROPERTY(int flag READ flag)
    Q_PROPERTY(int pieceSet  READ pieceSet)
    Q_PROPERTY(int language READ language)
    Q_PROPERTY(bool soundOn READ soundOn )
    Q_PROPERTY(bool useCoordinates READ useCoordinates )
    Q_PROPERTY(bool arrows READ arrows )
    Q_PROPERTY(bool autoPromote READ autoPromote )
    Q_PROPERTY(QString boardTheme READ boardTheme )
    Q_PROPERTY(int cgdata READ cgdata)
    Q_PROPERTY(bool isValid READ isValid )

public:
    CGProfile(QQuickItem * parent = nullptr);
    ~CGProfile();
    Q_INVOKABLE bool isLoggedIn();
    Q_INVOKABLE bool isBanned();
    Q_INVOKABLE QString name();
    Q_INVOKABLE int elo();
    Q_INVOKABLE int flag();
    Q_INVOKABLE int language();
    Q_INVOKABLE int pieceSet();
    Q_INVOKABLE bool soundOn();
    Q_INVOKABLE bool useCoordinates();
    Q_INVOKABLE bool arrows();
    Q_INVOKABLE bool autoPromote();
    Q_INVOKABLE QString boardTheme();
    Q_INVOKABLE int cgdata();
    Q_INVOKABLE bool isValid();

signals:
    void profileSet();
    void profileChangesSaved();

public slots:
    void setUserProfile(QString &data);
    void requestUpdateProfile(QString name, QString pass);

protected:
    CGServer  *mServer;
    CG_User    mUserData;
};

#endif // CGPROFILE_H
