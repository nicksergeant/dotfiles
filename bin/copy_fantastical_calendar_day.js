const open = require('open');
const { execSync } = require('child_process');

const dayText = execSync('pbpaste').toString();
const day = dayText.split('\n')[0];

const dayString = day.match(/\w+, \w+ \d+, \d{4}$/);

const mode = 'things'; // 'things' or 'markdown'

if (dayString) {
  const eventsRaw = dayText.replace(dayString, '').split('\n---\n');
  const events = [];

  for (i in eventsRaw) {
    const event = eventsRaw[i].trim();
    const eventLines = event.split('\n');
    const eventTime = eventLines[0]
      .split(' - ')[0]
      .replace(' AM', 'a')
      .replace(' PM', 'p');
    const eventTitle = eventLines[1].replace('❇️ ', '');
    const lastEvent = parseInt(i) === (eventsRaw.length - 1);

    if (
      !eventTime.includes('all-day') && event.toLowerCase().includes('trajector')
    ) {
      let title = eventTitle;

      if (mode === 'markdown') {
        console.log(`[ ] ${eventTime} ${title}${!lastEvent ? '\n': ''}`);
      } else if (mode === 'things') {
        events.push(`${eventTime} ${title}`);
      }

      firstEvent = false;
    }
  }

  if (mode === 'things' && events.length) {
    open(`things:///add?titles=${events.join('\n')}&when=Today&tags=Meeting`)
  }
}
