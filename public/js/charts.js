(function() {

  $(function() {
    $(".vote-chart").each(function(i, container) {
      var chart;
      return chart = new Highcharts.Chart({
        chart: {
          renderTo: $(container).attr("id")
        },
        title: {
          text: "Round " + $(container).data("round") + " User Votes"
        },
        xAxis: {
          categories: $(container).data("teams")
        },
        yAxis: {
          min: 0,
          title: {
            text: "Number of Votes"
          },
          plotLines: [
            {
              id: "limit-min",
              color: "#FF0000",
              dashStyle: "ShortDash",
              label: "Average",
              width: 2,
              value: $(container).data("average"),
              zIndex: 1
            }
          ]
        },
        legend: false,
        tooltip: {
          formatter: function() {
            return "" + this.x + ": " + this.y;
          }
        },
        plotOptions: {
          bar: {
            pointPadding: 0.2,
            borderWidth: 0,
            colorByPoint: true
          }
        },
        series: [
          {
            type: "bar",
            data: $(container).data("votes")
          }
        ]
      });
    });
    $(".dist-chart").each(function(i, container) {
      var chart;
      return chart = new Highcharts.Chart({
        chart: {
          renderTo: $(container).attr("id")
        },
        title: {
          text: "Round " + $(container).data("round") + " Investment"
        },
        xAxis: {
          categories: $(container).data("teams")
        },
        yAxis: {
          min: 0,
          title: {
            text: "Percentage Score"
          },
          plotLines: [
            {
              id: "limit-min",
              color: "#FF0000",
              dashStyle: "ShortDash",
              label: "Average",
              width: 2,
              value: $(container).data("average"),
              zIndex: 1
            }
          ]
        },
        legend: false,
        tooltip: {
          formatter: function() {
            return "" + this.x + ": " + this.y + " %";
          }
        },
        plotOptions: {
          bar: {
            pointPadding: 0.2,
            borderWidth: 0,
            colorByPoint: true
          }
        },
        series: [
          {
            type: "bar",
            data: $(container).data("results")
          }
        ]
      });
    });
    return $(".price-chart").each(function(i, container) {
      var chart, color, new_data, new_prices, old_prices;
      old_prices = $(container).data("old_prices");
      new_prices = $(container).data("prices");
      new_data = [];
      for (i in new_prices) {
        color = (new_prices[i] > old_prices[i] ? "green" : (new_prices[i] < old_prices[i] ? "red" : "#666666"));
        new_data.push({
          y: new_prices[i],
          color: color
        });
      }
      return chart = new Highcharts.Chart({
        chart: {
          renderTo: $(container).attr("id")
        },
        title: {
          text: "Round " + $(container).data("round") + " calculated prices"
        },
        xAxis: {
          categories: $(container).data("teams")
        },
        yAxis: {
          min: 0,
          title: {
            text: "Share price"
          }
        },
        legend: false,
        tooltip: {
          formatter: function() {
            return "" + this.x + ": $" + this.y;
          }
        },
        plotOptions: {
          bar: {
            pointPadding: 0.2,
            borderWidth: 0
          }
        },
        series: [
          {
            name: "old price",
            type: "bar",
            color: "#BBBBBB",
            data: $(container).data("old_prices")
          }, {
            name: "new price",
            type: "bar",
            data: new_data
          }
        ]
      });
    });
  });

}).call(this);
