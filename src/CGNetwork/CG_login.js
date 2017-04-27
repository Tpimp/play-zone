/**************************************************************
*	  Purpose:  Ensures the control fields pass all the
*               validators.
*
*     Entry:    User has clicked register.
*
*     Exit:     Returns whether the fields are valid or not.
****************************************************************/

function setValidators()
{
    return setUsernameValidator() && setPasswordValidator() && setConfirmPasswordValidator() && setEmailValidator()
}

/**************************************************************
*	  Purpose:  Ensures the username is valid when registering.
*
*     Entry:    User has clicked register.
*
*     Exit:     Displays whether the username is valid or not.
****************************************************************/

function setUsernameValidator()
{
    var valid_username = true

    if (tf_confirmPassword.visible == true)
    {
        if (Validator.checkValidUsername(tf_username.text))
        {
            tf_username.textColor = "#00AA00"
            tf_username.font.bold = false
        }
        else
        {
            valid_username = false
            tf_username.textColor = "#FF0000"
            tf_username.font.bold = true
        }
    }

    return valid_username
}

/**************************************************************
*	  Purpose:  Ensures the password is valid when registering.
*
*     Entry:    User has clicked register.
*
*     Exit:     Displays whether the password is valid or not.
****************************************************************/

function setPasswordValidator()
{
    var valid_password = true

    if (tf_confirmPassword.visible == true)
    {
        if (Validator.checkValidPassword(tf_password.text))
        {
            tf_password.textColor = "#00AA00"
            tf_password.font.bold = false
        }
        else
        {
            valid_password = false
            tf_password.textColor = "#FF0000"
            tf_password.font.bold = true
        }
    }

    return valid_password
}

/*****************************************************************
*	  Purpose:  Ensures the password is the same when registering.
*
*     Entry:    User has clicked register.
*
*     Exit:     Displays whether the confirm password is the same.
*******************************************************************/

function setConfirmPasswordValidator()
{
    var valid_confirm_password = true

    if (tf_confirmPassword.visible == true)
    {
        if (tf_password.text == tf_confirmPassword.text)
        {
            tf_confirmPassword.textColor = "#00AA00"
            tf_confirmPassword.font.bold = false
        }
        else
        {
            valid_confirm_password = false
            tf_confirmPassword.textColor = "#FF0000"
            tf_confirmPassword.font.bold = true
        }
    }

    return valid_confirm_password
}

/**************************************************************
*	  Purpose:  Ensures the email is valid when registering.
*
*     Entry:    User has clicked register.
*
*     Exit:     Displays whether the email is valid or not.
****************************************************************/

function setEmailValidator()
{
    var valid_email = true

    if (tf_confirmPassword.visible == true)
    {
        if (Validator.checkValidEmailAddress(tf_emailAddress.text))
        {
            tf_emailAddress.textColor = "#00AA00"
            tf_emailAddress.font.bold = false
        }
        else
        {
            valid_email = false
            tf_emailAddress.textColor = "#FF0000"
            tf_emailAddress.font.bold = true
        }
    }

    return valid_email
}

function storeUserInfo()
{
    var db = LocalStorage.openDatabaseSync("UserInfo", "1.0", "Store local user info.", 1000000);

    db.transaction(
        function(tx)
        {
            // Create the database if it doesn't already exist
            tx.executeSql('CREATE TABLE IF NOT EXISTS User(id INT, username TEXT, password TEXT)');

            // Show all added greetings
            var rs = tx.executeSql('SELECT * FROM User');

            if (rs.rows.length > 0)
            {
                tx.executeSql('UPDATE User SET username = ?, password = ? WHERE id = 0', [tf_username.text, tf_password.text]);
            }
            else
            {
                tx.executeSql('INSERT INTO User VALUES (?, ?, ?)', ['0', tf_username.text, tf_password.text]);
            }
        }
    )
}

function getUserInfo()
{
    var db = LocalStorage.openDatabaseSync("UserInfo", "1.0", "Store local user info.", 1000000);

    db.transaction(
        function(tx)
        {
            // Create the database if it doesn't already exist
            tx.executeSql('CREATE TABLE IF NOT EXISTS User(id INT, username TEXT, password TEXT)');

            // Show all added greetings
            var rs = tx.executeSql('SELECT * FROM User');

            if (rs.rows.length === 0)
            {
                tx.executeSql('INSERT INTO User VALUES (?, ?, ?)', ['0', 'StarWars', 'StarWars1']);
            }

            rs = tx.executeSql('SELECT * FROM User');

            tf_username.text = rs.rows.item(0).username;
            tf_password.text = rs.rows.item(0).password;
        }
    )
}

// The logo width and height is 1/2 of the height when in portrait
// and 1/4 of the height when in landscape.
function getLogoSize()
{
    return isLandscape() ? background.height / 4 : background.height / 2
}

// The individual control height is 1/15 of the height when in portrait
// and (2/3) * (1/8) = apprx 8.33% in landscape.
function getControlHeight()
{
    return background.width > background.height ? background.height * 0.0833 : background.height / 15
}

// The individual control width is 90% of the smallest orientation.
function getControlWidth()
{
    return getSmallestOrientation() * 0.9
}
