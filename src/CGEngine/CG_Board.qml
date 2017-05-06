import QtQuick 2.8
import "chess.js" as Engine
Item {
    id:board
    property string boardDark:"darkgrey"
    property string boardLight:"lightgrey"
    property string faveColor:"white"
    property var    game:undefined
    property real   cellSize:64
    onCellSizeChanged: {
        tile.height = cellSize;
        tile.width = cellSize;
    }

    GridView{
        anchors.left: parent.left
        anchors.right:parent.right
        anchors.margins: 2
        delegate:CG_Tile{
            id:tile
            color: (index % 2 ==0) ? boardLight:boardDark
        }
    }

    Component.onCompleted: {
        board.game = Engine.Chess();
//        var moves = board.game.moves();
//        var move = moves[Math.floor(Math.random() * moves.length)];
//        board.game.move(move);
//        console.log(board.game.pgn());
    }
}
