qt_dep = dependency(
  'qt6',
  modules: ['Core', 'Qml', 'Gui', 'Quick', 'Concurrent', 'Sql'],
)

inc = include_directories('.')

sources = files('fuzzy.cpp')

moc_headers = files('fuzzy.hpp')

plugin_install_dir_opt = get_option('plugin-install-dir')
if plugin_install_dir_opt != ''
  plugin_install_dir = plugin_install_dir_opt
else
  plugin_install_dir = meson.current_build_dir() / 'qml'
endif

shared_library(
  'shiny-plugin',
  sources,
  version: '1.0',
  dependencies: qt_dep,
  include_directories: inc,
  install: true,
  install_dir: plugin_install_dir / 'Shiny',
)

qt = import('qt6')
qml_mod = qt.qml_module(
  'Shiny',
  version: '1.0',
  include_directories: inc,
  moc_headers: moc_headers,
  install: true,
  install_dir: plugin_install_dir,
)
