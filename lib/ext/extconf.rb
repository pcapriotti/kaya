# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'mkmf'

$CPPFLAGS += " -I/usr/include/qt4/QtCore -I/usr/include/qt4/QtGui -I/usr/include/qt4/"
$LOCAL_LIBS += " -lQtCore -lstdc++"
create_makefile("extensions")
exec "moc-qt4 -o moc_extensions.cpp extensions.h"
