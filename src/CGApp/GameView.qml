import QtQuick 2.8
import CGNetwork 1.0
import CGEngine 1.0
import QtMultimedia 5.8
Rectangle {
    id: topRect
    property var white:undefined
    property var black:undefined
    property var gameBoard:undefined
    property bool playerTurn:true
    property int  plyCount:0
    signal gameOver();
    function resizeBoard(){
        if(boardLoader.status == Loader.Ready && boardLoader.active){
            gameBoard.resizeBoard();
        }
    }
    signal reviewGame(var review, string fen)

    function startNewGame(white,black)
    {
        if(playerProfile.name() == white.name){ // local player is white
            blackPlayer.setBack(drawComponent);
            whitePlayer.setBack(playerComponent);
            topRect.state = "MATCHED";
        }
        else{
            whitePlayer.setBack(drawComponent);
            blackPlayer.setBack(playerComponent);
            topRect.state = "MATCHEDB";
        }
        whitePlayer.banner.setBanner(white.name,white.elo,white.country,"image://avatars/"+white.avatar,true);
        blackPlayer.banner.setBanner(black.name,black.elo,black.country,"image://avatars/"+black.avatar, false);
        remoteGame.sendSync(serverPing);
    }
    function resetBoard(){
        boardLoader.active = false;
        boardLoader.active = true;
    }

    CGGame{
        id:remoteGame
        onOpponentMove: {
            gameBoard.makeRemoteMove(move);
            var lastmove = gameBoard.getLastMove()
            if(white.name == playerProfile.name()){ // if local player is white
                remoteGame.calculatePlayerClock(false,move.time);
                if(lastmove){
                    blackPlayer.setMove(plyCount + ".) " + lastmove)
                }
                else{
                    blackPlayer.setMove("")
                }
            }
            else{
                remoteGame.calculatePlayerClock(true,move.time);
                if(lastmove){
                    whitePlayer.setMove(++plyCount + ".) " + lastmove)
                    blackPlayer.setMove(plyCount + ".) ..")
                }
                else{
                    whitePlayer.setMove("")
                    blackPlayer.setMove("")
                }
            }
            remoteGame.startPlayerTimer();
        }
        onSyncClock: {
            whitePlayer.banner.clock.text = time;
            blackPlayer.banner.clock.text = time;
        }
        onSyncPlayerClock: {
            if(color){
                whitePlayer.banner.clock.text = time;
            }
            else{
                blackPlayer.banner.clock.text = time;
            }
        }
        onUpdatePlayerClock: {
            remoteGame.adjustPlayerTimer(playerTurn);
        }

        onGameSynchronized: {
            switch(state){
                case 0:
                    remoteGame.calculateSyncClock(time);
                    syncTimer.count =1;
                    var synctime = (5000 - serverPing);
                    syncTimer.interval = synctime;
                    syncTimer.start()
                    break;
                case 1:
                    if(white.name == playerProfile.name()){
                        remoteGame.calculatePlayerClock(true,time);
                    }
                    else
                    {
                        remoteGame.calculatePlayerClock(false,time);
                    }
                    break;
                default: break;
            }
        }
        onPlayerTimerExpired: {
            if(color)
            {
                remoteGame.stopPlayerTimer(true);
                if(white.name == playerProfile.name()){
                    remoteGame.sendResult(-2,gameBoard.getPGN());
                }
                else
                {
                    remoteGame.sendResult(2,gameBoard.getPGN());
                }
            }
            else{
                remoteGame.stopPlayerTimer(false);
                if(white.name == playerProfile.name()){
                    remoteGame.sendResult(2,gameBoard.getPGN());
                }
                else
                {
                    remoteGame.sendResult(-2,gameBoard.getPGN());
                }
            }
        }

        onDrawResponse: {
            switch(response){
                case 0:  // got draw offer
                    if(white.name == playerProfile.name()){ // if local player is white
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
                    if(playerProfile.name() == white.name){
                        blackPlayer.reset()
                        blackPlayer.back.resetDraw();
                    }
                    else{
                        whitePlayer.reset()
                        whitePlayer.back.resetDraw();
                    }
                    break;
                default: // reset
                    if(playerProfile.name() == white.name){
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
            remoteGame.stopPlayerTimer(playerColor);
            blackPlayer.banner.elo = game_result.elo_b;
            whitePlayer.banner.elo = game_result.elo_w;
            remoteGame.calculatePlayerClock(false,game_result.time_b);
            remoteGame.calculatePlayerClock(true,game_result.time_w);
            if(playerProfile.color){
                switch(game_result.result_w){
                    case -3: //loss by resignation
                        topRect.state = "POSTBW";
                        centerText.text = white.name + " lost by resignation"
                        resignSound.play();
                        break;
                    case -2: // loss to time expired
                        topRect.state = "POSTBW";
                        centerText.text = white.name + " lost by time"
                        resignSound.play();
                        break;
                    case -1: // loss to checkmate
                        topRect.state = "POSTBW";
                        centerText.text = black.name + " won by checkmate"
                        break;
                    case 0:  // Draw Agreed (offer)
                        topRect.state = "POSTWW";
                        centerText.text = "Game drawn by agreement"
                        drawSound.play();
                        break;
                    case 1: // I win by checkmate
                        topRect.state = "POSTWW";
                        centerText.text = white.name + " won by checkmate"
                        wonSound.play()
                        break;
                    case 2: // I win by player time expired
                        topRect.state = "POSTWW";
                        centerText.text = black.name + " lost by time"
                        wonSound.play()
                        break;
                    case 3: // I win by player resignation
                        topRect.state = "POSTWW";
                        centerText.text = black.name + " lost by resignation"
                        wonSound.play()
                        break;
                    case 10:
                        topRect.state = "POSTWW";
                        centerText.text = "Game drawn by stalemate"
                        staleSound.play();
                        break;
                    case 11:
                        topRect.state = "POSTWW";
                        centerText.text = "Game drawn by 50 move rule"
                        drawSound.play();
                        break;
                    case 12:
                        topRect.state = "POSTWW";
                        centerText.text = "Game drawn by repetition"
                        drawSound.play();
                        break;
                    case 13:
                        topRect.state = "POSTWW";
                        centerText.text = "Game drawn due to lack of material"
                        staleSound.play();
                        break;
                    default: break;
                }
            }

        else
        {
            switch(game_result.result_b){
                case -3: //loss by resignation
                    topRect.state = "POSTWW";
                    centerText.text = black.name + " lost by resignation"
                    resignSound.play();
                    break;
                case -2: // loss to time expired
                    topRect.state = "POSTWW";
                    centerText.text = black.name + " lost by time"
                    resignSound.play();
                    break;
                case -1: // loss to checkmate
                    topRect.state = "POSTWW";
                    centerText.text = black.name + " lost by checkmate"
                    break;
                case 0:  // Draw Agreed (offer)
                    topRect.state = "POSTBW";
                    centerText.text = "Game drawn by agreement"
                    drawSound.play();
                    break;
                case 1: // I win by checkmate
                    topRect.state = "POSTBW";
                    centerText.text = white.name + " lost by checkmate"
                    wonSound.play()
                    break;
                case 2: // I win by player time expired
                    topRect.state = "POSTBW";
                    centerText.text = white.name + " lost by time"
                    wonSound.play()
                    break;
                case 3: // I win by player resignation
                    topRect.state = "POSTBW";
                    centerText.text = white.name + " lost by resignation"
                    wonSound.play()
                    break;
                case 10:
                    topRect.state = "POSTBW";
                    centerText.text = "Game drawn by stalemate"
                    staleSound.play();
                    break;
                case 11:
                    topRect.state = "POSTBW";
                    centerText.text = "Game drawn by 50 move rule"
                    drawSound.play();
                    break;
                case 12:
                    topRect.state = "POSTBW";
                    centerText.text = "Game drawn by repetition"
                    drawSound.play();
                    break;
                case 13:
                    topRect.state = "POSTBW";
                    centerText.text = "Game drawn due to lack of material"
                    staleSound.play();
                    break;
                default: break;
                }
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
                if(playerProfile.name() == white.name){
                    topRect.state = "GAMEW"
                }
                else
                {
                    topRect.state = "GAMEB"
                }

                remoteGame.startPlayerTimer();
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
            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: blackPlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            AnchorChanges{target:blackPlayer;anchors.bottom:undefined;  anchors.top: boundingRect.top; anchors.left: boundingRect.left; anchors.right:boundingRect.right}

            PropertyChanges {
                target: blackPlayer
                anchors.margins:8
                height:boundingRect.height/5
                anchors.topMargin:boundingRect.height*.25
                anchors.leftMargin:boundingRect.width/20
            }
            PropertyChanges {
                target: whitePlayer
                anchors.margins:8
                anchors.topMargin: 8
                height:boundingRect.height/5
                anchors.bottomMargin:boundingRect.height*.05
                anchors.leftMargin:boundingRect.width/20
            }
        },
        State{
            name:"MATCHEDB"
            extend:""
            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: boundingRect.top; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            AnchorChanges{target:blackPlayer;anchors.bottom:undefined;  anchors.top: whitePlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}

            PropertyChanges {
                target: blackPlayer
                anchors.margins:8
                anchors.topMargin:8
                height:boundingRect.height/5
                anchors.bottomMargin:boundingRect.height*.05
                anchors.leftMargin:boundingRect.width/20
            }
            PropertyChanges {
                target: whitePlayer
                anchors.margins:8
                height:boundingRect.height/5
                anchors.topMargin:boundingRect.height*.25
                anchors.leftMargin:boundingRect.width/20
            }
        },
        State{
            name:"GAMEW"
            extend:""

            AnchorChanges{target:whitePlayer;  anchors.bottom:topRect.bottom;  anchors.top: boardLoader.bottom; anchors.left: boardLoader.left; anchors.right:boardLoader.right}
            AnchorChanges{target:blackPlayer;  anchors.top:topRect.top; anchors.bottom: boardLoader.top;anchors.left: boardLoader.left; anchors.right:boardLoader.right}

            PropertyChanges {
                target: blackPlayer
                anchors.topMargin:1
                anchors.bottomMargin:4
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                width:topRect.width
            }
            PropertyChanges {
                target: whitePlayer
                anchors.bottomMargin:1
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                anchors.topMargin: 4
                width:topRect.width
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
            name:"GAMEB"
            extend:""

            AnchorChanges{target:blackPlayer;  anchors.bottom:topRect.bottom;  anchors.top: boardLoader.bottom; anchors.left: boardLoader.left; anchors.right:boardLoader.right}
            AnchorChanges{target:whitePlayer;  anchors.top:topRect.top; anchors.bottom: boardLoader.top;anchors.left: boardLoader.left; anchors.right:boardLoader.right}

            PropertyChanges {
                target: whitePlayer
                anchors.topMargin:1
                anchors.bottomMargin:4
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                width:topRect.width
            }
            PropertyChanges {
                target: blackPlayer
                anchors.bottomMargin:1
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                anchors.topMargin: 4
                width:topRect.width
            }
            PropertyChanges {target:boundingRect; visible:false;}
            PropertyChanges {target:boardLoader; active:true; }
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
            PropertyChanges {target:boardLoader; active:true; visible:false}
            PropertyChanges {target:matchedImage; visible:false;}
            PropertyChanges {target:boundingRect; visible:true;}


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
                target:reviewButton
                enabled:true
                visible:true
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
            name:"POSTWW"
            extend:"POST"
            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: boundingRect.top; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            AnchorChanges{target:blackPlayer;anchors.bottom:undefined;  anchors.top: whitePlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}

            PropertyChanges {
                target: blackPlayer
                anchors.margins:8
                anchors.topMargin:8
                height:boundingRect.height/5
            }
            PropertyChanges {
                target: whitePlayer
                anchors.margins:8
                anchors.topMargin: 4
                height:boundingRect.height/5
            }
        },
        State{
            name:"POSTBW"
            extend:"POST"

            AnchorChanges{target:whitePlayer;anchors.bottom:undefined;  anchors.top: blackPlayer.bottom; anchors.left: boundingRect.left; anchors.right:boundingRect.right}
            AnchorChanges{target:blackPlayer;anchors.bottom:undefined;  anchors.top: boundingRect.top; anchors.left: boundingRect.left; anchors.right:boundingRect.right}

            PropertyChanges {
                target: blackPlayer
                anchors.margins:8
                anchors.topMargin:4
                height:boundingRect.height/5
            }
            PropertyChanges {
                target: whitePlayer
                anchors.margins:8
                anchors.topMargin: 8
                height:boundingRect.height/5
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
            id:reviewButton
            anchors.left:parent.left
            anchors.bottom:parent.bottom
            height:64
            width:parent.width*.43
            anchors.bottomMargin: 6
            anchors.leftMargin: 10
            visible:false
            enabled:false
            text.text:"Review"
            mouse.onClicked: {
                topRect.reviewGame(gameBoard.getHistory(),gameBoard.getFEN())
            }
        }
        CG_DarkButton{
            id:leaveButton
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            height:64
            width:parent.width*.43
            anchors.bottomMargin: 6
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
        height:topRect.height*.8
        rotation:0
        property bool pieceRotation:false
        sourceComponent:  CG_Board{
            anchors.fill: boardLoader
            pieceRotation:boardLoader.pieceRotation
            onSendMove: {
                moveSound.play();
                var lastmove = gameBoard.getLastMove()
                var color = false;
                if(playerProfile.name() == white.name){
                    if(lastmove){
                        whitePlayer.setMove(++plyCount + ".) " + lastmove)
                        blackPlayer.setMove(plyCount + ".) ..")
                    }
                    else{
                        blackPlayer.setMove("")
                    }
                    color = true;
                }
                else{
                    if(lastmove){
                        blackPlayer.setMove(plyCount + ".) " +lastmove)
                    }
                    else{
                        whitePlayer.setMove("")
                        blackPlayer.setMove("")
                    }
                }
                remoteGame.makeMove(from,to,fen,promote,remoteGame.stopPlayerTimer(color), serverPing);
                if(playerProfile.name() == white.name){
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
                remoteGame.startPlayerTimer();
            }
            onWhitesTurn: {
                whitePlayer.banner.setTurn(true);
                blackPlayer.banner.setTurn(false);
                playerTurn = true;
                if(playerProfile.name() == white.name){
                    interactive = true;
                }
                else{
                    interactive = false;
                }
            }
            onBlacksTurn: {
                blackPlayer.banner.setTurn(true);
                whitePlayer.banner.setTurn(false);
                playerTurn = false;
                if(playerProfile.name() != white.name){
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
                remoteGame.stopPlayerTimer(playerTurn);
                // do something to notify user game ended
                remoteGame.sendResult(result,game);
            }
            onPromote:{
                if(white.name == playerProfile.name()){
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
                if(playerProfile.name() == white.name)
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
                if(playerProfile.name() == white.name){
                    topRect.gameBoard.pieceRotation = false;
                }
                else
                {
                    topRect.gameBoard.pieceRotation = true;
                }
                topRect.gameBoard.resizeBoard();
            }
        }

    }

    CG_PromotePicker{
        id:promotePicker
        anchors.centerIn: parent
        width:parent.width *.6
        height: width
        visible:false
        property var from:undefined
        property var to:undefined
        onPieceChosen: {
            topRect.gameBoard.makeMove(from,to,piece,true);
            promotePicker.visible = false;
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
                if(playerProfile.name() == white.name){
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
                if(playerProfile.name() == white.name){
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



