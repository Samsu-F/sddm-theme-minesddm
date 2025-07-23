// This is a huge workaround to just to get the name of the sessions
// For some reason sessionModel.get is not working so I came up with this:
// This will store the values of sessionModel in a list for later use

import QtQml.Models 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Item {
    id: sessionHandler

    property var sessions: []
    property int sessionIndex: sessionModel.lastIndex
    property int sessionsInitialized: 0

    function getSessionName() {
        if (sessionIndex >= sessionsInitialized)
            return "";

        if (sessions.length === 0 || sessionIndex < 0 || sessionIndex >= sessions.length)
            return "";

        return sessions[sessionIndex].name;
    }

    function getSessionComment() {
        if (sessionIndex >= sessionsInitialized)
            return "";

        if (sessions.length === 0 || sessionIndex < 0 || sessionIndex >= sessions.length)
            return "";

        return sessions[sessionIndex].comment;
    }

    Instantiator {
        model: sessionModel

        delegate: QtObject {
            Component.onCompleted: {
                sessionHandler.sessions.push({
                    "name": model.name,
                    "comment": model.comment
                });
                sessionHandler.sessionsInitialized = sessionHandler.sessions.length;
            }
        }

    }

}
