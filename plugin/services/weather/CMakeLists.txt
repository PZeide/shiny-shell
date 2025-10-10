qml_module(shiny-services-weather
    URI Shiny.Services.Weather
    SOURCES
        provider.hpp provider.cpp
        data.hpp data.cpp
    LIBRARIES
        Qt::Network
)
