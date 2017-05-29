import QtQuick 2.8
import QtGraphicalEffects 1.0
Item{
    id:piece
    property string type:""
    property real index:0
    property alias selected:glow.visible
    z:100
    onTypeChanged: {
        pieceImage.source = "image://pieces/"+type;
    }
    Drag.hotSpot.x: width/2
    Drag.hotSpot.y: height/2
    Image{
        id:pieceImage
        cache:false
        anchors.centerIn: parent
        height:parent.height-2
        width:height
        fillMode: Image.PreserveAspectFit
    }
    Glow {
        id:glow
        anchors.fill: parent
        visible: false
        radius: 8
        samples: 17
        color: "yellow"
        source: pieceImage
    }
}


