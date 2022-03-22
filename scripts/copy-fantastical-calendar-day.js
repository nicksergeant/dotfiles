import { execSync } from 'child_process';

const MODE = 'things'; // 'things' or 'markdown'

const dayText = execSync('pbpaste').toString();
const day = dayText.split('\n')[0];
const dayString = day.match(/\w+, \w+ \d+, \d{4}$/);

if (dayString) {
  const eventsRaw = dayText.replace(dayString, '').split('\n---\n');
  const events = [];

  let firstEvent = true;

  for (var i in eventsRaw) {
    const event = eventsRaw[i].trim();
    const eventLines = event.split('\n');
    const eventTime = eventLines[0]
      .split(' - ')[0]
      .replace(' AM', 'a')
      .replace(' PM', 'p');
    const eventTitle = eventLines[1].replace('❇️ ', '');
    const lastEvent = parseInt(i) === eventsRaw.length - 1;

    if (!eventTime.includes('all-day')) {
      let title = eventTitle;

      if (MODE === 'markdown') {
        console.log(`[ ] ${eventTime} ${title}${!lastEvent ? '\n' : ''}`);
      } else if (MODE === 'things') {
        events.push(`${eventTime} ${title}`);
      }

      firstEvent = false;
    }
  }

  if (MODE === 'things' && events.length) {
    console.log(events.join('\n'));
  }
}
