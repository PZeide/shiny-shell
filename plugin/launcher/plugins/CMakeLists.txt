find_package(rapidfuzz REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(Qalculate IMPORTED_TARGET libqalculate REQUIRED)

qml_module(shiny-launcher-plugins
    URI Shiny.Launcher.Plugins
    SOURCES
        applications.hpp applications.cpp
        calculator.hpp calculator.cpp
        websearch.hpp websearch.cpp
    LIBRARIES
        shiny-launcher
        rapidfuzz::rapidfuzz
        PkgConfig::Qalculate
    DEPENDENCIES
        Shiny.Launcher
)
