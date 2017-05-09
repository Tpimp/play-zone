import QtQuick 2.8
import "chess.js" as Engine
import CGEngine 1.0
Item {
    id:board
    property string boardDark:"darkgrey"
    property string boardLight:"lightgrey"
    property string faveColor:"white"
    property var    game:undefined
    property real   cellSize:board.width > board.height ? board.height/8:board.width/8
    property var    boardComponent:null
    property var    pieceComponent:null
    property real   pieceCount:0
    property var    tileArray:[]
    property real   fromIndex:-1
    property var    names: ["a8","b8", "c8", "d8", "e8", "f8", "g8", "h8",
                            "a7","b7", "c7", "d7", "e7", "f7", "g7", "h7",
                            "a6","b6", "c6", "d6", "e6", "f6", "g6", "h6",
                            "a5","b5", "c5", "d5", "e5", "f5", "g5", "h5",
                            "a4","b4", "c4", "d4", "e4", "f4", "g4", "h4",
                            "a3","b3", "c3", "d3", "e3", "f3", "g3", "h3",
                            "a2","b2", "c2", "d2", "e2", "f2", "g2", "h2",
                            "a1","b1", "c1", "d1", "e1", "f1", "g1", "h1"]

    function removePiece(tile){
        var tile_obj = tileArray[tile];
        tile_obj.piece.destroy();
        tile_obj.piece = null;
    }
    CGEngine{
        id:chessEngine
    }

    Connections{
        target: chessEngine
        onPieceCreated:{
            board.setPiece(type,color,tile);
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
            to_obj.piece.x = to_obj.x +2;
            to_obj.piece.y = to_obj.y +2;
        }
        onPromotion:{
            chessEngine.refresh(board.game.get(names[tile]),tile);

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
                to_obj.piece.x = to_obj.x +2;
                to_obj.piece.y = to_obj.y +2;
            }
        }
        onClearTile:{
            board.removePiece(tile);
        }

    }

    function onPiecePlaced(from_tile, to_tile){
        if(board.makeMove(from_tile,to_tile, "q"))
        {
            console.log("Valid move made")
            if(board.game.in_checkmate()){
                if(to_tile.piece.type[1] ==='b'){
                    console.log("Black wins by checkmate")
                }
                else{
                    console.log("White wins by checkmate")
                }
            }

        }
        else{
            console.log("Invalid move")
            from_tile.piece.x = from_tile.x +2;
            from_tile.piece.y = from_tile.y +2;
        }

    }

    function makeMove(from_tile,to_tile, promote){
        var move_obj
        if(promote !== null){
          move_obj = board.game.move({from:from_tile.pos,to:to_tile.pos,promotion:promote});
        }
        else{
            move_obj = board.game.move({from:from_tile.pos,to:to_tile.pos});
        }
        return chessEngine.makeMove(from_tile.index,to_tile.index,move_obj);
       /* if(move_obj)
        {
            console.log(move_obj.flags)
            if(to_tile.piece != null){
                board.removePiece(to_tile);
            }
            to_tile.piece = from_tile.piece;
            to_tile.piece.index = to_tile.index;
            to_tile.piece.x = to_tile.x +2;
            to_tile.piece.y = to_tile.y + 2;
            from_tile.piece = null;
            return true;
        }
        return false;*/
    }
    function setPiece(piece,player_color, tile){
        var row = parseInt(tile/8);
        var col = parseInt(tile%8);
        var piece_str = piece+player_color;
        var p_index = PieceTable[piece_str];
        var tile_obj = tileArray[tile];

        if(tile_obj.piece !== null && tile_obj.piece !== undefined){
            tile_obj.piece.piece = "cg_kramnik.png#"+p_index
            // TODO: Add set piece in chess engine
        }
        else{
            tile_obj.piece = pieceComponent.createObject(boardMouse,{});
            tile_obj.piece.x = tile_obj.x + 2;
            tile_obj.piece.y = tile_obj.y + 2;
            tile_obj.piece.height = cellSize -4;
            tile_obj.piece.width = cellSize -4;
            tile_obj.piece.type = "cg_kramnik.png#"+p_index
            tile_obj.piece.index = tile;
        }
    }
    function resetBoard(){
        for(var index = 0; index < 64; index++){
            var tile = tileArray[index];
            if(tile.piece !== undefined  && tile.piece !== null){
                tile.piece.destroy();
                tile.piece = null;
            }
        }
        board.game = Engine.Chess();
        var board_data = board.game.board();
        chessEngine.resetBoard(board_data)

    }
    function clearBoard(){
        for(var index = 0; index < 64; index++){
            var tile = tileArray[index];
            if(tile.piece !== undefined  && tile.piece !== null){
                tile.piece.destroy();
                tile.piece = null;
            }
        }
    }
    function refreshBoard(){
        var board_data = board.game.board();
        chessEngine.resetBoard(board_data)
    }

    function setNewFen(fen){
        board.clearBoard();
        board.game = Engine.Chess(fen);
        board.refreshBoard()
    }
    function setNewPgn(pgn){
        board.clearBoard();
        board.game = Engine.Chess();
        board.game.load_pgn(pgn);
        board.refreshBoard()
    }

    function  createNextTile(){
        if(tileArray.length <= 63){
            populateBoard();
        }
        else{
            creationTimer.stop();
            creationTimer.triggered.disconnect(createNextTile);
            resetBoard();
        }
    }

    function populateBoard() // This function will generate a new image object
    {
        var index = tileArray.length;
        if(boardComponent.status == Component.Ready)
        {
            var instance = boardComponent.createObject(boardGrid,{})
            tileArray[index] = instance;
            if(instance == null)
            {
               return
            }
            else
            {
                var row =parseInt(index / 8);
                if ((row % 2) == 0)
                {
                    if (index % 2){
                        instance.color = boardDark
                    }
                    else{
                        instance.color = boardLight
                    }
                }
                else
                {
                    if (index % 2){
                        instance.color = boardLight
                    }
                    else{
                        instance.color = boardDark
                    }
                }
                instance.pos =  names[index];
                instance.index = index;
                instance.width = cellSize;
                instance.height = instance.width;
            }
        }
        return index;
    }


    Timer{
        id:creationTimer
        repeat: true
        interval:1
        //onTriggered:createNextTile();

    }

    Rectangle{
        id:boardBackground
        border.width: 2
        radius: 4
        anchors.fill: parent
        clip:true
        color:"lightblue"
        Grid{
            id:boardGrid
            anchors.fill: parent
            columns: 8
            columnSpacing:0
            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 150 }
                NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 350 }
            }
        }
        MouseArea{
            id: boardMouse
            anchors.fill: parent
            property bool wasDragged:false
            property real from:-1
            onPressed:{
                var col = parseInt(mouseX/cellSize);
                var row = parseInt(mouseY/cellSize);
                var index = (row*8) + col;
                if(boardMouse.from < 0)
                {
                    if(index >= 0 && index < 64){
                        if(tileArray[index].piece != null){
                            var piece_at = tileArray[index].piece;
                            boardMouse.drag.target = piece_at;
                            board.fromIndex = index;
                        }
                        else{
                            boardMouse.drag.target = null;
                            board.fromIndex = -1;
                        }
                    }
                    wasDragged = false;
                    boardMouse.from = index;
                }
                else{
                    if(index !== boardMouse.from){
                        var from_tile = tileArray[boardMouse.from];
                        var to_tile = tileArray[index];
                        board.onPiecePlaced(from_tile,to_tile)
                        boardMouse.from = -1;
                    }
                }
            }
            drag.onActiveChanged: {
                wasDragged =active;
            }

            onReleased: {
                var col = parseInt(mouseX/cellSize);
                var row = parseInt(mouseY/cellSize);
                var index = (row*8) + col;
                if(wasDragged){
                    boardMouse.from = -1;
                    if(board.fromIndex >=0)
                    {
                        var from_tile = tileArray[board.fromIndex];
                        if(index < 64 && index >= 0){
                            var to_tile = tileArray[index];
                            board.onPiecePlaced(from_tile,to_tile)
                        }
                        else{
                            from_tile.piece.x = from_tile.x +2;
                            from_tile.piece.y = from_tile.y +2;
                        }
                    }
                    boardMouse.drag.target = null;
                }
            }
        }
    }


    Component.onCompleted: {
        boardComponent = Qt.createComponent("CG_Tile.qml");
        pieceComponent = Qt.createComponent("CG_Piece.qml");
        creationTimer.triggered.connect(createNextTile)
        creationTimer.start();
        //        var moves = board.game.moves();
        //        var move = moves[Math.floor(Math.random() * moves.length)];
        //        board.game.move(move);
        //        console.log(board.game.pgn());
    }
    /*Component.onDestroyed: {
        for(var index = 0; index < 64; index++){
            var tile = tileArray[index];
            if(tile.piece !== undefined  && tile.piece !== null){
                tile.piece.destroy();
                tile.piece = null;
            }
        }
    }*/
}
