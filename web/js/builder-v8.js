var terms;
var categories;
var series;

function parseQueryString() {
    var query = (location.search || '?').substr(1),
        map   = {};
    query.replace(/([^&=]+)=?([^&]*)(?:&+|$)/g, function(match, key, value) {
        if (key.match(/compare[1-4]/gi)) {
            (map[key] = map[key] || []).push(decodeURIComponent(value.replace( /\+/g, '%20' )));
        }
    });
    return map;
}

var highChartConverter = (function ( $ ) {

  return  {

    convertCategories: function () {
      // initialize  xaxis categories (months)
      var months = [];
      $.map(data, function ( datapoint, i ) {
        months.push(datapoint["month"]);
      });
      return months;
    },

    convertSeries: function () {
      // initialize series data
      var series = [];
      $.map(terms, function ( term, i ) {
        var term_data = { "name": term, "data": [], "total_mentions": 0 }
        // build data
        $.map(data, function ( datapoint, i ) {
          term_data["data"].push( datapoint["terms"][term]["percentage"] );
          term_data["total_mentions"] += datapoint["terms"][term]["count"];
        });

        // calculate YOY change
        var first = term_data["data"][term_data["data"].length-13];
        var last = term_data["data"][term_data["data"].length-1]

        // assign a floor to have more meaningful change calculation
        if (first == 0) {
          first = 1;
        }
        if (last == 0) {
          last = 1;
        }

        term_data["change"] = (last - first) / first;
        term_data["latest_mentions"] = last;
        series.push(term_data);
      });

      return series;
    },

    convertCountYoySeries: function () {
      var countSeries = [];
      var months = {'Jan':0,'Feb':1,'Mar':2,'Apr':3,'May':4,'Jun':5,'Jul':6,'Aug':7,'Sep':8,'Oct':9,'Nov':10,'Dec':11};
      var years = {'13':0, '14':1, '15':2, '16':3, '17':4, '18':5};
      $.each(years, function(key, value) {
        countSeries.push({ name: "'" + key, data: [0,0,0,0,0,0,0,0,0,0,0,0]});
      });
      $.map(data, function(value, index) {
        var month = value.month.substr(0, 3);
        var year = value.month.substr(3, 2);
        if (typeof countSeries[years[year]] !== 'undefined') {
          countSeries[years[year]].data[months[month]] = parseInt(value.num_comments);
        }
      });
      // [{
      //             name: 'Year 1800',
      //             data: [107, 31, 635, 203, 2]
      //         }, {
      //             name: 'Year 1900',
      //             data: [133, 156, 947, 408, 6]
      //         }, {
      //             name: 'Year 2012',
      //             data: [1052, 954, 4250, 740, 38]
      //         }]

      return countSeries;
    }

  }

}) ( jQuery );

var chartBuilder = (function ( $ ) {

  function render( seriesData ) {
    $('#chart').highcharts({
      chart: {
        type: 'line'
      },
      title: {
        text: ''
      },
      xAxis: {
        categories: categories,
        labels: {
          step: 3,
          staggerLines: 1
        }
      },
      yAxis: {
        title: {
          text: 'Percentage of posts'
        },
        min: 0
      },
      tooltip: {
      },
      series: seriesData
    });
  }

  return {

    renderTopTerms: function( numTerms ) {
      render( series.slice( 0, numTerms ) );
    },

    renderComparison: function() {
      var compareTerms = [];
      var compareSeries = [];
      $(".term-compare").each ( function ( i, val ) {
        compareTerms.push( val.value.toLowerCase() );
      });
      $.each(series, function ( i, val) {
        if ( $.inArray(val.name.toLowerCase(), compareTerms) > -1 ) {
          compareSeries.push( val );
        }
      });
      render( compareSeries );
    }
  }

}) ( jQuery );

$(function () {
  data.reverse();
  terms = Object.keys( data[0]["terms"] );

  // transform raw data in to format consumable by highcharts
  categories = highChartConverter.convertCategories();
  series = highChartConverter.convertSeries();

  // sort by cumulative popularity
  series.sort(function(a,b){ return b.latest_mentions - a.latest_mentions });

  // wire up top terms filter
  $( "#topfilter" ).on( "change", function ( e ) {
    chartBuilder.renderTopTerms( parseInt($(this).val()) );
  });

  // process url parameters if present
  var urlParams = parseQueryString();
  if ( Object.keys( urlParams ).length > 0 ) {
    for (var term in urlParams) {
      $("input[name=" + term + "]").val( urlParams[term] );
    }
    chartBuilder.renderComparison();
  } else {
    chartBuilder.renderTopTerms( 5 );
  }

  $('#comments_chart').highcharts({
    chart: {
      type: 'column'
    },
    title: {
      text: ''
    },
    xAxis: {
      categories: [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ],
    },
    yAxis: {
      min: 0,
      title: {
        enabled: false,
      },
      labels: {
      }
    },
    legend: {
      enabled: true
    },
    series: highChartConverter.convertCountYoySeries()
  });

  // wire up autocomplete
  $( ".term-compare" ).autocomplete({
    source: terms
  });

});
