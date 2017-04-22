import QtQuick 2.8
import QtQuick.Window 2.2
import CGWebApi 1.0
import CGNetwork 1.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "CG_login.js" as Login

Window {
    id: background
    visible: true
    width: 400
    height: 600
    title: qsTr("Chessgames")
    color: "#d4d4d4"

    onClosing:
    {
        // Make sure we're connected before we try to disconnect
       // if(!login.visible)
       //     ServerConnection.onDisconnect()
    }

    CGWebConnection{
        id: webconnection
        onConnectedToCGWeb: {
            console.log("connected")
        }
        onUserCGVerified: {
            console.log("Verified" + " with email " + email);
        }
        onDisconnectedFromCGWeb: {
            console.log("Goodbye cg.com")
        }

    }

    CGLogin{
        id: login
        anchors.fill:parent
        onReadyForLogin:{
            login.sendAuthentication(tf_username.text,tf_password.text)
        }

        onUserLoggedIn:{
            console.log("User " + tf_username.text + " has logged in!")
        }
        onFailedToConnectToServer: {
            txt_isOpen.text = "Cannot connect to server"
        }

        onProfileData: profile.setUserProfile(data);
        CGProfile{
            id: profile
            onProfileSet:{
                txt_isOpen.text = ""
                tf_username.text = ""
                tf_password.text = ""
                tf_confirmPassword.text = ""
                tf_emailAddress.text = ""
            }
            Component.onCompleted: {
                console.log("Profile initialized " + profile.name)

            }
        }
        Audio
        {
            id: iPod
            source: "sounds/successfulLogin.mp3"
            autoLoad: true

            loops: 79 // TODO : Magic numbers
        }



        Column {
            width: getSmallestOrientation()
            anchors.centerIn: parent
            spacing: 6

            Image {
                id: cg_logo_hires
                source: "images/cg_logo.png"
                anchors.horizontalCenter: parent.horizontalCenter
                width: Login.getLogoSize()
                height: Login.getLogoSize()

                SequentialAnimation {
                    SequentialAnimation {
                        ParallelAnimation {
                            YAnimator {
                                target: cg_logo_hires;
                                from: cg_logo_hires.y;
                                to: cg_logo_hires.y/2;
                                easing.type: Easing.OutExpo;
                                duration: 300
                            }
                            ScaleAnimator {
                                target: cg_logo_hires
                                from: 1
                                to: 0.5
                                easing.type: Easing.OutExpo;
                                duration: 300
                            }
                        }
                        ParallelAnimation {
                            YAnimator {
                                target: cg_logo_hires;
                                from: cg_logo_hires.y;
                                to: cg_logo_hires.y/2;
                                easing.type: Easing.OutBounce;
                                duration: 1000
                            }
                            ScaleAnimator {
                                target: cg_logo_hires
                                from: 0.5
                                to: 1
                                easing.type: Easing.OutBounce;
                                duration: 1000
                            }
                        }
                    }
                    PauseAnimation { duration: 10000 }
                    running: true
                    //loops: Animation.Infinite
                }
            }

            Label {
                id: txt_isOpen
                text: Validator.getFeedback()

                // Adjusts the font size for scalability
                font.pixelSize: getSmallestOrientation() * 0.03
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: tf_username
                placeholderText: "Chessgames username"
                style: cgTextFieldStyle

                // For testing purposes I inputted StarWars automatically
                text: "StarWars"

                // Adjusts the font size for scalability
                font.pixelSize: getSmallestOrientation() * 0.03

                width: Login.getControlWidth()
                height: Login.getControlHeight()
                anchors.horizontalCenter: parent.horizontalCenter

                // When the text for the username is changed validate it
                onTextChanged: {
                    Login.setUsernameValidator()
                }
            }

            TextField {
                id: tf_password
                placeholderText: "Chessgames password"
                style: cgTextFieldStyle
                echoMode: TextInput.Password

                // For testing purposes I inputted StarWars automatically
                text: "StarWars1"

                // Adjusts the font size for scalability
                font.pixelSize: getSmallestOrientation() * 0.03

                width: Login.getControlWidth()
                height: Login.getControlHeight()
                anchors.horizontalCenter: parent.horizontalCenter

                // When the text for the password is changed validate it
                onTextChanged: {
                    Login.setPasswordValidator()
                }
            }

            TextField {
                id: tf_confirmPassword
                placeholderText: "Confirm password"
                style: cgTextFieldStyle
                echoMode: TextInput.Password
                visible: false

                // Adjusts the font size for scalability
                font.pixelSize: getSmallestOrientation() * 0.03

                width: Login.getControlWidth()
                height: Login.getControlHeight()
                anchors.horizontalCenter: parent.horizontalCenter

                // When the text for password confirmation is changed validate it
                onTextChanged: Login.setConfirmPasswordValidator()
            }

            TextField {
                id: tf_emailAddress
                placeholderText: "Email Address"
                style: cgTextFieldStyle
                visible: false

                // Adjusts the font size for scalability
                font.pixelSize: getSmallestOrientation() * 0.03

                width: Login.getControlWidth()
                height: Login.getControlHeight()
                anchors.horizontalCenter: parent.horizontalCenter

                // When the text for email is changed validate it
                onTextChanged: Login.setEmailValidator()
            }

            Button {
                id: btn_login
                text: "Login"
                style: cgButtonStyle

                onClicked: {
                    // If cannot connect to server,
                    // qDebug cannot connect to server

                      login.connectToServer(APP_IP,APP_PORT);
//                    if(txt_isOpen.text === "Successfully created user.")
//                    {

//                        // Connected to server
//                        // Send username and password in text boxes to server
//                        // Server will verify if this is a correct username or password
//                        ServerConnection.sendLoginCredentials(tf_username.text, ServerConnection.encryptPassword(tf_password.text))

//                        tf_confirmPassword.visible = false
//                        tf_emailAddress.visible = false

//                        // If the user is logging in reset the text color
//                        tf_username.textColor = "#000000"
//                        tf_password.textColor = "#000000"
//                    }

//                    else
//                    {
//                        WebApiManager.requestCGLoginVerify(tf_username.text,tf_password.text);
//                        //if(ServerConnection.connectToServer("75.142.143.96", 9556) === true)
//                        /*if(ServerConnection.connectToServer("75.142.141.121", 9556) === true)
//                    {
//                        // Connected to server
//                        // Send username and password in text boxes to server
//                        // Server will verify if this is a correct username or password
//                        ServerConnection.sendLoginCredentials(tf_username.text, ServerConnection.encryptPassword(tf_password.text))

//                        tf_confirmPassword.visible = false
//                        tf_emailAddress.visible = false

//                        // If the user is logging in reset the text color
//                        tf_username.textColor = "#000000"
//                        tf_password.textColor = "#000000"
//                    }
//                    else
//                        txt_isOpen.text = "Cannot connect to server"*/
//                    }
                }

                width: Login.getControlWidth()
                height: Login.getControlHeight()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Social Media Login Options
            Row {
                width: Login.getControlWidth()
                spacing: Login.getControlWidth() / 40

                anchors.right: btn_login.right
                anchors.left: btn_login.left
                // Facebook Login
                CG_SocialMediaBtn {
                    width: (parent.width / 2) - (parent.spacing / 2)
                    height: Login.getControlHeight()
                    color: "#5d79b4"
                    shadowColor: "#164785"
                    iconSource: "images/FacebookIcon.png"
                    text: "Log in with Facebook"
                    mouseArea.onClicked: {
                        // Login to Facebook (eventually)
                    }
                }

                // Google Plus Login
                CG_SocialMediaBtn {
                    width: (parent.width / 2) - (parent.spacing / 2)
                    height: Login.getControlHeight()
                    color: "#dd4b39"
                    shadowColor: "#be4031"
                    iconSource: "images/GooglePlusIcon.png"
                    text: "Sign in with Google+"
                    mouseArea.onClicked: {
                        // Login to Google Plus (eventually)
                    }
                }
            }

            // Register Button
            Button {
                id: btn_register
                text: "Don't have an account? Sign up here!"
                style: cgRegisterHere
                onClicked: {

//                    txt_isOpen.text = ""

//                    if(tf_confirmPassword.visible)
//                    {
//                        // If cannot connect to server,
//                        // qDebug cannot connect to server
//                        //if(ServerConnection.connectToServer("75.142.143.96", 9556) === true)
//                        if(ServerConnection.connectToServer("75.142.141.121", 9556) === true)
//                            // Request if user already exists on the server
//                            ServerConnection.requestUserExists(tf_username.text)

//                        else
//                            txt_isOpen.text = "Cannot connect to server."
//                    }
//                    else
//                    {
//                        /* The first time the register button is clicked it should
//                           reveal the password confirmation and email address fields.*/
//                        tf_confirmPassword.visible = true
//                        tf_emailAddress.visible = true
//                    }

                    Login.setValidators()
                }
                width: Login.getControlWidth()
                height: Login.getControlHeight()
            }
        }

        Component {
            id: cgTextFieldStyle

            TextFieldStyle {
                background: Rectangle {
                    color: "#e7e9e8"
                    smooth: true
                    radius: 8
                }
            }
        }

        Component {
            id: cgButtonStyle

            ButtonStyle {
                background: Rectangle {
                    color: "#3f3f3f"
                    smooth: true
                    radius: 9
                    border.color: "#000000"
                    border.width: 0
                }

                label: Text {
                    font.pixelSize: getSmallestOrientation() * 0.065
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "fonts/Arkhip_font.ttf"
                    color: "#e7e9e8"
                    text: control.text
                }
            }
        }

        Component {
            id: cgRegisterHere

            ButtonStyle {
                background: Rectangle {
                    color: "#00000000"
                    smooth: true
                    radius: 9
                    border.color: "#000000"
                    border.width: 0
                    width: (getSmallestOrientation()- (parent.spacing * 2)) / 3.5
                }

                label: Text {
                    font.pixelSize: getSmallestOrientation() * 0.040
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "fonts/helvetica-neue-bold.ttf"
                    color: "#000000"
                    text: control.text
                }
            }
        }
    }

    /**************************************************************
    *	  Purpose:  Get the background width of the app for all
    *               that need access to it.
    *
    *     Entry:    User has opened the application.
    *
    *     Exit:     Returns the width of the application.
    ****************************************************************/

    function getBackgroundWidth()
    {
        return background.width
    }

    /**************************************************************
    *	  Purpose:  Get the background height of the app for all
    *               that need access to it.
    *
    *     Entry:    User has opened the application.
    *
    *     Exit:     Returns the height of the application.
    ****************************************************************/

    function getBackgroundHeight()
    {
        return background.height
    }

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

    function getSmallestOrientation()
    {
        return background.width < background.height ? background.width : background.height
    }

    function getLargestOrientation()
    {
        return background.width > background.height ? background.width : background.height
    }

    function isLandscape()
    {
        return getSmallestOrientation() == getBackgroundHeight() ? true : false
    }

    function isPortrait()
    {
        return !isLandscape()
    }
}
