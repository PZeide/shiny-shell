qml_module(shiny-launcher
    URI Shiny.Launcher
    SOURCES
        delegate.hpp delegate.cpp
        item.hpp item.cpp
        plugin.hpp plugin.cpp
)

add_subdirectory(plugins)
