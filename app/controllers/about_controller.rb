class AboutController < ApplicationController

	def home
	end

	def charts
	end

	def presentation
	    render :layout => 'presentation'
	end

	def set_language
		new_language = params[:lang].to_sym 
		if @languages.keys.include? new_language
			session[:language] = new_language
		end
		redirect_to :back
	end


end
