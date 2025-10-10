qml_module(shiny-services-location
    URI Shiny.Services.Location
    SOURCES
        provider.hpp provider.cpp
        data.hpp data.cpp
    LIBRARIES
        Qt::Network
)
