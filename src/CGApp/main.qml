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
                extend:""
                PropertyChanges{target:loginView; state:"READY";}
                PropertyChanges{target:gameLoader; active:false;}
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
            }

        ]
        state:""
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
                    background.playerColor = color;
                    app.state = "GAME";
                    loadingLoader.item.text.text = "";
                    loadingLoader.item.visible = false;

                }
            }
        onLoaded: {
            if(lobbyLoader.item != undefined){
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
                gameLoader.item.setProfile(playerProfile)
                gameLoader.item.startNewGame(opponent,opelo,opflag, playerColor,opavatar);
            }
        }
        active:false
    }

}
