import QtQuick 2.8
import CGNetwork 1.0
import CGWeb 1.0
import QtQuick.Layouts 1.1
Rectangle{
    color: "transparent"
    id:loginView
    signal startLoading(string text, real duration, bool back);
    signal stopLoading();
    signal loggedIn();
    function disconnectFromHost(){
        loginController.disconnectFromServer()
    }

    property string connectionState:""
    property alias status:statusText.text
    property string username:""
    property string password:""
    property string email:""
    property var form: undefined

    function loginToCG(user,password){
        loginView.username = user;
        loginView.password = password;
        loginView.connectionState = "LOG";
        loginView.state = "LOGIN";
        loginController.login(user,password);
    }
    function registerUser(user, password, email){
        loginView.connectionState = "REG";
        loginController.attemptRegisterUser(user,password,email);
    }

    function setRegisterForm()
    {
        loginView.form.email.height = loginView.form.height/6.1;
        loginView.form.confirmPassword.height = loginView.form.height/6.1;
        loginView.form.socialButtons.height = 0;
        loginView.form.socialButtons.visible = 0;
        loginView.form.login.visible = 0;
        loginView.form.registerText.text = ""
    }
    function getPassword(){
        return loginController.getPassword();
    }

    /************************************************
    * This section defines the Connections to
    * "Updater"
    *
    ***********************************************/
    Connections{
        target: CGUpdater // comes from the C++ application loader
        onUpdateAvailable: loginView.state = "AVAILABLE";
        onReady:{loginView.state = "READY";}
    }

    states:[
        State{
            name:"AVAILABLE"
            PropertyChanges{target:formLoader; active:false; sourceComponent:undefined}
            PropertyChanges{target:statusText;text:"Update Available"}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:4200}
            PropertyChanges{target:formLoader; sourceComponent:availableContainer}
            StateChangeScript{script:CGUpdater.beginUpdateProcess();}
        },
        State{
            name:"DOWNLOADING"
            PropertyChanges{target:formLoader; active:false; sourceComponent:undefined}
            PropertyChanges{target:statusText;text:"Downloading Updates..."}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:3500}
            PropertyChanges{target:formLoader;sourceComponent:downloadContainer; active:true}
        },
        State{
            name:"UPDATING"
            PropertyChanges{target:formLoader; active:false; sourceComponent:undefined}
            PropertyChanges{target:statusText;text:"Installing Updates..."}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:2200}
            StateChangeScript{script:CGUpdater.validateRelocateUpdate();}
        },
        State{
            name:"WAITING"
            PropertyChanges{target:formLoader; active:false; sourceComponent:undefined}
            PropertyChanges{target:statusText;text:"Update Finished!"}
            PropertyChanges{target:logoAnimation;running:false;}
            PropertyChanges{target:formLoader; sourceComponent:waitingContainer; active:true}
        },
        State{
            name:"READY"
            extend:""
            PropertyChanges{target:formLoader; active:false; sourceComponent:undefined}
            StateChangeScript{script:loginView.stopLoading();}
            PropertyChanges{target:statusText;text:""}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:10000}
            PropertyChanges{target:formLoader; sourceComponent:readyContainer; active:true}
        },
        State{
            name:"REGISTER"
            PropertyChanges{target:formLoader; sourceComponent:readyContainer; active:true}
            StateChangeScript{script:loginView.stopLoading();}
            PropertyChanges{target:statusText;text:""}
            PropertyChanges{target:logoAnimation;loops:Animation.Infinite;running:true;}
            PropertyChanges{target:pauseAnimation;duration:10000}
            StateChangeScript{script: loginView.setRegisterForm();}
        },
        State{
            name:"LOGIN"
            PropertyChanges{target:formLoader; active:false; sourceComponent:undefined}
            PropertyChanges{target:formLoader; sourceComponent:loginContainer; active:true}
            StateChangeScript{script:loginView.startLoading("Connecting to Chessgames Server...",850,false);}
            PropertyChanges{target:statusText;text:""}
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
            statusText.text = "User Credentials Were Denied"
        }

        onUserCGVerified: {
            if(loginView.connectionState == "LOG"){
                //playerProfile.avatar = avatar;
                loginView.email = email;
                loginController.attemptRegisterUser(loginView.username,loginView.password,email);
            }
        }
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
        }
        onUserCredentialsDenied: {
            webController.requestCGLoginVerify(loginView.username,loginView.password);
        }
        onUserLoggedIn: {
            loginView.stopLoading();
            loginView.state = "READY"
            loginView.loggedIn();
        }
        onUserRegistered:{
            loginController.login(loginView.username,loginView.password);
        }
        onUserDeniedRegister: {
            loginView.state = "READY"
            statusText.text = reason
        }

        Component.onCompleted: {
            loginController.setServerAddress(APP_IP,APP_PORT)
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
    Item{
        id:buttonContainer
        anchors.bottom: parent.bottom
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.top:statusText.bottom
        anchors.topMargin:6
        anchors.margins: 2
        Loader{
            id:formLoader
            anchors.centerIn: parent
            onLoaded: {
                if(formLoader.item != undefined){
                    formLoader.item.parent = buttonContainer
                    loginView.form = formLoader.item;
                    formLoader.item.scale = 1;
                }
            }
        }
    }

    /********************************************************
    *availableContainer - Displayed when an update available
    *    Has one button Update - starts the update download
    * The user only has one choice - update or close.
    ********************************************************/
    Component{
        id:availableContainer
        CG_DarkButton{
            id:updateButton
            text.text: "Update"
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.leftMargin: parent.width*.025
            anchors.rightMargin: parent.width*.025
            height: parent.height/6.1
            anchors.verticalCenter: parent.verticalCenter
            mouse.onClicked:{
                CGUpdater.beginUpdateProcess();
                loginView.state = "DOWNLOADING";
            }
            scale:0
            Behavior on scale{
                NumberAnimation{from:0;to:1;duration:600}
            }

        }
    }
    /**********************************************************
    *downloadContainer - Displays the current download status
    *    Displays a progress bar and some output text.
    **********************************************************/
    Component{
        id:downloadContainer
        Rectangle{
            color:"#f3f3f3ff"
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.leftMargin: parent.width*.05
            anchors.rightMargin: parent.width*.05
            height: width *.098 < 76 ? width*.098:76
            anchors.verticalCenter: parent.verticalCenter
            border.width: 3
            radius:1
            scale:0
            Behavior on scale{
                NumberAnimation{from:0;to:1;duration:600}
            }

            //"#999999ff"
        }
    }
    /**********************************************************
    *waitingContainer - notifies user the Update is finished
    *    Displays a single button "continue" to notify
    *    application loader to swap to updated application.
    **********************************************************/
    Component{
        id:waitingContainer
        CG_DarkButton{
            id:waitingButton
            text.text: "Continue"
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.leftMargin: parent.width*.025
            anchors.rightMargin: parent.width*.025
            height: parent.height/6.1
            anchors.verticalCenter: parent.verticalCenter
            mouse.onClicked:{
                loginView.state = "READY";
            }
            scale:0
            Behavior on scale{
                NumberAnimation{from:0;to:1;duration:600}
            }
        }
    }

    /************************************************************
    *loginContainer - Notifies Player they are logging in
    *    Has a single button that can cancel the login and take
    *   them home.
    *************************************************************/
    Component{
        id:loginContainer
        CG_DarkButton{
            id:cancelButton
            text.text: "Cancel Login"
            mouse.onClicked:{
                loginView.state = "READY";
                loginController.disconnectFromServer();
            }
            scale:0
            Behavior on scale{
                NumberAnimation{from:0;to:1;duration:600}
            }
            Component.onCompleted: {
                anchors.left = parent.left
                anchors.right = parent.right
                anchors.leftMargin = parent.width*.025
                anchors.rightMargin = parent.width*.025
                height = parent.height/6.1
                anchors.verticalCenter = parent.verticalCenter
            }
        }
    }

    /************************************************************
    *readyContainer - Displays the login form and register form.
    *    In Ready state, username and password textfields are
    *    available. When transitioning to registration form or
    *    username form, various items will be hidden.
    *************************************************************/
    Component{
        id:readyContainer
        Column{
            id:form
            spacing:7
            anchors.fill: parent
            property alias username:tf_username
            property alias password:tf_password
            property alias email:tf_email
            property alias confirmPassword:tf_confirm_password
            property alias login:loginButton
            property alias register:registerButton
            property alias facebook:fbButton
            property alias google:googleButton
            property alias socialButtons:socialRow
            property alias registerRow:registerRow
            property alias registerText:registerText
            CG_TextField{
                id:tf_username
                placeholderText:"Chessgames Username"
                text:""
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.leftMargin: parent.width*.025
                anchors.rightMargin: parent.width*.025
                height: parent.height/6.1
                KeyNavigation.tab: loginView.state == "READY" ? tf_password:tf_email
                Component.onCompleted:{
                    tf_username.focus = true;
                }
            }
            CG_TextField{
                id:tf_email
                placeholderText:"Email Address"
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.leftMargin: parent.width*.025
                anchors.rightMargin: parent.width*.025
                height: 0
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
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.leftMargin: parent.width*.025
                anchors.rightMargin: parent.width*.025
                height: parent.height/6.1
                KeyNavigation.tab: tf_confirm_password
                Keys.onReturnPressed: {
                    if(tf_username.length > 0 && tf_password.length > 0){
                        if(loginView.state == "READY"){
                            loginView.loginToCG(tf_username.text,tf_password.text)
                        }
                    }
                }
            }
            CG_TextField{
                id:tf_confirm_password
                placeholderText:"Confirm Password"
                echoMode: TextInput.Password
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.leftMargin: parent.width*.025
                anchors.rightMargin: parent.width*.025
                height: 0
                Keys.onReturnPressed: {
                    if(loginView.state == "REGISTER"){
                        loginView.email = tf_email.text;
                        loginView.username = tf_username.text;
                        loginView.password = tf_password.text;
                        loginController.attemptRegisterUser(tf_username.text,tf_password.text,tf_email.text);
                    }
                }
                Behavior on height{
                    NumberAnimation{duration:450;}
                }
            }


            CG_DarkButton{
                id:loginButton
                text.text: "Login"
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.leftMargin: parent.width*.025
                anchors.rightMargin: parent.width*.025
                height: parent.height/6.1
                mouse.onClicked:{
                    if(tf_username.length > 0 && tf_password.length > 0){
                        if(loginView.state == "READY"){
                            loginView.loginToCG(tf_username.text,tf_password.text)
                        }
                    }
                }
            }
            Row{
                id: socialRow
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.leftMargin: parent.width*.025
                anchors.rightMargin: parent.width*.025
                height: parent.height/6.1
                anchors.margins: 2
                spacing:2
                CG_SocialMediaBtn{
                    id:fbButton
                    color: "#5d79b4"
                    shadowColor: "#164785"
                    iconSource: "images/FacebookIcon.png"
                    text: "Log in with Facebook"
                    anchors.verticalCenter: parent.verticalCenter
                    height:parent.height * .98
                    width:parent.width/2 -2
                }
                CG_SocialMediaBtn{
                    id:googleButton
                    color: "#dd4b39"
                    shadowColor: "#be4031"
                    iconSource: "images/GooglePlusIcon.png"
                    text: "Sign in with Google+"
                    anchors.verticalCenter: parent.verticalCenter
                    height:parent.height * .98
                    width:parent.width/2 -2
                }
            }
            Item{
                id:registerRow
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.leftMargin: parent.width*.025
                anchors.rightMargin: parent.width*.025
                height: parent.height/6.8
                anchors.margins: 6
                Text{
                    id:registerText
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text:"Don't Have an Account?"
                    font.pixelSize: googleButton.height * .41 <  googleButton.width * .115 ? googleButton.height *.41:googleButton.width * .115
                    anchors.top:parent.top
                    anchors.bottom: parent.bottom
                    anchors.left:parent.left
                    anchors.right:registerButton.left
                    anchors.rightMargin: 8
                    anchors.margins: 2
                }
                CG_DarkButton{
                    id:registerButton
                    text.text: "Register"
                    anchors.top:parent.top
                    anchors.bottom: parent.bottom
                    anchors.right:parent.right
                    anchors.margins: 2
                    width:googleButton.width
                    mouse.onClicked:{
                        if(loginView.state == "REGISTER")
                        {
                            if(tf_confirm_password.text == tf_password.text){
                                loginView.state = "LOGIN"
                                loginView.email = tf_email.text;
                                loginView.username = tf_username.text;
                                loginView.password = tf_password.text;
                                loginController.attemptRegisterUser(tf_username.text,tf_password.text,tf_email.text);
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
            }
            scale:0
            Behavior on scale{
                NumberAnimation{from:0;to:1;duration:400}
            }
        }
    }
}
