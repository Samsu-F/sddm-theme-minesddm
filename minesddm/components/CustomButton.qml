import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: customButton

    property url backgroundSource: "../images/button_background.png"
    property url hoveredBackgroundSource: "../images/selected_button_background.png"
    property url disabledBackgroundSource: "../images/disabled_button_background.png"

    signal customClicked()

    width: config.buttonWidth
    height: config.itemHeight
    enabled: true
    hoverEnabled: true
    onClicked: {
        customButton.customClicked();
    }
    states: [
        State {
            name: "hovered"
            when: customButton.hovered

            PropertyChanges {
                target: customButtonBackground
                // Use hoveredBackgroundSource if provided, otherwise fallback to default
                source: customButton.hoveredBackgroundSource
            }

            PropertyChanges {
                target: customButtonShadowText
                color: config.selectedShadowText
            }

            PropertyChanges {
                target: customButtonContentText
                color: config.selectedText
            }

        },
        State {
            name: "disabled"
            when: !customButton.enabled

            PropertyChanges {
                target: customButtonBackground
                // Use disabledBackgroundSource if provided, otherwise fallback to default
                source: customButton.disabledBackgroundSource
            }

            PropertyChanges {
                target: customButtonShadowText
                opacity: 0
            }

            PropertyChanges {
                target: customButtonContentText
                color: config.darkText
            }

        }
    ]

    Text {
        id: customButtonShadowText

        text: customButton.text
        color: config.shadowText
        z: -1

        anchors {
            centerIn: customButton
            horizontalCenterOffset: config.horizontalShadowOffset
            verticalCenterOffset: config.verticalShadowOffset
        }

        font {
            family: minecraftFont.name
            pixelSize: config.fontPixelSize
        }

    }

    contentItem: Text {
        id: customButtonContentText

        text: customButton.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: config.lightText

        font {
            family: minecraftFont.name
            pixelSize: config.fontPixelSize
        }

    }

    background: Image {
        id: customButtonBackground

        // Use backgroundSource if provided, otherwise fallback to default
        source: customButton.backgroundSource
    }

}
