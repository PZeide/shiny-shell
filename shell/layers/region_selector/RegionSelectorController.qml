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

    ipcTarget: "region-selector"
    completedStatus: "selected"
    concurrent: false
    ipcResultMapper: region => ({
        monitor: region.screen.name,
        x: region.x,
        y: region.y,
        width: region.width,
        height: region.height
      })

    onRequestStarted: request => root.requestStarted(request)
  }
}
