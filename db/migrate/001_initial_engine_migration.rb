class InitialEngineMigration < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :albums
    drop_table :gallery_sections
    remove_column "assets", "album_id"
    remove_column "assets", "album_order"
    remove_column "assets", "video_url"
  end
end