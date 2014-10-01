$(document).ready(function(){

	// init
	var searchTitles = $('.newspaper-title');

	// Set up sortable tables
	$('.datatable').dataTable({
		"sPaginationType": "bootstrap",
		"bPaginate": false
	});

	// Set up year sliders for advanced search
	$( ".slider-range" ).slider({
		range: true,
		min: 1839,
		max: 1945,
		values: [ 1839, 1945 ],
		slide: function( event, ui ) {
			var startYear = ui.values[0];
			var endYear = ui.values[1];
			$('.title-note').show();
			$( "#year-start" ).val( startYear );
			$( "#year-end" ).val( endYear );
			$( "#year-start-precise" ).val( startYear + '-01-01' );
			$( "#year-end-precise" ).val( endYear + '-12-31' );
			$( "#search-options-dates h4 span" ).html( startYear + '-' + endYear );
			showHideTitles(startYear, endYear);
		}
	});

	// Show/hide titles based on selected year
	function showHideTitles(startYear, endYear) {
		var titleCount = 0;
		var regionCount = 0;
		var regionList = new Array;
		// Hide regions when they are 'empty'
		$('.region-group').addClass('inactive');
		$('.region-group-all').removeClass('inactive');
		// Show/hide each title
		searchTitles.each(function(){
			if ($(this).data('yearend') < startYear || $(this).data('yearstart') > endYear) {
				$(this).addClass('inactive');
			} else {
				titleCount++;
				regionCount = parseInt(titleCount / 5);
				$(this).removeClass('inactive');
				$(this).parents('.region-group').removeClass('inactive');
			}
		});
		// Update date/title messages
		$('#facet-date-range .facet-label').html(startYear + ' - ' + endYear);
		$('#facet-title-region .facet-label').html(titleCount + ' titles from ' + regionCount + ' NZ regions');

	}

	// Set up quick help
	$('.quick-help-toggle').click(function(){
		$('body').chardinJs('start');
		return false;
	});

	// Set up fullscreen button
	$('.page-expander a').click(function(){
		$('.page-expander a.actual').toggle();
		$('.page-expander a.fit').toggle();
		$('.page-image-detail').toggleClass('page-image-detail-compressed');
		return false;
	});

	// Set up advanced search
	$('.title-select-all').click(function(){
		$('.title-select, .region-select').prop('checked', $(this).is(':checked') );
		harvestTitleCheckboxes();
	});

	$('.region-select').click(function(){
		$('.title-select-all').prop('checked', false);
		$("[data-region='" + $(this).attr('value') + "'] input").prop('checked', $(this).is(':checked') );
		harvestTitleCheckboxes();
	});

	$('.title-select').click(function(){
		harvestTitleCheckboxes();
	});

	// Date picker form
	$('.date-precise-button a').click(function(){
		$('.date-picker-slider').fadeOut();
		$('.date-precise').fadeIn();
		return false;
	});

	$('.date-precise-hider a').click(function(){
		$('.date-precise').fadeOut();
		$('.date-picker-slider').fadeIn();
		return false;
	});

	$(function() {
		$( "#year-start-precise, #year-end-precise" ).datepicker({ 
			dateFormat: "yy-mm-dd",
			minDate: '1830-01-01', 
			maxDate: '1946-01-01',
			onSelect: function(selectedDate) {
				var dateParts = selectedDate.split('-');
				if ($(this).attr('id') == 'year-start-precise') {
					$('#year-start').val(dateParts[0]);
				} else {
					$('#year-end').val(dateParts[0]);
				}
				showHideTitles($('#year-start').val(), $('#year-end').val());
			}
		});
	});

	$(function() {
		$( "#date-browser" ).datepicker({ 
			dateFormat: "d M, yy",
			minDate: '1830-01-01', 
			maxDate: '1946-01-01',
			onSelect: function(selectedDate) {
				var dateParts = selectedDate.split('-');
				if ($(this).attr('id') == 'year-start-precise') {
					$('#year-start').val(dateParts[0]);
				} else {
					$('#year-end').val(dateParts[0]);
				}
				showHideTitles($('#year-start').val(), $('#year-end').val());
			}
		});
	});

	// Search facets
	$('.facet').click(function(){
		$('.facet').removeClass('active');
		$(this).toggleClass('active');
		$('.tools').slideUp();
		$($(this).attr('href')).slideToggle();
		return false;
	});

	// Set up regular search
	$('#query').focus(function(){
		$('.facet').removeClass('active');
		$('.facet-tools').slideUp();
		$('.query-tools').slideDown();
	});

	// Set up closeable panels
	$('.closeable .close-widget').click(function(){
		$('.facet').removeClass('active');
		$(this).parent('.closeable').slideUp();
	});


	// Kick off presentation.
	$('#preso').jmpress();

});


function harvestTitleCheckboxes() {
	
	var titleField = $('#selected_titles');
	titleField.attr('value', '');

	if ( $('.title-select-all').is(':checked') ) {
		titleField.attr('value', 'ALL');
	} else {
		titleField.attr('value', '');
		$('.title-select').each(function(){
			if ( $(this).is(':checked') ) {
				titleField.attr( 'value', titleField.attr('value') + $(this).attr('value') + ',' );
			}
		});
	}
}
