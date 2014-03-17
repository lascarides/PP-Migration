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
			$('.title-note').show();
			$( "#year-start" ).val( ui.values[0] );
			$( "#year-end" ).val( ui.values[1] );
			$( "#search-options-dates h4 span" ).html( ui.values[0] + '-' + ui.values[1] );
			searchTitles.each(function(){
				var chk = $(this).find('input');
				if (chk.data('yearend') < ui.values[0] || chk.data('yearstart') > ui.values[1]) {
					$(this).addClass('inactive');
				} else {
					$(this).removeClass('inactive');
				}
			});
		}
	});

	// Set up advanced search
	$('.title-select-all').click(function(){
		$('.title-select, .region-select').prop('checked', $(this).is(':checked') );
	});
	$('.region-select').click(function(){
		$('.title-select-all').prop('checked', false);
		$("[data-region='" + $(this).attr('value') + "']").prop('checked', $(this).is(':checked') );
	});

});

