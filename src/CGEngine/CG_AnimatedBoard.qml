import QtQuick 2.8
import "chess.js" as Engine
import CGEngine 1.0
Item {
    id:animatedBoard
    property int  state:1
    property var move:undefined
    property string fen:""
    property int    result:0
    property alias  board:board
    function setAnimation(recent){
        animationTimer.stop();
        fen = recent.fen;
        move = recent.move;
        result = recent.result;
        //board.setBoardFEN(fen)
        state = 1;
        animationTimer.interval =100;
        animationTimer.start();
    }
    function updateAnimation(){
        switch(state){
            case 0: // moving to final move
                board.makeAnimatedMove(move)
                state = 1;
                break;
             case 1: // showing result
                 state =2;
                 break;
             case 2:
                 animationTimer.stop();
                 board.setBoardFEN(fen)
                 state = 0;
                 animationTimer.interval =1200;
                 animationTimer.start();
                 break;
            default: state = 2;
        }
    }

    Timer{
        id:animationTimer
        interval:1200
        repeat: true
        running:false
        onTriggered: updateAnimation()
    }

    CG_Board{
        id:board
        anchors.fill: animatedBoard
    }
}
