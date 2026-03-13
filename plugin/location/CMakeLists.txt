set_source_files_properties(org.freedesktop.GeoClue2.Client.xml PROPERTIES
    CLASSNAME DBusGeoClue2Client
    NO_NAMESPACE TRUE
)

set_source_files_properties(org.freedesktop.GeoClue2.Location.xml PROPERTIES
    CLASSNAME DBusGeoClue2Location
    NO_NAMESPACE TRUE
)

set_source_files_properties(org.freedesktop.GeoClue2.Manager.xml PROPERTIES
    CLASSNAME DBusGeoClue2Manager
    NO_NAMESPACE TRUE
)

qt_add_dbus_interface(DBUS_INTERFACES
    org.freedesktop.GeoClue2.Client.xml
    dbus_client
)

qt_add_dbus_interface(DBUS_INTERFACES
    org.freedesktop.GeoClue2.Location.xml
    dbus_location
)

qt_add_dbus_interface(DBUS_INTERFACES
    org.freedesktop.GeoClue2.Manager.xml
    dbus_manager
)

qml_module(shiny-shell-location
    URI Shiny.Location
    SOURCES
        provider.hpp provider.cpp
        location.hpp location.cpp
        ${DBUS_INTERFACES}
    LIBRARIES
        Qt::Network
        Qt::DBus
)

target_include_directories(shiny-shell-location PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
