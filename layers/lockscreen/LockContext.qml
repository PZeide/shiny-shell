pragma ComponentBehavior: Bound

import QtQuick
import qs.utils.animations

Item {
  id: root

  property bool locked: false
  property real opacityFactor: 0
  property real readinessFactor: 0

  state: "inactive"

  function lock() {
    if (state === "animateIn" || state === "fadeIn" || state === "secured")
      return;

    locked = true;
    state = "fadeIn";
  }

  function unlock() {
    if (state === "inactive" || state === "animateOut" || state === "fadeOut")
      return;

    state = "animateOut";
  }

  transitions: [
    Transition {
      to: "fadeIn"

      SequentialAnimation {
        StandardInNumberAnimation {
          target: root
          property: "opacityFactor"
          to: 1
        }

        ScriptAction {
          script: root.state = "animateIn"
        }
      }
    },
    Transition {
      from: "fadeIn"
      to: "animateIn"

      SequentialAnimation {
        EmphasizedInNumberAnimation {
          target: root
          property: "readinessFactor"
          to: 1
        }

        ScriptAction {
          script: root.state = "secured"
        }
      }
    },
    Transition {
      to: "animateOut"

      SequentialAnimation {
        EmphasizedOutNumberAnimation {
          target: root
          property: "readinessFactor"
          to: 0
        }

        ScriptAction {
          script: root.state = "fadeOut"
        }
      }
    },
    Transition {
      from: "animateOut"
      to: "fadeOut"

      SequentialAnimation {
        StandardOutNumberAnimation {
          target: root
          property: "opacityFactor"
          to: 0
        }

        ScriptAction {
          script: {
            root.state = "inactive";
            root.locked = false;
          }
        }
      }
    }
  ]
}
