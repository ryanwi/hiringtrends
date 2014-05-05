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
          term_data["data"].push( datapoint["terms"][term]["count"] );
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
          text: 'Number of Comments mentioned'
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

var tableBuilder = (function ( $ ) {

  return {

    renderTopTerms: function() {
      var topTerms = series.slice(0, 10);
      $.each(topTerms, function ( i, val ) {
        $('#topterms tbody').append('<tr><td><a href="?compare1=' + encodeURIComponent(val.name) + '">' + val.name +'</a></td><td>' +
          val["latest_mentions"] +'</td></tr>');
      });
    },

    renderRising: function() {
      var rising = series.slice().sort(function( a,b ){ return b.change - a.change }).slice(0, 10);
      $.each(rising, function ( i, val ) {
        $('#rising tbody').append('<tr><td><a href="?compare1=' + encodeURIComponent(val.name) + '">' + val.name +'</a></td><td>' +
          val["latest_mentions"] + '</td><td>' +
          (val["change"]*100).toFixed(2) +'%</td></tr>');
      });
    },

    renderFalling: function( falling ) {
      var falling = series.slice().sort(function( a,b ){ return a.change - b.change }).slice(0, 10);
      $.each(falling, function ( i, val ) {
        $('#falling tbody').append('<tr><td><a href="?compare1=' + encodeURIComponent(val.name) + '">' + val.name +'</a></td><td>' +
          val["latest_mentions"] + '</td><td>' +
          (val["change"]*100).toFixed(2) +'%</td></tr>');
      });
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

  // populate rising/falling tables
  // tableBuilder.renderTopTerms();
  // tableBuilder.renderRising();
  // tableBuilder.renderFalling();

  // wire up autocomplete
  $( ".term-compare" ).autocomplete({
    source: terms
  });

});
