import QtQuick 2.8
import "chess.js" as Engine
import CGEngine 1.0
import "board.js" as Board

Item {
    id:board
    // actual changeable values of the board
    property string  boardDark:"darkgrey"
    property string  boardLight:"lightgrey"
    property string  faveColor:"white"
    property bool    boldBorder:true
    property var     game:Engine.Chess()
    property real    cellSize:width/8 - 2
    property var     pieceComponent:undefined
    property var     lastHoverTile:null
    property var     moves:[]
    property string  heldType:''
    property string  turn:'w'
    property bool    playerColor:true
    property var     whiteKing:undefined
    property var     blackKing:undefined
    property var     boardLastMove: undefined

    signal finishedLoading();
    signal sendMove(int from, int to, string fen, string promote);
    signal whitesTurn();
    signal blacksTurn();
    signal promote(var from, var to);
    signal gameOver(int result, var move, string fen, string game);
    signal pieceTaken(var piece);

    // external flags
    property alias  interactive:boardMouse.enabled
    property alias  borderColor:boardBackground.color

    // after values are changed, redraw the board
    onCellSizeChanged:{
        board.resizeBoard();
    }
    onBoldBorderChanged: {
        board.resizeBoard();
    }
    onWidthChanged: {
        if(board.width >= board.height){
            boardBackground.width = board.height;
            boardBackground.height = board.height;
        }
        else{
            boardBackground.width = board.width;
            boardBackground.height = board.width;
        }
        board.cellSize = (boardBackground.width -2)/8;
        board.resizeBoard()
    }
    onHeightChanged: {
        if(board.width >= board.height){
            boardBackground.width = board.height;
            boardBackground.height = board.height;
        }
        else{
            boardBackground.width = board.width;
            boardBackground.height = board.width;
        }
        board.cellSize = (boardBackground.width -2)/8;
        board.resizeBoard()
    }
    // CG_Board Specific functions

    // update pgn header items
    function setHeader(white, black, date){
        board.game.header('White',white,'Black',black,'Date',date);
    }
    function resign(){
        board.gameOver(2, boardLastMove, board.game.fen(), board.game.pgn());
    }
    function sendDrawAccept(){
        board.gameOver(0, boardLastMove, board.game.fen(), board.game.pgn());
    }

    // function redraw all the board pieces
    function resizeBoard(){
        chessEngine.setCellSize(board.cellSize);
        boardMouse.cellSize = board.cellSize;
        for(var index = 0; index < 64; index++){
            var tile = tileRepeater.itemAt(index);
            if(tile){
                tile.width = board.cellSize;
                tile.height = board.cellSize;
                if(board.boldBorder){
                    tile.border.width = 1;
                }
                else{
                    tile.border.width = 0;
                }
                if(tile.piece !== undefined && tile.piece !== null){
                    tile.piece.x = tile.x;
                    tile.piece.y = tile.y;
                    tile.piece.width = tile.width;
                    tile.piece.height = tile.height;
                }
            }
        }
        boardGrid.spacing =1;
        boardGrid.spacing =0;
    }


    // redraw the pieces on the board
    function refreshBoard(){
        var board_data = board.game.board();
        chessEngine.resetBoard(board_data)
        finishedLoading();
    }

    function clearHeldPiece()
    {
        if(board.lastHoverTile){
            board.lastHoverTile.selected = false;
            board.lastHoverTile = null;
        }
        board.moves = [];
    }


    function removePiece(index){
        var tile = tileRepeater.itemAt(index)
        if(tile.piece){
            tile.piece.destroy();
            tile.piece = null;
        }
    }

    function makeRemoteMove(move){
        var from_tile = tileRepeater.itemAt(move.from);
        var to_tile = tileRepeater.itemAt(move.to);
        var move_obj = board.game.move({from:from_tile.pos,to:to_tile.pos,promotion:move.promote});
        if(move_obj !== null){
            chessEngine.makeMove(from_tile.index,to_tile.index,move_obj,promote);
            board.boardLastMove = move_obj;
            if(board.game.game_over()){
                chessEngine.handleGameOver(board.game.in_draw(),board.game.in_checkmate(),board.game.in_stalemate(),
                                           board.game.in_threefold_repetition(),board.game.insufficient_material())
            }
        }
    }

    // check the move is valid
    function makeMove(from_tile,to_tile, promote,override){
        if(override === undefined){
            promote = 'q';
        }
        var move_obj = board.game.move({from:from_tile.pos,to:to_tile.pos,promotion:promote});
        if(move_obj !== null){
            if(move_obj.flags.indexOf('p') >= 0 && override === undefined){ // if promote
                board.game.undo();
                board.promote(from_tile, to_tile);
            }
            else{
                chessEngine.makeMove(from_tile.index,to_tile.index,move_obj,promote);
                board.sendMove(from_tile.index,to_tile.index, board.game.fen(), promote);
                board.boardLastMove = move_obj;
                if(board.game.game_over()){
                    chessEngine.handleGameOver(board.game.in_draw(),board.game.in_checkmate(),board.game.in_stalemate(),
                                               board.game.in_threefold_repetition(),board.game.insufficient_material())

                }
            }
        }
        else
        {
            from_tile.piece.selected = false;
            from_tile.piece.x = from_tile.x;
            from_tile.piece.y = from_tile.y;
        }
        clearHeldPiece();
    }
    // CGEngine integration ( A bulk of the logic )

    CGEngine{
        id:chessEngine
        onPieceCreated:{ // create the piece on the board
            var tile_obj = tileRepeater.itemAt(tile);
            var row = parseInt(tile/8);
            var col = parseInt(tile%8);
            var piece_str = type+color;


            var p_index = PieceTable[piece_str];
            if(tile_obj.piece !== null && tile_obj.piece !== undefined){
                tile_obj.piece.piece = "cg_kramnik.png#"+p_index
            }
            else{
                var piece = pieceComponent.createObject(boardMouse,{});
                tile_obj.setPiece(piece,tile,p_index);
            }
            if(type == 'k'){
                if(color == 'w'){
                    board.whiteKing = tile_obj;
                }
                else
                {
                    board.blackKing = tile_obj;
                }
            }
        }
        onPieceCaptured:{ // remove it
            board.removePiece(tile);
        }
        onEnPassant:{ // remove the pawn
            board.removePiece(tile_destroy);
        }
        onPieceMoved:{ // move the piece
            var to_obj = tileRepeater.itemAt(tile_to);
            var from_obj = tileRepeater.itemAt(tile_from);
            to_obj.piece = from_obj.piece;
            from_obj.piece = null;
            to_obj.piece.x = to_obj.x;
            to_obj.piece.y = to_obj.y;
            var got = board.game.get(to_obj.pos);
            if(got.type === 'k'){
                if(got.color === 'w'){
                    board.whiteKing = to_obj;
                }
                else
                {
                    board.blackKing = to_obj;
                }
            }

            board.turn = board.game.turn()
            if(board.turn === 'w'){
                board.whitesTurn();
                if(board.game.in_check()){
                    chessEngine.isInCheck(board.whiteKing.index);
                }
            }
            else{
                board.blacksTurn();
                if(board.game.in_check()){
                    chessEngine.isInCheck(board.blackKing.index);
                }
            }
        }
        onPromotion:{
            var tile_obj = tileRepeater.itemAt(tile);
            chessEngine.refresh(board.game.get(tile_obj.pos),tile);
        }
        onPlayerCheck:{
            var tile_obj = tileRepeater.itemAt(index);
            checkText.x = tile_obj.x - (cellSize/2);
            checkText.y = tile_obj.y;
            checkText.visible = true;
            checkAnimation.start();
        }
        onGameOverCheckmate: {
            var result;
            if(board.game.turn() === 'b'){
                if(playerProfile.color){ // player one wins
                    result = 1;
                }
                else // player two wins
                {
                    result = -1;
                }

            }
            else{
                if(!playerProfile.color){ // player one wins
                    result = 1;
                }
                else // player two wins
                {
                    result = -1;
                }
            }
            var game = board.game.pgn();
            board.game.undo();
            var fen = board.game.fen();
            board.gameOver(result, board.boardLastMove ,fen, game);
        }
        onGameOverDraw: {
            var game = board.game.pgn();
            board.game.undo();
            var fen = board.game.fen();
            board.gameOver(0, board.boardLastMove ,fen, game);
        }
        onGameOverStaleMate: {
            var game = board.game.pgn();
            board.game.undo();
            var fen = board.game.fen();
            board.gameOver(0, board.boardLastMove ,fen, game);
        }

        onRefreshPiece:{
            var to_obj = tileRepeater.itemAt(tile);
            var piece_str = type+color;
            var p_index = PieceTable[piece_str];
            if(to_obj.piece === undefined || to_obj.piece === null){
                Board.setPiece(type,color,tile);
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



    /*********************************************************************************
    ** The QML Definition for the board object
    **
    **
    **
    *********************************************************************************/

    Rectangle{
        id:boardBackground
        anchors.horizontalCenter:  parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color:"black"
        width:parent.width >= parent.height ? parent.height:parent.width
        height:width
        z:1
        Grid{
            id:boardGrid
            anchors.fill: parent
            anchors.margins: 1
            columns: 8
            z:2
                Repeater{
                    id:tileRepeater
                    model:64
                    CG_Tile{
                        id: cell
                        height:cellSize
                        width:cellSize
                    }
                    Component.onCompleted: {
                        for(var index = 0; index < 64; index++){
                            var row =parseInt(index / 8);
                            var cell = tileRepeater.itemAt(index)
                            if ((row % 2) == 0)
                            {
                                if (index % 2){
                                    cell.setColor(boardDark,true);
                                }
                                else{
                                    cell.setColor(boardLight,false);
                                }
                            }
                            else
                            {
                                if (index % 2){
                                    cell.setColor(boardLight,false);
                                }
                                else{
                                    cell.setColor(boardDark,true);
                                }
                            }
                            cell.pos =  chessEngine.getName(index);
                            cell.index = index;
                            cell.piece = null;
                        }
                    }
                }
        }
        CG_DragSurface{
            id:boardMouse
            anchors.fill: parent
            cellSize:board.cellSize
            rowCount:8
            onClickStarted:{
                var tile = tileRepeater.itemAt(index);
                var piece = tile.piece;
                if(piece !== null && piece !== undefined){
                    var got = board.game.get(tile.pos);
                    if((got.color === board.turn) || (got.color === board.turn)){
                        piece.selected = true;
                        boardMouse.setSelected(index,true)
                        if(got.type !== 'p'){
                            if(got.color)
                            {
                                heldType = got.type.toUpperCase();
                            }
                            else{
                                heldType = got.type;
                            }
                        }
                        else{
                            heldType = '';
                        }
                        board.moves = piece.moves;
                    }
                }
                drag.target = null;

            }
            onClickMoved:{
                var from_tile = tileRepeater.itemAt(start);
                var to_tile = tileRepeater.itemAt(end);
                from_tile.piece.selected = false;
                board.makeMove(from_tile,to_tile,'q'); //initial check
                boardMouse.setSelected(-1,false);
                board.moves = [];
                drag.target = null;
            }
            onPressedAt: {
                var tile = tileRepeater.itemAt(index);
                var piece = tile.piece;
                if(piece !== null && piece !== undefined){
                    var got = board.game.get(tile.pos);
                    if((got.color === board.turn) || (got.color === board.turn)){
                        boardMouse.drag.target = piece;
                        board.moves = board.game.moves({square: tile.pos});
                        if(got.type !== 'p' && got.type !== 'P'){
                            if(got.color)
                            {
                                heldType = got.type.toUpperCase();
                            }
                            else{
                                heldType = got.type;
                            }
                        }
                        else{
                            heldType = '';
                        }
                    }
                }
            }

            onDragMoved:{
                var from_tile = tileRepeater.itemAt(start);
                if(from_tile){
                    var to_tile = tileRepeater.itemAt(end);
                    from_tile.piece.selected = false;
                    board.makeMove(from_tile,to_tile,'q'); //initial check
                }
                drag.target = null;
                boardMouse.setSelected(-1,false);
                board.moves = [];
            }
            onDragStartHover: {
                var tile = tileRepeater.itemAt(start);
                if(chessEngine.checkValidMove(board.moves, tile.pos)){
                    tile.selected = true;
                }
            }
            onDragStoppedHover: {
                var tile = tileRepeater.itemAt(left);
                tile.selected = false;
            }
        }
        onWidthChanged: {
            board.resizeBoard()
        }
    }

    Timer{
        id:creationTimer
        interval:1
        running:false
        repeat:false
        onTriggered: board.refreshBoard();
    }
    Image{
        id:checkText
        height:cellSize
        width:cellSize*2
        source:"/images/check2.png"
        fillMode: Image.PreserveAspectFit
        z:150
        visible:false
        SequentialAnimation{
            id: checkAnimation
            running:false
            NumberAnimation {
                target: checkText
                property: "scale"
                from: 1.0
                to: 1.25
                duration: 300
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: checkText
                property: "scale"
                from: 1.25
                to: 1.0
                duration: 300
                easing.type: Easing.InOutQuad
            }
            onStopped: {
                checkText.visible = false;
            }

            alwaysRunToEnd: true
        }

    }

    Component.onCompleted: {
        board.pieceComponent = Qt.createComponent("CG_Piece.qml");
        board.resizeBoard();
        creationTimer.start()
    }
}
