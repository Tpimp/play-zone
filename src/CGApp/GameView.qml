import QtQuick 2.8
import CGNetwork 1.0
import CGEngine 1.0

Rectangle {
    id: topRect
    property var playerProfile:undefined
    property var gameBoard:undefined
    function startNewGame(name, elo, country, color, avatar)
    {
        topRect.state = "MATCHED;"
        playerProfile.setColor(color);
        if(color){
            whitePlayer.setBanner(playerProfile.name,playerProfile.elo,playerProfile.flag,avatar,true);
            blackPlayer.setBanner(name,elo,country,avatar, false);
        }
        else{
            blackPlayer.setBanner(playerProfile.name,playerProfile.elo,playerProfile.flag,avatar,false);
            whitePlayer.setBanner(name,elo,country,avatar,true);
        }
    }
    function resetBoard(){
        boardLoader.active = false;
        boardLoader.active = true;
    }

    function setProfile(player)
    {
        topRect.playerProfile = player;
    }
    states:[
        State{
            name:"MATCHED"
            extend:""
        },
        State{
            name:"GAME"
        },
        State{
            name:"POST"
        }
    ]
    transitions: [
        Transition{
            from:"MATCHED"; to:"GAME";
            ParallelAnimation{
                AnchorAnimation{
                    targets:whitePlayer
                    //anchors.left:
                }
            }
        }

    ]

    Rectangle{
        id: boundingRect
        color:"darkgrey"
        anchors.fill: parent
        anchors.topMargin:parent.height*.09
        anchors.bottomMargin:parent.height*.3
        anchors.leftMargin:parent.width *.01
        anchors.rightMargin:anchors.leftMargin
        radius:4
        border.width: 3
        Image{
            anchors.top:parent.top
            anchors.topMargin:parent.height*.08
            height:parent.height*.11
            anchors.horizontalCenter: parent.horizontalCenter
            source:"/images/PlayerMatched.png"
            fillMode: Image.PreserveAspectFit

        }

        CG_PlayerBanner{
            id:whitePlayer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom:parent.bottom
            height:parent.height/5
            anchors.bottomMargin:parent.height*.05
            anchors.leftMargin:parent.width/20
            anchors.rightMargin:anchors.leftMargin
        }

        CG_PlayerBanner{
            id:blackPlayer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top:parent.top
            height:parent.height/5
            anchors.topMargin:parent.height*.25
            anchors.leftMargin:parent.width/20
            anchors.rightMargin:anchors.leftMargin
            pieceSet: "/images/cg_kramnik.png"
            MouseArea{
                anchors.fill: parent
                onClicked:gameView.resetBoard();
            }
        }
        Text{
            anchors.top:whitePlayer.bottom
            anchors.bottom: blackPlayer.top
            anchors.left:parent.left
            anchors.right:parent.right
            color:"white"
            font.bold:true
            styleColor: "black"
            style: Text.Outline
            text:"VS"
            font.family: "Comic Sans MS"
            font.pixelSize: height*.45
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

    }
    Loader{
        id:boardLoader
        active:false
        anchors.right: parent.right
        anchors.left:parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.width > parent.height ? parent.height:parent.width
        sourceComponent:  CG_Board{
        }
        onLoaded: {
            if(boardLoader.item){
                topRect.gameBoard = boardLoader.item
            }
        }
    }
    CG_TextField{
        id:fenInput
        anchors.top:boardLoader.bottom
        anchors.left:boardLoader.left
        width:boardLoader.width
        height:60
        Keys.onEnterPressed:{
            topRect.gameBoard.setNewFen(fenInput.text);
        }
    }



}
