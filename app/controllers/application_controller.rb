class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :initialize_session_stuff

  def initialize_session_stuff

    # Recent searches
    session[:recent_searches] ||= []

    # language switching
  	@languages = {
  		:en => "English",
  		:mi => "te reo Māori"
  	}
  	session[:language] ||= :en
  	I18n.locale = session[:language]

  end

end
