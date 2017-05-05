import QtQuick 2.8

Rectangle {
    id:emblem
    width:height
    radius:height/2
    color:"lightblue"
    property alias pieceSet: sprite.source
    property bool emblemColor:false
    onEmblemColorChanged: {
        if(emblemColor){
            sprite.frameX=810;
        }
        else{
            sprite.frameX=0;s
        }
    }

    SpriteSequence{
        id:image
        anchors.centerIn: parent
        height:parent.height *.65
        width:height
        anchors.margins: emblem.radius
        interpolate:true
        running:emblem.visible
        sprites:Sprite{
            id:sprite
            frameDuration:1000
            frameCount:5
            frameHeight: 135
            frameWidth: 135
            randomStart: true
            source:"/images/cg_kramnik2.png"
        }
    }
}
