import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    property int presenceState
    property bool offline: presenceState === 0
    property alias animationEnabled: colorAnimation.enabled

    width: Theme.iconSizeSmall
    height: Theme.paddingSmall
    radius: Math.round(height/3)

    color: {
        if (offline)
            return '#999999'

        switch (presenceState) {
            //Available
            case 1: return '#00ff23';
            //Busy
            case 2: return '#ff0f00';
            default: return '#ffa600';
        }
    }

    Behavior on color {
        id: colorAnimation
        ColorAnimation { }
    }
}
