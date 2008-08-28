require File.join(RAILS_ROOT, 'app/models/asset.rb')

class Asset < ActiveRecord::Base
  after_attachment_saved do |record|
    if !File.exist?(record.full_filename(:medium))
      record.generate_video_thumbnail
    end
  end
  has_attachment :storage => :file_system, :thumbnails => { 
    :medium => '640x480>', 
    :thumb => '120>', 
    :bb_thumb => '68x57!', 
    :bb_large => '535x645>', 
    :lalli_thumb => '100x69!', 
    :lalli_landscape => '570x390!', 
    :lalli_portrait => '350x505!', 
    :tiny => '50>' }, 
    :max_size => 50.megabytes, 
    :processor => :rmagick
  
  def is_embeddable_video?
    video_url
  end
  
  def video?
    content_type.match(/video\//)
  end
  
  def generate_video_thumbnail(offset=2)
    if video?
      [{:size => :bb_thumb, :dimensions => "68x57!"}, {:size => :lalli_thumb, :dimensions => "100x69!"}].each do |h|
        system("ffmpeg -i #{full_filename} -y -vframes 1 -ss #{offset} -f mjpeg /tmp/video_thumbnail.jpg")
        large = Magick::Image.read('/tmp/video_thumbnail.jpg').first
        large.change_geometry(h[:dimensions]) { |cols, rows, image| image.crop_resized!(cols, rows) }
	large.write(full_filename(h[:size]))
        thumb = Asset.new
        thumb.filename = full_filename(h[:size])
        thumb.content_type = "image/jpeg"
        thumb.thumbnail = h[:size].to_s
        thumb.parent_id = self.id
        thumb.site_id = self.site_id
        thumb.save
      end
    end
  end
  
  # makes much better video thumbnails because it can actually use .jpg
  def thumbnail_name_for(thumbnail = nil)
    return filename if thumbnail.blank?
    ext = nil
    basename = filename.gsub /\.\w+$/ do |s|
      ext = s; ''
    end
    if video?
      ext = '.jpg'
    end
    "#{basename}_#{thumbnail}#{ext}"
  end
  
  def regenerate_thumbs()
      temp_file = self.create_temp_file
      self.attachment_options[:thumbnails].each { |suffix, size|
        t = self.create_or_update_thumbnail(temp_file, suffix, *size)
        t.save_to_storage
      }
  end
  
  def orientation
    return "landscape" if width >= height
    return "portrait" if height > width
  end
end

# implements cropped resizing
module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module RmagickProcessor
        # Performs the actual resizing operation for a thumbnail
        def resize_image(img, size)
          size = size.first if size.is_a?(Array) && size.length == 1 && !size.first.is_a?(Fixnum)
          if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
            size = [size, size] if size.is_a?(Fixnum)
            img.crop_resized!(*size)
          else
            img.change_geometry(size.to_s) { |cols, rows, image| image.crop_resized!(cols, rows) }
          end
          self.temp_path = write_to_temp_file(img.to_blob)
        end
      end
    end
  end
end
