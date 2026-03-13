set_source_files_properties(org.freedesktop.login1.Manager.xml PROPERTIES
    CLASSNAME DBusLogin1Manager
    NO_NAMESPACE TRUE
)

set_source_files_properties(org.freedesktop.login1.Session.xml PROPERTIES
    CLASSNAME DBusLogin1Session
    NO_NAMESPACE TRUE
)

qt_add_dbus_interface(DBUS_INTERFACES
    org.freedesktop.login1.Manager.xml
    dbus_manager
)

qt_add_dbus_interface(DBUS_INTERFACES
    org.freedesktop.login1.Session.xml
    dbus_session
)

qml_module(shiny-shell-session
    URI Shiny.Session
    SOURCES
        core.hpp core.cpp
        inhibitor.hpp inhibitor.cpp
        ${DBUS_INTERFACES}
    LIBRARIES
        Qt::DBus
)

target_include_directories(shiny-shell-session PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
