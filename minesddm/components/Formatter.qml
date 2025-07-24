import QtQuick 2.15

QtObject {
    readonly property string escapeCharacter: "%" // also change the explanation in config file accordingly, if you change this
    required property var placeholderMap

    function formatString(str) {
        if (str === undefined) {
            showError("formatString: str is undefined.");
            return -1;
        }
        while (true) {
            let closingIndex = _findFirstUnescaped(str, '}');
            if (closingIndex === -1) {
                if (_findFirstUnescaped(str, '{') === -1) {
                    return _unescapeLiteral(str);
                }
                
                showError("formatString: unmatched '}' at position " + closingIndex + " in \"" + str + "\".");
                return _unescapeLiteral(str);
            }
            let openingIndex = _findLastUnescaped(str.substring(0, closingIndex), '{');
            if (openingIndex === -1) {
                showError("formatString: unmatched '{' at position " + openingIndex + " in \"" + str + "\".");
                return _unescapeLiteral(str);
            }
            str = str.substring(0, openingIndex) + _substitute(str.substring(openingIndex, closingIndex + 1)) + str.substring(closingIndex + 1);
        }
    }

    function _findFirstUnescaped(str, searchChar) {
        if (searchChar === escapeCharacter) {
            showError("findFirstUnescaped must not be used to search the escape character.");
            return -1;
        }
        let indexCandidate = -1;
        while (true) {
            indexCandidate = str.indexOf(searchChar, indexCandidate + 1);
            if (indexCandidate === -1) {
                return -1;
            }

            let i = indexCandidate - 1;
            while (i >= 0 && str.charAt(i) === escapeCharacter) {
                i--;
            }

            let numberOfBackslashes = indexCandidate - i - 1;
            if (numberOfBackslashes % 2 === 0) {
                return indexCandidate;
            }

        }
    }

    function _findLastUnescaped(str, searchChar) {
        if (searchChar === escapeCharacter) {
            showError(" _findLastUnescaped must not be used to search the escape character.");
            return -1;
        }
        let indexCandidate = str.length;
        while (true) {
            indexCandidate = str.lastIndexOf(searchChar, indexCandidate - 1);
            if (indexCandidate === -1) {
                return -1;
            }

            let i = indexCandidate - 1;
            while (i >= 0 && str.charAt(i) === escapeCharacter) {
                i--;
            }

            let numberOfBackslashes = indexCandidate - i - 1;
            if (numberOfBackslashes % 2 === 0) {
                return indexCandidate;
            }

        }
    }

    function _substitute(str) {
        let indexQuestionMark = _findFirstUnescaped(str, '?');
        if (indexQuestionMark !== -1) {
            let indexColon = _findFirstUnescaped(str, ':');
            if (indexQuestionMark > 1) {
                // '{' is at index 0
                return str.substring(indexQuestionMark + 1, indexColon);
            }

            else {
                return str.substring(indexColon + 1, str.length - 1);
            }
        } else {
            if (!placeholderMap.has(str)) {
                showError(`Invalid placeholder: \"${str}\"`);
                return "";
            }
            return _escapeLiteral(placeholderMap.get(str));
        }
    }

    function _escapeLiteral(str) {
        str = str.split(escapeCharacter).join(escapeCharacter + escapeCharacter);
        str = str.split("{").join(escapeCharacter + "{");
        str = str.split("}").join(escapeCharacter + "}");
        str = str.split("?").join(escapeCharacter + "?");
        str = str.split(":").join(escapeCharacter + ":");
        return str;
    }

    function _unescapeLiteral(str) {
        let result = "";
        for (let s of str.split(escapeCharacter + escapeCharacter)) {
            s = s.split(escapeCharacter + "{").join("{");
            s = s.split(escapeCharacter + "}").join("}");
            s = s.split(escapeCharacter + "?").join("?");
            s = s.split(escapeCharacter + ":").join(":");
            result += s;
        }
        return result;
    }

}
