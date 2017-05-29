import QtQuick 2.8
import "chess.js" as Engine
import CGEngine 1.0
Item {
    id:board
    property string boardDark:"darkgrey"
    property string boardLight:"lightgrey"
    property string faveColor:"white"
    property alias  borderColor:boardBackground.color
    property bool   boldBorder:true
    property var    game:undefined
    property real   cellSize:0
    property var    boardComponent:null
    property var    pieceComponent:null
    property real   pieceCount:0
    property var    tileArray:[]
    property real   fromIndex:-1
    property var    lastHoverTile:null
    property var    moves:[]
    property string pieceType:""
    property string   turn:'w'
    property bool   playerColor:true
    property alias  interactive:boardMouse.enabled
    property string lastFen:''
    function setRemoteGame(color){
        board.playerColor = color;
    }
    function setHeader(white, black, date){
        board.game.header('White',white,'Black',black,'Date',date);
    }

    signal finishedLoading();
    signal sendMove(int from, int to, string fen, string promote);
    signal sendResult(int result, var move, string fen, string game);
    signal whitesTurn();
    signal blacksTurn();
    signal promote(var from, var to);
    signal gameOver(int reslut, var move, string fen, string game);

    CGEngine{
        id:chessEngine
        onPieceCreated:{
            board.setPiece(type,color,tile);
            var tile_obj = tileArray[tile];
            tile_obj.piece.moves = board.game.moves({square: chessEngine.getName(tile)});
        }
        onPieceCaptured:{
            board.removePiece(tile);
        }
        onEnPassant:{
            board.removePiece(tile_destroy);
        }
        onPieceMoved:{
            var to_obj = tileArray[tile_to];
            var from_obj = tileArray[tile_from];
            to_obj.piece = from_obj.piece;
            from_obj.piece = null;
            to_obj.piece.x = to_obj.x;
            to_obj.piece.y = to_obj.y;
            board.turn = board.game.turn()
            if(board.turn === 'w'){
                board.whitesTurn();
            }
            else{
                board.blacksTurn();
            }
        }
        onPromotion:{
            chessEngine.refresh(board.game.get(chessEngine.getName(tile)),tile);

        }
        onRefreshPiece:{
            var to_obj = tileArray[tile];
            var piece_str = type+color;
            var p_index = PieceTable[piece_str];
            if(to_obj.piece === undefined || to_obj.piece === null){
                board.setPiece(type,color,tile);
            }
            else
            {
                to_obj.piece.type = "cg_kramnik.png#"+p_index;
                to_obj.piece.x = to_obj.x;
                to_obj.piece.y = to_obj.y;
            }
        }
        onClearTile:{
            board.removePiece(tile);
        }
    }


    Timer{
        id:creationTimer
        repeat: true
        interval:4
        //onTriggered:createNextTile();
    }

    Rectangle{
        id:boardBackground
        anchors.fill: parent
        color:"black"
        z:1

        onWidthChanged:{
            resizeBoard();
        }

        Grid{
            id:boardGrid
            anchors.centerIn: parent
            columns: 8
            z:2
            add: Transition {
                ParallelAnimation{
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 200 }
                NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 200 }
                }
            }
        }
        CG_DragSurface{
            id:boardMouse
            anchors.fill: parent
            z:100
            cellSize:board.cellSize
            rowCount:8
            onClickStarted:{
                if((board.turn ==='w' && playerColor === true) || (board.turn === 'b' && playerColor === false)){
                    var piece = tileArray[index].piece;
                    if(piece !== null && piece !== undefined){
                        piece.selected = true;
                        boardMouse.setSelected(index,true)
                        board.moves = piece.moves;
                    }
                }
            }
            onClickMoved:{
                var from_tile = tileArray[start];
                var to_tile = tileArray[end];
                from_tile.piece.selected = false;
                board.onPiecePlaced(from_tile,to_tile);
                boardMouse.setSelected(-1,false);
                board.moves = [];
            }
            onDragStarted:{

            }
            onDragMoved:{

            }
            onDragStartHover: {

            }
            onDragStoppedHover: {

            }
        }
    }

    onCellSizeChanged:{
        chessEngine.setCellSize(cellSize);
        board.resizeBoard();
    }

    Component.onCompleted: {
        boardComponent = Qt.createComponent("CG_Tile.qml");
        pieceComponent = Qt.createComponent("CG_Piece.qml");
        creationTimer.triggered.connect(createNextTile)
        creationTimer.start();
    }
}
