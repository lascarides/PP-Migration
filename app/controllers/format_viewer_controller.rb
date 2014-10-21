class FormatViewerController < ApplicationController

  before_filter :set_format_type
  before_filter :build_regions
  before_filter :build_facets

  def index
    @start_date   = params[:start_date]
    @end_date     = params[:end_date]
    if params[:query]
      @search_results = @format_class.search_results(params)
    elsif @format_class.respond_to? :front_pages
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
    # FIXME - display hack
    if @type == :newspapers
      @item[:page_number] ||= 1
    end
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

    @timeline_values = Newspaper.year_data_for_bar_chart
    @timeline_x_scale = 1.0 / (@timeline_values.values.max / 86.0)

    @facets = JSON.parse( File.read('db/facet_metadata.json') ).collect { |label,f|
      if f['formats_to_show_on'].include?(@type.to_s) or f['formats_to_show_on'].include?('all')
        f['name'] = label
        if label == 'newspapers'
          f['values'] = NewspaperTitle.info.values.group_by{ |info|
            info[:region]
          }
        end
        f
      end
    }.compact

  n = {}
  NewspaperTitle.info.each{|sym,vals| n[vals[:region]] ||= []; n[vals[:region]] << "{\"id\": \"#{sym}\", \"name\": \"#{vals[:title]}\", \"start-year\": \"#{vals[:start_year]}\", \"end-year\": \"#{vals[:end_year]}\"}" }
  n.each{ |r,v| puts '"' + r + '": [' + v.join(',') + ' ]'}

  end

end
