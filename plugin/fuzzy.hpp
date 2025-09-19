#include <QtCore/qcontainerfwd.h>
#include <QtCore/qobject.h>
#include <QtCore/qtmetamacros.h>
#include <QtQmlIntegration/qqmlintegration.h>

namespace Shiny {

  class Fuzzy : public QObject {
    Q_OBJECT;
    QML_SINGLETON;
    QML_NAMED_ELEMENT(Fuzzy);

  public:
    Q_INVOKABLE int score(const QString& input, const QString& target);

  private:
    Fuzzy(QObject* parent = nullptr);
  };

} // namespace Shiny
