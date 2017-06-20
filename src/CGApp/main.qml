import QtQuick 2.8
import QtQuick.Window 2.2
import CGNetwork 1.0
import QtMultimedia 5.8
Window {
    id: background
    visible: true
    width: 400
    height: 600
    title: qsTr("Chessgames")
    property var lobbyView:undefined
    property var gameView:undefined
    property string opponent:""
    property bool playerColor:false
    property double  serverPing:0
    onVisibilityChanged: {
        if(gameView !== null && gameView !== undefined){
            gameView.resizeBoard();
        }
    }

    CGProfile{
        id:playerProfile

    }


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
                extend:""
                //PropertyChanges{target:loginView; state:"READY";}
                PropertyChanges{target:gameLoader; active:false;}
                PropertyChanges{target:lobbyLoader; active:false;}
                PropertyChanges{target:loginView; visible:true;}
            },
            State{
                name:"LOBBY"
                PropertyChanges{target:gameLoader; active:false;}
                PropertyChanges{target:lobbyLoader; active:true;}
                PropertyChanges{target:loginView; visible:false;}
            },
            State{
                name:"GAME"
                extend:"LOBBY"
                PropertyChanges{target:gameLoader; active:true;}
            }

        ]
        state:"LOGIN"
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

    SoundEffect{
        id:loginSound
        source:"qrc:///sounds/successfulLogin.wav"
        volume: .4
        loops:0
    }
    LoginView{
        anchors.fill: parent
        id:loginView
        buttonSize: parent.height * .068
        onStartLoading: {
            loadingLoader.item.text.text = text;
            loadingLoader.item.visible = true;
            loadingLoader.item.duration = duration;
        }
        onStopLoading: {
            loadingLoader.item.visible = false;
        }
        onLoggedIn: {
            loginSound.play();
            app.state = "LOBBY"
        }
        onPing:
        {
            serverLatency.text = ping;
            serverPing = ping;
        }
    }
    SoundEffect{
        id:disconnectSound
        source:"qrc:///sounds/disconnect.wav"
        loops:0
    }
    Loader{
        id:lobbyLoader
        sourceComponent:LobbyView{
            id:lobbyView
                anchors.fill: parent
                onLogout:{
                    disconnectSound.play();
                    loginView.disconnectFromHost();
                    app.state = "LOGIN";
                    loginView.setStatus("User Logout Successful");
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
                    if(!color){
                        gameLoader.white.name = playerProfile.name();
                        gameLoader.white.elo = playerProfile.elo();
                        gameLoader.white.country = playerProfile.country();
                        gameLoader.white.avatar = playerProfile.avatar();
                        gameLoader.black.name = name;
                        gameLoader.black.elo = elo;
                        gameLoader.black.avatar = avatar;
                        gameLoader.black.country = country;
                    }
                    else{
                        gameLoader.black.name = playerProfile.name();
                        gameLoader.black.elo = playerProfile.elo();
                        gameLoader.black.country = playerProfile.country();
                        gameLoader.black.avatar = playerProfile.avatar();
                        gameLoader.white.name = name;
                        gameLoader.white.elo = elo;
                        gameLoader.white.avatar = avatar;
                        gameLoader.white.country = country;
                    }
                    app.state = "GAME";
                    loadingLoader.item.text.text = "";
                    loadingLoader.item.visible = false;
                }
            }
        onLoaded: {
            if(lobbyLoader.item != undefined){
                lobbyLoader.item.parent = app
                lobbyView = lobbyLoader.item;
            }
        }
        active:false
    }

    Loader{
        id:gameLoader
        anchors.fill: parent
        property real gameID:0
        property var  white:{
            "name":"",
            "country":"",
            "avatar":"",
            "elo":0
        }
        property var  black:{
            "name":"",
            "country":"",
            "avatar":"",
            "elo":0
        }
        sourceComponent: GameView{
            visible:true
            white:gameLoader.white
            black:gameLoader.black
            onGameOver: {
                app.state = "LOBBY";
            }
            onReviewGame:{
                app.state = "LOBBY";
                lobbyView.setReview(review,"",true);
            }
        }
        onLoaded: {
            if(gameLoader.item != undefined){
                background.gameView = gameLoader.item
                gameLoader.item.startNewGame(white,black);
                //gameLoader.item.startNewGame(opponent,opelo,opflag, playerColor,opavatar,gameID);
            }
        }
        active:false
    }

    Rectangle{
        color:"transparent"
        anchors.top:background.top
        anchors.horizontalCenter: background.horizontalCenter
        height:15
        width:15
        Text{
            id:serverLatency
            visible:false
            font.pixelSize: 18
            anchors.fill: parent
            anchors.leftMargin: 4
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea{
            anchors.fill: parent
            onDoubleClicked: serverLatency.visible = !serverLatency.visible;
        }
    }
}
