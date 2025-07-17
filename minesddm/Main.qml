import QtQml.Models 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import "components"

Rectangle {
    id: root

    readonly property var escapeCharacter: '%'

    function findFirstUnescaped(str, searchChar) {
        if(searchChar === escapeCharacter) {
            showError("findFirstUnescaped must not be used to search the escape character.");
            return -1;
        }
        let indexCandidate = -1;
        while(true) {
            indexCandidate = str.indexOf(searchChar, indexCandidate + 1);
            if(indexCandidate === -1) {
                return -1;
            }
            let i = indexCandidate - 1;
            while(i >= 0 && str.charAt(i) === escapeCharacter) {
                i--;
            }
            let numberOfBackslashes = indexCandidate - i - 1;
            if(numberOfBackslashes % 2 === 0) {
                return indexCandidate;
            }
        }
    }

    function findLastUnescaped(str, searchChar) {
        if(searchChar === escapeCharacter) {
            showError("findLastUnescaped must not be used to search the escape character.");
            return -1;
        }
        let indexCandidate = str.length;
        while(true) {
            indexCandidate = str.lastIndexOf(searchChar, indexCandidate - 1);
            if(indexCandidate === -1) {
                return -1;
            }
            let i = indexCandidate - 1;
            while(i >= 0 && str.charAt(i) === escapeCharacter) {
                i--;
            }
            let numberOfBackslashes = indexCandidate - i - 1;
            if(numberOfBackslashes % 2 === 0) {
                return indexCandidate;
            }
        }
    }

    function formatString(str) {
        while(true) {
            let closingIndex = findFirstUnescaped(str, '}');
            if(closingIndex === -1) {
                if(findFirstUnescaped(str, '{') === -1) {
                    return unescapeLiteral(str);
                }
                showError("formatString: unmatched '}' at position " + closingIndex + " in \"" + str + "\".");
                return unescapeLiteral(str);
            }
            let openingIndex = findLastUnescaped(str.substring(0, closingIndex), '{');
            if(openingIndex === -1) {
                showError("formatString: unmatched '{' at position " + openingIndex + " in \"" + str + "\".");
                return unescapeLiteral(str);
            }
            str = str.substring(0, openingIndex) +
                    substitute(str.substring(openingIndex, closingIndex + 1)) +
                    str.substring(closingIndex + 1);
        }
    }

    function substitute(str) {
        let indexQustionmark = findFirstUnescaped(str, '?');
        if (indexQustionmark !== -1) {
            let indexColon = findFirstUnescaped(str, ':');
            if(indexQustionmark > 1) { // '{' is at index 0
                return str.substring(indexQustionmark + 1, indexColon);
            }
            else {
                return str.substring(indexColon + 1, str.length - 1);
            }
        }
        else {
            const placeholderMap = new Map([
                ["{username}", usernameTextField.text],
                ["{password}", passwordTextField.getPassword()],
                ["{maskedPassword}", passwordTextField.displayText],
                ["{actionIndex}", root.currentActionIndex],
                ["{nextActionIndex}", (root.currentActionIndex + 1) % root.actionKeys.length],
            ]);

            if (!placeholderMap.has(str)) {
                showError(`Invalid placeholder: \"${str}\"`);
                return "";
            }
            return escapeLiteral(placeholderMap.get(str));
        }
    }

    function escapeLiteral(str) {
        str = str.split(escapeCharacter).join(escapeCharacter + escapeCharacter);
        str = str.split("{").join(escapeCharacter + "{");
        str = str.split("}").join(escapeCharacter + "}");
        str = str.split("?").join(escapeCharacter + "?");
        str = str.split(":").join(escapeCharacter + ":");
        return str;
    }

    function unescapeLiteral(str) {
        let result = "";
        for(let s of str.split(escapeCharacter + escapeCharacter)) {
            s = s.split(escapeCharacter + "{").join("{");
            s = s.split(escapeCharacter + "}").join("}");
            s = s.split(escapeCharacter + "?").join("?");
            s = s.split(escapeCharacter + ":").join(":");
            result += s;
        }
        return result;
    }





    // Session properties. Please look at the SessionHandler.qml file to understand hwo these properties work
    property int sessionIndex: sessionModel.lastIndex
    property var sessions: []
    // Define a mapping of actions to their corresponding methods and availability
    property var actionMap: ({
        "Power Off": {
            "text": config.textPowerOffButton,
            "enabled": sddm.canPowerOff,
            "method": sddm.powerOff
        },
        "Reboot": {
            "text": config.textRebootButton,
            "enabled": sddm.canReboot,
            "method": sddm.reboot
        },
        "Suspend": {
            "text": config.textSuspendButton,
            "enabled": sddm.canSuspend,
            "method": sddm.suspend
        },
        "Hibernate": {
            "text": config.textHibernateButton,
            "enabled": sddm.canHibernate,
            "method": sddm.hibernate
        },
        "Hybrid Sleep": {
            "text": config.textHybridSleepButton,
            "enabled": sddm.canHybridSleep,
            "method": sddm.hybridSleep
        }
    })
    property var actionKeys: Object.keys(root.actionMap)
    property int currentActionIndex: 0

    property bool sessionsInitialized: false

    function getSessionName() {
        if (!sessionsInitialized) {
            return config.sessionTextOnLoad;
        }
        if (sessions.length === 0 || sessionIndex < 0 || sessionIndex >= sessions.length) {
            return config.sessionTextOnFailure;
        }
        return root.replacePlaceholders(config.sessionText, {
                    "sessionname": sessions[sessionIndex].name,
                    "sessioncomment": sessions[sessionIndex].comment
               });
    }

    function getSessionComment() {
        if (!sessionsInitialized) {
            return config.sessionCommentOnLoad;
        }
        if (sessions.length === 0 || sessionIndex < 0 || sessionIndex >= sessions.length) {
            return config.sessionCommentOnFailure;
        }
        return root.replacePlaceholders(config.sessionComment, {
                    "sessionname": sessions[sessionIndex].name,
                    "sessioncomment": sessions[sessionIndex].comment
               });
    }

    function replacePlaceholders(text, placeholders) {
        let result = text;
        for (let key in placeholders) {
            let placeholder = "{" + key + "}"; // Match the placeholder format
            result = result.replace(placeholder, placeholders[key]);
        }
        return result;
    }

    function showError(errorMessage) {
        console.error(errorMessage);
        errorLabel.text += errorMessage + "\n";
    }

    height: config.screenHeight || Screen.height
    width: config.screenWidth || Screen.ScreenWidth

    // Load the minecraft font
    FontLoader {
        id: minecraftFont

        source: "resources/MinecraftRegular-Bmg3.otf"
    }

    // This is the background image
    Image {
        source: "images/background.png"
        fillMode: Image.PreserveAspectCrop
        clip: true

        anchors {
            fill: parent
        }

    }

    Label {
        id: errorLabel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        text: ""
        color: "#00ffff"
        font.pixelSize: 16
        visible: text.length > 0
    }

    Column {
        id: loginArea

        spacing: config.itemsSpacing

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: config.topMargin
        }

        // Main title
        CustomText {
            text: config.mainTitleText
            color: config.lightText

            anchors {
                horizontalCenter: parent.horizontalCenter
            }

        }

        // Spacer Rectangle between title and input fields
        Rectangle {
            width: parent.width
            height: config.itemsSpacing * 0.5
            color: "transparent" // Invisible spacer
        }

        // Username field
        Column {
            spacing: config.labelFieldSpacing

            CustomText {
                text: root.formatString(config.usernameTopLabel)
            }

            UsernameTextField {
                id: usernameTextField

                text: userModel.lastUser
                onAccepted: loginButton.clicked()
            }

            CustomText {
                text: root.formatString(config.usernameBottomLabel)
                color: config.darkText
            }

        }

        // Password field
        Column {
            spacing: config.labelFieldSpacing

            CustomText {
                text: root.formatString(config.passwordTopLabel)
            }

            PasswordTextField {
                id: passwordTextField

                focus: true
                onAccepted: loginButton.clicked()
            }

            CustomText {
                text: root.formatString(config.passwordBottomLabel);
                color: config.darkText
            }

        }

        // Session selector button
        // Please look at the SessionHandler.qml file to understand what is happening here
        Column {
            spacing: config.labelFieldSpacing

            CustomButton {
                text: root.getSessionName()
                onCustomClicked: {
                    root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count;
                }

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                SessionHandler {
                    // Please look at the SessionHandler.qml file to understand what is happening here
                }

            }

            CustomText {
                text: root.getSessionComment()
                wrapMode: Text.Wrap
                width: config.inputWidth
            }

        }

    }

    Row {
        spacing: config.itemsSpacing

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: config.bottomMargin
            // Offset to ignore the size of the small button for centering
            horizontalCenterOffset: config.itemHeight
        }

        // Login button
        CustomButton {
            id: loginButton

            text: root.formatString(config.textLoginButton)
            enabled: usernameTextField.text !== "" && passwordTextField.getPassword() !== ""
            onCustomClicked: {
                console.log("login button clicked");
                let password = passwordTextField.getPassword();
                // console.log("trying to log in with username = '" + usernameTextField.text + "', password = '" + password + "'"); // only for debugging
                sddm.login(usernameTextField.text, password, root.sessionIndex);
            }
        }

        // Do Action button
        CustomButton {
            text: root.formatString(root.actionMap[root.actionKeys[root.currentActionIndex]].text)
            enabled: root.actionMap[root.actionKeys[root.currentActionIndex]].enabled
            onCustomClicked: {
                var actionKey = root.actionKeys[root.currentActionIndex]
                var action = root.actionMap[actionKey];
                console.log(actionKey + " button clicked");
                action.method();
            }
        }

        // Action selector button
        CustomButton {
            text: root.formatString(config.textCycleButton)
            width: config.itemHeight
            onCustomClicked: {
                root.currentActionIndex = (root.currentActionIndex + 1) % root.actionKeys.length;
            }
	    // Override the default images for this specific button instance
	    backgroundSource: "../images/small_button_background.png"
	    hoveredBackgroundSource: "../images/selected_small_button_background.png"
	    disabledBackgroundSource: "../images/disabled_small_button_background.png"
        }

    }

    Connections {
        function onLoginFailed() {
            passwordTextField.ignoreChange = true;
            passwordTextField.text = "";
            passwordTextField.ignoreChange = false;
            passwordTextField.actualPasswordEntered = "";
            passwordTextField.focus = true;
        }

        target: sddm
    }

}
