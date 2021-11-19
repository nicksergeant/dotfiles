title = document.title;
url = document.URL;

markdownLabel = title;
markdownUrl = url;

if (url.includes('github.com')) {
  if (url.includes('/pull/')) {
    const urlMatches = /.*pull\/(\d+).*/i.exec(document.URL);

    if (urlMatches) {
      const pullRequestId = urlMatches[1];
      const repo = /.*Pull Request #\d+ · (.*)/.exec(document.title)[1];

      markdownLabel = title.replace(
        ` · Pull Request #${pullRequestId} · ${repo}`,
        '',
      );
    }
  } else if (url.includes('/issues/')) {
    const urlMatches = /.*issues\/(\d+).*/i.exec(document.URL);

    if (urlMatches) {
      const issueId = urlMatches[1];
      const repo = /.*Issue #\d+ · (.*)/.exec(document.title)[1];

      markdownLabel = title.replace(` · Issue #${issueId} · ${repo}`, '');
    }
  }
}

markdownLabel = markdownLabel.replace('[', '(').replace(']', ')');

`[${markdownLabel}](${markdownUrl})`;
