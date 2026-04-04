pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Shiny.Helpers

Singleton {
  function emptyIcon(): icon {
    return {
      name: "",
      fill: 0,
      grade: 0
    };
  }

  function success(data: var): string {
    return JSON.stringify({
      status: "ok",
      data
    }, null, 2);
  }

  function fail(message: string): string {
    return JSON.stringify({
      status: "error",
      message
    }, null, 2);
  }

  function parseFloatStrict(str: string): double {
    // Only digits and a single dot allowed
    const validFloatRegex = /^\d+(\.\d+)?$/;
    if (validFloatRegex.test(str)) {
      return parseFloat(str);
    }

    return NaN;
  }

  function parseDecimalCommand(command: string, value: double): double {
    const isRelative = command.startsWith("+") || command.startsWith("-");
    const sign = command.startsWith("-") ? -1 : 1;
    let workingStr = isRelative ? command.slice(1) : command;
    const isPercentage = workingStr.endsWith("%");
    workingStr = isPercentage ? workingStr.slice(0, -1) : workingStr;

    let targetValue = NaN;
    const parsedValue = parseFloatStrict(workingStr);
    if (!isNaN(parsedValue)) {
      if (isRelative) {
        if (isPercentage) {
          targetValue = value + (sign * (parsedValue / 100));
        } else {
          targetValue = value + (sign * parsedValue);
        }
      } else {
        targetValue = isPercentage ? (parsedValue / 100) : parsedValue;
      }
    }

    return targetValue;
  }
}
