#pragma once

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusUnixFileDescriptor>
#include <QLoggingCategory>
#include <QObject>
#include <QProperty>
#include <QQmlEngine>
#include <QStringView>
#include <QtQmlIntegration>

namespace Shiny::DBus {
  Q_DECLARE_LOGGING_CATEGORY(logSleepInhibitor)

  class SleepInhibitor : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(bool active READ default WRITE default NOTIFY activeChanged BINDABLE bindableActive)
    Q_PROPERTY(QString description READ default WRITE default BINDABLE bindableDescription REQUIRED FINAL)
    // clang-format on

  public:
    explicit SleepInhibitor(QObject* parent = nullptr);
    ~SleepInhibitor() override = default;

    [[nodiscard]] QBindable<bool> bindableActive() const;
    [[nodiscard]] QBindable<QString> bindableDescription() const;

  signals:
    void activeChanged();
    void descriptionChanged();

  private slots:

  private:
    QDBusConnection m_connection{QDBusConnection::systemBus()};
    QString m_sessionPath{};

    // clang-format off
    Q_OBJECT_BINDABLE_PROPERTY(SleepInhibitor, bool, b_active, &SleepInhibitor::activeChanged)
    Q_OBJECT_BINDABLE_PROPERTY(SleepInhibitor, QString, b_description, &SleepInhibitor::descriptionChanged)
    // clang-format on
  };
}
