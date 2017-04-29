import QtQuick 2.8

Rectangle {
    color:"blue"
    id: topRect
    property alias minuteText:minuteText.text
    property alias mouse:mouse
    radius:8
    Rectangle{
        anchors.fill: parent
        border.width: 1
        anchors.bottomMargin:5
        color:"#e7e9e8"
        border.color: "darkgrey"
        radius:3
        Text{
            id:minuteText
            anchors.fill:parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

    }
    MouseArea{
        id:mouse
        anchors.fill: parent
    }
}
