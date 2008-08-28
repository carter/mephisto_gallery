class Album < ActiveRecord::Base
  has_many :assets, :order => 'album_order'
  belongs_to :site
  belongs_to :gallery_section
  belongs_to :cover, :class_name => 'Asset', :foreign_key => 'cover_id'
  has_permalink :title
  
  def to_liquid(options = {})
    AlbumDrop.new self, options
  end
end