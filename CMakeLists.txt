project(kaya)
cmake_minimum_required(VERSION 2.6)

find_package(KDE4 REQUIRED)
include(KDE4Defaults)
add_subdirectory(lib)
add_subdirectory(translations)

configure_file(main.rb main.rb)

install(DIRECTORY lib DESTINATION ${DATA_INSTALL_DIR}/kaya
  FILES_MATCHING PATTERN "*.rb"
  PATTERN "plugins" EXCLUDE)
install(DIRECTORY lib/plugins DESTINATION ${DATA_INSTALL_DIR}/kaya/lib)
install(FILES ${PROJECT_BINARY_DIR}/main.rb
        DESTINATION ${BIN_INSTALL_DIR}
        PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        RENAME kaya)

