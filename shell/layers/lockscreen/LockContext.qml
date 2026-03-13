pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pam
import qs.config
import qs.services

Item {
  id: root

  readonly property int errorDuration: 5000
  readonly property int animationDuration: Config.appearance.anim.durations.lg

  property bool presented: false
  property bool locked: false
  property alias authenticating: pam.active
  property int result: PamResult.Success
  property string password: ""

  function tryAuthenticate(password: string) {
    if (authenticating) {
      console.warn("Already authenticating");
      return;
    }

    resetErrorTimer.stop();
    root.result = PamResult.Success;

    root.password = password;
    pam.start();
  }

  function lock() {
    if (locked) {
      console.warn("Lock already active");
      return;
    }

    animateOutTimer.stop();
    locked = true;
    presented = true;
  }

  function unlock() {
    if (!locked) {
      console.warn("Lock not active");
      return;
    }

    root.locked = false;
    animateOutTimer.restart();
  }

  PamContext {
    id: pam

    onCompleted: result => {
      root.password = "";

      if (result === PamResult.Success) {
        root.result = PamResult.Success;
        root.locked = false;
        animateOutTimer.restart();
      } else {
        root.result = result;
        resetErrorTimer.restart();
      }
    }

    onResponseRequiredChanged: {
      if (!responseRequired)
        return;

      respond(root.password);
    }
  }

  Connections {
    target: Session

    function onLockRequested(requestNotification: bool) {
      root.lock();

      if (requestNotification) {
        notifyLockReadyTimer.restart();
      }
    }

    function onUnlockRequested() {
      root.unlock();
    }
  }

  Timer {
    id: resetErrorTimer
    interval: root.errorDuration
    onTriggered: root.result = PamResult.Success
  }

  Timer {
    id: animateOutTimer
    interval: root.animationDuration
    onTriggered: root.presented = false
  }

  Timer {
    id: notifyLockReadyTimer
    interval: root.animationDuration
    onTriggered: Session.notifyLockReady()
  }
}
