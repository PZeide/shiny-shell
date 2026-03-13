#pragma once

#include "../plugin.hpp"
#include <qlist.h>
#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>
#include <qtypes.h>

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

    bool operator==(const ApplicationEntryAction& other) const;
    bool operator!=(const ApplicationEntryAction& other) const;
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

    bool operator==(const ApplicationEntry& other) const;
    bool operator!=(const ApplicationEntry& other) const;
};

class ApplicationsPlugin : public LauncherPlugin {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QList<Shiny::Launcher::Plugins::ApplicationEntry> applications READ default WRITE default NOTIFY applicationsChanged BINDABLE bindableApplications REQUIRED)
    Q_PROPERTY(QString terminalCommand READ default WRITE default NOTIFY terminalCommandChanged BINDABLE bindableTerminalCommand)
    Q_PROPERTY(bool useSystemd READ default WRITE default NOTIFY useSystemdChanged BINDABLE bindableUseSystemd)
    Q_PROPERTY(qreal scoreThreshold READ scoreThreshold WRITE setScoreThreshold NOTIFY scoreThresholdChanged)
    Q_PROPERTY(qreal scorePrefixBoost READ scorePrefixBoost WRITE setScorePrefixBoost NOTIFY scorePrefixBoostChanged)
    // clang-format on

public:
    explicit ApplicationsPlugin(QObject* parent = nullptr);

    QString name() const override;
    int priority() const override;
    bool canActivate(const QString& input) const override;
    void filter(const QString& input, qsizetype max) override;

    QBindable<QList<ApplicationEntry>> bindableApplications();

    QBindable<QString> bindableTerminalCommand();

    QBindable<bool> bindableUseSystemd();

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
    qreal m_scoreThreshold = 0.6;
    qreal m_scorePrefixBoost = 0.12;

    // clang-format off
    Q_OBJECT_BINDABLE_PROPERTY(ApplicationsPlugin, QList<ApplicationEntry>, b_applications, &ApplicationsPlugin::applicationsChanged)
    Q_OBJECT_BINDABLE_PROPERTY(ApplicationsPlugin, QString, b_terminalCommand, &ApplicationsPlugin::terminalCommandChanged)
    Q_OBJECT_BINDABLE_PROPERTY_WITH_ARGS(ApplicationsPlugin, bool, b_useSystemd, false, &ApplicationsPlugin::useSystemdChanged)
    // clang-format on

    void invoke(const ApplicationEntry& entry) const;
};

} // namespace Shiny::Launcher::Plugins
