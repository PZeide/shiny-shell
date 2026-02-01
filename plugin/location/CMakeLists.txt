qml_module(shiny-shell-location
    URI Shiny.Location
    SOURCES
      geoclue-agent.hpp geoclue-agent.cpp
    LIBRARIES
        Qt::DBus
)
