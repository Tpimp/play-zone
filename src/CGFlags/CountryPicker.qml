import QtQuick 2.8

Rectangle {
    id:root
    width:400
    height:500
    signal setCountry(string country);
    property var flagComponent:undefined
    property int flagCount:0
    Flickable{
        id:flicker
        anchors.fill: parent
        contentHeight: flagCount*80
        clip:true
        Column{
            id: list
            anchors.fill: parent
            add: Transition {              
                NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 150 }
            }
        }
    }
    Timer{
        id:creationTimer
        repeat: true
        running:false
        interval:30
        onTriggered:{
            if( flagCount< AvailableCountries.length){
                var instance = flagComponent.createObject(list,{modelData:AvailableCountries[flagCount++]})
                instance.y = ((flagCount-1) * instance.height)
            }
            else{
                creationTimer.stop();
            }
        }
    }

    Component.onCompleted: {
        flagComponent = Qt.createComponent("CG_FlagBar.qml");
        creationTimer.start()
    }
}
