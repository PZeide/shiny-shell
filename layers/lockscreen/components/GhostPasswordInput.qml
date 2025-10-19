pragma ComponentBehavior: Bound

import QtQuick

TextInput {
  id: root
  focus: true
  visible: false
  selectByMouse: false

  Keys.onPressed: event => {
    // Any Ctrl+[Key] should be discarded (except Ctrl+Backspace)
    if (event.modifiers & Qt.ControlModifier) {
      event.accepted = true;

      if (event.key === Qt.Key_Backspace) {
        // Ctrl+Backspace remove everything
        clear();
        return;
      }
    }
  }

  onOverwriteModeChanged: {
    if (overwriteMode)
      overwriteMode = false;
  }

  onCursorPositionChanged: {
    if (cursorPosition !== text.length)
      cursorPosition = text.length;
  }
}
