import QtQuick 2.8

Rectangle{
    id: clock
    radius:height -5
    property alias text:text
    Text{
        id:text
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text:"Clock"
        font.pixelSize: height*.65
    }
}

