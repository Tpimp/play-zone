import QtQuick 2.8
import CGFlags 1.0
import CGNetwork 1.0
import QtQuick.Controls 2.1
Rectangle {
    id:root
    anchors.fill: parent
    color:"transparent"
    signal logout()
    signal requestUpdateProfile()
    property var userProfile:undefined
    signal joinMatchMaking();
    signal playerMatched(string name, int elo, string country, bool color)
    function setProfile(profile){
        userProfile = profile;
        flag.source = "image://flags/" +root.userProfile.flag;
        eloText.text = root.userProfile.elo
        username.text = root.userProfile.name
    }

    CGLobby{
        id: lobbyController
        onMatchedWithAnotherPlayer:{
            root.playerMatched(name,elo,country, color);
        }
    }

    /*****************************************************************************
    *This Begins The User Interface
    * The Lobby View consists of:
    *
    *  [CONTENT DESCRIPTION]
    *  Lobbyview constist of multiple pages inside of a QML SwipeView.
    *  While the user is not in a game, they can swip right to get to profile
    *  and left to get to chat lobby.
    *
    *  The pages consist of "Chat Lobby", "Profile View", and "Lobby".
    *
    *  At lobby the user is able to view their recent matches, see live games
    *  and start matchmaking.
    *  Below will describe the Lobby portion of the LobbyView - Chat Lobby and
    *  Profile are described in their own files. (CGNetwork)
    *
    *  [SIZE AND LAYOUT]
    *  The root rectangle controls height and width. Because the SlideView inherits
    *  the size of root, pages should also be sized the same.
    *******************************************************************************/

    SwipeView{
    anchors.fill: parent
        Rectangle{
            id:lobby
            color:"transparent"
            height:root.height
            width:root.width
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
                        MouseArea{
                            anchors.fill: parent
                            onClicked:countryPicker.visible = true;
                        }
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
                anchors.top:userBar.bottom
                anchors.rightMargin: 8
                height:userBar.height * .8
                width:height
                anchors.topMargin:8
                minuteText:"1"
                mouse.onClicked: {
                    lobbyController.joinMatchMaking(0)
                    root.joinMatchMaking();
                }
            }

            LobbyButton{
                id:fiveButton
                anchors.horizontalCenter: userBar.horizontalCenter
                anchors.leftMargin: 8
                anchors.top:oneButton.top
                height:oneButton.width
                width:oneButton.width
                minuteText:"5"
                mouse.onClicked: {
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
                minuteText:"30"
                mouse.onClicked: {
                    lobbyController.joinMatchMaking(2)
                    root.joinMatchMaking();
                }

            }

            CountryPicker{
                id:countryPicker
                anchors.fill: parent
                width:parent.width
                height:parent.height
                visible:false
                onSetCountry:{
                    flag.source = "image://flags/" +country;
                    userProfile.setCountry(country);
                    root.requestUpdateProfile();
                    countryPicker.visible = false;
                }
            }
        }
    }





}
