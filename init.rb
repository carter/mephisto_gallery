require File.join(lib_path, 'asset_extension.rb')
require File.join(lib_path, 'asset_drop_extension.rb')

add_tab 'Gallery', '/admin/gallery'
#require File.join(lib_path, 'site_hack.rb')

# require all drops
Dir.glob(File.join(File.dirname(__FILE__), 'drops/*.rb')).each {|f| require f }