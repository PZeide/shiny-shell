pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates

Slider {
  id: root

  property real cooperativeValue: value

  Binding {
    target: root
    property: "value"
    value: root.cooperativeValue
    when: !root.pressed
  }
}
