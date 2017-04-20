#include "cgprofile.h"

CGProfile::CGProfile(QQuickItem *parent) : QQuickItem(parent)
{
    mServer = CG_SERVER_S();
}


CGProfile::~CGProfile()
{

}
