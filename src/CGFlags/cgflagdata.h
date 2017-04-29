#ifndef CGFLAGDATA_H
#define CGFLAGDATA_H

#include <QObject>

class CGFlagData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString country READ country WRITE setCountry NOTIFY countryChanged MEMBER mCountry)
public:
    explicit CGFlagData(QObject *parent = 0);
    void setCountry(QString country);
    QString country();
signals:
    void countryChanged(QString country);
public slots:

protected:
    QString mCountry;

};

#endif // CGFLAGDATA_H
