import QtQuick 2.8
import CGFlags 1.0

Rectangle {
    id:banner
    radius: height
    border.width: 2
    property alias pieceSet:emblem.pieceSet
    property alias player:nameText.text
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


        if(color){
            emblem.anchors.left = undefined
            emblem.anchors.right= banner.right
            emblem.border.color = "black"

            flag.anchors.right = undefined
            flag.anchors.left= banner.left
            nameText.anchors.left = flag.right;
            avatarFrame.anchors.right = emblem.left;
        }
        else{
            banner.border.color = "white"
            banner.color = "black"
            nameText.color = "white"
            eloText.color = "white"
            emblem.border.color = "white"
            nameText.anchors.left = emblem.right;
            avatarFrame.anchors.right = flag.left;
        }

    }
    CG_Emblem{
        id:emblem
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        border.width: 1
        height:parent.height-(12 +banner.border.width)
    }

    Text{
        id: nameText
        anchors.top: parent.top
        anchors.topMargin:parent.height*.05
        anchors.leftMargin:8
        anchors.left:emblem.right
        anchors.right:avatarFrame.left
        anchors.rightMargin:4
        height:parent.height* .5
        width:parent.width*.45
        font.pixelSize:(width/text.length < height/text.length ? width/text.length:height/text.length) + 18
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Text{
        id: eloText
        anchors.left:nameText.left
        anchors.right:nameText.right
        anchors.bottom:parent.bottom
        anchors.bottomMargin: parent.height*.06
        height: nameText.height
        font.pixelSize: nameText.font.pixelSize *.75
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Image{
        id: flag
        anchors.right:parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin:4
        anchors.leftMargin: 4
        width:emblem.width
        height:width
    }
    Rectangle{
        id:avatarFrame
        anchors.verticalCenter: parent.verticalCenter
        anchors.right:flag.left
        height:banner.height  *.65
        width:height
        border.width: 2
        color:"#d4d4d4"
        radius:2
        anchors.rightMargin:6
        Image{
            id: avatarImg
            anchors.fill: parent
            anchors.margins: 4
            asynchronous: true
            cache: false
        }
    }

    Behavior on y{
        NumberAnimation{duration:450}
    }
    Behavior on height{
        NumberAnimation{duration:450}
    }
}
