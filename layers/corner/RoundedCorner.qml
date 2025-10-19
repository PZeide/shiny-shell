pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.config
import qs.utils.animations

Item {
  id: root

  enum Type {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight
  }

  required property int type

  property int implicitSize: Config.appearance.rounding.corner
  property color color: Config.appearance.color.bgPrimary

  implicitWidth: implicitSize
  implicitHeight: implicitSize

  Behavior on color {
    EffectColorAnimation {}
  }

  Shape {
    layer.enabled: true
    layer.smooth: true
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      id: shapePath
      strokeWidth: 0
      fillColor: root.color
      pathHints: ShapePath.PathSolid & ShapePath.PathNonIntersecting

      startX: switch (root.type) {
      case RoundedCorner.Type.TopLeft:
        return 0;
      case RoundedCorner.Type.TopRight:
        return root.implicitSize;
      case RoundedCorner.Type.BottomLeft:
        return 0;
      case RoundedCorner.Type.BottomRight:
        return root.implicitSize;
      }

      startY: switch (root.type) {
      case RoundedCorner.Type.TopLeft:
        return 0;
      case RoundedCorner.Type.TopRight:
        return 0;
      case RoundedCorner.Type.BottomLeft:
        return root.implicitSize;
      case RoundedCorner.Type.BottomRight:
        return root.implicitSize;
      }

      PathAngleArc {
        moveToStart: false
        centerX: root.implicitSize - shapePath.startX
        centerY: root.implicitSize - shapePath.startY
        radiusX: root.implicitSize
        radiusY: root.implicitSize
        sweepAngle: 90

        startAngle: switch (root.type) {
        case RoundedCorner.Type.TopLeft:
          return 180;
        case RoundedCorner.Type.TopRight:
          return -90;
        case RoundedCorner.Type.BottomLeft:
          return 90;
        case RoundedCorner.Type.BottomRight:
          return 0;
        }
      }

      PathLine {
        x: shapePath.startX
        y: shapePath.startY
      }
    }
  }
}
