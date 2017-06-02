import QtQuick 2.8

Rectangle {
    id:drawDialog
    radius: height -1
    border.width: 2
    signal requestResign()
    signal requestDraw();
    function clearRow(){
        var children = buttonRow.children;
        for(var index = 0; index <children.length; index++){
            children[index].destroy();
        }
    }

    states:[
        State{
            name:"ASKING"
            PropertyChanges {
                target: drawDialog
                color:"darkgrey"

            }
            StateChangeScript{script:{
                        clearRow();
                        var text = textComponent.createObject(buttonRow,{});
                     }
                 }
        },
        State{
            name:"ASKED"
            StateChangeScript{script:{
                    clearRow();
                    var accept = buttonComponent.createObject(buttonRow,{"text.text":"Accept Draw",
                                                                  "border.width":1,
                                                                  "icon.source":"qrc:///images/thumb.png",
                                                                  "height":buttonRow.height,
                                                                  "iconBackground.color":"green",
                                                                  "width":buttonRow.width * .46});
                    var decline = buttonComponent.createObject(buttonRow,{"text.text":"Decline Draw",
                                                                  "border.width":1,
                                                                  "icon.source":"qrc:///images/thumb.png",
                                                                   "icon.rotation":180,
                                                                  "height":buttonRow.height,
                                                                   "iconBackground.color":"red",
                                                                  "width":buttonRow.width * .46});
                }
            }
        },
        State{
            name:"RESIGNING"
            StateChangeScript{script:{
                    clearRow();
                    var text = textComponent.createObject(buttonRow,{"text":"Sending Resignation..."});

                }
            }
        }

    ]
    Grid{
        id:buttonRow
        anchors.fill: parent
        anchors.leftMargin: parent.width/10
        anchors.rightMargin:anchors.leftMargin
        anchors.topMargin:4
        anchors.bottomMargin: 4
        spacing:buttonRow.width*.125
        columns:4
        add:Transition{
            NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 550 }
        }
        CG_IconButton{
            height:buttonRow.height
            width:buttonRow.width*.46
            icon.source: "qrc:///images/cg_draw.png"
            text.text:"Draw"
            iconBackground.color: "green"
            mouse.onClicked:{
                drawDialog.requestDraw()
                drawDialog.state = "ASKING"
            }
        }
        CG_IconButton{
            height:buttonRow.height
            width:buttonRow.width*.46
            iconBackground.color: "red"
            icon.source: "qrc:///images/cg_resign.png"
            text.text:"Resign"
            mouse.onClicked:{
                drawDialog.requestResign();
                drawDialog.state = "RESIGNING"
            }
        }
    }
    Component{
        id:buttonComponent
        CG_IconButton{}
    }
    Component{
        id:textComponent
        Text{
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text:"Requesting Draw..."
            color:"white"
            font.pixelSize: parent.height *.35
        }
    }
}
