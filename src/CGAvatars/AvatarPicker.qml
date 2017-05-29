import QtQuick 2.8

Rectangle {
    id:root
    width:400
    height:500
    signal setAvatar(string avatar);
    ListView{
        id: list
        anchors.fill: parent
        model: Avatars
        clip:true
        delegate:Rectangle{
            id:topDelegate
            border.width:1
            radius:2
            height:root.header/7
            implicitHeight: 80
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.margins: 2

            Image{
                id:avatar
                anchors.left:parent.left
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                anchors.margins: 4
                width:height
                source: "image://avatars/"+modelData
                fillMode: Image.PreserveAspectFit
                smooth:true
            }
            Text{
                anchors.left:avatar.right
                anchors.right:parent.right
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                anchors.margins: 8
                font.pixelSize: height * .32
                text:modelData
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    root.setAvatar(modelData);
                }
            }
        }
    }
}
