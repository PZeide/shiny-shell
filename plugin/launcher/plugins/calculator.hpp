#pragma once

#include "../plugin.hpp"
#include <libqalculate/qalculate.h>
#include <qcontainerfwd.h>
#include <qlist.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Launcher::Plugins {
  class CalculatorPlugin : public LauncherPlugin {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(int evaluationTimeout READ evaluationTimeout WRITE setEvaluationTimeout NOTIFY evaluationTimeoutChanged)
    // clang-format on

  public:
    explicit CalculatorPlugin(QObject* parent = nullptr);

    QList<LauncherItem> filter(const QString& input, qsizetype max) const override;
    bool canActivate(const QString& input) const override;
    int priority() const override;
    QString name() const override;

    int evaluationTimeout() const;
    void setEvaluationTimeout(int evaluationTimeout);

  signals:
    void evaluationTimeoutChanged();

  private:
    EvaluationOptions m_evaluationOptions = default_evaluation_options;
    PrintOptions m_printOptions = default_print_options;
    int m_evaluationTimeout = 100;

    void invoke(const QString& result) const;
  };
} // namespace Shiny::Launcher::Plugins
