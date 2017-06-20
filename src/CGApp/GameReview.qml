import QtQuick 2.8
import CGEngine 1.0

Item {
    id:reviewContainer
    function setReview(review, fen, start_back){
        boardEngine.clearBoard();
        if(start_back !== null){
            boardEngine.startReviewGame(review,fen,start_back);
        }
        else{
            boardEngine.startReviewGame(review,fen);
        }
    }

    function moveReviewForward(){
        boardEngine.moveReviewForward();
    }

    function moveReviewBackward(){
        boardEngine.moveReviewBackward();
    }

    function moveReviewFirst(){
        boardEngine.moveReviewFirst();
    }

    function moveReviewLast(){
        boardEngine.moveReviewLast();
    }

    CGEngine{
        id:boardEngine

        onPieceCreated:{
            reviewBoard.createPiece(type,color,tile);
        }

        onClearTile:{
            reviewBoard.removePiece(tile);
        }

        onPieceCaptured:{
            reviewBoard.removePiece(tile)
        }

        onEnPassant:{
            reviewBoard.removePiece(tile_destroy);
        }

        onPieceMoved:{
            reviewBoard.movePiece(tile_from,tile_to);
        }

        onPromotion:{
            reviewBoard.promotion(tile,promote,color);
        }

        onRefreshPiece:{
            reviewBoard.refreshPiece(tile);
        }
    }
    FontLoader{
        id:arkhip
        source:"qrc:/fonts/Arkhip_font.ttf"
    }

    Rectangle{
        id: titleRect
        anchors.fill:parent
        Text{
           anchors.top:parent.top
           anchors.left:buttonBack.left
           anchors.right:parent.right
           height:60
           horizontalAlignment: Text.AlignHCenter
           verticalAlignment: Text.AlignVCenter
           text:"Review Game"
           color:"white"
           font.family: arkhip.name
           font.pixelSize: 25
        }
        Rectangle{
            id:buttonBack
            color:"lightblue"
            opacity: .8
            border.width: 1
            height:60
            width:60
            radius:4
            anchors.top:parent.top
            anchors.left:parent.left
        }
        Image{
            anchors.fill:buttonBack
            source:"/images/CGbackbutton2.png"
            smooth:true
            fillMode: Image.PreserveAspectFit
            MouseArea{
                anchors.fill: parent
                onClicked: reviewContainer.visible = false;
            }
        }

        color:"lightgrey"
        CG_Board{
            id:reviewBoard
            anchors.top:buttonBack.bottom
            anchors.topMargin:2
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            anchors.bottomMargin: buttonGrid.height

        }
    }



    Rectangle{
        id:buttonGrid
        anchors.left:reviewContainer.left
        anchors.right:reviewContainer.right
        anchors.bottom: reviewContainer.bottom
        height:parent.height *.1
        color:"darkgrey"
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            Rectangle{
                height:50
                width:50
                color:"white"
                border.width: 1
                radius:20
                Image{
                    anchors.fill: parent
                    source:"/images/cg_leftBegin.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.margins: 2
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked:{
                        boardEngine.moveReviewFirst();
                    }
                }
            }
            Rectangle{
                height:50
                width:50
                color:"white"
                border.width: 1
                radius:20
                Image{
                    anchors.fill: parent
                    source:"/images/cg_leftArrow.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.margins: 2
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        boardEngine.moveReviewBack();
                    }
                }
            }
            Rectangle{
                height:50
                width:50
                color:"white"
                border.width: 1
                radius:20
                Image{
                    anchors.fill: parent
                    source:"/images/cg_rightArrow.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.margins: 2
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked:{
                        boardEngine.moveReviewForward();
                    }
                }
            }
            Rectangle{
                height:50
                width:50
                color:"white"
                border.width: 1
                radius:20
                Image{
                    anchors.fill: parent
                    source:"/images/cg_rightEnd.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.margins: 2
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        boardEngine.moveReviewLast();
                    }
                }
            }
        }
    }
}
