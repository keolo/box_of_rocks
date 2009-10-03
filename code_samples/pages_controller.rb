class PagesController < ApplicationController
  #caches_page :show
  #cache_sweeper :page_sweeper, :only => [:create, :update, :destroy, :recommend]

  layout 'admin', :except => [:show]

  before_filter :require_user, :except => [:show]

  def index
    @homepage = Homepage.first
    @pages = Page.all
  end

  def new
    @page = Page.new
    @page.topic = Topic.new
    10.times{@page.related_links.build}
    10.times{@page.external_links.build}
    @page.pdf_links.build
  end

  def create
    @page = Page.new(params[:page])
    @page.topic = Topic.find(params[:topic][:id]) unless params[:topic][:id].blank?
    @page.user = current_user
    if @page.save
      create_update_redirect('Page created.')
    else
      render :new
    end
  end

  def show
    begin
      @page = Page.find(params[:id])

      # 301 redirect to canonical url if topic or slug doesn't match what's in
      # the database. This is for SEO.
      if (params[:topic] && @page.topic && params[:topic] != @page.topic.slug) ||
         (params[:slug] && params[:slug] != @page.slug)
        redirect_to show_page_path(@page), :status => :moved_permanently and return false
      end

      render :layout => 'application'
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    params[:topic][:id].blank? ? @page.topic = nil : @page.topic = Topic.find(params[:topic][:id])
    @page.user = current_user
    if @page.update_attributes(params[:page])
      create_update_redirect('Page updated.')
    else
      render :edit
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    flash[:notice] = 'Page destroyed.'
    redirect_to pages_path
  end

  def recommend
    page = Page.find(params[:id])
    current_user.vote_for(page)
    redirect_to show_page_path(page)
  end

  def clear_cache
    cache_dir = ActionController::Base.page_cache_directory
    if cache_dir != Rails.public_path
      FileUtils.rm_r(Dir.glob("#{cache_dir}/*")) rescue Errno::ENOENT
      Rails.logger.info("Cache directory '#{cache_dir}' fully sweeped.")
      flash[:notice] = 'Cache cleared.'
      redirect_to pages_path
    else
      flash[:notice] = 'Cache could not be cleared.'
      redirect_to pages_path
    end
  end
end
