import { execSync } from 'child_process';

const dayText = execSync('pbpaste').toString();
const day = dayText.split('\n')[0];
const dayString = day.match(/\w+, \w+ \d+, \d{4}$/);

if (dayString) {
  const eventsRaw = dayText.replace(dayString, '').split('\n---\n');

  for (var i in eventsRaw) {
    const event = eventsRaw[i].trim();
    const eventLines = event.split('\n');
    const eventTime = eventLines[0]
      .split(' - ')[0]
      .replace(' AM', 'a')
      .replace(' PM', 'p');
    const eventTitle = eventLines[1].replace('❇️ ', '');

    if (!eventTime.includes('all-day')) {
      console.log(`${eventTime} ${eventTitle}`);
    }
  }
}
