#include "applications.hpp"
#include "../delegate.hpp"
#include <rapidfuzz/distance/JaroWinkler.hpp>
#include <qlogging.h>
#include <qnumeric.h>
#include <qprocess.h>
#include <qtypes.h>

namespace Shiny::Launcher::Plugins {
  bool ApplicationEntryAction::operator==(const ApplicationEntryAction& other) const {
    return other.command == this->command && other.name == this->name && other.icon == this->icon;
  }

  bool ApplicationEntry::operator==(const ApplicationEntry& other) const {
    return other.command == this->command && other.name == this->name &&
      other.genericName == this->genericName && other.comment == this->comment &&
      other.icon == this->icon && other.runInTerminal == this->runInTerminal &&
      other.workingDirectory == this->workingDirectory && other.keywords == this->keywords &&
      other.categories == this->categories && other.actions == this->actions;
  }

  ApplicationsPlugin::ApplicationsPlugin(QObject* parent) : LauncherPlugin(parent) {}

  QList<LauncherItem> ApplicationsPlugin::filter(const QString& input, qsizetype max) const {
    QString trimmedInput = input.trimmed();
    if (trimmedInput.isEmpty())
      return {};

    rapidfuzz::CachedJaroWinkler<quint32> scorer(
      trimmedInput.toLower().toUtf8(),
      m_scorePrefixBoost
    );

    using ScoredEntry = QPair<ApplicationEntry, qreal>;
    QList<ScoredEntry> scored;

    for (const auto& app : m_applications) {
      QString name = app.name.toLower();
      double score = scorer.normalized_similarity(name.toUtf8());

      if (score >= m_scoreThreshold) {
        scored.append({app, score});
      }
    }

    auto limit = std::min<qsizetype>(max, scored.size());
    std::partial_sort(
      scored.begin(),
      scored.begin() + limit,
      scored.end(),
      [](const ScoredEntry& a, const ScoredEntry& b) { return a.second > b.second; }
    );

    QList<LauncherItem> result;
    result.reserve(limit);

    for (qsizetype i = 0; i < limit; ++i) {
      ApplicationEntry& app = scored[i].first;
      result.append(LauncherItem(
        true,
        app.icon,
        app.name,
        app.comment,
        std::bind_front(&ApplicationsPlugin::invoke, this, app)
      ));
    }

    return result;
  }

  bool ApplicationsPlugin::canActivate(const QString&) const {
    return true;
  }

  int ApplicationsPlugin::priority() const {
    return CATCHALL_PLUGIN_PRIORITY;
  }

  QString ApplicationsPlugin::name() const {
    return "Applications";
  }

  QList<ApplicationEntry> ApplicationsPlugin::applications() const {
    return m_applications;
  }

  void ApplicationsPlugin::setApplications(QList<ApplicationEntry> applications) {
    if (m_applications == applications)
      return;

    m_applications = applications;
    emit applicationsChanged();
  }

  QString ApplicationsPlugin::terminalCommand() const {
    return m_terminalCommand;
  }

  void ApplicationsPlugin::setTerminalCommand(QString terminalCommand) {
    if (m_terminalCommand == terminalCommand)
      return;

    m_terminalCommand = terminalCommand;
    emit terminalCommandChanged();
  }

  bool ApplicationsPlugin::useSystemd() const {
    return m_useSystemd;
  }

  void ApplicationsPlugin::setUseSystemd(bool useSystemd) {
    if (m_useSystemd == useSystemd)
      return;

    m_useSystemd = useSystemd;
    emit useSystemdChanged();
  }

  qreal ApplicationsPlugin::scoreThreshold() const {
    return m_scoreThreshold;
  }

  void ApplicationsPlugin::setScoreThreshold(qreal scoreThreshold) {
    if (qFuzzyCompare(m_scoreThreshold, scoreThreshold))
      return;

    if (scoreThreshold < 0 || scoreThreshold > 1) {
      qCWarning(logLauncher) << "Score threshold should be between 0.0 and 1.0";
      return;
    }

    m_scoreThreshold = scoreThreshold;
    emit scoreThresholdChanged();
  }

  qreal ApplicationsPlugin::scorePrefixBoost() const {
    return m_scorePrefixBoost;
  }

  void ApplicationsPlugin::setScorePrefixBoost(qreal scorePrefixBoost) {
    if (qFuzzyCompare(m_scorePrefixBoost, scorePrefixBoost))
      return;

    if (scorePrefixBoost < 0 || scorePrefixBoost > 0.25) {
      qCWarning(logLauncher) << "Score threshold should be between 0.0 and 0.25";
      return;
    }

    m_scorePrefixBoost = scorePrefixBoost;
    emit scorePrefixBoostChanged();
  }

  void ApplicationsPlugin::invoke(const ApplicationEntry& entry) const {
    if (entry.command.isEmpty()) {
      qCWarning(logLauncher) << "Cannot invoke application because command is empty";
      return;
    }

    QString program;
    QStringList arguments;

    if (m_useSystemd) {
      program = "app2unit";

      if (entry.runInTerminal) {
        if (m_terminalCommand.isEmpty()) {
          arguments << "-T" << "--";
        } else {
          arguments << "--" << m_terminalCommand;
        }
      }

      arguments << entry.command;
    } else {
      if (entry.runInTerminal) {
        if (m_terminalCommand.isEmpty()) {
          program = "xdg-terminal-exec";
          arguments << "--";
        } else {
          program = m_terminalCommand;
        }

        arguments << entry.command;
      } else {
        program = entry.command.first();
        arguments << entry.command.sliced(1);
      }
    }

    QProcess process;
    process.setProgram(program);
    process.setArguments(arguments);

    if (!entry.workingDirectory.isEmpty())
      process.setWorkingDirectory(entry.workingDirectory);

    process.setStandardInputFile(QProcess::nullDevice());
    process.setStandardOutputFile(QProcess::nullDevice());
    process.setStandardErrorFile(QProcess::nullDevice());
    process.setProcessEnvironment(QProcessEnvironment::systemEnvironment());

    process.startDetached();
  }
}
