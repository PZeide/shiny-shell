pragma ComponentBehavior: Bound

import QtQuick

QtObject {
  required property string displayName
  required property string prefix

  function filter(input: string): list<LauncherItemDescriptor> {
    throw new Error("filter() of LauncherPlugin is not implemented");
  }

  function exec(item: LauncherItemDescriptor) {
    throw new Error("exec() of LauncherPlugin is not implemented");
  }
}
