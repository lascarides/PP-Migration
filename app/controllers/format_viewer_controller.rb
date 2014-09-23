class FormatViewerController < ApplicationController

  # STI : Invoices, Worksheets and Estimates use this controller
  before_filter :set_format_type
  before_filter :build_regions

  def index
    if params[:query]
      @search_results = @format_class.search_results(params)
    else
      @front_pages = @format_class.front_pages
    end
    respond_to do |format|
      format.html {}
      format.json {}
    end
  end

  def search
    @search_results = @format_class.search_results(params)
    respond_to do |format|
      format.html {}
      format.json {}
    end
  end

  def search_options
    respond_to do |format|
      format.html {}
      format.json {}
    end
  end

  def show
    @item = @format_class.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  private 

  def set_format_type
    @type = params[:type]
    unless SUPPORTED_FORMATS.include? @type
      @type = :newspapers
    end
    # Get class for the current type
    @format_class = Kernel.const_get(@type.to_s.singularize.camelize)
  end

  def build_regions
    @regions = [
      'National',
      'Northland',
      'Auckland',
      'Waikato',
      'Taranaki',
      'Bay of Plenty',
      'Gisborne',
      'Hawke\'s Bay',
      'Manawatu-Wanganui',
      'Wellington',
      'Marlborough',
      'Nelson',
      'West Coast',
      'Canterbury',
      'Otago'
    ]
  end

end
