project(kaya)
cmake_minimum_required(VERSION 2.6)

find_package(KDE4 REQUIRED)
include(KDE4Defaults)
add_subdirectory(lib)


configure_file(main.rb main.rb)

install(DIRECTORY lib DESTINATION ${DATA_INSTALL_DIR}/kaya
  PATTERN "*rc" EXCLUDE
  PATTERN "*.desktop" EXCLUDE)
install(FILES ${PROJECT_BINARY_DIR}/main.rb
        DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
        PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        RENAME kaya)
