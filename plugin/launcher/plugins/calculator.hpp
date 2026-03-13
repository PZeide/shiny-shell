#pragma once

#include "../plugin.hpp"
#include <libqalculate/includes.h>
#include <qcontainerfwd.h>
#include <qlist.h>
#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Launcher::Plugins {

class CalculatorPlugin : public LauncherPlugin {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(int evaluationTimeout READ default WRITE default NOTIFY evaluationTimeoutChanged BINDABLE bindableEvaluationTimeout)
    // clang-format on

public:
    explicit CalculatorPlugin(QObject* parent = nullptr);

    int priority() const override;
    QString name() const override;
    bool canActivate(const QString& input) const override;
    void filter(const QString& input, qsizetype max) override;

    QBindable<int> bindableEvaluationTimeout();

signals:
    void evaluationTimeoutChanged();

private:
    EvaluationOptions m_evaluationOptions = default_evaluation_options;
    PrintOptions m_printOptions = default_print_options;

    // clang-format off
    Q_OBJECT_BINDABLE_PROPERTY_WITH_ARGS(CalculatorPlugin, int, b_evaluationTimeout, 100, &CalculatorPlugin::evaluationTimeoutChanged)
    // clang-format on

    void invoke(const QString& result) const;
};

} // namespace Shiny::Launcher::Plugins
