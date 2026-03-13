foreach(dir assets components config layers services utils)
    install(DIRECTORY ${dir} DESTINATION "${INSTALL_SHELL}")
endforeach()

install(FILES shell.qml greeter.qml DESTINATION "${INSTALL_SHELL}")
