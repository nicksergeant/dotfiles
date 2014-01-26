if ($('div.issue-list').length) {

  var issues = $('div.issue-list-item');

  $.each(issues, function(i) {

    var issue = $(issues[i]);

    issue.css({
      'margin-bottom': '10px',
      'padding-bottom': '10px'
    });

    $('p.description', issue).remove();

    var octicon = $('span.mega-octicon', issue);
    var repo = $('ul.issue-meta li:first-child', issue);
    var repoLink = $('a', repo);
    var title = $('p.title');
    var titleLink = $('p.title a', issue);

    octicon.css({
      'font-size': '16px',
      'margin-left': '11px',
      'margin-top': '9px'
    });
    repo.remove();
    title.css('margin-bottom', '0');
    titleLink.before(repoLink);
    titleLink.before(' · ');

  });
}
