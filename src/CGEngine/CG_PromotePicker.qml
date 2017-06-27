import QtQuick 2.8

Rectangle {
    radius:4
    border.width: 2
    id:picker
    property bool playerColor:true
    signal   pieceChosen(string piece);
    property string pieceSet:"cg_kramnik.png#"

    onPlayerColorChanged:{
        if(picker.playerColor){
            rook.type = pieceSet + "10";
            knight.type = pieceSet + "8";
            bishop.type = pieceSet + "9";
            queen.type = pieceSet + "7";
        }
        else{
            rook.type = pieceSet + "4";
            knight.type =pieceSet + "2";
            bishop.type =pieceSet + "3";
            queen.type = pieceSet + "1";
        }
    }

    Text{
        id:titleText
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.right:parent.right
        text:"Choose Promotion Piece"
        horizontalAlignment: Text.AlignHCenter
        height:parent.height *.1
        font.pixelSize: parent.height *.06

    }

    CG_PieceButton{
        id:rook
        anchors.left:parent.left
        anchors.top:parent.top
        anchors.margins: 30
        height:parent.height*.34
        width:height
        type:"cg_kramnik.png#10"
        mouse.onPressed: {
            picker.pieceChosen("r");
        }
    }
    CG_PieceButton{
        id:knight
        anchors.right:parent.right
        anchors.top:parent.top
        anchors.margins: 30
        height:rook.height
        width:height
        type:"cg_kramnik.png#8"
        mouse.onPressed: {
            picker.pieceChosen("n");
        }
    }
    CG_PieceButton{
        id:queen
        anchors.left:parent.left
        anchors.bottom:parent.bottom
        anchors.margins: 30
        height:rook.height
        width:height
        type:"cg_kramnik.png#7"
        mouse.onPressed: {
            picker.pieceChosen("q");
        }
    }
    CG_PieceButton{
        id:bishop
        anchors.right:parent.right
        anchors.bottom:parent.bottom
        anchors.margins: 30
        height:rook.height
        type:"cg_kramnik.png#9"
        width:height
        mouse.onPressed: {
            picker.pieceChosen("b");
        }
    }
}
