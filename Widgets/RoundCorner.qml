pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.Config

Item {
  id: root

  enum Type {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight
  }

  required property int type
  required property int implicitSize
  property color color: Config.appearance.color.bgPrimary

  implicitWidth: implicitSize
  implicitHeight: implicitSize

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
      case RoundCorner.Type.TopLeft:
        return 0;
      case RoundCorner.Type.TopRight:
        return root.implicitSize;
      case RoundCorner.Type.BottomLeft:
        return 0;
      case RoundCorner.Type.BottomRight:
        return root.implicitSize;
      }

      startY: switch (root.type) {
      case RoundCorner.Type.TopLeft:
        return 0;
      case RoundCorner.Type.TopRight:
        return 0;
      case RoundCorner.Type.BottomLeft:
        return root.implicitSize;
      case RoundCorner.Type.BottomRight:
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
        case RoundCorner.Type.TopLeft:
          return 180;
        case RoundCorner.Type.TopRight:
          return -90;
        case RoundCorner.Type.BottomLeft:
          return 90;
        case RoundCorner.Type.BottomRight:
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
