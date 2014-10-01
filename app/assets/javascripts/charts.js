function truncate(str, maxLength, suffix) {
	if(str.length > maxLength) {
		str = str.substring(0, maxLength + 1); 
		str = str.substring(0, Math.min(str.length, str.lastIndexOf(" ")));
		str = str + suffix;
	}
	return str;
}

function matrix_chart() {

	var margin = {top: 20, right: 200, bottom: 0, left: 10},
		width = 900,
		height = 2000;

	var start_year = 1839,
		end_year = 1945;

	var c = d3.scale.category20c();

	var x = d3.scale.linear()
		.range([0, width]);

	var xAxis = d3.svg.axis()
		.scale(x)
		.tickSize(2)
		.orient("top");

	var formatYears = d3.format("0000");
	xAxis.tickFormat(formatYears);

	var svg = d3.select(".chart").append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.style("margin-left", margin.left + "px")
		.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	d3.json("/charts.json", function(data) {
		x.domain([start_year, end_year]);
		var xScale = d3.scale.linear()
			.domain([start_year, end_year])
			.range([0, width]);

		svg.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + 0 + ")")
			.call(xAxis);

		for (var j = 0; j < data.length; j++) {
			var g = svg.append("g").attr("class","journal");

			var circles = g.selectAll("circle")
				.data(data[j]['articles'])
				.enter()
				.append("circle");

			var text = g.selectAll("text")
				.data(data[j]['articles'])
				.enter()
				.append("text");

			var rScale = d3.scale.linear()
				.domain([0, 110000])
				.range([1, 22]);

			circles
				.attr("cx", function(d, i) { return xScale(d[0]); })
				.attr("cy", j*20+20)
				.attr("r", function(d) { return rScale(d[1]); })
				.style("fill", function(d) { return c(j); });

			text
				.attr("y", j*20+25)
				.attr("x",function(d, i) { return xScale(d[0])-5; })
				.attr("class","value")
				.text(function(d){ return d[1]; })
				.style("fill", function(d) { return c(j); })
				.style("display","none");

			g.append("text")
				.attr("y", j*20+25)
				.attr("x",width+20)
				.attr("class","label")
				.text(truncate(data[j]['name'],30,"..."))
				.style("fill", function(d) { return c(j); })
				.on("mouseover", mouseover)
				.on("mouseout", mouseout);
		};

		function mouseover(p) {
			var g = d3.select(this).node().parentNode;
			d3.select(g).selectAll("circle").style("display","none");
			d3.select(g).selectAll("text.value").style("display","block");
		}

		function mouseout(p) {
			var g = d3.select(this).node().parentNode;
			d3.select(g).selectAll("circle").style("display","block");
			d3.select(g).selectAll("text.value").style("display","none");
		}
	});

}








function timeline_chart() {

	var margin = {top: 0, right: 0, bottom: 20, left: 0},
		width = 900,
		height = 90;

	var start_year = 1839,
		end_year = 1945;

	var c = d3.scale.category20c();

	var x = d3.scale.linear()
		.range([0, width]);

	var xAxis = d3.svg.axis()
		.scale(x)
		.tickSize(2)
		.orient("bottom");

	var y = d3.scale.linear()
	    .range([height, 0]);

	var formatYears = d3.format("0000");
	xAxis.tickFormat(formatYears);

	var svg = d3.select(".chart").append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.style("margin-left", margin.left + "px")
		.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	d3.json("/charts.json", function(data) {
		x.domain([start_year, end_year]);
		var xScale = d3.scale.linear()
			.domain([start_year, end_year])
			.range([0, width]);

		svg.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + 0 + ")")
			.call(xAxis);

		for (var j = 0; j < data.length; j++) {
			var g = svg.append("g").attr("class","journal");

			var circles = g.selectAll("circle")
				.data(data[j]['articles'])
				.enter()
				.append("circle");

			var text = g.selectAll("text")
				.data(data[j]['articles'])
				.enter()
				.append("text");

			var rScale = d3.scale.linear()
				.domain([0, 110000])
				.range([0, 90]);

			circles
				.attr("cx", function(d, i) { return xScale(d[0]); })
				.attr("cy", j*20+20)
				.attr("r", function(d) { return rScale(d[1]); })
				.style("fill", function(d) { return c(j); });

			text
				.attr("y", j*20+25)
				.attr("x",function(d, i) { return xScale(d[0])-5; })
				.attr("class","value")
				.text(function(d){ return d[1]; })
				.style("fill", function(d) { return c(j); })
				.style("display","none");

			g.append("text")
				.attr("y", j*20+25)
				.attr("x",width+20)
				.attr("class","label")
				.text(truncate(data[j]['name'],30,"..."))
				.style("fill", function(d) { return c(j); })
				.on("mouseover", mouseover)
				.on("mouseout", mouseout);
		};

	});





// var svg = d3.select("body").append("svg")
//     .attr("width", width + margin.left + margin.right)
//     .attr("height", height + margin.top + margin.bottom)
//   .append("g")
//     .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// d3.tsv("data.tsv", type, function(error, data) {
//   x.domain(data.map(function(d) { return d.letter; }));
//   y.domain([0, d3.max(data, function(d) { return d.frequency; })]);

//   svg.append("g")
//       .attr("class", "x axis")
//       .attr("transform", "translate(0," + height + ")")
//       .call(xAxis);

//   svg.append("g")
//       .attr("class", "y axis")
//       .call(yAxis)
//     .append("text")
//       .attr("transform", "rotate(-90)")
//       .attr("y", 6)
//       .attr("dy", ".71em")
//       .style("text-anchor", "end")
//       .text("Frequency");

//   svg.selectAll(".bar")
//       .data(data)
//     .enter().append("rect")
//       .attr("class", "bar")
//       .attr("x", function(d) { return x(d.letter); })
//       .attr("width", x.rangeBand())
//       .attr("y", function(d) { return y(d.frequency); })
//       .attr("height", function(d) { return height - y(d.frequency); });

// });

// function type(d) {
//   d.frequency = +d.frequency;
//   return d;
// }




}

