import QtQuick 2.8
import QtQuick.Window 2.2
import CGWebApi 1.0
import CGNetwork 1.0


Window {
    id: background
    visible: true
    width: 400
    height: 600
    title: qsTr("Chessgames")
    Rectangle{
        id:rectBackground
        color: "#d4d4d4"
        anchors.fill: parent
    }
    CGProfile{
        id:playerProfile
        onProfileSet: {

        }
    }

    Item{
        id: systemState
        states:[
            State{
                name:""
            }
        ]
    }

    Loader{
        id:loadingLoader
        property string loadingText:""
        property int loadingDuration:750
        anchors.fill: parent
        active:true
        sourceComponent:CG_LoadingAnimation{
            visible:false
            text.text:loadingLoader.loadingText
            duration:loadingLoader.loadingDuration
            anchors.fill: parent
        }
    }

    Loader{
        id:loginLoader
        sourceComponent: LoginView{
            anchors.fill: parent
            onStartLoading: {
                loadingLoader.item.text.text = text;
                loadingLoader.item.visible = true;
                loadingLoader.item.duration = duration;
                loadingLoader.item.back.visible = back
            }
            onStopLoading: {
                loadingLoader.item.visible = false;
            }
            onConnectedToHost: {
                console.log("Moving into Lobby View")
            }
        }

        active:  true;
        anchors.fill: parent
    }




}
//    CGWebConnection{
//        id: webconnection
//        onConnectedToCGWeb: {
//            console.log("connected")
//        }
//        onUserCGVerified: {
//            console.log("Verified" + " with email " + email);
//        }
//        onDisconnectedFromCGWeb: {
//            console.log("Goodbye cg.com")
//        }

//    }

//    CGLogin{
//        id: login
//        anchors.fill:parent
//        onReadyForLogin:{
//            login.sendAuthentication(tf_username.text,tf_password.text)
//        }

//        onUserLoggedIn:{
//            console.log("User " + tf_username.text + " has logged in!")
//            login.visible = false;
//            lobby.visible = true;
//        }
//        onFailedToConnectToServer: {
//            txt_isOpen.text = "Cannot connect to server"
//        }

//        onProfileData: profile.setUserProfile(data);
//        CGProfile{
//            id: profile
//            onProfileSet:{

//            }
//            Component.onCompleted: {

//            }
//        }
//        Audio
//        {
//            id: iPod
//            source: "sounds/successfulLogin.mp3"
//            autoLoad: true

//            loops: 79 // TODO : Magic numbers
//        }



//        Column {
//            width: getSmallestOrientation()
//            anchors.centerIn: parent
//            spacing: 6

//            Image {
//                id: cg_logo_hires
//                source: "images/cg_logo.png"
//                anchors.horizontalCenter: parent.horizontalCenter
//                width: Login.getLogoSize()
//                height: Login.getLogoSize()

//                SequentialAnimation {
//                    SequentialAnimation {
//                        ParallelAnimation {
//                            YAnimator {
//                                target: cg_logo_hires;
//                                from: cg_logo_hires.y;
//                                to: cg_logo_hires.y/2;
//                                easing.type: Easing.OutExpo;
//                                duration: 300
//                            }
//                            ScaleAnimator {
//                                target: cg_logo_hires
//                                from: 1
//                                to: 0.5
//                                easing.type: Easing.OutExpo;
//                                duration: 300
//                            }
//                        }
//                        ParallelAnimation {
//                            YAnimator {
//                                target: cg_logo_hires;
//                                from: cg_logo_hires.y;
//                                to: cg_logo_hires.y/2;
//                                easing.type: Easing.OutBounce;
//                                duration: 1000
//                            }
//                            ScaleAnimator {
//                                target: cg_logo_hires
//                                from: 0.5
//                                to: 1
//                                easing.type: Easing.OutBounce;
//                                duration: 1000
//                            }
//                        }
//                    }
//                    PauseAnimation { duration: 10000 }
//                    running: true
//                    //loops: Animation.Infinite
//                }
//            }

//            Label {
//                id: txt_isOpen
//                text: "Registering Chessgames Account..."

//                // Adjusts the font size for scalability
//                font.pixelSize: getSmallestOrientation() * 0.05
//                anchors.horizontalCenter: parent.horizontalCenter
//            }
//            Label {
//                id: txt_isOpen
//                text: "Checking for Updates...Fetching File 8/22"

//                // Adjusts the font size for scalability
//                font.pixelSize: getSmallestOrientation() * 0.05
//                anchors.horizontalCenter: parent.horizontalCenter
//            }





    /**************************************************************
    *	  Purpose:  Get the background width of the app for all
    *               that need access to it.
    *
    *     Entry:    User has opened the application.
    *
    *     Exit:     Returns the width of the application.
    ****************************************************************/

//    function getBackgroundWidth()
//    {
//        return background.width
//    }

    /**************************************************************
    *	  Purpose:  Get the background height of the app for all
    *               that need access to it.
    *
    *     Entry:    User has opened the application.
    *
    *     Exit:     Returns the height of the application.
    ****************************************************************/

//    function getBackgroundHeight()
//    {
//        return background.height
//    }

    /**************************************************************
    *	  Purpose:  Get the smallest orientation for scalability
    *               purposes, whether it's the portrait or landscape
    *               orientation.
    *
    *     Entry:    User has opened the application.
    *
    *     Exit:     Returns the smallest orientation of the
    *               application.
    ****************************************************************/

//    function getSmallestOrientation()
//    {
//        return background.width < background.height ? background.width : background.height
//    }

//    function getLargestOrientation()
//    {
//        return background.width > background.height ? background.width : background.height
//    }

//    function isLandscape()
//    {
//        return getSmallestOrientation() == getBackgroundHeight() ? true : false
//    }

//    function isPortrait()
//    {
//        return !isLandscape()
//    }
//}
