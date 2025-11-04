pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.utils.animations

Item {
  id: root

  required property ShellScreen screen

  readonly property bool shown: state === "opened" || state === "animateIn" || state === "animateOut"
  readonly property bool opened: state === "opened" || state === "animateIn"
  readonly property bool closed: state === "closed" || state === "animateOut"
  readonly property bool animating: state === "animateIn" || state === "animateOut"
  property bool animated: true
  property real animationFactor: 0

  property PropertyAnimation animationIn: StandardInNumberAnimation {
    target: root
    property: "animationFactor"
    alwaysRunToEnd: false
    to: 1
  }

  property PropertyAnimation animationOut: StandardOutNumberAnimation {
    target: root
    property: "animationFactor"
    alwaysRunToEnd: false
    to: 0
  }

  state: "closed"

  states: [
    State {
      name: "closed"
    },
    State {
      name: "animateIn"
    },
    State {
      name: "opened"
    },
    State {
      name: "animateOut"
    }
  ]

  transitions: [
    Transition {
      to: "animateIn"

      SequentialAnimation {
        ScriptAction {
          script: {
            if (!root.animated) {
              root.state = "opened";
              return;
            }

            root.animationOut.stop();
            root.animationIn.from = root.animationFactor;
            root.animationIn.restart();
          }
        }
        PauseAnimation {
          duration: root.animated ? root.animationIn.duration : 0
        }
        ScriptAction {
          script: {
            if (root.state === "animateIn") {
              root.state = "opened";
            }
          }
        }
      }
    },
    Transition {
      to: "animateOut"

      SequentialAnimation {
        ScriptAction {
          script: {
            if (!root.animated) {
              root.state = "closed";
              return;
            }

            root.animationIn.stop();
            root.animationOut.from = root.animationFactor;
            root.animationOut.restart();
          }
        }
        PauseAnimation {
          duration: root.animated ? root.animationOut.duration : 0
        }
        ScriptAction {
          script: {
            if (root.state === "animateOut") {
              root.state = "closed";
            }
          }
        }
      }
    }
  ]

  function openLayer() {
    if (root.opened)
      return;

    state = root.animated ? "animateIn" : "opened";
  }

  function closeLayer() {
    if (root.closed)
      return;

    state = root.animated ? "animateOut" : "closed";
  }

  function toggleLayer() {
    if (root.closed) {
      state = root.animated ? "animateIn" : "opened";
    } else {
      state = root.animated ? "animateOut" : "closed";
    }
  }
}
