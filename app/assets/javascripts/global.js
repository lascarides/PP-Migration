$(document).ready(function(){

	/////////////////////////////////////////
	// SEARCH BEHAVIOUR
	/////////////////////////////////////////

	// Form submittal
	$('#search-form').submit(function(event){
		event.preventDefault();
		collateFacetValues();
		var queryString = new Array;
		$('input[type=hidden].sendable').each(function(){
			var f = $(this);
			if ( f.val() ) {
				queryString.push( $(this).attr('name') + '=' + $(this).val() );
			}
		});
		if ( $('#query').val() ) {
			queryString.push( 'query=' + $('#query').val() );
		}
		$('input[type=radio].sendable').each(function(){
			var f = $(this);
			if ( f.val() ) {
				// Don't send unchecked radio buttons
				if (f.attr('checked') != 'checked') {
					return false;
				}
				// Only send mode if query exists
				if (  f.attr('name') == 'mode' && !$('#query').val()) {
					return false;
				}
				queryString.push( $(this).attr('name') + '=' + $(this).val() );
			}
		});
		if (queryString != '') {
			var currentLocation = location.href

			window.location = currentLocation.split('?')[0] + '?' + queryString.join('&');
		}
	});

	// Show search query tools.
	$('#query').focus(function(){
		$('.facet a').removeClass('active');
		$('.facet-tools').slideUp();
		$('.query-tools').slideDown();
	});

	// Make collatable form elements report up to their 'sendable' counterpart
	// (This is where we harvest newspaper title checkboxen into a 
	// single collated field, for example.)
	function collateFacetValues() {
		// TODO : Make sure significant changes in place (ie, all titles selected despite interaction)
		$('.search-box .facet-interacted-with').each(function(){
			var targetField = $(this).find('.sendable');
			var boxen = new Array;
			$(this).find('.collatable:checked').each(function(){
				if ( !$(this).parents('label').hasClass('inactive') ) {
					boxen.push( $(this).val() );
				}
			});
			targetField.val(boxen.join(','));
		});
	}

	/////////////////////////////////////////
	// FACETS
	/////////////////////////////////////////

	// Facet display
	$('.facet a').click(function(e){
		e.preventDefault();
		if ($(this).hasClass('active')) {
			$(this).removeClass('active');
			$($(this).attr('href')).slideUp();
		} else {
			$('.facet a').removeClass('active');
			$('.tools').slideUp();
			$(this).addClass('active');
			$($(this).attr('href')).slideDown();
		}
	});

	// Set collatable trigger & label accordingly
	$('.collatable, .collatable-trigger').click(function(){
		$(this).parents('.facet-tools').each(function(){
			$(this).addClass('facet-interacted-with');
			var facetName = $(this).attr('id').replace(/-picker/, '');
			$('#facet-' + facetName).addClass('facet-interacted-with');
		});
	});

	// Facet resetter (clear) behaviour
	$('.facet-reset').click(function(){
		$(this).parents('.facet').each(function(){
			var facetName = $(this).attr('id').replace(/facet-/, '');
			$('#' + facetName + '-picker .collatable').prop('checked', true);
			$('#' + facetName + '-picker .collatable-trigger').prop('checked', true);
			$('#' + facetName + '-picker .facet-select-all').prop('checked', true);
			displayDates();
			$(this).removeClass('facet-interacted-with');
		});
	});

	// Facet "Select all" triggers
	$('.facet-select-all').click(function(){
		$(this).parents('.facet-tools').find('.collatable, .collatable-trigger').prop('checked', $(this).is(':checked') );
		facetCheckboxenDisplay( $(this).parents('.facet-tools') );
	});

	// Facet group checkboxen
	$('.facet-group-title input').click(function(){
		$(this).parents('.facet-group').find('.facet-item input').prop('checked', $(this).is(':checked') );
		facetCheckboxenDisplay( $(this).parents('.facet-tools') );
	});

	// Facet item checkboxen
	$('.facet-item').click(function(){
		facetCheckboxenDisplay( $(this).parents('.facet-tools') );
	});

	// Update bits & pieces of UI around page after facet checkboxes clicked
	function facetCheckboxenDisplay(scope) {

		var facetName = scope.attr('id').replace('-picker', '');
		var facetLabel = '';
		if (facetName == 'title-region') {
			facetLabel = titleFacetText();
		} else {
			facetLabel = summarizeFacetText('#' + scope.attr('id') + ' .facet-item', facetName.replace('-', ' '));
		}
		$('#facet-' + facetName + ' .facet-label').html( facetLabel );


		// Appropriately check grouped items
		scope.find('.facet-group').each(function(){
			var allActive = $(this).find('.facet-item input').length;
			var checkedActive = $(this).find('.facet-item input:checked').length;
			$(this).find('.facet-group-title input').prop('checked', (allActive == checkedActive) );
		});

		// Appropriately check the "Select All" checkbox
		var allActive = scope.find('.facet-item input').length;
		var checkedActive = scope.find('.facet-item input:checked').length;
		scope.find('.facet-group-all input').prop('checked', (allActive == checkedActive) );
		// Update select all label
		scope.find('.facet-group-all label span').toggle( scope.find('.facet-group-all input').prop('checked') );

	}

	// Show/hide titles based on selected year
	function showHideFacetGroups(startYear, endYear) {

		// Hide regions when they are 'empty'
		$('.facet-group').addClass('inactive');

		// Show/hide each item
		$('.facet-item').each(function(){
			if ($(this).data('end-year') < startYear || $(this).data('start-year') > endYear) {
				$(this).addClass('inactive');
			} else {
				$(this).removeClass('inactive');
				$(this).parents('.facet-group').removeClass('inactive');
			}
		});

	}

	// Title facet text
	function titleFacetText() {
		var titleText = summarizeFacetText('#title-region-picker .facet-item', 'newspaper');
		var regionText = summarizeFacetText('#title-region-picker .facet-group-title label', 'region');
		if (titleText == 'None selected') {
			return titleText;
		}
		if (titleText == 'All') {
			return 'All titles';
		}
		if (regionText == 'None selected' || regionText == 'All regions') {
			return titleText;
		}
		return titleText + ' <small>From ' + regionText + '</small>';
	}


	// Text for facet summaries
	function summarizeFacetText(scope, trailer) {

		var allValues = $(scope).not('.inactive').find('input');
		var checkedValues = $(scope).not('.inactive').find('input:checked').parents('label');
		var txt;

		if (allValues.length == checkedValues.length) {
			txt = 'All ' + trailer + 's';
		} else {
			if (checkedValues.length == 0) {
				txt = 'None selected';
				return txt;
			} else if (checkedValues.length == 1) {
				txt = $(checkedValues.get(0)).text().trim();
			} else if (checkedValues.length == 2) {
				txt = $(checkedValues.get(0)).text().trim() + ' and ' + $(checkedValues.get(1)).text().trim();
			} else if (checkedValues.length == 3) {
				txt = $(checkedValues.get(0)).text().trim() + ', ' + $(checkedValues.get(1)).text().trim() + ', and ' + $(checkedValues.get(2)).text().trim();
			} else {
				txt = $(checkedValues.get(0)).text().trim() + ', ' + $(checkedValues.get(1)).text().trim() + ', and ';
				txt = txt + (checkedValues.length - 2) + ' other ' + trailer;
				if ( (checkedValues.length - 2) > 1) {
					// FIXME: Naive pluralisation
					txt = txt + 's';	
				}
			}
		}
		return txt.trim();
	}


	/////////////////////////////////////////
	// DATE PICKER
	/////////////////////////////////////////

	var datePicker 			= $('.date-range-picker');
	var datePickerRangeMin 	= parseInt(datePicker.data('year-min'));
	var datePickerRangeMax 	= parseInt(datePicker.data('year-max'));
	var startDateField 		= $('#start_date');
	var endDateField 		= $('#end_date');

	// Set up year sliders for date picker
	$( ".slider-range" ).slider({
		range: true,
		min: datePickerRangeMin,
		max: datePickerRangeMax,
		values: [ datePickerRangeMin, datePickerRangeMax ],
		slide: function( event, ui ) {

			process_dates('y', ui.values[0], 'start');
			process_dates('y', ui.values[1], 'end');

		}
	});

	// Process dates, from any widget
	// date_part 	= one of 'y', 'm', or 'd'
	// date_value 	= ordinal value for the y/m/d, or '+n', '-n' to step
	// which_date 	= one of 'start' or 'end'
	function process_dates(date_part, date_value, which_date) {

		var current_date = $('#' + which_date + '_date').val();

		// No date set yet? Use correct edge
		if (!current_date) {
			current_date = (which_date == 'start') ? datePickerRangeMin : datePickerRangeMax;
		}

		current_date = parseInt(current_date);

		// Allow increments
		if (date_value == '+1') {
			date_value = current_date + 1;
		} else if (date_value == '-1') {
			date_value = current_date - 1;
		} else {
			date_value = parseInt(date_value);
		}

		// Validate range
		// FIXME More validation please, and dates not years
		if (date_value > datePickerRangeMax) {
			date_value = datePickerRangeMax;
			triggerDateBoundaryMessage();
		}
		if (date_value < datePickerRangeMin) {
			date_value = datePickerRangeMin;
		}
		// FIXME performance suck. vvvvvvv
		$('#' + which_date + '_date').val(date_value);
		displayDates();	
	}

	// Show message to anyone looking for dates after boundary
	function triggerDateBoundaryMessage() {
		$('#events-picker').slideUp();
		$('#date-range-message').slideDown();
	}

	// Multi-choice palettes (year, month, etc)
	$('html').click(function() {
	  $('.multi-choice-palette').hide();
	});
	$('.date-dropdown h2, .date-dropdown h4').click(function(e){
		e.stopPropagation();
		$(this).parent('.date-dropdown').find('.multi-choice-palette').toggle();
	});
	$('.multi-choice-palette a').click(function(e){
		e.preventDefault();
		process_dates($(this).data('date-part'), parseInt($(this).text()), $(this).data('date-which'));
	});

	// Once date is updated, adjust display of dates throughout page.
	function displayDates() {
		
		var startDate = startDateField.val();
		var endDate = endDateField.val();
		if (!startDate) {
			startDate = datePickerRangeMin;
		}
		if (!endDate) {
			endDate = datePickerRangeMax;
		}

		$(".slider-range").slider('values', [startDate,endDate] );

		if (startDate > datePickerRangeMin || endDate < datePickerRangeMax) {
			$('.title-note').show();
		} else {
			$('.title-note').hide();
		}

		$('#facet-date-range .facet-label').html(startDate + ' - ' + endDate);

		$('.start-year h2').html(startDate);
		$('.end-year h2').html(endDate);

		showHideFacetGroups(startDate, endDate);

		$( "#search-options-dates h4 span" ).html( startDate + '-' + endDate );

		updateTimeline(startDate, endDate);

	}

	$('.date-era-select a').click(function(){
		$('.date-era-select a').removeClass('active');
		$(this).addClass('active');
		process_dates('y', $(this).data('start'), 'start');
		process_dates('y', $(this).data('end'), 'end');
		return false;
	});

	// Date Timeline rules
	function updateTimeline(startDate, endDate) {
		$('.timeline-hilite').css({
			left: ((startDate - datePickerRangeMin) * 7) - 1 + 'px',
			width: ((endDate - startDate + 1) * 7) + 1 + 'px'
		});
		$('.timeline-bar').addClass('muted').filter(function() {
			var thisYear = parseInt($(this).find('.bar-label').text());
			return thisYear >= startDate && thisYear <= endDate;
		}).removeClass('muted');
	}

	$('.timeline-bar').click(function(){
		var sliderRange = $( ".slider-range" ).slider('option', 'values');
		var thisYear = parseInt($(this).data('year'));
		var which_date = (Math.abs(thisYear - parseInt(sliderRange[0])) < Math.abs(thisYear - parseInt(sliderRange[1]))) ? 'start' : 'end';
		process_dates('y', $(this).data('year'), which_date); 
	});


	$('.date-step-button').click(function(){
		process_dates($(this).data('date-part'), $(this).data('date-value'), $(this).data('date-which'))
		return false;
	});


	// Kick off date display on load
	displayDates();



	/////////////////////////////////////////
	// UI MISCELLANY
	/////////////////////////////////////////

	// Thumbnail/list switcher
	$('#view-style-list').click(function(){
		$('.thumbnail-pages').addClass('thumbnail-pages-list-view');
		$('#view-style-thumbs').removeClass('active');
		$(this).addClass('active');
	});
	$('#view-style-thumbs').click(function(){
		$('.thumbnail-pages').removeClass('thumbnail-pages-list-view');
		$('#view-style-list').removeClass('active');
		$(this).addClass('active');
	});

	// Set up sortable tables
	$('.datatable').dataTable({
		"sPaginationType": "bootstrap",
		"bPaginate": false
	});

	// Set up quick help
	$('.quick-help-toggle').click(function(e){
		e.preventDefault();
		$('body').chardinJs('start');
	});

	// Set up fullscreen button
	$('.page-expander a').click(function(e){
		e.preventDefault();
		$('.page-expander a.actual').toggle();
		$('.page-expander a.fit').toggle();
		$('.page-image-detail').toggleClass('page-image-detail-compressed');
	});

	// Set up closeable panels
	$('.closeable .close-widget').click(function(){
		$('.facet').removeClass('active');
		$(this).parent('.closeable').slideUp();
	});
	$('.closeable .done-widget').click(function(){
		$('#search-form').submit();
	});

	// Kick off presentation.
	$('#preso').jmpress();

});

