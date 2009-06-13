require 'mkmf'

$CPPFLAGS += " -I/usr/include/qt4/QtCore -I/usr/include/qt4/QtGui -I/usr/include/qt4/"
$LOCAL_LIBS += " -lQtCore -lstdc++"
create_makefile("extensions")
exec "moc-qt4 -o moc_extensions.cpp extensions.h"
