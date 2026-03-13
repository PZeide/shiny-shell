pragma ComponentBehavior: Bound

import QtQuick

Item {
  id: root

  readonly property bool shown: state === "opened" || state === "animateIn" || state === "animateOut"
  readonly property bool opened: state === "opened" || state === "animateIn"
  readonly property bool closed: state === "closed" || state === "animateOut"
  readonly property bool animating: state === "animateIn" || state === "animateOut"

  property Transition enter: Transition {
    to: "animateIn"
  }

  property Transition exit: Transition {
    to: "animateOut"
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

  transitions: [enter, exit]

  Connections {
    target: root.enter

    function onRunningChanged() {
      if (!root.enter.running && root.state === "animateIn") {
        root.state = "opened";
      }
    }
  }

  Connections {
    target: root.exit

    function onRunningChanged() {
      if (!root.exit.running && root.state === "animateOut") {
        root.state = "closed";
      }
    }
  }

  onEnterChanged: enter.to = "animateIn"
  onExitChanged: exit.to = "animateOut"

  function openLayer() {
    if (root.opened)
      return;

    state = "animateIn";
  }

  function closeLayer() {
    if (root.closed)
      return;

    state = "animateOut";
  }

  function toggleLayer() {
    if (root.closed) {
      state = "animateIn";
    } else {
      state = "animateOut";
    }
  }
}
