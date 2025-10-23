qml_module(shiny-booru-providers
    URI Shiny.Booru.Providers
    SOURCES
        gelbooru.hpp gelbooru.cpp
        konanchan.hpp konanchan.cpp
    LIBRARIES
        shiny-booru
        Qt::Network
    DEPENDENCIES
        Shiny.Booru
)
