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
    property real opelo:0
    property string opavatar:""
    property string opflag:""
    property bool playerColor:false
    property double  gameID:-1
    onVisibilityChanged: {
        if(gameView !== null && gameView !== undefined){
            gameView.resizeBoard();
        }
    }

    CGProfile{
        id:profile

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
        onStartLoading: {
            loadingLoader.item.text.text = text;
            loadingLoader.item.visible = true;
            loadingLoader.item.duration = duration;
        }
        onStopLoading: {
            loadingLoader.item.visible = false;
        }
        onLoggedIn: {
            profile.setName(loginView.username)
            profile.setPassword(loginView.getPassword())
            loginSound.play();
            app.state = "LOBBY"
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
                    background.opavatar =  avatar;
                    background.opflag = country;
                    background.playerColor = color;
                    gameID = id;
                    app.state = "GAME";
                    loadingLoader.item.text.text = "";
                    loadingLoader.item.visible = false;
                }
            }
        onLoaded: {
            if(lobbyLoader.item != undefined){
                lobbyLoader.item.parent = app
                lobbyLoader.item.setProfile(profile)
            }
        }
        active:false
    }

    Loader{
        id:gameLoader
        anchors.fill: parent
        sourceComponent: GameView{
            visible:true
            onGameOver: {
                profile.requestUpdateProfile()
                app.state = "LOBBY";
            }
        }
        onLoaded: {
            if(gameLoader.item != undefined){
                background.gameView = gameLoader.item
                gameLoader.item.setProfile(profile)
                gameLoader.item.startNewGame(opponent,opelo,opflag, playerColor,opavatar,gameID);
            }
        }
        active:false
    }
//    CG_Board{
//        id:temp
//        anchors.verticalCenter: parent.verticalCenter
//        anchors.horizontalCenter: parent.horizontalCenter
//        height: parent.width*.8
//        width: height
//        onPromote: {
//            temp.interactive = false;
//            promotePicker.to = to;
//            promotePicker.from = from;
//            promotePicker.visible = true;
//        }

//    }
//    CG_PromotePicker{
//        id: promotePicker
//        anchors.centerIn:temp
//        height:temp.height
//        width:temp.width
//        visible:false
//        z:200
//        property var from: null
//        property var to:null
//        onPieceChosen: {
//            promotePicker.visible = false;
//            temp.makeMove(from,to,piece,true);
//            temp.interactive = true;
//        }
//    }
}
