set_source_files_properties(org.freedesktop.portal.Screenshot.xml PROPERTIES
    CLASSNAME DBusPortalScreenshot
    NO_NAMESPACE TRUE
)

qt_add_dbus_interface(DBUS_INTERFACES
    org.freedesktop.portal.Screenshot.xml
    dbus_screenshot
)

qml_module(shiny-shell-screenshot
    URI Shiny.Screenshot
    SOURCES
        manager.hpp manager.cpp
        ${DBUS_INTERFACES}
    LIBRARIES
        Qt::DBus
)

target_include_directories(shiny-shell-screenshot PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
