pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell

Singleton {
  function success(data: var): string {
    return JSON.stringify({
      status: "ok",
      data
    });
  }

  function fail(message: string): string {
    return JSON.stringify({
      status: "error",
      message
    });
  }
}
