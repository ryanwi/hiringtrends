'use strict';

let terms;
let categories;
let series;

const highChartConverter = (function ( $ ) {

  return  {

    convertCategories: function () {
      // initialize  xaxis categories (months)
      const months = [];
      $.map(data, function ( datapoint, i ) {
        months.push(datapoint["month"]);
      });

      return months;
    },

    convertSeries: function () {
      // initialize series data
      const series = [];
      $.map(terms, function ( term, i ) {
        const term_data = { "name": term, "data": [], "total_mentions": 0 }
        // build data
        $.map(data, function ( datapoint, i ) {
          term_data["data"].push( datapoint["terms"][term]["percentage"] );
          term_data["total_mentions"] += datapoint["terms"][term]["count"];
        });

        // calculate YOY change
        let first = term_data["data"][term_data["data"].length-13];
        let last = term_data["data"][term_data["data"].length-1]

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

  }

}) ( jQuery );

const chartBuilder = (function ( $ ) {

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
      const compareTerms = $(".term-compare").map(function(i, val) {
        return val.value.toLowerCase();
      }).get();
      const compareSeries = series.filter(function(val, i) {
        return compareTerms.includes(val.name.toLowerCase());
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
  const url = new URL(window.location);
  let comparisons = url.searchParams.getAll("compare");
  if (comparisons.length > 0) {
    if (comparisons.length < 4) {
      comparisons = comparisons.concat(Array(4-comparisons.length).fill(""));
    }

    $("div#term_comparisons").empty();    
    comparisons.forEach(function(queryTerm) {
      $("div#term_comparisons").append(
        $("<div class=\"col\">").append(
          $("<input/>", {
            type: 'text',
            name: 'compare',
            value: queryTerm,
            class: "term-compare form-control"
          })
        )
      );
    });
    
    chartBuilder.renderComparison();
  } else {
    chartBuilder.renderTopTerms(5);
  }

  // wire up autocomplete
  $( ".term-compare" ).autocomplete({
    source: terms
  });

});
