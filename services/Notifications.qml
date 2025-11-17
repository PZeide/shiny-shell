pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.utils
import qs.config

Singleton {
  id: root

  property list<WrappedNotification> all
  property bool dnd: false

  NotificationServer {
    id: server
    bodySupported: true
    bodyMarkupSupported: true
    bodyImagesSupported: true
    bodyHyperlinksSupported: true
    actionsSupported: true
    actionIconsSupported: true
    imageSupported: true
    persistenceSupported: true
    inlineReplySupported: true
    keepOnReload: false

    onNotification: notification => {
      notification.tracked = true;

      const wrapped = wrappedNotificationFactory.createObject(root, {
        backing: notification,
        popup: !root.dnd
      });

      root.all = [wrapped, ...root.all];

      if (Config.notification.enableSound) {
        if (notification.urgency === NotificationUrgency.Critical) {
          SoundEffects.play(Config.notification.urgentSound);
        } else {
          SoundEffects.play(Config.notification.normalSound);
        }
      }
    }
  }

  Component {
    id: wrappedNotificationFactory
    WrappedNotification {}
  }

  component WrappedNotification: QtObject {
    id: wrapper

    required property Notification backing

    readonly property string appName: backing.appName
    readonly property string appIcon: backing.appIcon
    readonly property string desktopEntry: backing.desktopEntry
    readonly property int urgency: backing.urgency
    readonly property string summary: backing.summary
    readonly property string body: backing.body
    readonly property string image: backing.image
    readonly property list<NotificationAction> actions: backing.actions
    readonly property bool hasActionsIcons: backing.hasActionIcons
    readonly property bool hasInlineReply: backing.hasInlineReply
    readonly property string inlineReplyPlaceholder: backing.inlineReplyPlaceholder
    readonly property real expireTimeout: backing.expireTimeout
    readonly property bool isTransient: backing.transient
    readonly property date time: new Date()
    property bool popup: false

    readonly property Connections connection: Connections {
      target: wrapper.backing

      function onClosed(reason: int) {
        console.info(`Notification closed reason: ${reason}`);
      }
    }

    readonly property Connections retainableConnection: Connections {
      target: wrapper.backing.Retainable

      function onAboutToDestroy() {
        root.all = root.all.filter(n => n !== wrapper);
        wrapper.destroy();
      }
    }

    readonly property Timer popupTimer: Timer {
      running: wrapper.popup
      interval: Config.notification.popupTimeout

      onTriggered: {
        wrapper.popup = false;
        console.info("NOT POPUP ANYMORE");
        wrapper.dismiss();
      }
    }

    function dismiss() {
      backing.dismiss();
    }
  }
}
