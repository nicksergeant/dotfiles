import { execSync } from 'child_process';

const dayText = execSync('pbpaste').toString();
const day = dayText.split('\n')[0];
const dayString = day.match(/\w+, \w+ \d+, \d{4}$/);
const ignores = ['Lunch (via Clockwise)', 'Take garbage and recycling out'];

if (dayString) {
  const eventsRaw = dayText.replace(dayString, '').split('\n---\n');
  const events = [];

  for (var i in eventsRaw) {
    const event = eventsRaw[i].trim();
    const eventLines = event.split('\n');
    const eventTime = eventLines[0].split(' - ')[0];
    const eventTitle = eventLines[1].replace('❇️ ', '');

    if (
      !eventTime.includes('all-day') &&
      !ignores.find((ignore) => eventTitle === ignore)
    ) {
      let title = eventTitle;
      events.push(`${eventTime} ${title}`);
    }
  }

  console.log(events.join('\n'));
}
