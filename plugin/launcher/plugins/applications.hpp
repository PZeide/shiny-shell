#pragma once

#include "../plugin.hpp"
#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>

namespace Shiny::Launcher::Plugins {
  struct ApplicationEntryAction {
    Q_GADGET
    QML_VALUE_TYPE(applicationEntryAction)
    QML_STRUCTURED_VALUE

    // clang-format off
    Q_PROPERTY(QList<QString> command MEMBER command)
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(QString icon MEMBER icon)
    // clang-format on

  public:
    QList<QString> command;
    QString name;
    QString icon;

    [[nodiscard]] bool operator==(const ApplicationEntryAction& other) const;
  };

  struct ApplicationEntry {
    Q_GADGET
    QML_VALUE_TYPE(applicationEntry)
    QML_STRUCTURED_VALUE

    // clang-format off
    Q_PROPERTY(QList<QString> command MEMBER command)
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(QString genericName MEMBER genericName)
    Q_PROPERTY(QString comment MEMBER comment)
    Q_PROPERTY(QString icon MEMBER icon)
    Q_PROPERTY(bool runInTerminal MEMBER runInTerminal)
    Q_PROPERTY(QString workingDirectory MEMBER workingDirectory)
    Q_PROPERTY(QList<QString> keywords MEMBER keywords)
    Q_PROPERTY(QList<QString> categories MEMBER categories)
    Q_PROPERTY(QList<Shiny::Launcher::Plugins::ApplicationEntryAction> actions MEMBER actions)
    // clang-format on

  public:
    QList<QString> command;
    QString name;
    QString genericName;
    QString comment;
    QString icon;
    bool runInTerminal = false;
    QString workingDirectory;
    QList<QString> keywords;
    QList<QString> categories;
    QList<ApplicationEntryAction> actions;

    [[nodiscard]] bool operator==(const ApplicationEntry& other) const;
  };

  class ApplicationsPlugin : public LauncherPlugin {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QList<Shiny::Launcher::Plugins::ApplicationEntry> applications READ applications WRITE setApplications
                   NOTIFY applicationsChanged REQUIRED)
    Q_PROPERTY(QString terminalCommand READ terminalCommand WRITE setTerminalCommand NOTIFY terminalCommandChanged)
    Q_PROPERTY(bool useSystemd READ useSystemd WRITE setUseSystemd NOTIFY useSystemdChanged)
    Q_PROPERTY(qreal scoreThreshold READ scoreThreshold WRITE setScoreThreshold NOTIFY scoreThresholdChanged)
    Q_PROPERTY(qreal scorePrefixBoost READ scorePrefixBoost WRITE setScorePrefixBoost NOTIFY scorePrefixBoostChanged)
    // clang-format on

  public:
    explicit ApplicationsPlugin(QObject* parent = nullptr);

    QList<LauncherItem> filter(const QString& input, qsizetype max) const override;
    bool canActivate(const QString& input) const override;
    int priority() const override;
    QString name() const override;

    QList<ApplicationEntry> applications() const;
    void setApplications(QList<ApplicationEntry> applications);

    QString terminalCommand() const;
    void setTerminalCommand(QString terminalCommand);

    bool useSystemd() const;
    void setUseSystemd(bool useSystemd);

    qreal scoreThreshold() const;
    void setScoreThreshold(qreal scoreThreshold);

    qreal scorePrefixBoost() const;
    void setScorePrefixBoost(qreal scorePrefixBoost);

  signals:
    void applicationsChanged();
    void terminalCommandChanged();
    void useSystemdChanged();
    void scoreThresholdChanged();
    void scorePrefixBoostChanged();

  private:
    QList<ApplicationEntry> m_applications;
    QString m_terminalCommand = "auto";
    bool m_useSystemd = false;
    qreal m_scoreThreshold = 0.6;
    qreal m_scorePrefixBoost = 0.12;

    void invoke(const ApplicationEntry& entry) const;
  };
}
