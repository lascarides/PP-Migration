PPMigration::Application.routes.draw do

	get '/about', to: 'about#about'
	get '/charts', to: 'about#charts'
	get '/about/dates', to: 'about#dates'
	get '/help', to: 'about#help'
	get '/set_language', to: 'about#set_language'
	get '/presentation', to: 'about#presentation'

	get '/newspapers/title', to: 'newspapers#title'
	get '/newspapers/title/:id', to: 'newspapers#title'
	get '/newspapers/title/:id/:year', to: 'newspapers#title'
	get '/newspapers/title/:id/:year/:month', to: 'newspapers#title'
	get '/newspapers/title/:id/:year/:month/:day', to: 'newspapers#title'
	get '/newspapers/title/:id/:year/:month/:day/:page', to: 'newspapers#title'

	SUPPORTED_FORMATS.each do |format|
		resources format, :controller => 'format_viewer', :type => format do
			collection do 
				get 'search'
			end
			collection do 
				get 'search_options'
			end
		end
	end

	root 'about#home'

end
