pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Greetd
import Shiny.Greeter

Item {
  id: root

  required property string session
  property SessionDesktopEntry sessionEntry
  required property string user
  readonly property int state: Greetd.state
  readonly property bool acceptAuthentication: Greetd.available && state === GreetdState.Inactive
  property string password
  property string error: ""

  function requestAuthentication() {
    if (!acceptAuthentication) {
      console.error("Greetd is not ready to authenticate");
      return;
    }

    resetErrorTimer.stop();
    root.error = "";

    console.info(`Creating greetd user ${user} for session ${sessionEntry.name}`);
    Greetd.createSession(user);
  }

  function showError(error: string) {
    root.error = error;
    resetErrorTimer.interval = 5000;
    resetErrorTimer.restart();
  }

  function showErrorInf(error: string) {
    root.error = error;
    resetErrorTimer.interval = Math.pow(2, 31) - 1;
    resetErrorTimer.restart();
  }

  Timer {
    id: resetErrorTimer
    interval: 0
    onTriggered: root.error = ""
  }

  Connections {
    target: Greetd

    function onAuthMessage(message, error, responseRequired, echoResponse) {
      if (responseRequired) {
        Greetd.respond(root.password);
      }
    }

    function onAuthFailure(message) {
      root.password = "";
      root.showError("Incorrect password");
    }

    function onError(error) {
      root.password = "";
      root.showError(`Error: ${error}`);
    }

    function onReadyToLaunch() {
      console.info(`Launching Greetd session ${root.sessionEntry.name}`);
      Greetd.launch(root.sessionEntry.command);
    }
  }

  Component.onCompleted: {
    if (!Greetd.available) {
      console.error("Greetd is not available");
      root.showErrorInf("Greetd is not available");
      return;
    }

    sessionEntry = GreeterHelpers.findSession(session);
    if (!sessionEntry) {
      console.error(`Session ${session} not found`);
      root.showErrorInf(`Session ${session} not found`);
    }
  }
}
