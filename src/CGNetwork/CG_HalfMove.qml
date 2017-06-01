import QtQuick 2.8

Rectangle{
    id:halfMove
    radius:height -5
    property alias text:text
    Text{
        id:text
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text:"Move"
        font.pixelSize: height*.45
    }
}

