module Admin
  class GalleryController < Admin::BaseController
      
    def index
      @albums = Album.paginate(:page => params[:page], :conditions => {:site_id => site.id}, :order => 'order_by')
      @sections = GallerySection.find(:all, :conditions => {:site_id => site.id})
    end
    
    def new
      @album = Album.new
      @sections = GallerySection.find(:all, :conditions => {:site_id => site.id})
    end
    
    def create
      @album = Album.new(params[:album])
      @album.site_id = site.id
      if @album.save
        flash[:notice] = 'Your album was successfully created'
        redirect_to :action => 'edit', :id => @album.id
      else
        render :action => 'new'
      end
    end
    
    def destroy
      @album = Album.find(params[:id])
      if @album.destroy
        flash[:notice] = 'Your album was successfully removed'
      else
        flash[:error] = 'Your album could not be removed'
      end
      redirect_to :action => 'index'
    end
    
    def edit
      @album = Album.find(params[:id])
      @sections = GallerySection.find(:all, :conditions => {:site_id => site.id})
      @available_assets = Asset.find(:all, :conditions => ['site_id = ? and album_id IS NULL and thumbnail IS NULL', site.id])
    end
    
    def update
      @album = Album.find(params[:id])
      
      unless params[:asset_data].first.blank?
        # Upload new assets
        @assets = []
        params[:asset] ||= {} ; params[:asset_data] ||= []
        params[:asset].delete(:title) if params[:asset_data].size > 1
        params[:asset_data].each do |file|
          @assets << site.assets.build(params[:asset].merge(:uploaded_data => file, :user_id => current_user.id, :album_id => @album.id))
        end
        Asset.transaction { @assets.each &:save! }
      end 
      
      if @album.update_attributes(params[:album])
        flash[:notice] = 'Your album was successfully updated'
        redirect_to :action => 'index'
      else
        flash[:error] = 'Your album could not be updated'
        render :action => 'edit'
      end
    end
    
    def create_section
      @section = GallerySection.new(params[:section])
      @section.site_id = site.id
      
      if @section.save
        render :update do |page|
          page.insert_html :bottom, 'gallery_sections', :partial => 'gallery_section', :locals => {:gallery_section => @section, :hidden => true}
          page.visual_effect :appear, "gallery_section_#{@section.id}", :duration => 1
        end
      end
    end
    
    def destroy_section
      @section = GallerySection.find(params[:id])
      
      if @section.destroy
        render :update do |page|
          page.visual_effect :fade, "gallery_section_#{@section.id}", :duration => 1
        end
      end
    end
    
    def add_asset
      @asset = Asset.find(params[:asset_id])
      @album = Album.find(params[:album_id])
      @asset.album_id = @album.id
      
      if @asset.save
        render :update do |page|
          page.visual_effect :fade, "available_asset_#{@asset.id}", :duration => 1
          page.insert_html :bottom, 'articles', :partial => 'asset', :locals => {:asset => @asset, :hidden => true, :album => @album}
          page.visual_effect :appear, "asset_row_#{@asset.id}", :duration => 1
        end
      end
    end
    
    def remove_asset
      @asset = Asset.find(params[:id])
      @album = Album.find(@asset.album_id)
      
      @asset.album_id = nil
      
      if @album.cover_id = @asset.id
        @album.cover_id = nil
        @album.save
      end
      
      if @asset.save
        render :update do |page|
          page.visual_effect :fade, "asset_row_#{@asset.id}", :duration => 1
        end
      end
    end
    
    def update_caption
      @asset = Asset.find(params[:id])
      @asset.title = params[:value]
      if @asset.save
        render :text => @asset.title
      else
        render :text => "Oh No!"
      end
    end
    
    def add_video
      @video = EmbeddableVideo.new(params[:video_url])
      @asset = Asset.new
      @asset.filename = @video.unique_id + '.jpg'
      @asset.size = 1
      @asset.content_type = "image/jpeg"
      @asset.video_url = params[:video_url]
      @asset.album_id = params[:album_id]
      @asset.site_id = site.id
      @asset.save!
      @video.save_thumbnail(@asset.full_filename)
      
      [{:size => :thumb, :dimensions => "120>"}, {:size => :tiny, :dimensions => "50>"}].each do |h|
        thumb = Asset.new
        thumb.filename = @video.save_thumbnail(@asset.full_filename(h[:size]), h[:dimensions])
        thumb.content_type = "image/jpeg"
        thumb.thumbnail = h[:size].to_s
        thumb.parent_id = @asset.id
        thumb.site_id = site.id
        thumb.save
      end
      
      render :update do |page|  
        page.insert_html :bottom, 'articles', :partial => 'asset', :locals => {:asset => @asset, :hidden => true, :album => @album}
        page.visual_effect :appear, "asset_row_#{@asset.id}", :duration => 1
      end
    end
    
    def new_thumbnail
      @asset = Asset.find(params[:asset_id])
      @asset.generate_video_thumbnail(params[:offset])
      
      render :update do |page|
        page << "document.images.asset_thumb_#{@asset.id}.src = '#{@asset.public_filename(:lalli_thumb)}?#{Time.now.to_i}'"
        #page << "$('asset_thumb_#{@asset.id}').setAttribute('src', '#{@asset.public_filename(:lalli_thumb)}?#{Time.now.to_i}')"
      end
    end
    
    def page
      
    end
    
    def reorder
      @album = Album.find(params[:id])
      params[:articles].each_with_index do |id, index|
        asset = Asset.find(id)
        asset.album_order = index
        asset.save!
      end
      render :layout => false
    end
    
    def reorder_albums
      params[:articles].each_with_index do |id, index|
        asset = Album.find(id)
        asset.order_by = index
        asset.save!
      end
      render :layout => false
    end
  end
end