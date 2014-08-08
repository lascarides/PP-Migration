$(document).ready(function(){

	// init
	var searchTitles = $('.title');

	// Set up sortable tables
	$('.datatable').dataTable({
		"sPaginationType": "bootstrap",
		"bPaginate": false
	});

	// Set up year sliders for advanced search
	$( ".slider-range" ).slider({
		range: true,
		min: 1830,
		max: 1945,
		values: [ 1830, 1945 ],
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
		searchTitles.each(function(){
			if ($(this).data('yearend') < startYear || $(this).data('yearstart') > endYear) {
				$(this).addClass('inactive');
			} else {
				$(this).removeClass('inactive');
			}
		});
	}


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

	function harvestTitleCheckboxes() {
		var titleField = $('#selected_titles');
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

	// Date picker form
	$('.date-precise-button a').click(function(){
		$('.date-picker-slider').hide();
		$('.date-precise').show();
		return false;
	});

	$('.date-precise-hider').click(function(){
		$('.date-precise').hide();
		$('.date-picker-slider').show();
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

	// Kick off presentation.
	$('#preso').jmpress();

});

