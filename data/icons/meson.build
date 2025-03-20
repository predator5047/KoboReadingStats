application_id = 'org.butiu.koboreadingstats'

#scalable_dir = 'hicolor' / 'scalable' / 'apps'


#install_data(
#  scalable_dir / ('@0@.png').format(application_id),
#  install_dir: get_option('datadir') / 'icons' / scalable_dir
#)

symbolic_dir = 'hicolor' / 'symbolic' / 'apps'
install_data(
  symbolic_dir / ('@0@-symbolic.svg').format(application_id),
  install_dir: get_option('datadir') / 'icons' / symbolic_dir
)


dir_256 = 'hicolor' / '256x256'

install_data(
   dir_256 / ('@0@.png').format(application_id),
  install_dir: get_option('datadir') / 'icons' / dir_256
)

