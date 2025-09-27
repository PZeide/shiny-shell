find_package(Qt6 REQUIRED COMPONENTS Core Qml Gui Quick Sql)
find_package(rapidfuzz REQUIRED)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")
qt_standard_project_setup(REQUIRES 6.9)

function(qml_module arg_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URI" "SOURCES;LIBRARIES")

    qt_add_qml_module(${arg_TARGET}
        URI ${arg_URI}
        VERSION 1.0.0
        SOURCES ${arg_SOURCES}
    )

    qt_query_qml_module(${arg_TARGET}
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
    )

    set(module_dir "${INSTALL_PLUGIN}/${module_target_path}")
    install(TARGETS ${arg_TARGET} LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}")
    install(TARGETS "${module_plugin_target}" LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}")
    install(FILES "${module_qmldir}" DESTINATION "${module_dir}")
    install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")

    target_link_libraries(${arg_TARGET} PRIVATE Qt::Core Qt::Qml ${arg_LIBRARIES})
endfunction()

qml_module(shiny
    URI Shiny
    SOURCES
        fuzzyengine.hpp fuzzyengine.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Sql
        rapidfuzz::rapidfuzz
)
