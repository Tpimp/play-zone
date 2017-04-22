import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: root
    property alias color: socialMediaRect.color
    property alias shadowColor: socialMediaShadow.color
    property alias iconSource: socialMediaIcon.source
    property alias text: socialMediaText.text
    property alias mouseArea: socialMediaMouseArea

    // Social Media Rectangle
    Rectangle {
        id: socialMediaRect
        color: "blue"
        smooth: true
        radius: 9
        width: parent.width
        height: parent.height

        // Social Media Icon
        Image {
            id: socialMediaIcon
            width: parent.height
            height: parent.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: socialMediaText
            text: "Log in with social media"
            font.family: "fonts/HelveticaNeue.ttf"
            font.pixelSize: getSmallestOrientation() * 0.03
            color: "white"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: (parent.width - socialMediaIcon.width - width) / 2
        }

        MouseArea {
            id: socialMediaMouseArea
            anchors.fill: parent
        }
    }

    DropShadow {
        id: socialMediaShadow
        anchors.fill: socialMediaRect
        horizontalOffset: 0
        verticalOffset: 4
        radius: 0
        color: "black"
        samples: 17
        spread: 0.0
        source: socialMediaRect
    }
}
