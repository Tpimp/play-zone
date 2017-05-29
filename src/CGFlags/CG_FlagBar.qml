import QtQuick 2.8
Rectangle{
    property string modelData:""
    id:topDelegate
    height:root.header/7
    implicitHeight: 80
    anchors.left:parent.left
    anchors.right:parent.right
    anchors.margins: 2
    clip:false
    Image{
        id:flag
        anchors.left:parent.left
        anchors.top:parent.top
        anchors.bottom:parent.bottom
        anchors.margins: 4
        width:height
        source: "image://flags/"+modelData
        fillMode: Image.PreserveAspectFit
        smooth:true
    }
    Text{
        anchors.left:flag.right
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
            root.setCountry(modelData);
        }
    }
}
