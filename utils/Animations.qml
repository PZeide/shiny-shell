pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import qs.config

QtObject {
  id: root

  component AnimationFactory: QtObject {
    id: factory

    required property real duration
    required property int type
    property list<real> curve

    function createNumber(parent: QtObject, properties: var): Animation {
      return numberFactory.createObject(this, properties) as Animation;
    }

    function createColor(parent: QtObject, properties = {}): Animation {
      return colorFactory.createObject(this, properties) as Animation;
    }

    readonly property Component numberFactory: Component {
      NumberAnimation {
        duration: factory.duration
        easing.type: factory.type
        easing.bezierCurve: factory.curve
      }
    }

    readonly property Component colorFactory: Component {
      ColorAnimation {
        duration: factory.duration
        easing.type: factory.type
        easing.bezierCurve: factory.curve
      }
    }
  }

  readonly property AnimationFactory effects: AnimationFactory {
    duration: Config.appearance.anim.durations.expressiveEffects
    type: Easing.BezierSpline
    curve: Config.appearance.anim.curves.expressiveEffects
  }

  readonly property AnimationFactory sineEnter: AnimationFactory {
    duration: Config.appearance.anim.durations.sm
    type: Easing.InSine
  }

  readonly property AnimationFactory sineLeave: AnimationFactory {
    duration: Config.appearance.anim.durations.sm
    type: Easing.OutSine
  }

  readonly property AnimationFactory moveEnter: AnimationFactory {
    duration: Config.appearance.anim.durations.md
    type: Easing.BezierSpline
    curve: Config.appearance.anim.curves.emphasizedDecel
  }

  readonly property AnimationFactory moveExit: AnimationFactory {
    duration: Config.appearance.anim.durations.sm
    type: Easing.BezierSpline
    curve: Config.appearance.anim.curves.emphasizedAccel
  }
}
