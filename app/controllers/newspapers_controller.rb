class NewspapersController < FormatViewerController

	def title
		@title = Newspaper.collections.collect{|n, i| n if n.parameterize == params[:id] }.compact.first
	end

	def date
	end

	def region
	end

end
