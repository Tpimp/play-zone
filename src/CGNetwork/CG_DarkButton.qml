import QtQuick 2.8

Rectangle{
    id:container
    color: "#3f3f3f"
    smooth: true
    radius: 9
    border.width: 0
    property alias text:buttonText
    property alias background:container
    property alias mouse:mouseArea
    Text{
        id:buttonText
        anchors.fill: parent
        color:"#e7e9e8"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "fonts/Arkhip_font.ttf"
        renderType: Text.NativeRendering
        font.pixelSize: container.height *.65
    }

    MouseArea{
        id:mouseArea
        anchors.fill:parent
    }
}

