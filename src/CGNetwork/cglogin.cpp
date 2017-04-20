#include "cglogin.h"

CGLogin::CGLogin(QQuickItem *parent) : QQuickItem(parent)
{
    mServer = CG_SERVER_S();
}

CGLogin::~CGLogin()
{

}
