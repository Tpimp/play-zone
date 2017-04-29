#include "cgflagdata.h"

CGFlagData::CGFlagData(QObject *parent) : QObject(parent)
{

}


QString CGFlagData::country()
{
    return mCountry;

}

void CGFlagData::setCountry(QString country)
{
    if(country.compare(mCountry) != 0){
        mCountry = country;
        emit countryChanged(mCountry);
    }
}
