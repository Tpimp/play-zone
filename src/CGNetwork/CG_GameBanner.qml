import QtQuick 2.8

Flipable {
    id:parentContainer
    property bool showBack:false
    property alias banner:playerBanner
    onHeightChanged: rotation.origin.y = height/2
    function setBack(component){
        backLoader.active = false;
        backLoader.sourceComponent = component;
        backLoader.active = true;
    }
    function stopReset(){
        resetTimer.stop();
    }

    onShowBackChanged:{
        if(showBack){
            resetTimer.start()
        }
    }

    front:CG_PlayerBanner{
        id:playerBanner
        anchors.fill: parentContainer
        MouseArea {
            anchors.fill: parent
            onClicked: parentContainer.showBack = !parentContainer.showBack;
        }
    }
    transform: Rotation {
            id: rotation
            // center the origin
            origin.x: 0
            origin.y: 0
            axis.x: 1; axis.y: 0; axis.z: 0     // set axis.y to 1 to rotate around y-axis
            angle: 0    // the default angle
        }
    states:State{
        name:"FLIPPED"
        extend:""
        PropertyChanges {
            target: rotation
            angle:180
        }
        when:parentContainer.showBack
    }
    transitions:Transition{

        NumberAnimation {
            target:rotation
            property: "angle"
            duration: 650
        }
    }
    Loader{
        id:backLoader
        onLoaded:{
            item.parent = parentContainer;
            parentContainer.back = item;
        }
    }
    Timer{
        id: resetTimer
        interval:5000
        running:false
        repeat:false
        onTriggered: {
            parentContainer.showBack = false;
        }
    }
}
