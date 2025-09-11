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

  onActiveFocusChanged: {
    if (!activeFocus)
      forceActiveFocus();
  }

  onOverwriteModeChanged: {
    if (overwriteMode)
      overwriteMode = false;
  }

  onCursorPositionChanged: {
    if (cursorPosition !== text.length)
      cursorPosition = text.length;
  }

  Component.onDestruction: {
    // I have no clue why but disabling before destruction remove the warning 'Try to enable surface x with focusing surface y'
    enabled = false;
  }
}
