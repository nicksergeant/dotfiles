const { execSync } = require('child_process');

const dayText = execSync('pbpaste').toString();
const day = dayText.split('\n')[0];

const dayString = day.match(/\w+, \w+ \d+, \d{4}$/);

if (dayString) {
  const events = dayText.replace(dayString, '').split('\n---\n');

  let firstEvent = true;

  for (i in events) {
    const event = events[i].trim();
    const eventLines = event.split('\n');
    const eventTime = eventLines[0]
      .split(' - ')[0]
      .replace(' AM', 'a')
      .replace(' PM', 'p');
    const eventTitle = eventLines[1].replace('❇️ ', '');

    if (
      !eventTime.includes('all-day') &&
      !eventTitle.includes("Get Arlene's mail") &&
      !eventTitle.includes('Focus Time') &&
      !eventTitle.includes('Take garbage') &&
      !eventTitle.includes('Water herbs')
    ) {
      let title = eventTitle;

      if (eventTitle.includes('Lunch')) {
        title = 'Workout';
      }

      if (event.includes('hubspot.zoom.us')) {
        const zoomLink = event.match(/(https:\/\/hubspot.zoom.us)[^\s]+/);

        if (zoomLink) {
          title = `[${eventTitle}](${zoomLink[0]})`;
        }
      }

      console.log(`${firstEvent ? '' : '- [ ] '}${eventTime} ${title}`);

      firstEvent = false;
    }
  }
}
