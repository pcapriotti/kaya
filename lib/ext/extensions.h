#include <QObject>

class QImage;

class Extensions : public QObject {
Q_OBJECT
public:
  explicit Extensions(QObject* parent);
public slots:
  void exp_blur(QImage* img, int radius) const;
};
