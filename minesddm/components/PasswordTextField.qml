import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    echoMode: config.passwordMode === "noEcho" ? TextInput.NoEcho : TextInput.Normal
    width: config.inputWidth
    height: config.itemHeight
    color: config.lightText
    placeholderText: config.passwordPlaceholder
    placeholderTextColor: config.darkText
    leftPadding: config.inputLeftPadding

    font {
        family: minecraftFont.name
        pixelSize: config.fontPixelSize
    }

    background: TextFieldBackground {
    }

    // to prevent running into potentially big problems if the user sets config.passwordMode to an invalid value, we sanitize it here
    readonly property string passwordMode: (
        config.passwordMode === "plain" ? "plain" :
        config.passwordMode === "noEcho" ? "plain" : // treat it like plain here. The desired effect is achieved by setting the echoMode (see above).
        config.passwordMode === "fixedMask" ? "fixedMask" :
        config.passwordMode === "randomMask" ? "randomMask" :
        config.passwordMode === "jitterMask" ? "jitterMask" :
        "plain" // default to this mode if config.passwordMode is an invalid value
    )
    readonly property int maskCharsPerTypedChar: config.maskCharsPerTypedChar ? config.maskCharsPerTypedChar : 1 // fallback if undefined or 0

    property string actualPasswordEntered: ""
    property bool ignoreChange: false   // safety switch to prevent unwanted recursion
    property int textLength: 0          // used to be able to tell whether the change was an addition or a deletion

    onTextChanged: {
        let prevTextLength = textLength;
        textLength = text.length;
        if(passwordMode !== "plain" && !ignoreChange) {
            let simCursorPos = Math.floor(cursorPosition / maskCharsPerTypedChar); // simulated cursor position of the imaginary cursor in actualPasswordEntered
            if (text.length > prevTextLength) { // addition
                // insert the newly typed substring at the correct position into actualPasswordEntered
                let editLength = text.length - prevTextLength;
                let indexSplit = Math.ceil((cursorPosition - editLength + 1) / maskCharsPerTypedChar) - 1;
                actualPasswordEntered = actualPasswordEntered.substring(0, indexSplit)
                                        + text.substring(cursorPosition - editLength, cursorPosition)
                                        + actualPasswordEntered.substring(indexSplit, actualPasswordEntered.length);
                simCursorPos = indexSplit + editLength;
            } else if (text.length < prevTextLength) { // deletion
                // delete the correct substring from actualPasswordEntered
                let editLength = Math.ceil((prevTextLength - text.length) / maskCharsPerTypedChar);
                actualPasswordEntered = actualPasswordEntered.substring(0, simCursorPos)
                                        + actualPasswordEntered.substring(simCursorPos + editLength, actualPasswordEntered.length);
            } else { // either one or multiple characters were overwritten or something went wrong
                // either way, there is no way to know what actually happened.
                actualPasswordEntered = "";
                ignoreChange = true;
                text = "";
                ignoreChange = false;
            }
            let maskedPassword = maskPassword(actualPasswordEntered);
            ignoreChange = true;
            text = maskedPassword;
            ignoreChange = false;
            cursorPosition = simCursorPos * maskCharsPerTypedChar;
        }
    }

    function getPassword() {
        return passwordMode === "plain" ? text : actualPasswordEntered;
    }

    property string randomMaskString: ""

    function maskPassword(plainInput) {
        let outputLength = plainInput.length * maskCharsPerTypedChar;
        if(passwordMode === "fixedMask") {
            let maskPattern = config.passwordFixedMaskString;
            if (maskPattern === "" || maskPattern === undefined) {
                maskPattern = "*"; // fallback
            }
            let result = "";
            for (let i = 0; i < outputLength; ++i) {
                result += maskPattern[i % maskPattern.length];
            }
            return result;
        }
        else if(["randomMask", "jitterMask"].includes(passwordMode)) {
            if(passwordMode === "jitterMask") {
                randomMaskString = "";
            }
            while(randomMaskString.length < outputLength) {
                randomMaskString += randomMaskChar();
            }
            // dicard deleted tail so it will be newly generated if chars are added again
            randomMaskString = randomMaskString.substring(0, outputLength);
            return randomMaskString;
        }
    }

    function randomMaskChar() {
        let charSet = config.passwordRandomMaskChars;
        if(charSet === "" || charSet === undefined) {
            charSet = "1234567890"; // fallback
        }
        const index = Math.floor(Math.random() * charSet.length)
        return charSet.charAt(index);
    }
}
