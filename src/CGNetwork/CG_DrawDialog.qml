import QtQuick 2.8

Rectangle {
    id:drawDialog
    radius: height -1
    border.width: 2
    color: "lightgrey"
    signal requestResign()
    signal requestDraw();
    signal acceptedDraw();
    signal declinedDraw();
    function setAsked(){
        drawDialog.state = "ASKED";
    }

    function setWaitDraw(){
        drawDialog.state = "ASKING";
    }
    function setWaitResign(){
        drawDialog.state = "RESIGN";
    }


    function resetDraw(){
        content.active = false;
        content.sourceComponent = defaultComponent;
        content.active = true;
    }

    states:[ State{
            name:"ASKING"
            PropertyChanges {
                target: drawDialog
                color:"darkgrey"
            }
            PropertyChanges {
                target: content
                active:false
                sourceComponent: textDraw
            }
            PropertyChanges {
                target: content
                active:true
            }
        },
        State{
            name:"ASKED"
            PropertyChanges {
                target: drawDialog
                color:"lightgrey"
            }
            PropertyChanges {
                target: content
                active:false
                sourceComponent:askedComponent
            }
            PropertyChanges {
                target: content
                active:true
            }
        },
        State{
            name:"RESIGN"
            PropertyChanges {
                target: drawDialog
                color:"darkgrey"
            }
            PropertyChanges {
                target: content
                active:false
                sourceComponent:textResign
            }
            PropertyChanges {
                target: content
                active:true
            }
        }

    ]
    Loader{
        id:content
        anchors.fill: parent
        anchors.leftMargin: parent.width/10
        anchors.rightMargin:anchors.leftMargin
        anchors.topMargin:4
        anchors.bottomMargin: 4
        sourceComponent: defaultComponent
        active:true
        onLoaded: {
            item.parent = content
        }
    }
    Component{
        id:textDraw
        Text{
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text:"Requesting Draw..."
            color:"white"
            font.pixelSize: content.height *.35
            height:content.height
            width:content.width
        }
    }
    Component{
        id:textResign
        Text{
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text:"Sending Resignation..."
            color:"white"
            font.pixelSize: parent.height *.35
            height:content.height
            width:content.width
        }
    }

    Component{
        id:defaultComponent
        Row{
            anchors.fill: content
            spacing:width*.02
            populate:Transition{
                NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 550 }
            }
            CG_IconButton{
                height:content.height
                width:content.width*.49
                icon.source: "qrc:///images/cg_draw.png"
                text.text:"Draw"
                iconBackground.color: "green"
                mouse.onClicked:{
                    drawDialog.requestDraw()
                }
            }
            CG_IconButton{
                height:content.height
                width:content.width*.49
                iconBackground.color: "red"
                icon.source: "qrc:///images/cg_resign.png"
                text.text:"Resign"
                mouse.onClicked:{
                    drawDialog.requestResign();
                }
            }
        }
    }

    Component{
        id:askedComponent
        Row{
            anchors.fill: content
            spacing:width*.02
            populate:Transition{
                NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 550 }
            }
            CG_IconButton{
                height:content.height
                width:content.width*.49
                icon.source: "qrc:///images/thumb.png"
                text.text:"Accept Draw"
                iconBackground.color: "green"
                mouse.onClicked:{
                    drawDialog.acceptedDraw();
                }
            }
        }
    }

}
