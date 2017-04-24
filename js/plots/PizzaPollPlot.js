// Wrapping in nv.addGraph allows for '0 timeout render', stores rendered charts in nv.graphs, and may do more in the future... it's NOT required
d3.json("http://jaredlander.com/data/PizzaPollData.php", function(error, data) { 
    if (error){alert(error); return console.warn(error);}
    
    var nestedData = d3.nest()
        .key(function(d) { return d.Answer })
        .entries(data);
    
    var chart;

nv.addGraph(function() {
  chart = nv.models.multiBarChart().stacked(true)
  .x(function(d) { return d.pollq_id })
  //.x(function(d) { return d.Question })
  .y(function(d) { return d.Percent })
  .options({
    margin: {left: 100, bottom: 200},
    showXAxis: true,
    showYAxis: true,
    transitionDuration: 250
  })
  ;
  
  d3.json("http://www.jaredlander.com/data/PollQuestions.php", function(error, qList){
    if (error){alert(error); return console.warn(error);}
    
    var lookup = {};
    qList.forEach(function (el, i, arr)
    {
	lookup[el.pollq_id] = el.Question;
    });
    
    var x_format = function(num)
    {
	return(lookup[num]);
    }

  chart.xAxis.tickFormat(function(d, i) { return x_format(d); }).staggerLabels(false).rotateLabels(-45);
  //chart.reduceXTicks(false)
  // chart sub-models (ie. xAxis, yAxis, etc) when accessed directly, return themselves, not the parent chart, so need to chain separately
  chart.xAxis
    .axisLabel("Pizza")
    ;//.tickFormat(d3.format(',.1f'));
  chart.reduceXTicks(false);
  chart.yAxis
    .axisLabel('Percent')
    ;//.tickFormat(d3.format(',.2f'));

  d3.select('#ratingsbypizzeria')
// d3.select('#ratingsbypizzeria' svg)
    .datum(nestedData)
.attr("height", 800)
.attr("width", 800)
.attr("min-width", 400)
.attr("min-height", 200)
.call(chart);

  //TODO: Figure out a good way to do this automatically
  nv.utils.windowResize(chart.update);
  //nv.utils.windowResize(function() { d3.select('#chart1 svg').call(chart) });

  chart.dispatch.on('stateChange', function(e) { nv.log('New State:', JSON.stringify(e)); });

  return chart;
  });
});
});
