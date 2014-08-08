PPMigration::Application.routes.draw do

	get '/about', to: 'about#about'
	get '/charts', to: 'about#charts'
	get '/about/dates', to: 'about#dates'
	get '/help', to: 'about#help'
	get '/presentation', to: 'about#presentation'

	get '/newspapers/title', to: 'newspapers#title'
	get '/newspapers/title/:id', to: 'newspapers#title'
	get '/newspapers/title/:id/:year', to: 'newspapers#title'
	get '/newspapers/title/:id/:year/:month', to: 'newspapers#title'
	get '/newspapers/title/:id/:year/:month/:day', to: 'newspapers#title'
	get '/newspapers/title/:id/:year/:month/:day/:page', to: 'newspapers#title'
	get '/newspapers/title/:id/:year/:month/:day/:page/:article', to: 'newspapers#title'

	get '/newspapers/date', to: 'newspapers#date'
	get '/newspapers/date/:year', to: 'newspapers#date'
	get '/newspapers/date/:year/:month', to: 'newspapers#date'
	get '/newspapers/date/:year/:month/:day', to: 'newspapers#date'

	get '/newspapers/region', to: 'newspapers#region'
	get '/newspapers/region/:region', to: 'newspapers#region'

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
