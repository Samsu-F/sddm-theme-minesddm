// This is a huge workaround to just to get the name of the sessions
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

    function getSessionName() {
        if (sessionIndex >= sessions.count)
            return "";

        if (sessions.count === 0 || sessionIndex < 0 || sessionIndex >= sessions.count)
            return "";

        return sessions.get(sessionIndex).name;
    }

    function getSessionComment() {
        if (sessionIndex >= sessions.count)
            return "";

        if (sessions.count === 0 || sessionIndex < 0 || sessionIndex >= sessions.count)
            return "";

        return sessions.get(sessionIndex).comment;
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
