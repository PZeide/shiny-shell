pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property string container: "mp4"
  property string videoCodec: "h264"
  property string audioCodec: "aac"
  property int fps: 60
  property bool audioOutput: true
  property bool audioInput: true
  property string videoDirectory: Quickshell.env("XDG_VIDEOS_DIR") ?? Quickshell.env("HOME") + "/Videos"
  property string videoFilename: `yyyy-MM-dd HH-mm-ss.${container}`
}
