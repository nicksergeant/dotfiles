'use strict';

$(function() {

  var ready = false;

  var checkReady = function() {
    if ($('#AccountSummaryTransactionTable tbody tr').length > 1) {
      ready = true;
      init();
    } else {
      setTimeout(checkReady, 500);
    }
  };
  var init = function() {
    var businessCats = ['Consulting', 'Domains', 'Hardware', 'Hosting', 'Services', 'Software'];
    var $transactions = $('#AccountSummaryTransactionTable tbody tr');

    $.each($transactions, function(i) {

      var t = $transactions.eq(i);
      var cat = $('input.categoryInputElement', t).val();

      if (businessCats.indexOf(cat) !== -1) {
        t.css({
          'background': '#eef9fe',
          'background-image': 'none'
        });
      } else {
        t.css({
          'background': 'white',
          'background-image': 'none'
        });
      }
    });

    setTimeout(init, 1000);
  };

  checkReady();
});
