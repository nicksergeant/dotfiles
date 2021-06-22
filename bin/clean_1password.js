const {execSync} = require('child_process');

// Sensitive accounts that we don't want to touch.
const EXCLUDED_ACCOUNTS = [
  '1Password Account (Ashley Sergeant)',
  '1Password Account (Nick Sergeant)',
  'fastmail.com',
];

const items = JSON.parse(
  execSync('op list items --categories Login').toString(),
).filter(
  i =>
    i.trashed === 'N' &&
    !EXCLUDED_ACCOUNTS.includes(i.overview.title) &&
    i.overview &&
    i.overview.url &&
    i.overview.url.includes('http'),
);

let currentItem = 1;
const totalItems = items.length;

const cleanUrl = url => {
  if (!url.includes('http')) {
    return url;
  } else {
    return new URL(url).hostname;
  }
};

items.forEach(i => {
  const item = JSON.parse(execSync(`op get item ${i.uuid}`).toString());
  const urls = (item.overview && item.overview.URLs) || [];
  const percentDone = Math.floor((currentItem / totalItems) * 100);

  console.log(
    `- ${percentDone}% [${currentItem}/${totalItems}] ${i.overview.title} ${i.uuid}`,
  );

  if (urls.length === 1) {
    const cleanedUrl = cleanUrl(urls[0].u);
    console.log(`op edit item ${i.uuid} url=${cleanedUrl}`);
    execSync(`   op edit item ${i.uuid} url=${cleanedUrl}`);
  } else if (urls.length > 1) {
    console.log(`!! Manual edit needed for multiple URLs: ${i.uuid}`);
  }

  currentItem++;
})
