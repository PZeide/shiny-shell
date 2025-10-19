#pragma once

#include <memory>
#include <optional>
#include <qdir.h>
#include <qfilesystemwatcher.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtimer.h>
#include <qtmetamacros.h>

namespace Shiny::Services {
  Q_DECLARE_LOGGING_CATEGORY(logBrightness)

  const QString SYS_BACKLIGHT = "/sys/class/backlight/";
  constexpr int BRIGHTNESS_SMOOTH_INTERVAL_MSECS = 20;
  constexpr double BRIGHTNESS_GAMMA = 2.2;

  class BrightnessController : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(QString controller READ controller WRITE setController NOTIFY controllerChanged)
    Q_PROPERTY(qreal value READ value NOTIFY valueChanged)
    Q_PROPERTY(qreal naturalValue READ naturalValue NOTIFY valueChanged)
    // clang-format on

  public:
    explicit BrightnessController(QObject* parent = nullptr);

    bool available() const;

    QString controller() const;
    void setController(QString controller);

    qreal value() const;
    Q_INVOKABLE void setValue(qreal value);
    Q_INVOKABLE void setValueSmooth(qreal value, int durationMsecs);

    qreal naturalValue() const;
    Q_INVOKABLE void setNaturalValue(qreal naturalValue);
    Q_INVOKABLE void setNaturalValueSmooth(qreal naturalValue, int durationMsecs);

  signals:
    void availableChanged();
    void controllerChanged();
    void valueChanged();

  private slots:
    void brightnessFileChanged();

  private:
    std::optional<QDir> m_controllerDir;
    QFileSystemWatcher m_brightnessWatcher;
    int m_maxRawValue = 0;
    int m_rawValue = 0;
    std::unique_ptr<QTimer> m_smoothTimer;

    bool setupController(QDir controllerDir);
    void reset();

    static std::optional<int> readBrightness(QDir& controllerDir);
    static std::optional<int> readMaxBrightness(QDir& controllerDir);
    static std::optional<QDir> preferredController();
  };
}
