class VeridianAPI 

	require 'open-uri'

	# TODO : Sanitize ALL inputs

	def initialize(address = nil)
		@api_address = address || 'http://paperspast-devel.natlib.govt.nz/veridian6/paperspast/cgi-bin/paperspast'
	end

	def get_publications
		xml = do_query({
			a: 		'cl',
			cl: 	'CL1'
		})
		xml.css('PublicationMetadata').collect do |p|
			{
				:id 	=> p.css('PublicationID').first.content,
				:title 	=> p.css('PublicationTitle').first.content
			}
		end
	end

	def get_dates( publication_id = nil )
		xml = do_query({
			a: 		'cl',
			cl: 	'CL2',
			sp: 	publication_id
		})
		xml.css('Date').collect do |d|
			Date.parse(d.content)
		end
	end

	def get_publication_documents( publication_id )
		xml = do_query({
			a: 		'cl',
			cl: 	'CL1',
			sp: 	publication_id
		})
		xml.css('DocumentMetadata').collect do |d|
			{
				id: 			d.css('DocumentID').first.content,
				date: 			Date.parse(d.css('DocumentDate').first.content),
				feature_code: 	d.css('DocumentFeatureCode').first.content,
				number: 		d.css('DocumentNumber').first.content,
				title: 			d.css('DocumentTitle').first.content,
				type: 			d.css('DocumentType').first.content,
				volume: 		d.css('DocumentVolume').first.content
			}
		end
	end

	def get_document_content( document_id )
		xml = do_query({
			a: 		'd',
			d: 		document_id
		})
		response = {
			:next_document_id => xml.css('DocumentNextDocumentID').first.content,
			:prev_document_id => xml.css('DocumentPrevDocumentID').first.content
		}
		response[:pages] = xml.css('Page').collect do |page|
			{
				id: 			page.css('PageID').first.content,
				feature_code: 	page.css('PageFeatureCode').first.content,
				image_height: 	page.css('PageImageHeight').first.content,
				image_width: 	page.css('PageImageWidth').first.content,
				ocr_accuracy: 	page.css('PageOCRAccuracy').first.content,
				title: 			page.css('PageTitle').first.content
			}
		end
		response[:logical_sections] = xml.css('LogicalSection').collect do |ls|
			{
				id: 			ls.css('LogicalSectionID').first.content,
				page_id: 		ls.css('LogicalSectionFirstPageID').first.content,
				type: 			ls.css('LogicalSectionType').first.content,
				title: 			ls.css('LogicalSectionTitle').first.content
			}
		end
		response
	end

	def get_page_content( document_id, page_id )
		xml = do_query({
			a: 		'd',
			d: 		"#{document_id}.1.#{page_id}"
		})
		response = {
			:image_html 		=> xml.css('PageImageHTML').first.content,
			:next_page_id 		=> xml.css('PageNextPageID').first.content,
			:prev_page_id 		=> xml.css('PagePrevPageID').first.content,
			:pdf_url 			=> xml.css('PagePdfURL').first.content,
			:text_html 			=> xml.css('PageTextHTML').first.content,
			:word_count 		=> xml.css('PageTextWordCount').first.content.to_i
		}
		response[:logical_sections] = xml.css('LogicalSectionBlock').collect do |ls|
			x, y, w, h = ls.css('LogicalSectionBlockLocation').first.content.split(',')
			{
				id: 			ls.css('LogicalSectionID').first.content,
				type: 			ls.css('LogicalSectionType').first.content,
				title: 			ls.css('LogicalSectionTitle').first.content,
				x_offset: 		x,
				y_offset: 		y,
				width: 			w,
				height: 		h
			}
		end
		response
	end

	def get_logical_section_content( document_id, logical_section_id, highlightable_terms = nil )
		xml = do_query({
			a: 		'd',
			d: 		"#{document_id}.2.#{logical_section_id}",
			hl: 	highlightable_terms
		})
		response = {
			:image_html 		=> xml.css('LogicalSectionImagesHTML').first.content,
			:next_section_id 	=> xml.css('LogicalSectionNextLogicalSectionID').first.content,
			:prev_section_id 	=> xml.css('LogicalSectionPrevLogicalSectionID').first.content,
			:text_html 			=> xml.css('LogicalSectionTextHTML').first.content,
			:word_count 		=> xml.css('LogicalSectionTextWordCount').first.content.to_i
		}
		response
	end

	def search_documents( search_params = {} )
		xml = do_query({
			a: 		'q',
			leq: 	'Document'
		}, search_params)
		response = {
			:num_results 		=> xml.css('TotalNumberOfSearchResults').first.content.to_i,
			:first_match_num 	=> xml.css('FirstSearchResultNumberReturned').first.content.to_i,
			:last_match_num 	=> xml.css('LastSearchResultNumberReturned').first.content.to_i
		}
		response[:search_results] = xml.css('Document').collect do |ls|
			{
				id: 				ls.css('DocumentID').first.content,
				result_number: 		ls.css('SearchResultNumber').first.content,
				title: 				ls.css('DocumentTitle').first.content,
				date: 				Date.parse( ls.css('DocumentDate').first.content ),
				publication_id: 	ls.css('PublicationID').first.content,
				publication_title: 	ls.css('PublicationTitle').first.content
			}
		end
		response[:facets] = xml.css('SearchFacet').collect do |f|
			{
				field_name: 		f.css('SearchFacetField').first.content,
				value: 				f.css('SearchFacetValue').first.content,
				count: 				f.css('SearchFacetCount').first.content
			}
		end
		response
	end

	def search_logical_sections( text_query, search_params = {} )
		xml = do_query({
			a: 		'q',
			leq: 	'Logical',
			txq: 	text_query
		}, search_params)
		response = {
			:num_results 		=> xml.css('TotalNumberOfSearchResults').first.content.to_i,
			:first_match_num 	=> xml.css('FirstSearchResultNumberReturned').first.content.to_i,
			:last_match_num 	=> xml.css('LastSearchResultNumberReturned').first.content.to_i
		}
		response[:search_results] = xml.css('LogicalSection').collect do |ls|
			{
				id: 				ls.css('LogicalSectionID').first.content,
				result_number: 		ls.css('SearchResultNumber').first.content,
				relevancy_score: 	ls.css('SearchResultScore').first.content,
				html_snippet: 		ls.css('SearchResultSnippetHTML').first.content,
				title: 				ls.css('LogicalSectionTitle').first.content,
				date: 				Date.parse( ls.css('DocumentDate').first.content ),
				publication_id: 	ls.css('PublicationID').first.content,
				publication_title: 	ls.css('PublicationTitle').first.content
			}
		end
		response[:facets] = xml.css('SearchFacet').collect do |f|
			{
				field_name: 		f.css('SearchFacetField').first.content,
				value: 				f.css('SearchFacetValue').first.content,
				count: 				f.css('SearchFacetCount').first.content
			}
		end
		response
	end

	def search_pages( text_query, search_params = {} )
		xml = do_query({
			a: 		'q',
			leq: 	'Page',
			txq: 	text_query
		}, search_params)
		response = {
			:num_results 		=> xml.css('TotalNumberOfSearchResults').first.content.to_i,
			:first_match_num 	=> xml.css('FirstSearchResultNumberReturned').first.content.to_i,
			:last_match_num 	=> xml.css('LastSearchResultNumberReturned').first.content.to_i
		}
		response[:search_results] = xml.css('LogicalSection').collect do |ls|
			{
				id: 				ls.css('LogicalSectionID').first.content,
				result_number: 		ls.css('SearchResultNumber').first.content,
				relevancy_score: 	ls.css('SearchResultScore').first.content,
				html_snippet: 		ls.css('SearchResultSnippetHTML').first.content,
				title: 				ls.css('PageTitle').first.content,
				date: 				Date.parse( ls.css('DocumentDate').first.content ),
				publication_id: 	ls.css('PublicationID').first.content,
				publication_title: 	ls.css('PublicationTitle').first.content
			}
		end
		response[:facets] = xml.css('SearchFacet').collect do |f|
			{
				field_name: 		f.css('SearchFacetField').first.content,
				value: 				f.css('SearchFacetValue').first.content,
				count: 				f.css('SearchFacetCount').first.content
			}
		end
		response
	end



private



	def do_query( params, extra_search_params = {} )
		params[:f] = 'XML'
		params.merge!( process_search_params( extra_search_params ) )
		query = [ @api_address, process_query_params(params) ].join('?')
		Nokogiri::XML(open(query, :http_basic_authentication=> ['observer', '7626bleh'] ))
	end


	def process_search_params(search_params)
		
		# Process date ranges
		start_year, start_month, start_day = /(\d\d\d\d)?-?(\d\d)?-?(\d\d)?/.match(search_params[:start_date].to_s)
		end_year, end_month, end_day = /(\d\d\d\d)?-?(\d\d)?-?(\d\d)?/.match(search_params[:end_date].to_s)

		{
			# Process miscellany
			o: 		search_params[:items_per_page],
			puq: 	search_params[:publication_id],
			r: 		search_params[:offset],
			sf: 	search_params[:sort_by],
			ssnip: 	search_params[:snippet],
			wofq: 	search_params[:min_words],
			wotq: 	search_params[:max_words],
			# Process date ranges
			dafyq: 	start_year,
			dafmq: 	start_month,
			dafdq: 	start_day,
			datyq: 	end_year,
			datmq: 	end_month,
			datdq: 	end_day
		}

	end


	def process_query_params(params)

		# Sanitise here?
		integer_fields = [:o, :r, :wofq, :wotq]

		params.to_a.collect{ |k,v|
			if not v.nil?
				if integer_fields.include? k
					v = v.to_i
				end
				"#{k}=#{v}"
			end
		}.compact.join('&')

	end


end