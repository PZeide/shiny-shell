qml_module(shiny-booru
    URI Shiny.Booru
    SOURCES
        data.hpp data.cpp
        provider.hpp provider.cpp
    LIBRARIES
        Qt::Network
        Qt::Sql
)

add_subdirectory(providers)
