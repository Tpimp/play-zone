import QtQuick 2.8
import CGFlags 1.0

Rectangle {
    id:banner
    radius: height -1
    border.width: 2
    property string pieceSet:""
    property alias player:nameText.text
    property alias elo:eloText.text
    property string buttonIcon:""
    property var    emblem:undefined
    signal buttonPressed();
    signal lostFocus();
    function setBanner(name,elo,country,avatar, color)
    {
        //avatarImg.source = avatar;
        if(country.length > 0){
            flag.source = "image://flags/"+country
        }
        else
        {
            flag.source = ""
        }

        eloText.text = elo;
        nameText.text  = name;
        emblem.emblemColor = color;
        avatarImg.source = avatar;


        if(!color){
            banner.border.color = "white"
            banner.color = "black"
            nameText.color = "white"
            eloText.color = "white"
            led.border.color = "white"
            avatarFrame.border.color = "white"
        }
    }
    function setMove(move){
        halfMove.text.text = move;
    }

    function setGameMode(){
        emblemLoader.active = false;
    }
    function setTurn(turn){
        if(turn){
            led.color = "green"
        }
        else{
            led.color = "red"
        }
    }

    function getTurn(){
        return led.color === "green";
    }

    Rectangle{
        id:led
        anchors.left: parent.left
        anchors.leftMargin:1
        anchors.verticalCenter: parent.verticalCenter
        height:parent.height - 12
        width:height
        radius:height
        color:"red"
        border.width: 1
        Behavior on color{
            ColorAnimation
            {
                duration: 500
            }
        }
    }

    Loader{
        id:emblemLoader
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.verticalCenter: parent.verticalCenter
        height:led.height
        width:led.width
        sourceComponent:CG_Emblem{
            id:emblem
            anchors.fill: emblemLoader
            border.width: 1
            pieceSet: banner.pieceSet
        }
        onLoaded: {
            if(emblemLoader.item){
                banner.emblem = emblemLoader.item
            }
        }
    }
    Text{
        id: nameText
        anchors.top: parent.top
        anchors.topMargin:2
        anchors.leftMargin:2
        anchors.left:led.right
        anchors.right:avatarFrame.left
        anchors.rightMargin:2
        height:parent.height* .45
        font.pixelSize:(width/text.length < 16 ? width/text.length:16) + 6
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }
    Text{
        id: eloText
        anchors.top: nameText.bottom
        anchors.left:led.right
        anchors.right:avatarFrame.left
        anchors.bottom:parent.bottom
        anchors.margins: 2
        font.pixelSize:(width/text.length < 16 ? width/text.length:16) + 6
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }
    Rectangle{
        id:avatarFrame
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        anchors.bottom:parent.bottom
        anchors.topMargin:6
        anchors.bottomMargin:6
        width:height + 4
        border.width: 2
        color:"#d4d4d4"
        radius:2
        Image{
            id: avatarImg
            anchors.fill: parent
            anchors.margins: 4
            fillMode: Image.PreserveAspectFit
            smooth:true
            antialiasing: true
            asynchronous: true
            cache: false
        }
    }
    CG_Clock{
        id:clock
        color:"darkgrey"
        text.color:"white"
        anchors.left:avatarFrame.right
        anchors.right: flag.left
        anchors.top:parent.top
        anchors.margins:8
        height:banner.height*.34
    }

    CG_HalfMove{
        id:halfMove
        color:"darkgrey"
        text.color:"white"
        border.width: 1
        anchors.left:avatarFrame.right
        anchors.right: flag.left
        anchors.bottom:parent.bottom
        height:banner.height*.32
        anchors.margins: 8
        anchors.leftMargin: parent.width/12
        anchors.rightMargin:anchors.leftMargin
    }

    Image{
        id: flag
        anchors.right:parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin:2
        anchors.leftMargin: 2
        width:led.height
        height:width
        fillMode: Image.PreserveAspectFit
        smooth:true
        antialiasing: true
    }


    Behavior on y{
        NumberAnimation{duration:450}
    }
    Behavior on height{
        NumberAnimation{duration:450}
    }
}
