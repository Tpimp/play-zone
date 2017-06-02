import QtQuick 2.8

Rectangle {
    id:container
    property alias icon:icon
    property alias iconBackground:iBackground
    property alias text:buttonText
    property alias mouse:mouse
    radius:height
    border.width: 2
    Rectangle{
        id:iBackground
        anchors.top:parent.top
        anchors.bottom:parent.bottom
        anchors.left:parent.left
        anchors.margins: 3
        width:container.height-4
        radius:container.height-8
        border.width: 1
        Image{
            id:icon
            anchors.fill: parent
            anchors.margins: 4
            fillMode: Image.PreserveAspectFit
            smooth:true
            antialiasing: true
        }
    }

    Text{
        id:buttonText
        anchors.top:parent.top
        anchors.bottom:parent.bottom
        anchors.left:iBackground.right
        anchors.right:parent.right
        anchors.leftMargin:container.width*.01
        anchors.topMargin:1
        anchors.bottomMargin:1
        anchors.rightMargin:container.radius
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    MouseArea{
        id:mouse
        anchors.fill: parent
    }
}
