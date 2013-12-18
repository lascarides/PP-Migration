class FormatViewerController < ApplicationController

  # STI : Invoices, Worksheets and Estimates use this controller
  before_filter :set_format_type

  def index
    respond_to do |format|
      format.html {}
      format.json {}
    end
  end

  def search
    @search_results = @format_class.search_results(params[:query])
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

end
