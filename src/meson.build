koboreadingstats_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
]

koboreadingstats_deps = [
  config_dep,
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
]

blueprints = custom_target('blueprints',
  input: files(
    'gtk/help-overlay.blp',
    'window.blp',
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

koboreadingstats_sources += gnome.compile_resources('koboreadingstats-resources',
  'koboreadingstats.gresource.xml',
  c_name: 'koboreadingstats',
  dependencies: blueprints,
  source_dir: meson.current_build_dir()
)

executable('koboreadingstats', koboreadingstats_sources,
  dependencies: koboreadingstats_deps,
  include_directories: config_inc,
       install: true,
)
