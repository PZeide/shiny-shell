#include "calculator.hpp"
#include <functional>
#include <qclipboard.h>
#include <qguiapplication.h>
#include <string>
#include <vector>

namespace Shiny::Launcher::Plugins {
  CalculatorPlugin::CalculatorPlugin(QObject* parent) : Shiny::Launcher::LauncherPlugin(parent) {
    if (!CALCULATOR) {
      new Calculator();
      CALCULATOR->loadExchangeRates();
      CALCULATOR->loadGlobalDefinitions();
      CALCULATOR->loadLocalDefinitions();
    }
  }

  QString CalculatorPlugin::name() const {
    return "Calculator";
  }

  int CalculatorPlugin::priority() const {
    return PREFIXED_PLUGIN_PRIORITY;
  }

  bool CalculatorPlugin::canActivate(const QString& input) const {
    return input.startsWith("=");
  }

  void CalculatorPlugin::filter(const QString& input, qsizetype) {
    QString expression = input;
    if (expression.startsWith("="))
      expression = expression.mid(1).trimmed();

    if (expression.isEmpty()) {
      emit filterResult({});
      return;
    }

    std::string unlocalized =
      CALCULATOR->unlocalizeExpression(expression.toStdString(), m_evaluationOptions.parse_options);
    std::string parsed;
    std::string result = CALCULATOR->calculateAndPrint(
      unlocalized,
      m_evaluationTimeout,
      m_evaluationOptions,
      m_printOptions,
      &parsed
    );

    std::vector<std::string> warnings;
    std::vector<std::string> errors;
    while (CalculatorMessage* message = CALCULATOR->message()) {
      if (!message->message().empty()) {
        if (message->type() == MESSAGE_ERROR) {
          errors.push_back(message->message());
        } else if (CALCULATOR->message()->type() == MESSAGE_WARNING) {
          warnings.push_back(message->message());
        }
      }

      CALCULATOR->nextMessage();
    }

    if (!errors.empty()) {
      QString description = QString::fromStdString(errors.front());
      emit filterResult({LauncherItem(
        false,
        "calculate",
        "Failed to evaluate expression",
        description,
        std::bind_front(&CalculatorPlugin::invoke, this, "Expression error")
      )});
      return;
    }

    QString name = QString("%1 = %2").arg(parsed).arg(result);
    QString description;
    if (!warnings.empty()) {
      // We can only show the first one
      description = QString::fromStdString(warnings.front());
    }

    emit filterResult({LauncherItem(
      false,
      "calculate",
      name,
      description,
      std::bind_front(&CalculatorPlugin::invoke, this, QString::fromStdString(result))
    )});
  }

  int CalculatorPlugin::evaluationTimeout() const {
    return m_evaluationTimeout;
  }

  void CalculatorPlugin::setEvaluationTimeout(int evaluationTimeout) {
    if (m_evaluationTimeout == evaluationTimeout)
      return;

    m_evaluationTimeout = evaluationTimeout;
    emit evaluationTimeoutChanged();
  }

  void CalculatorPlugin::invoke(const QString& result) const {
    QClipboard* clipboard = QGuiApplication::clipboard();
    clipboard->setText(result);
  }
}
