const fs = require('fs');
const https = require('https');

const VERSION = process.argv[2].replace(/^v/, '');
const CHANGELOG_FILE = 'docs/changelog.md';
const USER = 'lumin-dev'
const PROJECT = 'LuminFramework'

const extractChangelog = (version) => {
  const changelog = fs.readFileSync(CHANGELOG_FILE, 'utf8');
  const regex = new RegExp(`## ${version}\\s*(.*?)\n## `, 's');
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

const fetchPreviousTag = async () => {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.github.com',
      path: `/repos/${USER}/${PROJECT}/releases`,
      method: 'GET',
      headers: {
        'User-Agent': 'Node.js',
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const releases = JSON.parse(data);
          if (releases.length >= 2) {
            const previousTag = releases[1].tag_name
            resolve(previousTag);
          } else {
            resolve('main')
          }
        } catch (error) {
          reject(error);
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.end();
  });
};

const createReleaseNotes = async (version) => {
  try {
    const data = await fetchQuote();
    const previousVersion = await fetchPreviousTag();
    const changelog = extractChangelog(version);
    const trimmedChangelog = changelog.replace('/##/d', '')
    if (changelog) {
      const releaseNotes = `**${data[0]} - ${data[1]}**\n\n${trimmedChangelog}\n\n**Internal changes:** https://github.com/${USER}/${PROJECT}/compare/${previousVersion}...v${VERSION}`;
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
