const fs = require('fs');
const https = require('https');

const VERSION = process.argv[2];
const PREVIOUS_VERSION = process.argv[3];
const CHANGELOG_FILE = 'docs/changelog.md';
const USER = 'lumin-dev'
const PROJECT = 'LuminFramework'

const extractChangelog = (version) => {
  const changelog = fs.readFileSync(CHANGELOG_FILE, 'utf8');
  const regex = new RegExp(`## \\[${version}\\]([\\s\\S]*?)(?=## \\[|$)`);
  const match = changelog.match(regex);
  return match ? match[0].trim() : null;
};

const fetchQuote = () => {
  return new Promise((resolve, reject) => {
    https.get('https://zenquotes.io/api/random', (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        const result = JSON.parse(data)[0]
        resolve([result.q, result.a]);
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
};

const createReleaseNotes = async (version) => {
  try {
    const data = await fetchQuote();
    const changelog = extractChangelog(version);
    if (changelog) {
      const releaseNotes = `**${data[0]} - ${data[1]}**\n\n${changelog}\n\n**Internal changes:** https://github.com/${USER}/${PROJECT}/compare/v${PREVIOUS_VERSION}...v${VERSION}`;
      fs.writeFileSync('release_log.md', releaseNotes);
      console.log('Release notes created successfully.');
    } else {
      console.error('Changelog section not found.');
    }
  } catch (error) {
    console.error('Error fetching quote:', error);
  }
};

createReleaseNotes(VERSION);
