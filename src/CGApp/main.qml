import QtQuick 2.8
import QtQuick.Window 2.2
import CGNetwork 1.0


Window {
    id: background
    visible: true
    width: 400
    height: 600
    title: qsTr("Chessgames")
    property var lobbyView:undefined
    property var gameView:undefined
    property string opponent:""
    property real opelo:0
    property string opavatar:""
    property string opflag:""
    property bool playerColor:false



    Rectangle{
        id:app
        color: "#d4d4d4"
        anchors.fill: parent
        Image{
            anchors.fill: parent
            source:"/images/loginBG.png"
        }

        /****************************************************************
         *Window doesn't have states property so app acts
         * as the root state controller
         *
         *
         *
         *
         *
         *****************************************************************/
        states:[
            State{
                name:"LOGIN"
                PropertyChanges{target:loginView; state:"READY";}
                //PropertyChanges{target:gameLoader; active:false;}
                PropertyChanges{target:lobbyLoader; active:false;}
                PropertyChanges{target:loginView; visible:true;}
            },
            State{
                name:"LOBBY"
                PropertyChanges{target:lobbyLoader; active:true;}
                PropertyChanges{target:loginView; visible:false;}
            },
            State{
                name:"GAME"
                extend:"LOBBY"
                PropertyChanges{target:gameLoader; active:true;}
//                PropertyChanges{target:gameView; visible:true;}
            }

        ]
        state:"LOGIN"
    }




    CGProfile{
        id:playerProfile
        onProfileChangesSaved: {
            console.log("Saved Player Profile...")
        }
    }




    Loader{
        id:loadingLoader
        property string loadingText:""
        property int loadingDuration:750
        anchors.fill: parent
        active:true
        sourceComponent:CG_LoadingAnimation{
            visible:false
            text.text:loadingLoader.loadingText
            duration:loadingLoader.loadingDuration
            anchors.fill: parent
        }
    }

    LoginView{
        anchors.fill: parent
        id:loginView
        onStartLoading: {
            loadingLoader.item.text.text = text;
            loadingLoader.item.visible = true;
            loadingLoader.item.duration = duration;
        }
        onStopLoading: {
            loadingLoader.item.visible = false;
        }
        onLoggedIn: {
            app.state = "LOBBY"
        }
    }

    Loader{
        id:lobbyLoader
        sourceComponent:LobbyView{
            id:lobbyView
                anchors.fill: parent
                onLogout:{
                    loginView.disconnectFromHost();
                    app.state = "LOGIN";
                    loginView.status = "User Logout Successful";
                }
                onRequestUpdateProfile:{
                    playerProfile.requestUpdateProfile(loginView.username,loginView.password);
                    console.log("Sent Request to update proflie.")
                }
                onJoinMatchMaking:{
                    loadingLoader.item.text.text = "Finding Opponent...";
                    loadingLoader.item.visible = true;
                    loadingLoader.item.duration = 650;
                }
                onPlayerMatched:{

                    background.opponent = name;
                    background.opelo = elo;
                    background.opavatar = avatar;
                    background.opflag = country;
                    bakcground.playerColor = color;
                    app.state = "GAME";
                    loadingLoader.item.text.text = "";
                    loadingLoader.item.visible = false;

                }
            }
        onLoaded: {
            if(lobbyLoader.item != undefined){
                lobbyLoader.item.setProfile(playerProfile);
                lobbyLoader.item.parent = app
            }
        }
        active:false
    }

    Loader{
        id:gameLoader
        anchors.fill: parent
        sourceComponent: GameView{
            id:gameView
            visible:true
        }
        onLoaded: {
            if(gameLoader.item != undefined){
                //gameLoader.item.parent = app
                gameLoader.item.setProfile(playerProfile)
                gameLoader.item.startNewGame(opponent,opelo,opflag, playerColor,opavatar);
            }
        }
        active:false
    }



}
//    CGWebConnection{
//        id: webconnection
//        onConnectedToCGWeb: {
//            console.log("connected")
//        }
//        onUserCGVerified: {
//            console.log("Verified" + " with email " + email);
//        }
//        onDisconnectedFromCGWeb: {
//            console.log("Goodbye cg.com")
//        }

//    }

//    CGLogin{
//        id: login
//        anchors.fill:parent
//        onReadyForLogin:{
//            login.sendAuthentication(tf_username.text,tf_password.text)
//        }

//        onUserLoggedIn:{
//            console.log("User " + tf_username.text + " has logged in!")
//            login.visible = false;
//            lobby.visible = true;
//        }
//        onFailedToConnectToServer: {
//            txt_isOpen.text = "Cannot connect to server"
//        }

//        onProfileData: profile.setUserProfile(data);
//        CGProfile{
//            id: profile
//            onProfileSet:{

//            }
//            Component.onCompleted: {

//            }
//        }
//        Audio
//        {
//            id: iPod
//            source: "sounds/successfulLogin.mp3"
//            autoLoad: true

//            loops: 79 // TODO : Magic numbers
//        }



//        Column {
//            width: getSmallestOrientation()
//            anchors.centerIn: parent
//            spacing: 6

//            Image {
//                id: cg_logo_hires
//                source: "images/cg_logo.png"
//                anchors.horizontalCenter: parent.horizontalCenter
//                width: Login.getLogoSize()
//                height: Login.getLogoSize()

//                SequentialAnimation {
//                    SequentialAnimation {
//                        ParallelAnimation {
//                            YAnimator {
//                                target: cg_logo_hires;
//                                from: cg_logo_hires.y;
//                                to: cg_logo_hires.y/2;
//                                easing.type: Easing.OutExpo;
//                                duration: 300
//                            }
//                            ScaleAnimator {
//                                target: cg_logo_hires
//                                from: 1
//                                to: 0.5
//                                easing.type: Easing.OutExpo;
//                                duration: 300
//                            }
//                        }
//                        ParallelAnimation {
//                            YAnimator {
//                                target: cg_logo_hires;
//                                from: cg_logo_hires.y;
//                                to: cg_logo_hires.y/2;
//                                easing.type: Easing.OutBounce;
//                                duration: 1000
//                            }
//                            ScaleAnimator {
//                                target: cg_logo_hires
//                                from: 0.5
//                                to: 1
//                                easing.type: Easing.OutBounce;
//                                duration: 1000
//                            }
//                        }
//                    }
//                    PauseAnimation { duration: 10000 }
//                    running: true
//                    //loops: Animation.Infinite
//                }
//            }

//            Label {
//                id: txt_isOpen
//                text: "Registering Chessgames Account..."

//                // Adjusts the font size for scalability
//                font.pixelSize: getSmallestOrientation() * 0.05
//                anchors.horizontalCenter: parent.horizontalCenter
//            }
//            Label {
//                id: txt_isOpen
//                text: "Checking for Updates...Fetching File 8/22"

//                // Adjusts the font size for scalability
//                font.pixelSize: getSmallestOrientation() * 0.05
//                anchors.horizontalCenter: parent.horizontalCenter
//            }





    /**************************************************************
    *	  Purpose:  Get the background width of the app for all
    *               that need access to it.
    *
    *     Entry:    User has opened the application.
    *
    *     Exit:     Returns the width of the application.
    ****************************************************************/

//    function getBackgroundWidth()
//    {
//        return background.width
//    }

    /**************************************************************
    *	  Purpose:  Get the background height of the app for all
    *               that need access to it.
    *
    *     Entry:    User has opened the application.
    *
    *     Exit:     Returns the height of the application.
    ****************************************************************/

//    function getBackgroundHeight()
//    {
//        return background.height
//    }

    /**************************************************************
    *	  Purpose:  Get the smallest orientation for scalability
    *               purposes, whether it's the portrait or landscape
    *               orientation.
    *
    *     Entry:    User has opened the application.
    *
    *     Exit:     Returns the smallest orientation of the
    *               application.
    ****************************************************************/

//    function getSmallestOrientation()
//    {
//        return background.width < background.height ? background.width : background.height
//    }

//    function getLargestOrientation()
//    {
//        return background.width > background.height ? background.width : background.height
//    }

//    function isLandscape()
//    {
//        return getSmallestOrientation() == getBackgroundHeight() ? true : false
//    }

//    function isPortrait()
//    {
//        return !isLandscape()
//    }
//}
