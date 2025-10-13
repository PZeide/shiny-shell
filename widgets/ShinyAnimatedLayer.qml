pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Item {
  id: root

  required property ShellScreen screen
  required property PropertyAnimation animationIn
  required property PropertyAnimation animationOut

  readonly property bool opened: state !== "closed"

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
            root.animationOut.stop();
            root.animationIn.restart();
          }
        }
        PauseAnimation {
          duration: root.animationIn.duration
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
            root.animationIn.stop();
            root.animationOut.restart();
          }
        }
        PauseAnimation {
          duration: root.animationOut.duration
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
    if (state === "animateIn" || state === "opened")
      return;

    state = "animateIn";
  }

  function closeLayer() {
    if (state === "animateOut" || state === "closed")
      return;

    state = "animateOut";
  }

  function toggleLayer() {
    if (state === "animateOut" || state === "closed") {
      state = "animateIn";
    } else {
      state = "animateOut";
    }
  }
}
