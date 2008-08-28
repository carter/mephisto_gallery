class AlbumDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  
  timezone_dates :created_at, :updated_at
  liquid_attributes << :title << :permalink << :description
  
  def initialize(source, options = {})
    super source
    @options  = options
  end

  def assets
    @assets ||= liquify(*@source.assets)
  end
  
  def url
    @url ||= "#{@source.gallery_section.url}/#{@source.permalink}"
  end
  
  def cover
    @cover ||= @source.cover.public_filename(:thumb)
  end
end