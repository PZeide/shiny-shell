qml_module(shiny-services
    URI Shiny.Services
    SOURCES
        backgroundremoval.hpp backgroundremoval.cpp
        brightness.hpp brightness.cpp
        location.hpp location.cpp
        weather.hpp weather.cpp
    LIBRARIES
        Qt::Network
)

