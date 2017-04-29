import QtQuick 2.0
import QtGraphicalEffects 1.0

// Social Media Rectangle
Item {
    id: root
    property alias color:rect.color
    property alias shadowColor: socialMediaShadow.color
    property alias iconSource: socialMediaIcon.source
    property alias text: socialMediaText.text
    property alias mouseArea: socialMediaMouseArea
    Rectangle{
        id:rect
        color: "blue"
        smooth: true
        radius: 9
        anchors.fill: parent
        // Social Media Icon
        Image {
            id: socialMediaIcon
            anchors.left: parent.left
            anchors.top:parent.top
            anchors.bottom:parent.bottom
            anchors.margins: 1
            width: height
        }

        Text {
            id: socialMediaText
            anchors.right: parent.right
            anchors.top:parent.top
            anchors.bottom:parent.bottom
            anchors.left: socialMediaIcon.right
            anchors.margins: 3
            text: "Log in with social media"
            font.family: "fonts/HelveticaNeue.ttf"
            font.pixelSize: height * .44 <  width * .115 ? height *.44:width * .115
            color: "white"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            anchors.rightMargin: 10
        }

        MouseArea {
            id: socialMediaMouseArea
            anchors.fill: parent
        }
    }
    DropShadow {
        id: socialMediaShadow
        anchors.fill: root
        verticalOffset: 6
        radius: 1
        color: "black"
        samples: 8
        spread: 0.1
        source: rect
    }
}



