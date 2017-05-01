function tabulate(data, columns, divID, sortColumn, sortType) {
	var table = d3.select("#" + divID).append("table")
//	var table = d3.select("body").append("table")
		.attr("style", "margin-left: auto")
		.attr("style", "margin-right: auto")
//		.attr("style", "width: 200px")
		.style("border-collapse", "collapse").style("border", "2px black solid"),
	thead = table.append("thead"),
	tbody = table.append("tbody");
	
	// append the header row
	thead.append("tr")
	.selectAll("th")
	.data(columns)
	.enter()
	.append("th")
	.style("border-collapse", "collapse").style("border", "2px black solid")
	.text(function(column) { return column; });
	
	// create a row for each object in the data
	var rows = tbody.selectAll("tr")
	.data(data)
	.enter()
	.append("tr");
	
	// create a cell in each row for each column

	// create a cell in each row for each column
	var cells = rows.selectAll("td")
	.data(function(row) {
		return columns.map(function(column) {
			return {column: column, value: row[column]};
			});
		})
	.enter()
	.append("td")
	.attr("style", "font-family: Courier").
	style("border-collapse", "collapse").style("border", "2px black solid")
        .style("white-space", "wrap")
//        .style("width", "20px")
	.on("mouseover", function(){d3.select(this).style("background-color", "aliceblue")})
    .on("mouseout", function(){d3.select(this).style("background-color", "white")})
	.html(function(d) { return d.value; });
	
        table.selectAll("tbody tr")
        .sort(function(a, b) {
            return d3[sortType](a[sortColumn], b[sortColumn] );
        });
	return table;
}