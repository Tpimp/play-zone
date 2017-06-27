import QtQuick 2.8
import CGNetwork 1.0
Item {
    id: loadContainer
    property int duration:750
    property alias text:loadingText
    property alias cancel:cancelButton
    property alias cancelText:cancelButton.text
    property real ballWidth:width/5 < height/7 ? width/5:height/7
    anchors.fill: parent
    property alias ballSpacing:ballRow.spacing
    FontLoader{
        id:arkhip
        source:"qrc:/fonts/Arkhip_font.ttf"
    }

    Rectangle{
        id:background
        anchors.fill: parent
        color:"black"
        opacity: .45
        Row{
            id:ballRow
            anchors.fill: parent
            spacing: 4
            anchors.margins: 4
            CG_LoadingBall{
                id: ball1
                bottomValue: (parent.height - width)
                topValue: parent.y + 20
                y:topValue
                visible: false
            }

            CG_LoadingBall{
                id:ball2
                bottomValue: ball1.bottomValue
                topValue: ball1.topValue
                y:bottomValue
                visible: false
            }
            CG_LoadingBall{
                id:ball3
                bottomValue: ball1.bottomValue
                topValue: ball1.topValue
                y:topValue
                visible: false
            }
            CG_LoadingBall{
                id:ball4
                bottomValue: ball1.bottomValue
                topValue: ball1.topValue
                y:bottomValue
                visible: false
            }
            CG_LoadingBall{
                id:ball5
                bottomValue: ball1.bottomValue
                topValue: ball1.topValue
                y:topValue
                visible: false
            }
        }
    }

    Text
    {
        id: loadingText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: parent.height*.16
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "white"
        font.bold: true
        styleColor: "darkgrey"
        font.family:  arkhip.name
        font.pointSize: parent.height < parent.width ? 22:24
        antialiasing: true

    }
    onVisibleChanged: {
        if(visible){
            ball1.startTop();
            ball2.startBottom();
            ball3.startTop();
            ball4.startBottom()
            ball5.startTop()
        }
        else{
            ball1.stop()
            ball2.stop()
            ball3.stop()
            ball4.stop()
            ball5.stop()
        }
    }
    onWidthChanged: {
        ball1.x = width*.05;
        ball1.width = width/5.5
        ball2.width = ball1.width
        ball3.width = ball1.width
        ball4.width = ball1.width
        ball5.width = ball1.width
        ball2.x = ball1.width + (ball1.x*2)
        ball3.x = (ball1.width + ball1.x)*2
        ball4.x = (ball1.width + ball1.x)*3
        ball5.x = (ball1.width + ball1.x)*4
    }
    CG_DarkButton{
        id: cancelButton
        anchors.bottom:parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: parent.height/8
        width: parent.width >= 800 ? 560:parent.width*.8
        height: 60
    }
}
