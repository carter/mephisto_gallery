class GallerySection < ActiveRecord::Base
  has_many :albums, :order => 'order_by'
  belongs_to :site
  has_permalink :name
  
  def to_liquid(options = {})
    GallerySectionDrop.new self, options
  end
  
  def layout
    "gallery_layout.liquid"
  end
  
  def url
    "/gallery/#{permalink}"
  end
end