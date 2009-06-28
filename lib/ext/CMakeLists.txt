find_package(Qt4 REQUIRED)
find_package(Ruby REQUIRED)

add_definitions(${QT_DEFINITIONS})
include_directories(${QT_INCLUDES})


set(src extensions.cpp expblur.cpp)
qt4_wrap_cpp(src extensions.h)
add_library(extensions SHARED ${src})
set_target_properties(extensions PROPERTIES PREFIX "")


message("lib: ${QT_QTGUI_LIBRARY}")
target_link_libraries(extensions ${QT_QTCORE_LIBRARY} ${QT_QTGUI_LIBRARY})

# install(TARGETS ksimple DESTINATION bin)



