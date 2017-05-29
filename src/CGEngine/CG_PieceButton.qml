import QtQuick 2.0

Rectangle {
    border.width:2
    radius:2
    color:"lightgrey"
    property alias type:piece.type
    property alias index:piece.index
    property alias mouse:mouse
    CG_Piece{
        id:piece
        anchors.fill: parent
        anchors.margins: 4
        height:parent.height
    }
    MouseArea{
        id:mouse
        anchors.fill: parent
    }

}
