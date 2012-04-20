$(function(){

  
  $('.dist-chart').each(function(i,container) {
    chart = new Highcharts.Chart({
      chart: { renderTo: $(container).attr('id') },

      title: { text: 'Round ' + $(container).data("round") + ' distribution'},

      xAxis: { categories: $(container).data('teams').split(',') },

      yAxis: 
      { 
        min: 0, 
        title: { text: 'Percentage Score' },
        plotLines: [{
          id: 'limit-min',
          color: '#FF0000',
          dashStyle: 'ShortDash', 
          label: 'Average',
          width: 2,
          value: $(container).data('average'),
          zIndex: 1
        }]
      },

      legend: false,

      tooltip: 
      {
        formatter: function() { return ''+ this.x +': '+ this.y +' %'; }
      },

      plotOptions: 
      {
        column: {
          pointPadding: 0.2,
          borderWidth: 0, 
          colorByPoint: true
        },
        series: { animation: {enabled: true, duration: 3000} }
      },

      series: [{
        type: "column",
        data:  JSON.parse("[" + $(container).data('results') + "]") 
      }]

    });
  });

  $('.price-chart').each(function(i,container) {

    var old_prices = JSON.parse("[" + $(container).data('old_prices') +"]")
    , new_prices = JSON.parse("[" + $(container).data('prices') +"]")
    , new_data = [];

    //colorize the movement
    for (var i in new_prices) {
      var color = (new_prices[i] > old_prices[i]) ? "green" : ((new_prices[i] < old_prices[i]) ? "red" : "#666666"); 
      new_data.push({y: new_prices[i], color: color});
    }

    chart = new Highcharts.Chart({
      chart: { renderTo: $(container).attr('id') },

      title: { text: 'Round ' + $(container).data("round") + ' prices'},

      xAxis: { categories: $(container).data('teams').split(',') },

      yAxis: 
      { 
        min: 0, 
        title: { text: 'Share price' }
      },

      legend: false,

      tooltip: 
      {
        formatter: function() { return ''+ this.x +': $'+ this.y; }
      },

      plotOptions: 
      {
        column: {
          pointPadding: 0.2,
          borderWidth: 0    
        },
        series: { animation: {enabled: true, duration: 3000} }
      },

      series: [{
        name: "old price",
        type: "column",
        color: "#BBBBBB",
        data:  JSON.parse("[" + $(container).data('old_prices') + "]") 
      }, {
        name: "new price",
        type: "column",
        data: new_data
      }]

    });
  });
});