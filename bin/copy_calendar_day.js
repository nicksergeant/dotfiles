const { execSync } = require('child_process');
const open = require('open');

const dayText = execSync('pbpaste').toString();
const day = dayText.split('\n')[0];

const dayString = day.match(/\w+, \w+ \d+, \d{4}$/);

if (dayString) {
  const eventsRaw = dayText.replace(dayString, '').split('\n---\n');

  let firstEvent = true;

  const events = [];

  for (i in eventsRaw) {
    const event = eventsRaw[i].trim();
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
      !eventTitle.includes('Water herbs') &&
      !eventTitle.includes('Lunch (via Clockwise)')
    ) {
      let title = eventTitle.replace('&', 'and');

      // if (event.includes('hubspot.zoom.us')) {
      //   const zoomLink = event.match(/(https:\/\/hubspot.zoom.us)[^\s]+/);

      //   if (zoomLink) {
      //     title = `${eventTitle} ${zoomLink[0]}`;
      //   }
      // }

      events.push(`${eventTime} ${title}`);

      firstEvent = false;
    }
  }

  let thingsUrl = '';

  if (events.length) {
    thingsUrl = `things:///add?titles=${events.join('\n')}&when=Today&tags=Meeting,Work`;
  }

  open(thingsUrl);
}
