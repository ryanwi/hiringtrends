'use strict';

let terms;
let categories;
let series;

const populateTermsDatalist = (dataListElement, optionList) => {
  const list = document.getElementById(dataListElement); 
  optionList.forEach(item => {
    let option = document.createElement('option');
    option.value = item;   
    list.appendChild(option);
  });
};

const highChartConverter = (function () {

  return  {

    convertCategories: function () {
      // initialize  xaxis categories (months)
      const months = [];
      data.map(function ( datapoint, i ) {
        const dateString = datapoint["month"];
        const dataMonth = dateString.slice(0, 3);
        const dataYear = dateString.slice(3);
        const dataDate = new Date(`${dataMonth} 1, ${dataYear}`);
        months.push(dataDate);
      });

      return months;
    },

    convertSeries: function () {
      // initialize series data
      const series = [];
      terms.map(function ( term, i ) {
        const term_data = { "name": term, "data": [], "total_mentions": 0 }
        // build data
        data.map(function ( datapoint, i ) {
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

    convertCountYoySeries: function () {
      const countSeries = [];
      const months = {'Jan':0,'Feb':1,'Mar':2,'Apr':3,'May':4,'Jun':5,'Jul':6,'Aug':7,'Sep':8,'Oct':9,'Nov':10,'Dec':11};
      const years = {'20':0, '21':1, '22':2, '23':3};
      for (const [key, value] of Object.entries(years)) {
        countSeries.push({ name: "'" + key, data: [0,0,0,0,0,0,0,0,0,0,0,0]});
      }
      data.map(function(value, index) {
        const month = value.month.substr(0, 3);
        const year = value.month.substr(3, 2);
        if (typeof countSeries[years[year]] !== 'undefined') {
          countSeries[years[year]].data[months[month]] = parseInt(value.num_comments);
        }
      });

      return countSeries;
    }

  }

}) ();

const chartBuilder = (function () {

  function render( seriesData ) {
    Highcharts.chart({
      chart: {
        renderTo: 'chart',
        type: 'line'
      },
      title: {
        text: 'September 2023 Hacker News Hiring Trends'
      },
      // subtitle: {
      //   text: 'September 2023 Hacker News Hiring Trends'
      // },
      xAxis: {
        type: 'datetime',
        categories: categories,
        type: 'datetime',
        labels: {
          step: 4,
          rotation: [-45],
          formatter: function() {
            return Highcharts.dateFormat('%Y', this.value);
          }
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
      let compareTerms = [];
      for (let item of document.getElementsByClassName("term-compare")) {
        compareTerms.push(item.value.toLowerCase());
      }
      const compareSeries = series.filter(function(val, i) {
        return compareTerms.includes(val.name.toLowerCase());
      });

      render( compareSeries );
    }
  }

}) ();

window.addEventListener('DOMContentLoaded', (event) => {
  data.reverse();
  terms = Object.keys( data[0]["terms"] );

  // transform raw data in to format consumable by highcharts
  categories = highChartConverter.convertCategories();
  series = highChartConverter.convertSeries();

  // sort by cumulative popularity
  series.sort(function(a,b){ return b.latest_mentions - a.latest_mentions });

  // wire up top terms filter
  const selectElement = document.querySelector('#topfilter');
  selectElement.addEventListener('change', (event) => {
    chartBuilder.renderTopTerms( parseInt(event.target.value) );
  });  

  // process url parameters if present
  const url = new URL(window.location);
  let comparisons = url.searchParams.getAll("compare");
  if (comparisons.length > 0) {
    if (comparisons.length < 4) {
      comparisons = comparisons.concat(Array(4-comparisons.length).fill(""));
    }

    const comparisonsParent = document.getElementById("term_comparisons");
    while (comparisonsParent.firstChild) {
      comparisonsParent.firstChild.remove()
    }
    var fragment = new DocumentFragment();
    comparisons.forEach(function(queryTerm) {
      var div = document.createElement("div");
      div.className = 'col';
      var input = document.createElement("input");
      input.value = queryTerm;
      input.type = 'text';
      input.className = 'term-compare form-control';
      input.name = 'compare';
      div.appendChild(input);
      fragment.appendChild(div);
    });
    comparisonsParent.appendChild(fragment);

    chartBuilder.renderComparison();
  } else {
    chartBuilder.renderTopTerms(5);
  }

  Highcharts.chart('total_postings_history_chart',{
    chart: {
      type: 'line'
    },
    legend: {
      enabled: false
    },
    title: {
      text: 'Ask HN: Who is hiring? Total Job Postings'
    },
    subtitle: {
      text: 'September 2023'
    },
  yAxis: {
      title: {
        text: 'Number of Job Postings'
      },
      min: 0
    },
    xAxis: {
      type: 'datetime',
      categories: categories,
      dateTimeLabelFormats: {
        month: '%b %y'
      },
      labels: {
        rotation: [-45],
        step: 5,
        formatter: function() {
          return Highcharts.dateFormat('%Y', this.value);
        }
    },
      accessibility: {
        rangeDescription: 'Range: April 2011 to 2023'
      }
    },
    plotOptions: {
    },
    series: [
      {
        name: 'Total Job Postings',
        data: data.map(function(value, index) { return [parseInt(value["num_comments"])] })
      }]
  });

  populateTermsDatalist('datalistTerms', terms);
});
