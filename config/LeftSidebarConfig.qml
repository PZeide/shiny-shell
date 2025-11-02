pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property AiConfig ai: AiConfig {}
  property BooruConfig booru: BooruConfig {}
  property GachaConfig gacha: GachaConfig {}

  component AiConfig: JsonObject {
    property bool enabled: true
  }

  component BooruConfig: JsonObject {
    property bool enabled: true
  }

  component GachaConfig: JsonObject {
    property bool enabled: true
  }
}
