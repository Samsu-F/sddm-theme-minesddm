// This is a huge workaround just to get the name of the sessions
// For some reason sessionModel.get is not working so I came up with this:
// This will store the values of sessionModel in a list for later use

import QtQml.Models 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Item {
    id: sessionHandler

    property ListModel sessions: ListModel {}
    property int sessionIndex: sessionModel.lastIndex

    function isValidIndex() {
        return sessionIndex >= 0 && sessionIndex < sessions.count;
    }

    function getSessionName() {
        return isValidIndex() ? sessions.get(sessionIndex).name : "";
    }

    function getSessionComment() {
        return isValidIndex() ? sessions.get(sessionIndex).comment : "";
    }

    Instantiator {
        model: sessionModel

        delegate: QtObject {
            Component.onCompleted: {
                // Add session to ListModel
                sessions.append({
                    "name": model.name,
                    "comment": model.comment
                });
            }
        }
    }

}
