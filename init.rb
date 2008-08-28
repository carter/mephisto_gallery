require File.join(lib_path, 'plugin')
require File.join(lib_path, 'asset_drop.rb')
require File.join(lib_path, 'asset_extension.rb')
config.controller_paths << (Mephisto::Plugins::Gallery.plugin_path + 'lib').to_s
Mephisto::Plugins::Gallery.public_controller 'Gallery', 'gallery'
Mephisto::Plugins::Gallery.admin_controller 'Gallery', 'gallery'