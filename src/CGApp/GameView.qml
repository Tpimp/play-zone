import QtQuick 2.8
import CGNetwork 1.0
import CGEngine 1.0
import QtMultimedia 5.8
Rectangle {
    id: topRect
    property var playerProfile:undefined
    property var gameBoard:undefined
    signal gameOver();
    function resizeBoard(){
        if(boardLoader.status == Loader.Ready && boardLoader.active){
            gameBoard.resizeBoard();
        }
    }

    function startNewGame(name, elo, country, color, avatar,id)
    {
        topRect.state = "MATCHED";
        playerProfile.setColor(!color);
        if(!color){
            whitePlayer.banner.setBanner(playerProfile.name,playerProfile.elo,playerProfile.flag,"image://avatars/"+playerProfile.avatar,true);
            blackPlayer.banner.setBanner(name,elo,country,"image://avatars/"+avatar, false);
            blackPlayer.setBack(drawComponent);
            whitePlayer.setBack(playerComponent);
        }
        else{
            blackPlayer.banner.setBanner(playerProfile.name,playerProfile.elo,playerProfile.flag,"image://avatars/"+playerProfile.avatar,false);
            whitePlayer.banner.setBanner(name,elo,country,"image://avatars/"+avatar,true);
            whitePlayer.setBack(drawComponent);
            blackPlayer.setBack(playerComponent);
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
            var lastmove = gameBoard.getLastMove()
            if(playerProfile.color){
                if(lastmove){
                    blackPlayer.setMove(lastmove)
                }
                else{
                    blackPlayer.setMove("")
                }
            }
            else{
                if(lastmove){
                    whitePlayer.setMove(gameBoard.getLastMove())
                }
                else{
                    whitePlayer.setMove("")
                    blackPlayer.setMove("")
                }
            }
        }
        onGameSynchronized: {
            syncTimer.count =1;
            syncTimer.interval = 350;
            syncTimer.start()
        }
        onDrawResponse: {
            switch(response){
                case 0:  // got draw offer
                    if(playerProfile.color){
                        blackPlayer.back.setAsked();
                        blackPlayer.showBack = true;
                        blackPlayer.stopReset();
                    }
                    else{
                        whitePlayer.back.setAsked();
                        whitePlayer.showBack = true;
                        whitePlayer.stopReset();
                    }
                    drawSound.play();
                    break;
                case 1: // got accepted draw
                    blackPlayer.reset()
                    whitePlayer.reset()
                    drawAccept.play();
                    gameBoard.sendDrawAccept();
                    break;
                case 2: // got decline
                    if(playerProfile.color){
                        blackPlayer.reset()
                        blackPlayer.back.resetDraw();
                    }
                    else{
                        whitePlayer.reset()
                        whitePlayer.back.resetDraw();
                    }
                    break;
                default: // reset
                    if(playerProfile.color){
                        blackPlayer.reset()
                        blackPlayer.back.resetDraw();
                    }
                    else{
                        whitePlayer.reset()
                        whitePlayer.back.resetDraw();
                    }
                    break;
            }
        }

        onGameFinished: {
            var white_elo = parseInt(whitePlayer.front.elo)
            var black_elo = parseInt(blackPlayer.front.elo)

            switch(result){
            case -2:
                if(playerProfile.color){
                    white_elo -= 5;
                    black_elo +=5;
                    topRect.state = "RESIGNW";
                }
                else{
                    black_elo -=5;
                    white_elo += 5;
                    topRect.state = "RESIGNB";
                }
                resignSound.play();
                break;
            case -1: if(playerProfile.color){
                    white_elo -= 5;
                    black_elo += 5;
                    topRect.state = "POSTBW";
                }
                else{
                    white_elo += 5;
                    black_elo -=5;
                    topRect.state = "POSTWW";
                }
                break;
            case 0: topRect.state = "POSTDW";
                    staleSound.play();
                    break;
            case 1: if(playerProfile.color){
                    white_elo += 5;
                    black_elo -=5;
                    topRect.state = "POSTWW";
                }
                else{
                    white_elo -= 5;
                    black_elo +=5;
                    topRect.state = "POSTBW";
                }
                wonSound.play()
                break;
            case 2: if(playerProfile.color){
                    white_elo += 5;
                    black_elo -=5;
                    topRect.state = "RESIGNB";
                }
                else{
                    white_elo -= 5;
                    black_elo +=5;
                    topRect.state = "RESIGNW";
                }
                wonSound.play()
                break;
            default: break;
            }
            whitePlayer.front.elo = white_elo;
            blackPlayer.front.elo = black_elo;
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
                    whitePlayer.banner.setGameMode();
                    whitePlayer.banner.setTurn(true)
                    blackPlayer.banner.setGameMode();
                    topRect.resetBoard();
                }
            }
        },
        State{
            name:"POST"
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
            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: blackPlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            //AnchorChanges{target:blackPlayer;anchors.bottom:undefined;  anchors.top: whitePlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            AnchorChanges{target:centerText;anchors.bottom:leaveButton.top;  anchors.top: undefined; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            PropertyChanges{
                target:centerText
                visible:true
                anchors.margins: 8
                font.pixelSize: 16
                anchors.bottomMargin:72
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment:Text.AlignVCenter
            }
            PropertyChanges{
                target:leaveButton
                enabled:true
                visible:true
            }
            StateChangeScript{script:{
                    whitePlayer.reset();
                    blackPlayer.reset();
                }
            }
        },

        State{
            name:"POSTBW"
            extend:"POST"

            PropertyChanges{
                target:centerText
                visible:true
                text:blackPlayer.banner.player+" Wins By\nCheckmate"
            }

        },
        State{
            name:"POSTWW"
            extend:"POST"

            PropertyChanges{
                target:centerText
                visible:true
                text:whitePlayer.banner.player+" Wins By\nCheckmate"
            }

            // to do build post game view

        },
        State{
            name:"POSTDW"
            extend:"POST"
            PropertyChanges{
                target:centerText
                visible:true
                text:"Game finished a Draw"
            }
        },
        State{
            name:"RESIGNW"
            extend:"POST"
            PropertyChanges{
                target:centerText
                visible:true
                text:blackPlayer.banner.player+" Wins by opponent Resignation"
            }

        },
        State{
            name:"RESIGNB"
            extend:"POST"
           PropertyChanges{
                target:centerText
                visible:true
                text:whitePlayer.banner.player+" Wins by opponent Resignation"
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
            source:"qrc:///images/PlayerMatched.png"
            fillMode: Image.PreserveAspectFit
        }
        Text{
            id:centerText
            visible: false
            color:"white"
            font.bold:true
            styleColor: "black"
            style: Text.Outline
            text:"VS"
            font.family: "Comic Sans MS"
            font.pixelSize: matchedImage.height
            anchors.bottom:leaveButton.top
            anchors.bottomMargin:parent.height*.02
            anchors.left:parent.left
            anchors.right:parent.right
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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
                moveSound.play();
                var lastmove = gameBoard.getLastMove()
                if(playerProfile.color){
                    if(lastmove){
                        whitePlayer.setMove(gameBoard.getLastMove())
                    }
                    else{
                        blackPlayer.setMove("")
                    }
                }
                else{
                    if(lastmove){
                        blackPlayer.setMove(lastmove)
                    }
                    else{
                        whitePlayer.setMove("")
                        blackPlayer.setMove("")
                    }
                }
                remoteGame.makeMove(from,to,fen,promote);
                if(playerProfile.color){
                    if(blackPlayer.showBack){
                        blackPlayer.showBack = false;
                        blackPlayer.back.resetDraw();
                        remoteGame.sendDraw(2);
                    }
                }
                else{
                    if(whitePlayer.showBack){
                        whitePlayer.showBack = false;
                        whitePlayer.back.resetDraw();
                        remoteGame.sendDraw(2);
                    }
                }
            }
            onWhitesTurn: {
                whitePlayer.banner.setTurn(true);
                blackPlayer.banner.setTurn(false);
                if(playerProfile.color){
                    interactive = true;
                }
                else{
                    interactive = false;
                }
            }
            onBlacksTurn: {
                blackPlayer.banner.setTurn(true);
                whitePlayer.banner.setTurn(false);
                if(!playerProfile.color){
                    interactive = true;
                }
                else{
                    interactive = false;
                }
            }
            onChecked: {
                checkSound.play()
            }
            onWrongMove: {
                wrongSound.play();
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
                gameBoard.setHeader(whitePlayer.banner.player,blackPlayer.banner.player,cdate.toLocaleDateString())
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
    CG_GameBanner{
        id:whitePlayer
        anchors.left: boundingRect.left
        anchors.right: boundingRect.right
        anchors.bottom:boundingRect.bottom
        height:blackPlayer.height
        anchors.bottomMargin:boundingRect.height*.05
        anchors.leftMargin:boundingRect.width/20
        anchors.rightMargin:anchors.leftMargin
        banner.pieceSet: "qrc:///images/cg_kramnik2.png"
    }

    CG_GameBanner{
        id:blackPlayer
        anchors.left: boundingRect.left
        anchors.right: boundingRect.right
        anchors.top:boundingRect.top
        height:boundingRect.height/5
        anchors.topMargin:boundingRect.height*.25
        anchors.leftMargin:boundingRect.width/20
        anchors.rightMargin:anchors.leftMargin
        banner.pieceSet: "qrc:///images/cg_kramnik.png"
    }




    // Components used throught the game view
    Component{
        id: drawComponent
        CG_DrawDialog{
            id:drawDialog
            anchors.fill: parent
            color:"#959595"
            onRequestResign:{gameBoard.resign(); setWaitResign();parent.stopReset(); resignSound.play();}
            onRequestDraw:{drawSound.play(); setWaitDraw(); parent.stopReset(); remoteGame.sendDraw(0); }
            onAcceptedDraw:{
                if(playerProfile.color){
                    blackPlayer.reset()
                    blackPlayer.back.resetDraw();
                }
                else{
                    whitePlayer.reset()
                    whitePlayer.back.resetDraw();
                }
                drawAccept.play();
                remoteGame.sendDraw(1);
                gameBoard.sendDrawAccept();
            }
            onDeclinedDraw:{
                if(playerProfile.color){
                    blackPlayer.reset()
                    blackPlayer.back.resetDraw();
                }
                else{
                    whitePlayer.reset()
                    whitePlayer.back.resetDraw();
                }
                remoteGame.sendDraw(2);
            }
        }
    }
    Component{
        id: playerComponent
        CG_PlayerDialog{
            id:playerDialog
            anchors.fill: parent
        }
    }
    SoundEffect{
        id:checkSound
        source:"qrc:///sounds/check.wav"
        loops:0
    }
    SoundEffect{
        id:moveSound
        source:"qrc:///sounds/move.wav"
        loops:0
    }
    SoundEffect{
        id:wrongSound
        source:"qrc:///sounds/wrongMove.wav"
        loops:0
    }
    SoundEffect{
        id:drawSound
        source:"qrc:///sounds/drawOffer.wav"
        loops:0
    }
    SoundEffect{
        id:resignSound
        source:"qrc:///sounds/resign.wav"
        loops:0
    }
    SoundEffect{
        id:drawAccept
        source:"qrc:///sounds/drawOfferAccepted.wav"
        loops:0
    }
    SoundEffect{
        id:wonSound
        source:"qrc:///sounds/gameWon.wav"
        loops:0
    }
    SoundEffect{
        id:staleSound
        source:"qrc:///sounds/stalemate.wav"
        loops:0

    }
}



