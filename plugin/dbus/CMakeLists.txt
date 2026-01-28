qml_module(shiny-dbus
    URI Shiny.DBus
    SOURCES
        geoclueagent.hpp geoclueagent.cpp
        loginmanager.hpp loginmanager.cpp
        sleepinhibitor.hpp sleepinhibitor.cpp
    LIBRARIES
        Qt::DBus
)
