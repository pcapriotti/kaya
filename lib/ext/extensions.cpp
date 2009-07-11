// Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.

#include "extensions.h"

#include <QCoreApplication>
#include <kdemacros.h>
#include <ruby.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

Extensions::Extensions(QObject* parent)
: QObject(parent) { }

static void init() 
{
    Extensions* ext = new Extensions(QCoreApplication::instance());
    ext->setObjectName("kaya extensions");
}

#ifdef RUBY_EXCEPTIONS_ONLY
static void crash_handler(int)
{
    rb_raise(rb_eException, "Native code crash!");
}
#endif

extern "C" KDE_EXPORT void Init_extensions() {
    init();

#ifdef RUBY_EXCEPTIONS_ONLY
    signal(SIGSEGV, crash_handler);
#endif
}
