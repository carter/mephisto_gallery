class CopyLiquidTemplates < ActiveRecord::Migration
  def self.up
    FileUtils.cp(File.join(RAILS_ROOT, 'vendor', 'plugins', 'mephisto_gallery', 'templates', 'album.liquid'), File.join(RAILS_ROOT, 'themes', 'site-1', 'simpla', 'templates'))
    FileUtils.cp(File.join(RAILS_ROOT, 'vendor', 'plugins', 'mephisto_gallery', 'templates', 'gallery.liquid'), File.join(RAILS_ROOT, 'themes', 'site-1', 'simpla', 'templates'))
  end
  
  def self.down
    
  end
end