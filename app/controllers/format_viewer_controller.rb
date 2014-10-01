class FormatViewerController < ApplicationController

  # STI : Invoices, Worksheets and Estimates use this controller
  before_filter :set_format_type
  before_filter :build_regions
  before_filter :build_facets

  def index
    if params[:query]
      @search_results = @format_class.search_results(params)
    elsif @format_class.respond_to? :front_pages
      @front_pages = [] #@format_class.front_pages
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

  def build_facets
    @facets = [
      {
        name: 'date-range',
        help_text: 'Click here to choose a specific range of dates',
        default_value: '1839 - 1945',
        choose_text: 'Dates',
        formats_to_show_on: [:all]
      },
      {
        name: 'title-region',
        help_text: 'Click here to choose specific newspaper titles by NZ region',
        default_value: 'All titles from all regions',
        choose_text: 'Titles and NZ regions',
        formats_to_show_on: [:newspapers]
      },
      {
        name: 'title',
        help_text: 'Click here to choose specific periodicals by title',
        default_value: 'All titles',
        choose_text: 'Titles',
        formats_to_show_on: [:periodicals]
      },
      {
        name: 'article-types',
        help_text: 'Click here to choose the types of newspaper articles you\'d like to search',
        default_value: 'All article types',
        choose_text: 'Article types',
        formats_to_show_on: [:newspapers]
      },
      {
        name: 'collections',
        help_text: 'Click here to choose collections (groupings of materials)',
        default_value: 'All collections',
        choose_text: 'Collections',
        formats_to_show_on: [:manuscripts]
      },
      {
        name: 'parliamentary-sessions',
        help_text: 'Click here to choose the parliamentary session',
        default_value: 'All parliamentary sessions',
        choose_text: 'Parliamentary sessions',
        formats_to_show_on: [:parliamentary_papers]
      },
      {
        name: 'participants',
        help_text: 'Click here to choose the people involved in the correspondence',
        default_value: 'All people',
        choose_text: 'People',
        formats_to_show_on: [:manuscripts, :parliamentary_papers]
      },
      {
        name: 'subjects',
        help_text: 'Click here to choose the subjects in which you\'re interested',
        default_value: 'All subjects',
        choose_text: 'Subjects',
        formats_to_show_on: [:periodicals, :manuscripts, :parliamentary_papers]
      }
    ].collect { |f|
      if f[:formats_to_show_on].include?(@type) or f[:formats_to_show_on].include?(:all)
        f 
      end
    }.compact

    @timeline_values = Newspaper.year_data_for_bar_chart
    @timeline_x_scale = 1.0 / (@timeline_values.values.max / 86.0)

  end

end
