find_package(Qt6 REQUIRED COMPONENTS Core Qml Gui Sql Network)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")
qt_standard_project_setup(REQUIRES 6.10)

function(qml_module arg_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URI" "SOURCES;LIBRARIES;DEPENDENCIES")

    qt_add_qml_module(${arg_TARGET}
        URI ${arg_URI}
        VERSION ${CMAKE_PROJECT_VERSION}
        SOURCES ${arg_SOURCES}
        DEPENDENCIES ${arg_DEPENDENCIES}
    )

    qt_query_qml_module(${arg_TARGET}
        URI module_uri
        VERSION module_version
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
    )

    message(STATUS "Created QML module ${module_uri}, version ${module_version}")
    set(module_dir "${INSTALL_PLUGIN}/${module_target_path}")
    install(TARGETS ${arg_TARGET} LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}")
    install(TARGETS "${module_plugin_target}" LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}")
    install(FILES "${module_qmldir}" DESTINATION "${module_dir}")
    install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")

    target_link_libraries(${arg_TARGET} PRIVATE Qt::Core Qt::Gui Qt::Qml ${arg_LIBRARIES})
endfunction()


add_subdirectory(launcher)
add_subdirectory(services)
