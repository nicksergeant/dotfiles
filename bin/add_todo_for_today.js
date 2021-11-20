import { format, isWeekend, nextMonday, startOfTomorrow } from 'date-fns';
import fs from 'fs';

const log = fs.readFileSync('/Users/nsergeant/Downloads/daily.md', 'utf8');

const dates = {
  today: new Date(),
  tomorrow: startOfTomorrow(),
  get nextWorkDay() {
    return isWeekend(this.tomorrow) ? nextMonday(this.tomorrow) : this.tomorrow;
  },
};

const logsRaw = log.split('\n\n');

const firstFiveLogs = logsRaw.slice(0, 5).map((d) => {
  return d.split('\n');
});

const restOfLogs = logsRaw.slice(4);

const fmt = (date) => format(date, '# yyyy-LL-dd (EEEE)');
const logForDay = (day) => firstFiveLogs.find((d) => d[0] === fmt(day));
const addToLog = (log, task) => [...log, `- [ ] ${task}`];

const logs = {
  today: logForDay(dates.today),
  tomorrow: logForDay(dates.tomorrow),
  nextWorkDay: logForDay(dates.nextWorkDay),
};

console.log(addToLog(logs.today, 'hey'));

// NS TODO: Rebuild log file and save it.
