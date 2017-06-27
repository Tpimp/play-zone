import QtQuick 2.8
import CGNetwork 1.0
import CGFlags 1.0
import CGAvatars 1.0
import "chess.js" as Engine
Rectangle {
    id: view
    clip:false
    property var profileBoard:undefined
    signal finishedReview();
    function setShowingReview(review,fen,start_back){
        reviewView.setReview(review,fen,start_back);
        reviewView.visible = true;
    }

    function testGameReview()
    {
        var pgn = ['[Event "CG composition contest"]',
                '[Site "Chessgames.com"]',
                '[Date "2017.06.16"]',
                '[Round "1"]',
                '[White "WannaBe"]',
                '[Black "Stockfish"]',
                '[Result "1-0"]',
                '[WhiteElo "?"]',
                '[BlackElo "?"]',
                '',
                '1. e4 Na6 2. e5 d5 3. exd6 Bh3 4. Bb5+ Qd7 5. Nxh3 O-O-O 6. O-O Qxb5 7. dxe7 Kb8 8. exd8=R# 1-0']
        profileBoard.board.setBoardPGN(pgn.join('\n'));
        var history = profileBoard.board.getHistory();
        reviewView.setReview(history,"",true);
        reviewView.visible = true;
        recentGames.enabled = false;
    }

    states:[
        State{
            name:"HOME"
            extend:""
            //PropertyChanges {target:lastMove; height:0}
            //PropertyChanges {target:transitionBar; height:parent.height * .1}
            //PropertyChanges {target:recentGames; y:parent.height * .13}
           // PropertyChanges {target:recentTrigger; enabled:true}
        },
        State{
            name:"COUNTRY"
            extend:"HOME"
            PropertyChanges{target:avatarLoader; active:false;}
            PropertyChanges{target:countryLoader; active:true;}
        },
        State{
            name:"AVATAR"
            extend:"HOME"
            PropertyChanges{target:avatarLoader; active:true;}
            PropertyChanges{target:countryLoader; active:false;}
        },
        State{
            name:"RECENT"
            extend:"HOME"
            when: recentTrigger.drag.active
            PropertyChanges{target:recentTrigger; enabled:false;}
            PropertyChanges{target:avatarLoader; active:false;}
            PropertyChanges{target:countryLoader; active:false;}
            PropertyChanges{target:flagFrame; visible:false; enabled:false}
            PropertyChanges{target:avatarFrame; visible:false; enabled:false}
            PropertyChanges{target:transitionBar; height:parent.height * .1}
            AnchorChanges{target:transitionBar; anchors.left:parent.left;anchors.right:parent.right}
            PropertyChanges{target:recentGames; y:parent.height * .105}
            PropertyChanges{target:messageText; visible:false}
            PropertyChanges{target:favesText; visible:false}
            PropertyChanges{target:challengeText; visible:false}
            PropertyChanges{target:lastLoader; opacity:0}
            AnchorChanges{target:message;
                            anchors.top: parent.top;anchors.bottom:parent.bottom; anchors.left:parent.left;}
            PropertyChanges{target:message; anchors.margins: parent.height*.01; anchors.leftMargin:parent.width *.02;}
            AnchorChanges{target:challenge;
                            anchors.top: parent.top;anchors.bottom:parent.bottom;
                            anchors.horizontalCenter:parent.horizontalCenter;}
            PropertyChanges{target:challenge; anchors.margins: parent.height*.01;}
            AnchorChanges{target:faves;
                            anchors.top: parent.top;anchors.bottom:parent.bottom; anchors.right:parent.right;}
            PropertyChanges{target:faves; anchors.margins: parent.height*.01; anchors.rightMargin:parent.width *.02;}
        },
        State{
            name:"REPLAY"
            extend:"HOME"
        }

    ]
    state: "HOME"
    Connections{
        target:playerProfile
        onCountryChanged: {
                flag.source = "image://flags/" +country

        }
        onAvatarChanged: {
            avatarImg.source = "image://avatars/" +avatar

        }
//      onReceivedLastMatch:{
//            view.profileBoard.setAnimation(pgn)
//        }
    }

    /*****************************************************************************
    *This Begins The User Interface
    * The Profile View consists of:
    *
    *  [CONTENT DESCRIPTION]
    *  Top Left is Avatar and Top Right is the Country flag
    *   Consuming most of the top screens view is the last played game highlight.
    *   Down the road this can be chosen by a scoring system. for now its the
    *   last move of the game. (non-interactive single move animation)
    *   If no games have been played, then a place holder sign "Play Chess" is
    *   displayed.
    *
    *   The profile view also has the place to set your country (i.e. a color picker)
    *
    *
    *   Next is the transtion bar. The transition bar helps users navigate to
    *    the recent games list and then back to the profile home. On the transition
    *    bar is quick links to favorites list, recent messgaes, and settings.
    *    The bar is large and slightly curved in home view but becomes a tab like
    *    when the user is navigating recently played games.
    *
    *   Between the Transition bar and the recent played games is a "Recent Games"
    *   line break. this also doubles as the invisible break between home and
    *   the recent games section.
    *
    *   The Recent Games section consists of the game list and a single game
    *    preview frame. The preview fram allows the user to "peek" at the game
    *    without loading the full replay view. The peek consists of the textual
    *    data for the match as well as an easy "copy pgn" button.
    *
    *
    *  [SIZE AND LAYOUT]
    *  The root rectangle controls height and width. Because the SlideView inherits
    *  the size of root, pages should also be designed to size fullscreen
    *******************************************************************************/

    FontLoader{
        id:arkhip
        source:"qrc:/fonts/Arkhip_font.ttf"
    }

    FontLoader{
        id:rodina
        source:"qrc:/fonts/Rodina-Regular.otf"
    }
    Rectangle{
        id:lastMove
        radius:8
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.top:flagFrame.bottom
        anchors.topMargin:-flagFrame.height/2
        anchors.margins:flag.width/2 +1
        color:"darkgrey"
        border.width: 3
        anchors.bottom:transitionBar.top
        anchors.bottomMargin: 2
        Loader{
            id:lastLoader
            anchors.centerIn: parent
            sourceComponent:CG_AnimatedBoard{
                height:lastMove.height > lastMove.width ? lastMove.height*.8:lastMove.width*.8
                width: height
                board.interactive: false
            }

            onLoaded: {
                if(item){
                    view.profileBoard = item;
                }
            }

            active:true
            Behavior on opacity { NumberAnimation{duration:300;}}
        }


        Text{
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:lastLoader.bottom
            anchors.topMargin: 6
            font.pixelSize:  height * .45
            color:"white"
            text:"No Recent Games"
            anchors.bottomMargin: 4
            font.family: arkhip.name
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Behavior on height {
            NumberAnimation{duration:450}
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                testGameReview();
            }
        }
    }
    Rectangle{
        id:transitionBar
        height:parent.height * .25
        radius:2
        border.width: 1
        color:"white"
        anchors.left:lastMove.left
        anchors.right:lastMove.right
        anchors.topMargin:4
        anchors.bottom: recentGames.top
        anchors.bottomMargin: 4
        Behavior on height {
            NumberAnimation{duration:450}
        }
        Image{
            id:message
            source:"qrc:/images/CGmessages.png"
            height:parent.height*.5
            width:height
            anchors.left: parent.left
            anchors.top:parent.top
            anchors.margins:parent.height*.08
            fillMode: Image.PreserveAspectFit
            smooth:true
            MouseArea{
                anchors.fill: parent
                onClicked: view.state = "HOME"
            }
        }
        Text{
            id:messageText
            font.family:rodina.name
            anchors.top:message.bottom
            anchors.topMargin:3
            anchors.left:message.left
            anchors.right:message.right
            text:"Message"
            color:"black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Image{
            id:challenge
            source:"qrc:/images/ChallengeIcon.png"
            height:parent.height*.5
            width:height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:challengeText.top
            anchors.bottomMargin: 12
            fillMode: Image.PreserveAspectFit
            smooth:true
            MouseArea{
                anchors.fill: parent
                onClicked: view.state = "HOME"
            }
        }
        Text{
            id:challengeText
            font.family:rodina.name
            anchors.bottom:parent.bottom
            anchors.topMargin: 3
            anchors.left:challenge.left
            anchors.right:challenge.right
            anchors.bottomMargin:parent.height*.02
            text:"Challenge"
            color:"black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Image{
            id:faves
            source:"qrc:/images/CGfaveProfile.png"
            height:parent.height*.5
            width:height
            anchors.right: parent.right
            anchors.top:parent.top
            anchors.margins:parent.height*.08
            fillMode: Image.PreserveAspectFit
            smooth:true
            MouseArea{
                anchors.fill: parent
                onClicked: view.state = "HOME"
            }
        }
        Text{
            id:favesText
            font.family:rodina.name
            anchors.top:faves.bottom
            anchors.topMargin:3
            anchors.left:faves.left
            anchors.right:faves.right
            text:"Favorite"
            color:"black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea{
            anchors.fill:parent
            onPressed:  {
                view.state = "HOME"
            }
        }
    }
    Rectangle{
        id:recentGames
        anchors.left:parent.left
        anchors.right:parent.right
        y: parent.height * .85
        //anchors.top:parent.bottom
        //anchors.bottomMargin: parent
        height: parent.height * .85
        color:"transparent"
        MouseArea{
            id:recentTrigger
            anchors.fill: parent
            enabled: true
            onPressed: view.state = "RECENT"
        }
        Text{
            id:labelText
            font.family:arkhip.name
            anchors.top:parent.top
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.leftMargin: 4
            anchors.topMargin: 2
            height:48
            text:"Recent Games"
            font.pixelSize: 20
        }
        Rectangle{
            anchors.right:parent.right
            anchors.left:parent.left
            anchors.top: labelText.bottom
            height:2
            radius: 1
            anchors.leftMargin:parent.width*.225
            color:"lightgrey"
            border.width: 1
        }
        Behavior on y {
            NumberAnimation{duration:450}
        }
    }
    Rectangle{
        id:flagFrame
        anchors.top:parent.top
        anchors.right:parent.right
        anchors.margins: 1
        width:parent.width * .14
        height:width
        border.width: 2
        color:"#d4d4d4"
        radius:2
        Image{
            id:flag
            anchors.fill: parent
            anchors.margins: 4
            fillMode: Image.PreserveAspectFit
            smooth:true
            cache: false
            source:"image://flags/" + playerProfile.country()
            MouseArea{
                anchors.fill: parent
                onClicked: view.state = "COUNTRY"
            }
        }
    }
    Rectangle{
        id:avatarFrame
        anchors.left:parent.left
        anchors.top:parent.top
        anchors.margins: 1
        width:parent.width * .14
        height:width
        border.width: 2
        color:"#d4d4d4"
        radius:2
        Image{
            id: avatarImg
            anchors.fill: parent
            anchors.margins: 4
            cache: false
            fillMode: Image.PreserveAspectFit
            smooth:true
            source:"image://avatars/"+ playerProfile.avatar();
        }
        MouseArea{
            anchors.fill: parent
            onPressed: {
                view.state = "AVATAR";
            }
        }
    }
    Loader{
        id: countryLoader
        anchors.fill: parent
        active: false
        sourceComponent: CountryPicker{
            visible: visible
            onSetCountry: {
                playerProfile.setCountry(country);
                view.state = "HOME"
            }
        }
    }
    Loader{
        id: avatarLoader
        anchors.fill: parent
        active: false
        sourceComponent: AvatarPicker{
            visible: visible
            onSetAvatar: {
                playerProfile.setAvatar(avatar)
                view.state = "HOME"
            }
        }
    }

    GameReview{
         id:reviewView
         anchors.fill: parent
         visible:false
         onBackPressed:{
             reviewView.visible = false;
             recentGames.enabled = true;
             finishedReview();
         }
    }

    Component.onCompleted: {
        lastLoader.active =false;
        lastLoader.active =true;
        flag.source =  "image://flags/" + playerProfile.country();
        avatarImg.source = "image://avatars/"+ playerProfile.avatar();
    }
}
