import QtQuick 2.8

Rectangle{
    id:rect
    property string pos:""
    property var    piece:undefined
    property real   index:0
    property alias  selected:glowRect.visible
    function setColor(color,isDark){
        rect.color = color;
        if(isDark){
            glowRect.color = Qt.tint(color,Qt.rgba(0,0,0,.8))
        }
        else{
            glowRect.color = Qt.tint(color,Qt.rgba(1,1,1,.8))
        }
    }
    Rectangle{
        id:glowRect
        visible:false
        opacity: .8
        anchors.fill: parent
    }
    function setPiece(piece,index,p_index){
        piece.height = rect.height;
        piece.width = rect.width;
        piece.x = rect.x;
        piece.y = rect.y;
        piece.type = "cg_kramnik.png#"+p_index
        piece.index = index;
        rect.piece = piece;
    }
}
