cmake_minimum_required(VERSION 3.20)

project(shiny-shell LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(ENABLE_MODULES "shell;plugin" CACHE STRING "Modules to build/install")
set(INSTALL_SHELL "/etc/xdg/quickshell/shiny-shell" CACHE STRING "Installation directory of the shell")
set(INSTALL_PLUGIN "/usr/lib/qt6/qml" CACHE STRING "Installation directory of the plugin")

add_compile_options(-Wall -Wextra -Wpedantic)

if("plugin" IN_LIST ENABLE_MODULES)
    add_subdirectory(plugin)
endif()

if("shell" IN_LIST ENABLE_MODULES)
    foreach(dir assets config layers scripts services utils widgets)
        install(DIRECTORY ${dir} DESTINATION "${INSTALL_SHELL}")
    endforeach()

    install(FILES shell.qml DESTINATION "${INSTALL_SHELL}")
endif()
