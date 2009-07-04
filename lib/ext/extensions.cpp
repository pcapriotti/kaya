// Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.

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
