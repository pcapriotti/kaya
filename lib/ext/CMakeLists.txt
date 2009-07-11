find_package(Qt4 REQUIRED)
find_package(Ruby REQUIRED)

option(RUBY_BACKTRACE
  "Display a ruby backtrace for exceptions originating in native code"
  OFF)

if(RUBY_BACKTRACE)
  add_definitions("-DRUBY_EXCEPTIONS_ONLY")
endif(RUBY_BACKTRACE)

add_definitions(${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(${KDE4_INCLUDES} ${RUBY_INCLUDE_PATH})

set(src extensions.cpp expblur.cpp)
qt4_wrap_cpp(src extensions.h)
add_library(extensions SHARED ${src})
set_target_properties(extensions PROPERTIES PREFIX "")

target_link_libraries(extensions ${QT_QTCORE_LIBRARY} ${QT_QTGUI_LIBRARY} ${RUBY_LIBRARY})

install(TARGETS extensions DESTINATION ${DATA_INSTALL_DIR}/kaya/lib/ext)



