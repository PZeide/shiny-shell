qml_module(shiny-dbus
    URI Shiny.DBus
    SOURCES
        logindhandler.hpp logindhandler.cpp
    LIBRARIES
        Qt::DBus
)
