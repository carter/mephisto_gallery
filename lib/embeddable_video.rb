require 'uri'
require 'open-uri'
require 'hpricot'
require 'RMagick'
require 'fileutils'

class EmbeddableVideo
  def initialize(url)
    @url = url
  end
  
  def thumbnail_url
    if provider == 'vimeo.com'
      doc = Hpricot(open(@url))
      elements = (doc/"link[@rel='videothumbnail']")
      if elements.length > 0
        return elements.first.attributes['href']
      else
        return false
      end
    elsif provider.match(/techtv.mit.edu/)
      open(@url) do |file|
        file.each_line do |line|
          match = line.match(/window.player.setThumbnail\("(.*)"\)/)
          return match[1] if match
        end
      end
    end
  end
  
  def source_video_url
    if provider.match(/techtv.mit.edu/)
      open(@url) do |file|
        file.each_line do |line|
          match = line.match(/window.player.setPrimaryMediaUrl\("(.*)"\)/)
          return match[1] if match
        end
      end
    end
  end
  
  def save_thumbnail(location, dimensions=nil)
    puts "Thumbnailing.. #{location}"
    dir = File.dirname(location)
    FileUtils.mkdir_p(dir) unless File.exists?(dir)
    large = Magick::Image.read(self.thumbnail_url).first
    
    if dimensions
      thumb = ""
      large.change_geometry!(dimensions) { |cols, rows, img|
        thumb = img.resize(cols, rows)
      }
      if thumb.write(location)
        return location
      else
        return false
      end
    else
      if large.write(location)
        return location
      else
        return false
      end
    end
  end
  
  # Returns the hostname of the embedded video provider without a www.
  def provider
    uri = URI.parse(@url)
    if uri.host =~ /www.(.*)/
      return  /www\.(.*)\//.match(uri.to_s)[1]
    else
      return uri.host
    end
  end
  
  def unique_id
    uri = URI.parse(@url)
    if provider.match(/vimeo.com/)
      return uri.path[1..-1]
    elsif provider.match(/techtv.mit.edu/)
      return uri.path.match(/\/file\/(\w*)(\/?)/)[1]
    end
  end
  
  def embed_code(width=640, height=480)
    if provider == "vimeo.com"
      return "<object type=\"application/x-shockwave-flash\" width=\"#{width}\" height=\"#{height}\" data=\"http://vimeo.com/moogaloop.swf?clip_id=#{unique_id}&amp;server=vimeo.com&amp;fullscreen=1&amp;show_title=1&amp;show_byline=1&amp;show_portrait=1&amp;color=00ADEF\">	<param name=\"quality\" value=\"best\" />	<param name=\"allowfullscreen\" value=\"true\" />	<param name=\"scale\" value=\"showAll\" />	<param name=\"movie\" value=\"http://vimeo.com/moogaloop.swf?clip_id=#{unique_id}&amp;server=vimeo.com&amp;fullscreen=1&amp;show_title=1&amp;show_byline=1&amp;show_portrait=1&amp;color=00ADEF\" /></object>"
    elsif provider.match(/techtv.mit.edu/)
      return "<embed wmode=\"transparent\" src=\"http://techtv.mit.edu/scripts/flash/blipplayer.swf?autoStart=false&file=#{source_video_url}\" quality=\"high\" width=\"#{width}\" height=\"#{height}\" name=\"movie\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\"></embed>"
    end
  end
end
