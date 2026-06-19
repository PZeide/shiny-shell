pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import qs.components.misc

Singleton {
  id: root

  signal requestStarted(request: var)

  function request(handler: var, options: var): string {
    return requests.request(handler, options);
  }

  function resolve(request: var, result: var): void {
    requests.resolve(request, result);
  }

  function cancel(request: var): void {
    requests.cancel(request);
  }

  AsyncRequestHelper {
    id: requests

    ipcTarget: "share-picker"
    completedStatus: "selected"
    concurrent: true

    onRequestStarted: request => root.requestStarted(request)
  }
}
