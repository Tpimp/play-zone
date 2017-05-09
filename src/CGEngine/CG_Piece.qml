import QtQuick 2.8

Image{
    id:pieceImage
    cache:false
    property string type:""
    property real index:0
    z:60

    onTypeChanged: {
        pieceImage.source = "image://pieces/"+type;
    }
    fillMode: Image.PreserveAspectFit
    //Drag.source: rootItem
    Drag.hotSpot.x: pieceImage.width/2
    Drag.hotSpot.y: pieceImage.height/2
}


