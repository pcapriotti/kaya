#include "extensions.h"

#include <QCoreApplication>
#include <kdemacros.h>

Extensions::Extensions(QObject* parent)
: QObject(parent) { }

static void init() 
{
    Extensions* ext = new Extensions(QCoreApplication::instance());
    ext->setObjectName("kaya extensions");
}

extern "C" KDE_EXPORT void Init_extensions() {
    init();
}
