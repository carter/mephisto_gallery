require 'ostruct'

class GalleryController < ApplicationController
  unloadable
  
  layout false
  def index
    @gallery_section = GallerySection.find(:first, :conditions => {:site_id => site.id}, :order => 'order_by')
    redirect_to :action => 'section', :section => @gallery_section.permalink
  end
  
  def section
    @gallery_sections = GallerySection.find(:all, :conditions => {:site_id => site.id}, :order => 'order_by')
    @gallery_section = GallerySection.find(:first, :conditions => {:permalink => params[:section], :site_id => site.id})
    template = File.join(RAILS_ROOT, 'themes', "site-#{site.id}", site.theme.name, 'templates', "gallery.liquid")
    
    if @gallery_section.albums.length == 1 || !File.exists?(template)
      redirect_to :action => 'show', :section => @gallery_section.permalink, :album => @gallery_section.albums.first.permalink
    else
      render_liquid_template_for(:gallery, 'gallery_section' => @gallery_section, 'gallery_sections' => @gallery_sections)
    end
  end
  
  def show
    @gallery_sections = GallerySection.find(:all, :conditions => {:site_id => site.id}, :order => 'order_by')
    @album = Album.find(:first, :conditions => {:permalink => params[:album], :site_id => site.id})
    @media = Asset.paginate_by_album_id(@album.id, :page => params[:page], :per_page => @album.items_per_page, :order => 'album_order')
    section_layout = File.join(RAILS_ROOT, 'themes', "site-#{site.id}", site.theme.name, 'layouts', "#{@album.permalink}_layout.liquid")
    
    @section = OpenStruct.new
    if File.exists?(section_layout) || request.xhr?
      if request.xhr?
        @section.layout = File.join(RAILS_ROOT, 'themes', "site-#{site.id}", site.theme.name, 'layouts', "blank.liquid")
      else
        @section.layout = section_layout
      end
    end
    
    pages = Array.new(@media.page_count)    
    if request.xhr?
      render_liquid_template_for(:thumbnails, 'album' => @album, 'media' => @media, 'gallery_sections' => @gallery_sections, 'next_page' => @media.next_page, 'previous_page' => @media.previous_page, 'current_page' => @media.current_page)
    else
      render_liquid_template_for(:album, 'album' => @album, 'media' => @media, 'gallery_sections' => @gallery_sections, 'gallery_section' => @album.gallery_section, 'next_page' => @media.next_page, 'previous_page' => @media.previous_page, 'current_page' => @media.current_page, 'page_count' => @media.page_count, 'pages' => pages)
    end
  end
  
  def show_video
    @asset = Asset.find(params[:id])
    @video = EmbeddableVideo.new(@asset.video_url)
  end
end
