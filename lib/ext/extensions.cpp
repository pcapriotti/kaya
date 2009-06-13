#include "extensions.h"

#include <QCoreApplication>

Extensions::Extensions(QObject* parent)
: QObject(parent) { }

static void init() 
{
    Extensions* ext = new Extensions(QCoreApplication::instance());
    ext->setObjectName("kaya extensions");
}

extern "C" {

void Init_extensions() {
    init();
}

};
