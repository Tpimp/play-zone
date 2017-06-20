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
    //property var userProfile:undefined
    signal joinMatchMaking();
    signal playerMatched(string name, int elo, string country, string avatar, bool color,double id)
    function setReview(review, fen, start_back){
        swipeView.currentIndex = 0;
        profileView.setShowingReview(review,fen,start_back);
    }

    CGLobby{
        id: lobbyController
        onMatchedWithPlayer:{
            root.playerMatched(opponent.name,opponent.elo,opponent.flag,opponent.avatar, opponent.color,opponent.id);
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
        id:swipeView
        anchors.fill: parent
        currentIndex: 1
        ProfileView{
            id:profileView
            color:"transparent"
        }

        MatchView{
            id:lobby
            color:"transparent"
        }
        ChatView{
            id:chatView
            color:"transparent"

        }
    }

}
