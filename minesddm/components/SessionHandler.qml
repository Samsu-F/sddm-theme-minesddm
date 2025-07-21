// This is a huge workarround to just to get the name of the sessions
// For some reason sessionModel.get is not working so I came up with this:
// This will store the values of sessionModel in a list for later use

import QtQml.Models 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Instantiator {
    model: sessionModel

    delegate: QtObject {
        Component.onCompleted: {
            root.sessions.push({
                "name": model.name,
                "comment": model.comment
            });

            root.sessionsInitialized = root.sessions.length;
        }
    }
}
