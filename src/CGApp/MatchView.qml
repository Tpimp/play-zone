import QtQuick 2.8
import CGFlags 1.0
import CGNetwork 1.0
import QtQuick.Controls 2.1

Rectangle {
    id: match
    function returnToLobby(){
        oneButton.enabled = true;
        fiveButton.enabled = true;
        thirtyButton.enabled = true;
    }

    Image{
        id:background
        anchors.fill: parent
        source:"/images/ChessBackground.png"
        fillMode: Image.Stretch
    }

    Image{
        id:hamburgerButton
        source:"/images/HamburgerMenu.png"
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.1
        anchors.top:parent.top
        height: parent.height * .08
        width:height
        MouseArea{
            anchors.fill: parent
            onClicked:{
                root.logout();
            }
        }
    }

    Rectangle{
        id: userBar
        color:"#5fc393"
        border.color: "darkgrey"
        border.width: 1
        radius:8
        anchors.top:hamburgerButton.bottom
        anchors.left: parent.left
        anchors.right:parent.right
        anchors.margins: parent.width*.1
        height:parent.height*.16
        Rectangle{
            id:innerBar
            color:"#e7e9e8"
            anchors.fill:parent
            anchors.topMargin:1
            anchors.bottomMargin: 5
            radius:4
            Image{
                id:flag
                anchors.left:parent.left
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                anchors.margins: 8
                width:height
                fillMode: Image.PreserveAspectFit
                smooth:true
            }
            Text{
                id:username
                anchors.left:flag.right
                anchors.right:parent.right
                anchors.top:parent.top
                anchors.margins:4
                anchors.bottom:eloText.top
                font.pixelSize: height * .65
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                id: eloText
                anchors.left:flag.right
                anchors.right:parent.right
                anchors.bottom:parent.bottom
                height:parent.height *.465
                font.pixelSize: height * .52
                anchors.margins:4
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    LobbyButton{
        id:oneButton
        anchors.right:fiveButton.left
        anchors.top:fiveButton.top
        anchors.rightMargin: 8
        height:userBar.height * .75
        width:height
        minuteText:"1\nMinute"
        mouse.onClicked: {
            oneButton.enabled = false;
            fiveButton.enabled = false;
            thirtyButton.enabled = false;
            lobbyController.joinMatchMaking(0)
            root.joinMatchMaking();
        }
    }

    LobbyButton{
        id:fiveButton
        anchors.top:userBar.bottom
        anchors.margins: userBar.width * 0.15
        anchors.horizontalCenter: userBar.horizontalCenter
        height:userBar.height * .75
        width:height
        minuteText:"5\nMinutes"
        mouse.onClicked: {
            oneButton.enabled = false;
            fiveButton.enabled = false;
            thirtyButton.enabled = false;
            lobbyController.joinMatchMaking(1)
            root.joinMatchMaking();
        }

    }

    LobbyButton{
        id:thirtyButton
        anchors.left:fiveButton.right
        anchors.leftMargin: 8
        anchors.top:fiveButton.top
        height:oneButton.width
        width:oneButton.width
        minuteText:"30\nMinutes"
        mouse.onClicked: {
            oneButton.enabled = false;
            fiveButton.enabled = false;
            thirtyButton.enabled = false;
            lobbyController.joinMatchMaking(2)
            root.joinMatchMaking();
        }

    }
    Connections{
        target:playerProfile
        onCountryChanged:{
            flag.source = "image://flags/" +country
        }
        onNameChanged:{
            username.text = name;
        }
        onEloChanged:{
            eloText.text = elo;
        }
    }

    Component.onCompleted: {
        flag.source = "image://flags/" + playerProfile.country()
        username.text = playerProfile.name()
        eloText.text = playerProfile.elo()
    }
}
