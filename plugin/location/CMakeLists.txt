qml_module(shiny-shell-location
    URI Shiny.Location
    SOURCES
      geoclue-agent.hpp geoclue-agent.cpp
      geoclue-agent-registration.cpp
    QML_FILES
      GeoclueAgent.qml
      GeoclueAgentExample.qml
      qmldir
    LIBRARIES
        Qt::DBus
)
