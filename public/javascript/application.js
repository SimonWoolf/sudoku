$(document).ready(function () {

  function isDay() {
    return $('body').css('background-color').match(/255/);
  };

  function bgcolor(day) {
    return day ? 'black' : 'white';
  };

  function fgcolor(day) {
    return day ? 'white' : 'black';
  }

  $('#night').on('click', function(event) {
    event.preventDefault();
    day = !!isDay();
    $('body').css('background-color', bgcolor(day));
    $('h1,h2,h3,h4,button').css('color', fgcolor(day));
    $('button').css('border-color', fgcolor(day));
  });
});
