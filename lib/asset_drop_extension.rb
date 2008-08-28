require File.join(RAILS_ROOT, 'app/drops/asset_drop.rb')

class AssetDrop < BaseDrop
  def title
    @title ||= @source.title
  end
  
  def thumb_url
    @thumb_url ||= @source.public_filename(:thumb)
  end
  
  def medium_url
    if @source.is_embeddable_video?
      @medium_url ||= "/gallery/show_video/#{@source.id}"
    else
      @medium_url ||= @source.public_filename(:medium)
    end
  end
  
  def bb_large
    @bb_large ||= @source.public_filename(:bb_large)
  end
  
  def bb_thumb
    @bb_thumb ||= @source.public_filename(:bb_thumb)
  end
  
  def lalli_large
    if @source.width > @source.height
      return @lalli_large ||= @source.public_filename(:lalli_landscape)
    else
      return @lalli_large ||= @source.public_filename(:lalli_portrait)
    end
  end
  
  def lalli_thumb
    @lalli_thumb ||= @source.public_filename(:lalli_thumb)
  end
  
  def orientation
    @orientation ||= @source.orientation
  end
  
  def is_video
    if @source.is_embeddable_video?
      @is_video ||= true
    else
      @is_video ||= false
    end
  end
end