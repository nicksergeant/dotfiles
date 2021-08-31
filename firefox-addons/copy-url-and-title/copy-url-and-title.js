const copyUrlAndTitle = () => {
  const title = document.title;
  const url = document.URL;

  markdownLabel = title;
  markdownUrl = url;

  if (url.includes('git.hubteam.com')) {
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
  } else if (url.includes('issues.hubspotcentral.com')) {
    const urlMatches = /.*browse\/(\w+-\d+).*/i.exec(document.URL);

    if (urlMatches) {
      const ticketId = urlMatches[1];

      markdownLabel = title
        .replace(`[${ticketId}] `, '')
        .replace(' - HubSpot JIRA', '');
    }
  }

  markdownLabel = markdownLabel.replace('[', '(').replace(']', ')');

  navigator.clipboard.writeText(
    `[${markdownLabel}](${markdownUrl})`,
  );
};

const handleKeyDown = e => {
  if (e.altKey && e.ctrlKey && e.shiftKey && e.metaKey && e.keyCode === 32) {
    copyUrlAndTitle();
  }
};

document.addEventListener('keydown', handleKeyDown);
