PPMigration::Application.routes.draw do

	root 'about#home'

	SUPPORTED_FORMATS.each do |format|
		resources format, :controller => 'format_viewer', :type => format do
			collection do 
				get 'search'
			end
		end
	end

end
