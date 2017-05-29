function populateBoard() // This function will generate a new image object
{
    var index = board.tileArray.length;
    if(boardComponent.status == Component.Ready)
    {
        var instance = boardComponent.createObject(boardGrid,{})
        board.tileArray[index] = instance;
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
                    instance.setColor(boardDark,true);
                }
                else{
                    instance.setColor(boardLight,false);
                }
            }
            else
            {
                if (index % 2){
                    instance.setColor(boardLight,false);
                }
                else{
                    instance.setColor(boardDark,true);
                }
            }
            instance.pos =  chessEngine.getName(index);
            instance.index = index;
            instance.width = cellSize;
            instance.height = instance.width;
        }
    }
    return index;
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
    if(board.tileArray.length <= 63){
        populateBoard();
    }
    else{
        creationTimer.stop();
        creationTimer.triggered.disconnect(createNextTile);
        creationTimer.triggered.connect(resetBoard);
        creationTimer.repeat = false;
        creationTimer.interval = 290;
        creationTimer.start()
    }
}

function resetBoard(board){
    for(var index = 0; index < 64; index++){
        var tile = board.tileArray[index];
        if(tile.piece !== undefined  && tile.piece !== null){
            tile.piece.destroy();
            tile.piece = null;
        }
    }
    board.game = Engine.Chess();
    var board_data = board.game.board();
    chessEngine.resetBoard(board_data)
    board.finishedLoading();

}

function clearBoard(){
    for(var index = 0; index < 64; index++){
        var tile = board.tileArray[index];
        if(tile.piece !== undefined  && tile.piece !== null){
            tile.piece.destroy();
            tile.piece = null;
        }
    }
}

function setPiece(piece,player_color, tile){
    var row = parseInt(tile/8);
    var col = parseInt(tile%8);
    var piece_str = piece+player_color;
    var p_index = PieceTable[piece_str];
    var tile_obj = tileRepeater.itemAt(tile);
    if(tile_obj.piece !== null && tile_obj.piece !== undefined){
        tile_obj.piece.piece = "cg_kramnik.png#"+p_index
        // TODO: Add set piece in chess engine
    }
    else{
        tile_obj.setPiece(pieceComponent.createObject(boardMouse,{}),tile,p_index);
    }
}

function makeMove(from_tile,to_tile, promote, override){
    var move_obj = board.game.move({from:from_tile.pos,to:to_tile.pos,promotion:'q'});
    if(move_obj !== null && override === undefined){
        if(move_obj.flags.indexOf('p') >= 0){
            board.game.undo();
            board.isPromote(from_tile, to_tile);
            return;
        }
    }

    return chessEngine.makeMove(from_tile.index,to_tile.index,move_obj);
}

function makeRemoteMove(move){
    var from_tile = board.tileArray[move.from];
    var to_tile = board.tileArray[move.to];
    var move_obj = board.game.move({from:from_tile.pos,to:to_tile.pos,promotion:move.promote});
    chessEngine.makeMove(from_tile.index,to_tile.index,move_obj);
    checkGameOver(move_obj);
    board.lastFen = board.game.fen();
}

function checkValidMove(x,y){
    var col = parseInt(x/cellSize);
    var row = parseInt(y/cellSize);
    var index = (row*8) + col;
    if(board.lastHoverTile !== null){
        board.lastHoverTile.selected = false;
    }
    if(index >= 0 && index < 64){
        if(board.moves.indexOf(board.pieceType + chessEngine.getName(index)) >=0){
            board.lastHoverTile = board.tileArray[index];
            board.lastHoverTile.selected = true;
            return true;
        }
    }
    return false;
}

function onPiecePlaced(from_tile, to_tile){
    if(board.makeMove(from_tile,to_tile, "q"))
    {
        board.turn = board.game.turn()
        var move_obj = {to:to_tile.pos,from:from_tile.pos,promotion:"q"};
        board.lastFen = board.game.fen();
        board.sendMove(from_tile.index,to_tile.index, board.lastFen ,"q")
        checkGameOver(move_obj);
        to_tile.piece.moves = board.game.moves({square: chessEngine.getName(to_tile.index)});
        board.lastFen = board.game.fen();
    }
    else{
        //console.log("Invalid move")
        from_tile.piece.selected = false;
        from_tile.piece.x = from_tile.x;
        from_tile.piece.y = from_tile.y;

    }
    if(board.lastHoverTile){
        board.lastHoverTile.selected = false;
    }
    board.moves = [];

}


function checkGameOver(move_obj){
    if(board.game.game_over()){
        if(board.game.in_checkmate()){ // one side lost
            if(board.turn === 'w'){
                if(playerColor){
                    board.sendResult(-1,move_obj,board.lastFen,board.game.pgn())
                }
                else{
                    board.sendResult(1,move_obj,board.lastFen,board.game.pgn())
                }
                console.log("Black wins by checkmate")
            }
            else{
                if(playerColor){
                    board.sendResult(1,move_obj,board.lastFen,board.game.pgn())
                }
                else{
                    board.sendResult(-1,move_obj,board.lastFen,board.game.pgn())
                }
                console.log("White wins by checkmate")
            }
        }
        else if(board.game.in_draw()){ // draw game
            board.sendResult(0,move_obj,board.lastFen,board.game.pgn())
        }
    }
}

function resizeBoard(){
    if(board.boldBorder){
        boardGrid.spacing = 1;
        boardGrid.width = boardBackground.width-2;
        boardGrid.height = boardBackground.height-2;
        chessEngine.setCellSize(cellSize-1);
        for(var index = 0; index < 64; index++){
            var tile = board.tileArray[index];
            if(tile){
                tile.width = (cellSize - 1);
                tile.height = (cellSize - 1);
                if(tile.piece !== undefined && tile.piece !== null){
                    tile.piece.x = tile.x;
                    tile.piece.y = tile.y;
                    tile.piece.width = tile.width;
                    tile.piece.height = tile.height;
                }
            }
        }
    }
    else
    {
        boardGrid.width = boardBackground.width;
        boardGrid.height = boardBackground.height;
        boardGrid.spacing = 0;
        chessEngine.setCellSize(cellSize);
        for(var indexw = 0; indexw < 64; indexw++){
            var tilew = board.tileArray[indexw];
            if(tilew){
                tilew.width = cellSize;
                tilew.height = cellSize;
                if(tilew.piece !== undefined && tilew.piece !== null){
                    tilew.piece.x = tilew.x;
                    tilew.piece.y = tilew.y;
                    tilew.piece.width = tilew.width;
                    tilew.piece.height = tilew.height;
                }
            }
        }
    }

}


function removePiece(tile){
    var tile_obj = tileArray[tile];
    tile_obj.piece.destroy();
    tile_obj.piece = null;
}
