module Mephisto
  module Plugins
    class Gallery < Mephisto::Plugin
      author 'Carter Parks'
      version '0.1'
      notes "Shows your assets (photos and video) grouped into albums"
    
      # options 
      #option :no_feedback_msg, "You don't seem to have any feedback."
      #option :destroy_msg,     "Feedback deleted."
      #option :clear_msg,       "All feedback has been cleared."
    
      add_route '/gallery', :controller => 'gallery'
      add_route '/gallery/show_video/:id', :controller => 'gallery', :action => 'show_video'
      add_route '/gallery/:section', :controller => 'gallery', :action => 'section'
      add_route '/gallery/:section/:album', :controller => 'gallery', :action => 'show'
      add_route '/gallery/:section/:album/:page', :controller => 'gallery', :action => 'show'

	add_route '/photography', :controller => 'gallery', :action => 'show', :album => 'photography'
	add_route '/commercials', :controller => 'gallery', :action => 'show', :album => 'commercials'

      class Schema < ActiveRecord::Migration
        def self.install
          create_table :albums do |t|
            t.column :site_id, :integer
            t.column :title, :string
            t.column :description, :text
            t.column :permalink, :string
            t.column :gallery_section_id, :integer
            t.column :cover_id, :integer
            t.column :created_at, :datetime
            t.column :updated_at, :datetime
            t.column :order_by, :integer
            t.column :items_per_page, :integer
          end
          
          create_table :gallery_sections do |t|
            t.column :name, :string
            t.column :permalink, :string
            t.column :order_by, :integer
            t.column :site_id, :integer
          end
          
          add_column "assets", "album_id", :integer
          add_column "assets", "album_order", :integer
          add_column "assets", "video_url", :string
        end
        
        def self.uninstall
          drop_table :albums
          drop_table :gallery_sections
          remove_column "assets", "album_id"
          remove_column "assets", "album_order"
          remove_column "assets", "video_url"
        end
      end
    end
  end
end
