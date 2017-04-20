import QtQuick 2.8
import QtQuick.Window 2.2
import CGWebApi 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    Connections {
        target:CGWebConnection
        onCheckingConnection:{
            console.log("Checking the connection.")
        }

    }
    MouseArea{
        anchors.fill: parent
        onClicked: {
            console.log("Calling function")
            CGWebConnection.requestCGLoginVerify("obnoxious jerk", "hohoho");
            console.log("Function Called")
        }
    }
}
