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
        if(color){
            whiteLED.color = "red";
        }
        else{
            blackLED.color = "red";
        }
        if(!color){
            whitePlayer.setBanner(playerProfile.name,playerProfile.elo,playerProfile.flag,"image://avatars/"+playerProfile.avatar,true);
            blackPlayer.setBanner(name,elo,country,"image://avatars/"+avatar, false);
            gameBoard.interactive = true;
        }
        else{
            blackPlayer.setBanner(playerProfile.name,playerProfile.elo,playerProfile.flag,"image://avatars/"+playerProfile.avatar,false);
            whitePlayer.setBanner(name,elo,country,"image://avatars/"+avatar,true);
            gameBoard.interactive = false;
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
            topRect.gameOver();
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
                topRect.resetBoard();
                whiteLED.anchors.leftMargin = -(whiteLED.width/2 - 2);
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
            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: boardLoader.bottom; anchors.left: topRect.left; anchors.right:topRect.right}
            AnchorChanges{target:blackPlayer;  anchors.top:undefined;anchors.bottom: boardLoader.top;anchors.left: topRect.left; anchors.right:topRect.right}
            PropertyChanges {
                target: blackPlayer
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                anchors.rightMargin:0
                anchors.leftMargin:whiteLED.width * .4
            }
            PropertyChanges {
                target: whitePlayer
                anchors.bottomMargin: 4
                anchors.topMargin: 4
                anchors.rightMargin:0
                anchors.leftMargin:whiteLED.width * .4
            }
            PropertyChanges {target:boundingRect; visible:false;}
        },
        State{
            name:"POST"

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
            anchors.top:parent.top
            anchors.topMargin:parent.height*.08
            height:parent.height*.11
            anchors.horizontalCenter: parent.horizontalCenter
            source:"/images/PlayerMatched.png"
            fillMode: Image.PreserveAspectFit
        }
    }
    Loader{
        id:boardLoader
        active:false
        anchors.right: parent.right
        anchors.left:parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.width > parent.height ? parent.height:parent.width
        sourceComponent:  CG_Board{
            onSendMove: {
                remoteGame.makeMove(from,to,fen,promote);
            }
            onWhitesTurn: {
                blackLED.anchors.leftMargin = 0;
                whiteLED.anchors.leftMargin = -(whiteLED.width/2 - 2);
                if(playerProfile.color){
                    interactive = true;
                }
                else{
                    interactive = false;
                }
            }
            onBlacksTurn: {
                whiteLED.anchors.leftMargin = 0;
                blackLED.anchors.leftMargin = -(blackLED.width/2 - 2);
                if(!playerProfile.color){
                    interactive = true;
                }
                else{
                    interactive = false;
                }
            }

            onSendResult: {
                // do something to notify user game ended
                remoteGame.sendResult(result,move,fen,game);
                switch(result){
                    case 0: console.log("finished game " + fen)
                }
            }
            onPromote:{
                if(blackLED.anchors.leftMargin === 0){
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
                gameBoard.playerColor = playerProfile.color;
                var cdate = new Date();
                if(playerColor){
                    interactive = true;
                }
                else{
                    interactive = false;
                }

                gameBoard.setHeader(whitePlayer.player,blackPlayer.player,cdate.toLocaleDateString())
            }


        }
        onLoaded: {
            if(boardLoader.item){
                topRect.gameBoard = boardLoader.item
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

    Rectangle{
        id:whiteLED
        anchors.top: whitePlayer.top
        anchors.bottom: whitePlayer.bottom
        width:height
        color: "#00ff15"
        radius:height
        anchors.left:whitePlayer.left
        border.width: 1
        Behavior on anchors.leftMargin {
            NumberAnimation{duration:550}
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
        MouseArea{
            anchors.fill: parent
            onPressed:{
                gameBoard.boldBorder = !gameBoard.boldBorder;
            }
        }
    }

    Rectangle{
        id:blackLED
        anchors.top: blackPlayer.top
        anchors.bottom: blackPlayer.bottom
        color: "#00ff15"
        border.width: 2
        width:height
        radius:height
        anchors.left:blackPlayer.left
        Behavior on anchors.leftMargin {
            NumberAnimation{duration:550}
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
