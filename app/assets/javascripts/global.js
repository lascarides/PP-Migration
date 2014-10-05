$(document).ready(function(){

	/////////////////////////////////////////
	// SEARCH BEHAVIOUR
	/////////////////////////////////////////

	// Convenience JQuery traversals
	var searchTitles = $('.newspaper-title');

	// Facet UI behaviour
	$('#query').focus(function(){
		$('.facet').removeClass('active');
		$('.facet-tools').slideUp();
		$('.query-tools').slideDown();
	});

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

	// Make collatable form elements report up to their 'sendable' counterpart
	// (This is where we harvest newspaper title checkboxen into a 
	// single collated field, for example.)
	function collateFacetValues() {
		// TODO : Make sure significant changes in place (ie, all titles selected despite interaction)
		$('.facet-interacted-with').each(function(){
			var targetField = $(this).find('.sendable');
			var boxen = new Array;
			$(this).find('.collatable:checked').each(function(){
				if ( !$(this).hasClass('inactive') ) {
					boxen.push( $(this).val() );
				}
			});
			targetField.val(boxen.join(','));
		});
	}

	// Set collatable trigger
	$('.collatable, .collatable-trigger').click(function(){
		$(this).parents('.facet-tools').addClass('facet-interacted-with');
	});

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
		}
		if (date_value < datePickerRangeMin) {
			date_value = datePickerRangeMin;
		}
		// FIXME performance suck. vvvvvvv
		$('#' + which_date + '_date').val(date_value);
		displayDates();	
	}

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

		// FIXME performance suck. vvvvvvv
		if (startDate > datePickerRangeMin || endDate < datePickerRangeMax) {
			$('.title-note').show();
		} else {
			$('.title-note').hide();
		}

		$('#facet-date-range .facet-label').html(startDate + ' - ' + endDate);

		// FIXME performance suck. vvvvvvv
		$('.start-year h2').html(startDate);
		$('.end-year h2').html(endDate);

		showHideTitles(startDate, endDate);

		// FIXME performance suck. vvvvvvv
		$( "#search-options-dates h4 span" ).html( startDate + '-' + endDate );

		updateTimeline(startDate, endDate);

	}

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

	// Set up advanced search
	$('.title-select-all').click(function(){
		$('.title-select, .region-select').prop('checked', $(this).is(':checked') );
		displayDates();
	});

	$('.region-select').click(function(){
		$('.title-select-all').prop('checked', false);
		var checkboxen = $("[data-region='" + $(this).attr('value') + "'] input");
		checkboxen.prop('checked', $(this).is(':checked') );
		displayDates();
	});

	$('.title-select').click(function(){
		displayDates();
	});

	// Show/hide titles based on selected year
	function showHideTitles(startYear, endYear) {
		var regionList = new Array;
		// Hide regions when they are 'empty'
		$('.region-group').addClass('inactive');
		$('.region-select').addClass('inactive');
		$('.region-group-all').removeClass('inactive');
		$('.region-select').prop('checked', false);

		// Show/hide each title
		searchTitles.each(function(){
			if ($(this).data('yearend') < startYear || $(this).data('yearstart') > endYear) {
				$(this).addClass('inactive');
			} else {
				$(this).removeClass('inactive');
				$(this).parents('.region-group').removeClass('inactive').find('.region-select').removeClass('inactive');
			}
		});

		// Appropriately check regions
		$('.region-group').each(function(){
			var allActive = $(this).find('.title-select').length
			var checkedActive = $(this).find('.title-select:checked').length
			$(this).find('.region-select').prop('checked', (allActive == checkedActive) );
		});

		// Update date/title messages
		$('.title-select-all').prop('checked', ($('.title-select').not(':checked').length == 0) );
		var activeTitles = $('.newspaper-title').not('.inactive').find('.title-select:checked');
		var titleCount = activeTitles.length;
		var regionCount = activeTitles.parents('.region-group').length;
		var introText = ($('.title-select-all').prop('checked')) ? 'All ' : '';
		$('#facet-title-region .facet-label').html(introText + titleCount + ' titles from ' + regionCount + ' regions');

	}



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

	// Search facets
	$('.facet').click(function(e){
		e.preventDefault();
		if ($(this).hasClass('active')) {
			$(this).removeClass('active');
			$($(this).attr('href')).slideUp();
		} else {
			$('.facet').removeClass('active');
			$('.tools').slideUp();
			$(this).addClass('active');
			$($(this).attr('href')).slideDown();
		}
	});

	// Set up closeable panels
	$('.closeable .close-widget').click(function(){
		$('#search-form').submit();
		// $('.facet').removeClass('active');
		// $(this).parent('.closeable').slideUp();
	});

	// Multi-choice palettes
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


	// Kick off presentation.
	$('#preso').jmpress();

});

