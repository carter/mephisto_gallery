class GallerySectionDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  
  timezone_dates :created_at, :updated_at
  liquid_attributes << :name << :permalink
  
  def initialize(source, options = {})
    super source
    @options  = options
  end

  def albums
    @assets ||= liquify(*@source.albums)
  end
  
  def url
    @url ||= "/gallery/#{@source.permalink}"
  end
end