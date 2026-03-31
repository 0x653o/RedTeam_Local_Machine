// ──────────────────────────────────────────────────────
// Local-Machine Portal — Server
// ──────────────────────────────────────────────────────
// Lightweight dashboard with gamification features.
// Uses flat JSON file storage — intentionally simple.
// ──────────────────────────────────────────────────────

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const express = require('express');
const cookieParser = require('cookie-parser');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// ── Configuration ────────────────────────────────────
const PORT = 8443;
const PORTAL_SECRET = process.env.PORTAL_SECRET || 'change-me';
const FLAG_SEED = process.env.FLAG_SEED || 'default-seed';
const TOTAL_MACHINES = parseInt(process.env.TOTAL_MACHINES || '42');
const DATA_DIR = path.join(__dirname, '..', 'data');

// Ensure data directory
if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
}

// ── Machine Database ─────────────────────────────────
const MACHINES = [
    { id: 1,  name: 'Log4Hell',      cve: 'CVE-2021-44228',  cvss: 10.0, category: 'Web Server & Runtime',      difficulty: 'Medium',  points: 25  },
    { id: 2,  name: 'SpringBreak',   cve: 'CVE-2022-22965',  cvss: 9.8,  category: 'Web Server & Runtime',      difficulty: 'Medium',  points: 25  },
    { id: 3,  name: 'PathFinder',    cve: 'CVE-2021-41773',  cvss: 9.8,  category: 'Web Server & Runtime',      difficulty: 'Easy',    points: 10  },
    { id: 4,  name: 'StrutsZone',    cve: 'CVE-2017-5638',   cvss: 10.0, category: 'Web Server & Runtime',      difficulty: 'Medium',  points: 25  },
    { id: 5,  name: 'ShellShocked',  cve: 'CVE-2014-6271',   cvss: 10.0, category: 'Web Server & Runtime',      difficulty: 'Easy',    points: 10  },
    { id: 6,  name: 'PHPocalypse',   cve: 'CVE-2012-1823',   cvss: 9.8,  category: 'Web Server & Runtime',      difficulty: 'Easy',    points: 10  },
    { id: 7,  name: 'GhostCat',      cve: 'CVE-2020-1938',   cvss: 9.8,  category: 'Web Server & Runtime',      difficulty: 'Medium',  points: 25  },
    { id: 8,  name: 'DrupalDoom',    cve: 'CVE-2018-7600',   cvss: 9.8,  category: 'CMS & Web Application',     difficulty: 'Medium',  points: 25  },
    { id: 9,  name: 'PressGrave',    cve: 'CVE-2022-0739',   cvss: 9.8,  category: 'CMS & Web Application',     difficulty: 'Hard',    points: 50  },
    { id: 10, name: 'BulletProof',   cve: 'CVE-2019-16759',  cvss: 9.8,  category: 'CMS & Web Application',     difficulty: 'Medium',  points: 25  },
    { id: 11, name: 'Confluencer',   cve: 'CVE-2022-26134',  cvss: 9.8,  category: 'CMS & Web Application',     difficulty: 'Medium',  points: 25  },
    { id: 12, name: 'GitLabyrinth',  cve: 'CVE-2021-22205',  cvss: 10.0, category: 'CMS & Web Application',     difficulty: 'Hard',    points: 50  },
    { id: 13, name: 'GrafanLeak',    cve: 'CVE-2021-43798',  cvss: 7.5,  category: 'CMS & Web Application',     difficulty: 'Easy',    points: 10  },
    { id: 14, name: 'JoomBleed',     cve: 'CVE-2023-23752',  cvss: 7.5,  category: 'CMS & Web Application',     difficulty: 'Easy',    points: 10  },
    { id: 15, name: 'Ignition',      cve: 'CVE-2021-3129',   cvss: 9.8,  category: 'Framework & Library',       difficulty: 'Medium',  points: 25  },
    { id: 16, name: 'ThinkPwned',    cve: 'CVE-2018-20062',  cvss: 9.8,  category: 'Framework & Library',       difficulty: 'Easy',    points: 10  },
    { id: 17, name: 'ImageTragick',  cve: 'CVE-2016-3714',   cvss: 8.4,  category: 'Framework & Library',       difficulty: 'Medium',  points: 25  },
    { id: 18, name: 'ProtoPoison',   cve: 'CWE-1321',        cvss: 9.8,  category: 'Framework & Library',       difficulty: 'Hard',    points: 50  },
    { id: 19, name: 'PickleRick',    cve: 'CWE-502',         cvss: 9.8,  category: 'Framework & Library',       difficulty: 'Hard',    points: 50  },
    { id: 20, name: 'JWTwisted',     cve: 'CVE-2022-21449',  cvss: 9.8,  category: 'Framework & Library',       difficulty: 'Hard',    points: 50  },
    { id: 21, name: 'WebLogicBmb',   cve: 'CVE-2019-2725',   cvss: 9.8,  category: 'Framework & Library',       difficulty: 'Medium',  points: 25  },
    { id: 22, name: 'React2Shell',   cve: 'CVE-2025-55182',  cvss: 10.0, category: 'Framework & Library',       difficulty: 'Insane',  points: 100 },
    { id: 23, name: 'JenkinsOwned',  cve: 'CVE-2024-23897',  cvss: 9.8,  category: 'Enterprise Middleware',     difficulty: 'Hard',    points: 50  },
    { id: 24, name: 'ActiveMQtter',  cve: 'CVE-2023-46604',  cvss: 10.0, category: 'Enterprise Middleware',     difficulty: 'Medium',  points: 25  },
    { id: 25, name: 'RedisRaider',   cve: 'Miscfg',          cvss: 9.8,  category: 'Enterprise Middleware',     difficulty: 'Easy',    points: 10  },
    { id: 26, name: 'MongoMayhem',   cve: 'Miscfg+NoSQLi',   cvss: 9.1,  category: 'Enterprise Middleware',     difficulty: 'Medium',  points: 25  },
    { id: 27, name: 'ElasticPwn',    cve: 'CVE-2015-1427',   cvss: 9.8,  category: 'Enterprise Middleware',     difficulty: 'Medium',  points: 25  },
    { id: 28, name: 'SolrBlaze',     cve: 'CVE-2019-17558',  cvss: 9.8,  category: 'Enterprise Middleware',     difficulty: 'Medium',  points: 25  },
    { id: 29, name: 'BigIPwned',     cve: 'CVE-2022-1388',   cvss: 9.8,  category: 'Network Appliance & Proxy', difficulty: 'Medium',  points: 25  },
    { id: 30, name: 'CitrixBreaker', cve: 'CVE-2019-19781',  cvss: 9.8,  category: 'Network Appliance & Proxy', difficulty: 'Hard',    points: 50  },
    { id: 31, name: 'IvantiGate',    cve: 'CVE-2024-21887',  cvss: 9.1,  category: 'Network Appliance & Proxy', difficulty: 'Hard',    points: 50  },
    { id: 32, name: 'MinIOLeaker',   cve: 'CVE-2023-28432',  cvss: 9.8,  category: 'Network Appliance & Proxy', difficulty: 'Easy',    points: 10  },
    { id: 33, name: 'MOVEitMstr',    cve: 'CVE-2023-34362',  cvss: 9.8,  category: 'Data & File Transfer',      difficulty: 'Hard',    points: 50  },
    { id: 34, name: 'ApacheNght',    cve: 'CVE-2023-25690',  cvss: 9.8,  category: 'Data & File Transfer',      difficulty: 'Hard',    points: 50  },
    { id: 35, name: 'GoAnywher',     cve: 'CVE-2023-0669',   cvss: 9.8,  category: 'Data & File Transfer',      difficulty: 'Hard',    points: 50  },
    { id: 36, name: 'BaronSamedit',  cve: 'CVE-2021-3156',   cvss: 7.8,  category: 'Privilege Escalation',      difficulty: 'Hard',    points: 50  },
    { id: 37, name: 'PwnKit',        cve: 'CVE-2021-4034',   cvss: 7.8,  category: 'Privilege Escalation',      difficulty: 'Medium',  points: 25  },
    { id: 38, name: 'DirtyPipe',     cve: 'CVE-2022-0847',   cvss: 7.8,  category: 'Privilege Escalation',      difficulty: 'Hard',    points: 50  },
    { id: 39, name: 'V8_MapRem',     cve: 'CVE-2018-17463',  cvss: 8.8,  category: 'Advanced Exploitation',     difficulty: 'Hard',    points: 50  },
    { id: 40, name: 'V8_TurboConf',  cve: 'CVE-2020-6418',   cvss: 8.8,  category: 'Advanced Exploitation',     difficulty: 'Insane',  points: 100 },
    { id: 41, name: 'V8_OOBArray',   cve: 'CVE-2021-30632',  cvss: 8.8,  category: 'Advanced Exploitation',     difficulty: 'Insane',  points: 100 },
    { id: 42, name: 'JSC_JITRCE',    cve: 'CVE-2020-9802',   cvss: 8.8,  category: 'Advanced Exploitation',     difficulty: 'Insane',  points: 100 },
];

// ── Flag Validation ──────────────────────────────────
function generateFlag(type, machineId) {
    const id = String(machineId).padStart(2, '0');
    const prefix = type === 'root' ? 'machine' : 'user';
    const hash = crypto.createHash('sha256')
        .update(`${FLAG_SEED}:${prefix}_${id}`)
        .digest('hex')
        .substring(0, 32);
    return `FLAG{${hash}}`;
}

// ── Player Data Store ────────────────────────────────
const PLAYERS_FILE = path.join(DATA_DIR, 'players.json');

function loadPlayers() {
    try {
        return JSON.parse(fs.readFileSync(PLAYERS_FILE, 'utf8'));
    } catch {
        return {};
    }
}

function savePlayers(data) {
    fs.writeFileSync(PLAYERS_FILE, JSON.stringify(data, null, 2));
}

function getOrCreatePlayer(playerId) {
    const players = loadPlayers();
    if (!players[playerId]) {
        players[playerId] = {
            id: playerId,
            name: playerId,
            points: 0,
            solves: {},
            firstBloods: [],
            joinedAt: new Date().toISOString(),
        };
        savePlayers(players);
    }
    return players[playerId];
}

// ── First Blood Tracking ─────────────────────────────
const FIRST_BLOOD_FILE = path.join(DATA_DIR, 'first_bloods.json');

function loadFirstBloods() {
    try {
        return JSON.parse(fs.readFileSync(FIRST_BLOOD_FILE, 'utf8'));
    } catch {
        return {};
    }
}

function saveFirstBloods(data) {
    fs.writeFileSync(FIRST_BLOOD_FILE, JSON.stringify(data, null, 2));
}

// ── Auth Middleware ───────────────────────────────────
function authMiddleware(req, res, next) {
    const token = req.cookies?.session || req.headers['x-session-token'];
    
    if (!token) {
        if (req.path.startsWith('/api/') && req.path !== '/api/health' && req.path !== '/api/login') {
            return res.status(401).json({ error: 'Not authenticated' });
        }
        return next();
    }
    
    try {
        // Simple HMAC-based session token: playerId:hmac
        const [playerId, hmac] = token.split(':');
        const expectedHmac = crypto.createHmac('sha256', PORTAL_SECRET)
            .update(playerId).digest('hex').substring(0, 16);
        
        if (hmac === expectedHmac) {
            req.player = getOrCreatePlayer(playerId);
            req.playerId = playerId;
        }
    } catch {}
    
    next();
}

app.use(authMiddleware);

// ── Static Files ─────────────────────────────────────
app.use('/static', express.static(path.join(__dirname, 'static')));

// ── API Routes ───────────────────────────────────────

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', uptime: process.uptime(), machines: TOTAL_MACHINES });
});

// Login
app.post('/api/login', (req, res) => {
    const { playerId, secret } = req.body;
    
    if (!playerId) {
        return res.status(400).json({ error: 'Player ID required' });
    }
    
    // Simple shared secret auth
    if (secret !== PORTAL_SECRET && PORTAL_SECRET !== 'change-me') {
        return res.status(401).json({ error: 'Invalid secret' });
    }
    
    const hmac = crypto.createHmac('sha256', PORTAL_SECRET)
        .update(playerId).digest('hex').substring(0, 16);
    const sessionToken = `${playerId}:${hmac}`;
    
    res.cookie('session', sessionToken, {
        httpOnly: true,
        secure: true,
        sameSite: 'strict',
        maxAge: 86400000, // 24 hours
    });
    
    const player = getOrCreatePlayer(playerId);
    res.json({ success: true, player });
});

// Get machines list
app.get('/api/machines', (req, res) => {
    const machines = MACHINES.map(m => ({
        ...m,
        ip: `10.10.${m.id}.10`,
        solved: req.player?.solves?.[m.id] || {},
    }));
    res.json(machines);
});

// Get machine details
app.get('/api/machines/:id', (req, res) => {
    const machine = MACHINES.find(m => m.id === parseInt(req.params.id));
    if (!machine) return res.status(404).json({ error: 'Machine not found' });
    
    const firstBloods = loadFirstBloods();
    
    res.json({
        ...machine,
        ip: `10.10.${machine.id}.10`,
        solved: req.player?.solves?.[machine.id] || {},
        firstBlood: firstBloods[machine.id] || null,
    });
});

// Submit flag
app.post('/api/submit', (req, res) => {
    if (!req.player) {
        return res.status(401).json({ error: 'Login required' });
    }
    
    const { machineId, flag } = req.body;
    const machine = MACHINES.find(m => m.id === parseInt(machineId));
    
    if (!machine) {
        return res.status(400).json({ error: 'Invalid machine' });
    }
    
    // Check if already solved
    const solveKey = flag === generateFlag('root', machineId) ? 'root' : 
                     flag === generateFlag('user', machineId) ? 'user' : null;
    
    if (!solveKey) {
        return res.status(400).json({ error: 'Incorrect flag', correct: false });
    }
    
    const players = loadPlayers();
    const player = players[req.playerId];
    
    if (!player.solves[machineId]) {
        player.solves[machineId] = {};
    }
    
    if (player.solves[machineId][solveKey]) {
        return res.json({ correct: true, message: 'Already submitted', points: 0 });
    }
    
    // Award points
    const points = solveKey === 'root' ? Math.ceil(machine.points * 0.6) : Math.floor(machine.points * 0.4);
    player.solves[machineId][solveKey] = {
        timestamp: new Date().toISOString(),
        points,
    };
    player.points += points;
    
    // Check first blood
    const firstBloods = loadFirstBloods();
    const fbKey = `${machineId}_${solveKey}`;
    if (!firstBloods[fbKey]) {
        firstBloods[fbKey] = {
            player: req.playerId,
            timestamp: new Date().toISOString(),
        };
        player.firstBloods.push(fbKey);
        saveFirstBloods(firstBloods);
    }
    
    savePlayers(players);
    
    res.json({
        correct: true,
        type: solveKey,
        points,
        totalPoints: player.points,
        firstBlood: firstBloods[fbKey]?.player === req.playerId,
        message: `🎉 ${solveKey === 'root' ? '🏴' : '👤'} ${machine.name} ${solveKey} flag captured! +${points} pts`,
    });
});

// Player profile
app.get('/api/profile', (req, res) => {
    if (!req.player) {
        return res.status(401).json({ error: 'Login required' });
    }
    
    const totalPossiblePoints = MACHINES.reduce((sum, m) => sum + m.points, 0);
    const totalSolves = Object.values(req.player.solves).reduce((count, s) => {
        return count + (s.root ? 1 : 0) + (s.user ? 1 : 0);
    }, 0);
    
    res.json({
        ...req.player,
        totalPossiblePoints,
        totalSolves,
        totalFlags: TOTAL_MACHINES * 2,
        completion: ((totalSolves / (TOTAL_MACHINES * 2)) * 100).toFixed(1),
    });
});

// Heatmap data
app.get('/api/heatmap', (req, res) => {
    if (!req.player) {
        return res.status(401).json({ error: 'Login required' });
    }
    
    const heatmap = MACHINES.map(m => ({
        id: m.id,
        name: m.name,
        category: m.category,
        difficulty: m.difficulty,
        userSolved: !!req.player.solves[m.id]?.user,
        rootSolved: !!req.player.solves[m.id]?.root,
    }));
    
    res.json(heatmap);
});

// ── HTML Page Route ──────────────────────────────────
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'templates', 'index.html'));
});

app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'templates', 'login.html'));
});

// ── Start Server ─────────────────────────────────────
try {
    const httpsOptions = {
        key: fs.readFileSync('/app/certs/key.pem'),
        cert: fs.readFileSync('/app/certs/cert.pem'),
    };
    
    https.createServer(httpsOptions, app).listen(PORT, () => {
        console.log(`[Portal] HTTPS server running on port ${PORT}`);
        console.log(`[Portal] ${TOTAL_MACHINES} machines configured`);
    });
} catch {
    // Fallback to HTTP for development
    http.createServer(app).listen(PORT, () => {
        console.log(`[Portal] HTTP server running on port ${PORT} (TLS not available)`);
    });
}
