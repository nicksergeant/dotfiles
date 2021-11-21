import { format, isWeekend, nextMonday, startOfTomorrow } from 'date-fns';
import fs from 'fs';

const DATE_FORMAT = '# yyyy-LL-dd (EEEE)';

const logFile = '/Users/nsergeant/Documents/Notes/daily.md';
const logLines = fs.readFileSync(logFile, 'utf8');
const newTask = process.argv[3];
const tomorrowDate = startOfTomorrow();
const dates = {
  today: format(new Date(), DATE_FORMAT),
  tomorrow: format(startOfTomorrow(), DATE_FORMAT),
  nextWorkDay: format(
    isWeekend(tomorrowDate) ? nextMonday(tomorrowDate) : tomorrowDate,
    DATE_FORMAT
  ),
};

const targetDay = dates[process.argv[2]];
const separator =
  '\n\n----------------------------------------------------------------------\n\n';
const [headers, logsRaw] = logLines.split(separator);

let logs = logsRaw.split('\n\n').map((l) => l.split('\n'));
let logForTargetDay = logs.find((l) => l[0] === targetDay);
if (logForTargetDay) {
  logs[logs.indexOf(logForTargetDay)] = [
    ...logForTargetDay,
    `- [ ] ${newTask}`,
  ];
} else {
  logForTargetDay = [targetDay, `- [ ] ${newTask}`];
  logs.unshift(logForTargetDay);
}

fs.writeFileSync(
  logFile,
  `${headers}${separator}${logs.map((l) => l.join('\n')).join('\n\n')}`
);
