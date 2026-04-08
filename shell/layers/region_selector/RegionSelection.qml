pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  property list<var> requests: []

  signal requestReceived

  function request(callback, options: var) {
    requests.push({
      callback,
      resolved: false,
      options
    });

    requestReceived();
  }

  function pump(): var {
    if (requests.length === 0) {
      return null;
    }

    return requests.shift();
  }
}
