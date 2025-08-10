pragma Singleton

import Quickshell

Singleton {
  enum PanelState {
    Collapsed,
    Hover,
    Expanded
  }

  property int calendarState: PanelsHandler.PanelState.Collapsed
}
