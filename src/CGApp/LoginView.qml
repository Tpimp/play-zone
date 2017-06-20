import QtQuick 2.8
import CGNetwork 1.0
import CGWeb 1.0
import QtQuick.Layouts 1.1
Rectangle{
    color: "transparent"
    id:loginView
    signal startLoading(string text, real duration, bool back);
    signal stopLoading();
    signal ping(real ping)
//    //property alias status:statusText.text
    property real  buttonSize:0.0
    signal loggedIn()
    function loginToCG(user,password){
        loginView.state = "LOGIN";
        console.log("Trying to log in")
        loginController.login(user,password);
    }
    function registerUser(user, password, email){
        loginController.attemptRegisterUser(user,password,email, "");
    }
    function disconnectFromHost(){
        loginController.disconnectFromServer()
    }
    function setStatus(text){
        statusText.text = text;
    }

    /************************************************
    * This section defines the Connections to
    * "Updater"
    *
    ***********************************************/
    Connections{
        target: CGUpdater // comes from the C++ application loader
        onUpdateAvailable: loginView.state = "AVAILABLE";
        onReady:{
            console.log("No Updates Found")
            loginView.state = "READY";}
    }

    /************************************************
    * This section defines the Connections to
    * "CGLogin"
    *
    ***********************************************/

    CGLogin{
        id:loginController
        onDisconnectedFromServer: {
            loginView.state = "READY"
            statusText.text = "User Logout Successful"
            tf_password.textColor = "black";
            tf_confirm_password.text = "";
        }
        onUserCredentialsDenied: {
            statusText.text = "Playzone member not found.\nAttempting to login to chessgames.com"
            webController.requestCGLoginVerify(tf_username.text,tf_password.text);
        }
        onUserLoggedIn: {
            loginView.stopLoading();
            loginView.state = "READY"
            loginView.loggedIn();
        }
        onUserRegistered:{
            loginController.login(tf_username.text,tf_password.text);
        }
        onUserDeniedRegister: {
            loginView.state = "READY"
            loginController.disconnectFromServer();
            statusText.text = reason
        }
        onCurrentPing: loginView.ping(ping)
    }

    states:[
        State{
            name:"AVAILABLE"

            PropertyChanges{target:statusText;text:"Update Available"}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:4200}
            StateChangeScript{script:CGUpdater.beginUpdateProcess();}
        },
        State{
            name:"DOWNLOADING"
            PropertyChanges{target:statusText;text:"Downloading Updates..."}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:3500}
        },
        State{
            name:"UPDATING"
            PropertyChanges{target:statusText;text:"Installing Updates..."}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:2200}
            StateChangeScript{script:CGUpdater.validateRelocateUpdate();}
        },
        State{
            name:"WAITING"
            PropertyChanges{target:statusText;text:"Update Finished!"}
            PropertyChanges{target:logoAnimation;running:false;}
        },
        State{
            name:"READY"
            StateChangeScript{script:loginView.stopLoading();}
            PropertyChanges{target:statusText;text:""}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:10000}
            PropertyChanges{target:tf_username; height:buttonSize; KeyNavigation.tab: tf_password}
            PropertyChanges{target:tf_password; height:buttonSize; KeyNavigation.tab: tf_username}
            PropertyChanges{target:loginButton; height:buttonSize}
            PropertyChanges{target:updateButton; visible:false}
            PropertyChanges{target:socialRow; height:buttonSize; visible:true}
            PropertyChanges{target:registerButton; height:buttonSize}
            PropertyChanges {target: form;scale:1}
        },
        State{
            name:"REGISTER"
            StateChangeScript{script:loginView.stopLoading();}
            PropertyChanges{target:statusText;text:""}
            PropertyChanges{target: backArrow; visible:true}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:10000}
            PropertyChanges{target:tf_username; height:buttonSize; KeyNavigation.tab: tf_email}
            PropertyChanges{target:tf_password; height:buttonSize; KeyNavigation.tab: tf_confirm_password}
            PropertyChanges{target:registerButton; height:buttonSize}
            PropertyChanges{target:updateButton; visible:false}
            PropertyChanges{target:tf_confirm_password; height:buttonSize; KeyNavigation.tab: tf_username}
            PropertyChanges{target:tf_email; height:buttonSize; KeyNavigation.tab: tf_password}
            PropertyChanges {target: form;scale:1}
        },
        State{
            name:"LOGIN"
            PropertyChanges {target:statusText; text:""}
            StateChangeScript{script:loginView.startLoading("Connecting to Chessgames Server...",850,false);}
            PropertyChanges {target:cancelButton; height:buttonSize; text.visible: true }
            PropertyChanges{target:logoAnimation;running:false;}
        }

    ]

    CGWebConnection{
        id: webController
        onUserCGDeniedDoesNotExist: {
            loginView.state = "READY"
            statusText.text = "Chessgames User Does Not Exist."
        }
        onUserCGDeniedPasswordError: {
            loginView.state = "READY"
            statusText.text = "User login was Denied"
        }

        onUserCGVerified: {
            //playerProfile.avatar = avatar;
            loginController.attemptRegisterUser(tf_username.text,tf_password.text,email,"");

        }
    }



    /*****************************************************************************
    *This Begins The User Interface
    * The Login View consists of:
    *
    *  [CONTENT DESCRIPTION]
    *
    *    Login Logo Animation - Visible in ALL States.
    *                           Active during background processes
    *
    *    Status Text - Notifies the user through text of the ongoing process
    *
    *    Button and Form Container - Holds currently needed widgets for
    *                             the current login state.
    *
    *  [SIZE AND LAYOUT]
    *  The logo animation is 40% of the height of the client or 94% of
    *           the width of the client; depending on which is smaller.
    *           The aspect ratio should be respected.
    *
    *  The Status Text is 5% of the height of the client. Width is always
    *           the width of the client Minus margins. Status text should
    *           remain small.
    *
    *  The Button and Form Container -takes up the remainder of the screen (height).
    *        The Button and Form Container maintains 90% of client width.
    *
    *  The button and form container combine with the "x" container Components
    *  to generate the various states of the login view.
    *******************************************************************************/

    Item{
        id:logoContainer
        anchors.topMargin:parent.height *.0125
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.right: parent.right
        height: parent.height *.52 < (parent.width*.96) ? parent.height *.52:parent.width*.96
        Image{
            id: cg_logo_hires
            anchors.fill: parent
            anchors.margins: 2
            source: "images/cg_logo.png"
            fillMode: Image.PreserveAspectFit
            SequentialAnimation {
                id:logoAnimation
                ScaleAnimator {
                    target: cg_logo_hires
                    from: 1
                    to: 0.5
                    easing.type: Easing.OutExpo;
                    duration: 300
                }

                ScaleAnimator {
                    target: cg_logo_hires
                    from: 0.5
                    to: 1
                    easing.type: Easing.OutBounce;
                    duration: 1000
                }
                PauseAnimation {id: pauseAnimation; duration: 10000 }
                running: true
                loops:3
            }
        }
    }
    Text{
        id: statusText
        anchors.top:logoContainer.bottom
        anchors.margins: parent.height*.01
        anchors.topMargin: parent.height*.02
        anchors.left: parent.left
        anchors.right:parent.right
        height:parent.height*.04
        font.pixelSize: parent.height*.028
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text:"Checking for Updates..."
        onTextChanged: {
            if(text.length == 0){
                statusText.height = 0;
                font.pixelSize = 0
            }
            else{
                statusText.height = parent.height*.04;
                font.pixelSize = parent.height*.028
            }
        }
    }

    Column{
        id:form
        spacing:8
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height - statusText.y
        anchors.topMargin:6
        width:parent.width *.9

        property alias username:tf_username
        property alias password:tf_password
        property alias email:tf_email
        property alias confirmPassword:tf_confirm_password
        property alias login:loginButton
        property alias register:registerButton
        property alias facebook:fbButton
        property alias google:googleButton
        property alias socialButtons:socialRow
        //property alias registerText:registerText
        // For LOGIN and REGISTER
        CG_TextField{
            id:tf_username
            placeholderText:"Chessgames Username"
            text:""
            height: 0
            width:parent.width
            KeyNavigation.tab: loginView.state == "READY" ? tf_password:tf_email
            Component.onCompleted:{
                tf_username.focus = true;
            }
        }
        // FOR REGISTER ONLY
        CG_TextField{
            id:tf_email
            placeholderText:"Email Address"
            height: 0
            width:parent.width
            KeyNavigation.tab: tf_password
            Behavior on height{
                NumberAnimation{duration:450;}
            }
        }
        CG_TextField{
            id:tf_password
            placeholderText:"Chessgames Password"
            text:""
            echoMode: TextInput.Password
            height:0
            width:parent.width
            KeyNavigation.tab: tf_confirm_password
            Keys.onReturnPressed: {
                if(tf_username.length > 0 && tf_password.length > 0){
                    if(loginView.state == "READY"){
                        loginView.state = "LOGIN"
                        loginView.loginToCG(tf_username.text,tf_password.text)
                    }
                }
            }
        }
        CG_TextField{
            id:tf_confirm_password
            placeholderText:"Confirm Password"
            echoMode: TextInput.Password
            height:0
            width:parent.width
            Keys.onReturnPressed: {
                if(loginView.state == "REGISTER"){
                    loginController.attemptRegisterUser(tf_username.text,tf_password.text,tf_email.text,"");
                }
            }
            onTextChanged: {
                if (tf_password.text == tf_confirm_password.text)
                {
                    tf_password.textColor = "#00AA00"
                    tf_password.font.bold = false
                    tf_confirm_password.textColor = "#00AA00"
                    tf_confirm_password.font.bold = false
                }
                else
                {
                    tf_password.textColor = "#FF0000"
                    tf_password.font.bold = true
                    tf_confirm_password.textColor = "#FF0000"
                    tf_confirm_password.font.bold = true
                }
            }

            Behavior on height{
                NumberAnimation{duration:300;}
            }
        }


        CG_DarkButton{
            id:loginButton
            text.text: "Login"
            height:0
            width:parent.width
            mouse.onClicked:{
                if(tf_username.length > 0 && tf_password.length > 0){
                    if(loginView.state == "READY"){
                        loginView.state = "LOGIN"
                        loginView.loginToCG(tf_username.text,tf_password.text)
                    }
                }
            }
            Behavior on height{
                NumberAnimation{duration:300}
            }
        }
        Row{
            id: socialRow
            height: 0
            width:parent.width
            spacing:2
            visible:false
            CG_SocialMediaBtn{
                id:fbButton
                color: "#5d79b4"
                shadowColor: "#164785"
                iconSource: "images/FacebookIcon.png"
                text: "Log in with Facebook"
                anchors.verticalCenter: parent.verticalCenter
                height:parent.height
                width:parent.width/2 -2
            }
            CG_SocialMediaBtn{
                id:googleButton
                color: "#dd4b39"
                shadowColor: "#be4031"
                iconSource: "images/GooglePlusIcon.png"
                text: "Sign in with Google"
                anchors.verticalCenter: parent.verticalCenter
                height:parent.height
                width:parent.width/2 -2
            }
        }

        CG_DarkButton{
            id:registerButton
            text.text: "Register"
            height:0
            width:googleButton.width
            anchors.right:parent.right
            mouse.onClicked:{
                if(loginView.state == "REGISTER")
                {
                    if(tf_confirm_password.text == tf_password.text){
                        loginView.state = "LOGIN"
                        loginController.attemptRegisterUser(tf_username.text,tf_password.text,tf_email.text,"");
                    }
                    else{
                        statusText.text = "Password fields do not match."
                    }
                }
                else
                {
                    loginView.state = "REGISTER";
                }
            }
        }
        CG_DarkButton{
            id:updateButton
            text.text: "Update"
            width:parent.width
            height: 0
            mouse.onClicked:{
                CGUpdater.beginUpdateProcess();
                loginView.state = "DOWNLOADING";
            }
            Behavior on height{
                NumberAnimation{duration:600}
            }

        }
        Rectangle{
            id:downloadBar
            color:"#f3f3f3ff"
            width:parent.width* .76
            border.width: 3
            radius:1
            height:0
            Behavior on height{
                NumberAnimation{duration:600}
            }

            //"#999999ff"
        }
        scale:0
        Behavior on scale{
            NumberAnimation{duration:400}
        }
    }
    CG_DarkButton{
        id:cancelButton
        text.text: "cancel"
        text.visible: false;
        anchors.left:form.left
        anchors.right: form.right
        anchors.bottom:parent.bottom
        anchors.bottomMargin: parent.height/6
        height: 0
        mouse.onClicked:{
            if(loginView.state == "LOGIN"){
                loginView.stopLoading()
                loginController.disconnectFromServer();
                //loginView.state = "READY"
            }
        }
        Behavior on height{
            NumberAnimation{duration:600}
        }

    }
    Rectangle{
        id: backArrow
        anchors.left: parent.left
        anchors.top:parent.top
        anchors.margins: 10
        color:"transparent"
        height:50
        width:60
        visible:false
        Image{
            anchors.fill:parent
            source:"/images/CGbackbutton2.png"
            anchors.margins: 4
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(loginView.state == "REGISTER"){
                    loginView.state = "READY";
                }
            }
        }
    }

    Component.onCompleted: {
        loginController.setConnection(APP_IP,APP_PORT)
    }
}
