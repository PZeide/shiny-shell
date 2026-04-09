#pragma once

#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>

namespace Shiny::Helpers {

struct Icon {
    Q_GADGET
    QML_VALUE_TYPE(icon)
    QML_STRUCTURED_VALUE

    // clang-format off
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(double fill MEMBER fill)
    Q_PROPERTY(int grade MEMBER grade)
    // clang-format on

public:
    QString name;
    double fill;
    int grade;
};

} // namespace Shiny::Helpers
