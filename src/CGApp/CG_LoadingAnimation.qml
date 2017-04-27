import QtQuick 2.8

Item {
    id: loadContainer
    property int duration:750
    property alias text:loadingText
    property real ballWidth:width/5 < height/7 ? width/5:height/7
    anchors.fill: parent
    property alias ballSpacing:ballRow.spacing
    property alias back:btn_back
    Rectangle{
        id:background
        anchors.fill: parent
        color:"black"
        opacity: .45
        Row{
            id:ballRow
            anchors.fill: parent
            anchors.topMargin: btn_back.height
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
        color: "white"
        font.bold: true
        style: Text.Raised
        styleColor: "darkgrey"
        font.pixelSize:parent.height * .056 < parent.width*.056 ? parent.height * .056:parent.width*.056

    }

    CG_DarkButton
    {
        id: btn_back
        anchors.top:parent.top
        anchors.left:parent.left
        width:parent.width/3
        height:parent.height*.11
        text.text:"Back"
        text.font.pixelSize: text.height * .45
        text.color: "white"
        border.color: "#AA000000"
        border.width: 2
        color:"transparent"
        gradient: Gradient
        {
            //GradientStop { position: 0.0; color: control.pressed ? Definitions.BUTTON_COLOR_ON_CLICK : Definitions.TOP_COLOR_FOR_BUTTON }
            //GradientStop { position: 0.5; color: control.pressed ? Definitions.BUTTON_COLOR_ON_CLICK : Definitions.BOTTOM_COLOR_FOR_BUTTON}
            GradientStop { position: 0.0; color: btn_back.mouse.pressed ? "#AA000000" : "#11000000" }
            GradientStop { position: 1.0; color: btn_back.mouse.pressed ? "#11000000" : "#AA000000" }
        }
        Image
        {
            source: "images/cg_leftArrow.png"
            anchors.left:parent.left
            anchors.top:parent.top
            anchors.bottom:parent.bottom
            anchors.margins: 4
            width:height
            opacity: 1.0
            fillMode: Image.PreserveAspectFit
        }
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
}
