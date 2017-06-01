import QtQuick 2.8
import CGNetwork 1.0
import CGEngine 1.0

Rectangle {
    id: topRect
    property var playerProfile:undefined
    property var gameBoard:undefined
    signal gameOver();
    function resizeBoard(){
        if(gameLoader.status == Loader.Ready && gameLoader.active){
            gameBoard.resizeBoard();
        }
    }

    function startNewGame(name, elo, country, color, avatar,id)
    {
        topRect.state = "MATCHED";
        playerProfile.setColor(!color);
        if(!color){
            whitePlayer.setBanner(playerProfile.name,playerProfile.elo,playerProfile.flag,"image://avatars/"+playerProfile.avatar,true);
            blackPlayer.setBanner(name,elo,country,"image://avatars/"+avatar, false);
        }
        else{
            blackPlayer.setBanner(playerProfile.name,playerProfile.elo,playerProfile.flag,"image://avatars/"+playerProfile.avatar,false);
            whitePlayer.setBanner(name,elo,country,"image://avatars/"+avatar,true);
        }
        remoteGame.startNewGame(name,country,elo,!color,id);
        remoteGame.sendSync();
    }
    function resetBoard(){
        boardLoader.active = false;
        boardLoader.active = true;
    }

    function setProfile(player)
    {
        topRect.playerProfile = player;
    }
    CGGame{
        id:remoteGame
        onOpponentMove: {
            gameBoard.makeRemoteMove(move);
        }
        onGameSynchronized: {
            syncTimer.count =1;
            syncTimer.interval = 1000;
            syncTimer.start()
        }
        onGameFinished: {
            switch(result){
            case -1: if(playerProfile.color){
                    topRect.state = "POSTBW";
                }
                else{
                    topRect.state = "POSTWW";
                }
                break;
            case 0: topRect.state = "POSTDW";
                    break;
            case 1: if(playerProfile.color){
                    topRect.state = "POSTWW";
                }
                else{
                    topRect.state = "POSTBW";
                }
                break;
            case 2: topRect.state = "RESIGNP1";
                break;
            case 3: topRect.state = "RESIGNP2";
                break;
            default: break;
            }
        }
    }
    Timer{
        id:syncTimer
        property int count:3
        interval: 0
        repeat: true
        running: false
        onTriggered: {
            if(syncTimer.count <=0){
                syncTimer.stop();
                topRect.state = "GAME"
            }
            else{
                count -=1;
            }
        }
    }

    states:[
        State{
            name:"MATCHED"
            extend:""
        },
        State{
            name:"GAME"
            extend:"MATCHED"
            AnchorChanges{target:whitePlayer;  anchors.bottom:topRect.bottom;  anchors.top: boardLoader.bottom; anchors.left: topRect.left; anchors.right:topRect.right}
            AnchorChanges{target:blackPlayer;  anchors.top:topRect.top;anchors.bottom: boardLoader.top;anchors.left: topRect.left; anchors.right:topRect.right}

            PropertyChanges {
                target: blackPlayer
                anchors.topMargin:4
                anchors.bottomMargin:8
                anchors.leftMargin: 1
                anchors.rightMargin: 1
            }
            PropertyChanges {
                target: whitePlayer
                anchors.bottomMargin:4
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                anchors.topMargin: 8
            }
            PropertyChanges {target:boundingRect; visible:false;}
            PropertyChanges {target:boardLoader; active:true;}

            StateChangeScript{ script:{
                    whitePlayer.setGameModeLocal();
                    whitePlayer.setTurn(true)
                    blackPlayer.setGameModeLocal();
                    topRect.resetBoard();
                }
            }
        },

        State{
            name:"POSTBW"
            extend:""
            PropertyChanges {target:boardLoader; active:false}
            PropertyChanges {target:matchedImage; visible:false;}
            PropertyChanges {target:boundingRect; visible:true;}
            PropertyChanges {
                target: blackPlayer
                anchors.margins:8
                anchors.topMargin:2
            }
            PropertyChanges {
                target: whitePlayer
                anchors.margins:8
                anchors.topMargin: 4
            }
            AnchorChanges{target:blackPlayer;anchors.bottom:undefined;  anchors.top: boundingRect.top; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: blackPlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}

            AnchorChanges{target:centerText;anchors.bottom:boundingRect.bottom;  anchors.top: whitePlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            PropertyChanges{
                target:centerText
                visible:true
                anchors.margins: 8
                font.pixelSize: 16
                anchors.bottomMargin:72
                horizontalAlignment:Text.AlignRight
                verticalAlignment:Text.AlignVCenter
                text:"Black Wins By\nCheckmate"
            }
            PropertyChanges{
                target:leaveButton
                enabled:true
                visible:true
            }

            // to do build post game view

        },
        State{
            name:"POSTWW"
            extend:""
            PropertyChanges {target:boardLoader; active:false}
            PropertyChanges {target:matchedImage; visible:false;}
            PropertyChanges {target:boundingRect; visible:true;}
            PropertyChanges {
                target: blackPlayer
                anchors.margins:8
                anchors.topMargin:2
            }
            PropertyChanges {
                target: whitePlayer
                anchors.margins:8
                anchors.topMargin: 4
            }
            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: boundingRect.top; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            AnchorChanges{target:blackPlayer;anchors.bottom:undefined;  anchors.top: whitePlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}

            AnchorChanges{target:centerText;anchors.bottom:boundingRect.bottom;  anchors.top: blackPlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            PropertyChanges{
                target:centerText
                visible:true
                anchors.margins: 8
                font.pixelSize: 16
                anchors.bottomMargin:72
                horizontalAlignment:Text.AlignRight
                verticalAlignment:Text.AlignVCenter
                text:"White Wins By\nCheckmate"
            }
            PropertyChanges{
                target:leaveButton
                enabled:true
                visible:true
            }

            // to do build post game view

        },
        State{
            name:"POSTDW"
            extend:""
            PropertyChanges {target:boardLoader; active:false}
            PropertyChanges {target:matchedImage; visible:false;}
            PropertyChanges {target:boundingRect; visible:true;}
            PropertyChanges {
                target: blackPlayer
                anchors.margins:8
                anchors.topMargin:2
            }
            PropertyChanges {
                target: whitePlayer
                anchors.margins:8
                anchors.topMargin: 4
            }
            AnchorChanges{target:blackPlayer;anchors.bottom:undefined;  anchors.top: boundingRect.top; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: blackPlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}

            AnchorChanges{target:centerText;anchors.bottom:boundingRect.bottom;  anchors.top: whitePlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            PropertyChanges{
                target:centerText
                visible:true
                anchors.margins: 8
                anchors.bottomMargin:72
                font.pixelSize: 16
                horizontalAlignment:Text.AlignRight
                verticalAlignment:Text.AlignVCenter
                text:"Game finished a Draw"
            }
            PropertyChanges{
                target:leaveButton
                enabled:true
                visible:true
            }
        }

    ]

    Rectangle{
        id: boundingRect
        color:"darkgrey"
        anchors.fill: parent
        anchors.topMargin:parent.height*.09
        anchors.bottomMargin:parent.height*.3
        anchors.leftMargin:parent.width *.01
        anchors.rightMargin:anchors.leftMargin
        radius:4
        border.width: 3
        Image{
            id: matchedImage
            anchors.top:parent.top
            anchors.topMargin:parent.height*.08
            height:parent.height*.11
            anchors.horizontalCenter: parent.horizontalCenter
            source:"/images/PlayerMatched.png"
            fillMode: Image.PreserveAspectFit
        }
        CG_DarkButton{
            id:leaveButton
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            height:64
            anchors.bottomMargin: 6
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            visible:false
            enabled:false
            text.text:"Leave"
            mouse.onClicked: {
                topRect.gameOver();
            }
        }
    }
    Loader{
        id:boardLoader
        active:false
        anchors.left: topRect.left
        anchors.right: topRect.right
        anchors.verticalCenter: topRect.verticalCenter
        height:topRect.height*.78
        sourceComponent:  CG_Board{
            anchors.fill: boardLoader
            onSendMove: {
                remoteGame.makeMove(from,to,fen,promote);
            }
            onWhitesTurn: {
                whitePlayer.setTurn(true);
                blackPlayer.setTurn(false);
                if(playerProfile.color){
                    interactive = true;
                }
                else{
                    interactive = false;
                }
            }
            onBlacksTurn: {
                blackPlayer.setTurn(true);
                whitePlayer.setTurn(false);
                if(!playerProfile.color){
                    interactive = true;
                }
                else{
                    interactive = false;
                }
            }

            onGameOver: {
                // do something to notify user game ended
                remoteGame.sendResult(result,move,fen,game);
            }
            onPromote:{
                if(blackPlayer.getTurn()){
                    promotePicker.playerColor = true;
                }
                else{
                    promotePicker.playerColor = false;
                }
                interactive = false;
                promotePicker.from = from;
                promotePicker.to = to;
                promotePicker.visible = true;
            }

            onFinishedLoading: {
                var cdate = new Date();
                if(playerProfile.color)
                {
                    topRect.gameBoard.interactive = true;
                }
                else{
                    topRect.gameBoard.interactive = false;
                }
                gameBoard.setHeader(whitePlayer.player,blackPlayer.player,cdate.toLocaleDateString())
            }

        }
        onLoaded: {
            if(boardLoader.item){
                topRect.gameBoard = boardLoader.item
                topRect.gameBoard.resizeBoard();
            }
        }

    }

    CG_PromotePicker{
        id:promotePicker
        anchors.fill: boardLoader
        anchors.margins: 8
        visible:false
        property var from:undefined
        property var to:undefined
        onPieceChosen: {
            topRect.gameBoard.makeMove(from,to,piece,true);
            promotePicker.visible = false;
            gameBoard.interactive = true
        }
    }
    CG_PlayerBanner{
        id:whitePlayer
        anchors.left: boundingRect.left
        anchors.right: boundingRect.right
        anchors.bottom:boundingRect.bottom
        height:blackPlayer.height
        anchors.bottomMargin:boundingRect.height*.05
        anchors.leftMargin:boundingRect.width/20
        anchors.rightMargin:anchors.leftMargin
        pieceSet: "/images/cg_kramnik2.png"
        MouseArea{
            anchors.fill: parent
            onPressed:{
                gameBoard.boldBorder = !gameBoard.boldBorder;
            }
        }
    }

    CG_PlayerBanner{
        id:blackPlayer
        anchors.left: boundingRect.left
        anchors.right: boundingRect.right
        anchors.top:boundingRect.top
        height:boundingRect.height/5
        anchors.topMargin:boundingRect.height*.25
        anchors.leftMargin:boundingRect.width/20
        anchors.rightMargin:anchors.leftMargin
        pieceSet: "/images/cg_kramnik.png"
    }

    Text{
        id:centerText
        visible: boundingRect.visible
        anchors.top:whitePlayer.bottom
        anchors.bottom: blackPlayer.top
        anchors.left:boundingRect.left
        anchors.right:boundingRect.right
        color:"white"
        font.bold:true
        styleColor: "black"
        style: Text.Outline
        text:"VS"
        font.family: "Comic Sans MS"
        font.pixelSize: height*.45
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

}
