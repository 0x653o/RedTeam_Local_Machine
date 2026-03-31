// ──────────────────────────────────────────────────────
// Local-Machine Portal — Dashboard JavaScript
// ──────────────────────────────────────────────────────

// ── State ────────────────────────────────────────────
let machines = [];
let profile = null;
let heatmapData = [];

// ── Initialization ───────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
    setupNavigation();
    await loadData();
    renderDashboard();
    renderMachines();
    renderHeatmap();
    renderProfile();
});

// ── Navigation ───────────────────────────────────────
function setupNavigation() {
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const section = link.dataset.section;
            switchSection(section);
        });
    });
}

function switchSection(sectionName) {
    // Update nav links
    document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
    document.querySelector(`.nav-link[data-section="${sectionName}"]`)?.classList.add('active');
    
    // Update sections
    document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
    document.getElementById(`section-${sectionName}`)?.classList.add('active');
}

// ── Data Loading ─────────────────────────────────────
async function loadData() {
    try {
        const [machinesRes, profileRes, heatmapRes] = await Promise.allSettled([
            fetch('/api/machines'),
            fetch('/api/profile'),
            fetch('/api/heatmap'),
        ]);
        
        if (machinesRes.status === 'fulfilled' && machinesRes.value.ok) {
            machines = await machinesRes.value.json();
        }
        
        if (profileRes.status === 'fulfilled' && profileRes.value.ok) {
            profile = await profileRes.value.json();
        }
        
        if (heatmapRes.status === 'fulfilled' && heatmapRes.value.ok) {
            heatmapData = await heatmapRes.value.json();
        }
    } catch (err) {
        console.error('Failed to load data:', err);
    }
}

// ── Dashboard Rendering ──────────────────────────────
function renderDashboard() {
    // Stats
    const owned = machines.filter(m => m.solved?.root).length;
    const totalPoints = profile?.points || 0;
    const totalPossible = profile?.totalPossiblePoints || machines.reduce((s, m) => s + m.points, 0);
    const flags = profile?.totalSolves || 0;
    const totalFlags = machines.length * 2;
    const bloods = profile?.firstBloods?.length || 0;
    
    animateValue('stat-owned', owned);
    animateValue('stat-total-points', totalPoints);
    animateValue('stat-flags', flags);
    animateValue('stat-first-bloods', bloods);
    
    // Progress bars
    setTimeout(() => {
        setBarWidth('stat-owned-bar', (owned / machines.length) * 100);
        setBarWidth('stat-points-bar', (totalPoints / totalPossible) * 100);
        setBarWidth('stat-flags-bar', (flags / totalFlags) * 100);
    }, 300);
    
    // Nav points
    document.getElementById('nav-points').textContent = `${totalPoints} pts`;
    
    // Avatar
    if (profile?.name) {
        const initial = profile.name.charAt(0).toUpperCase();
        document.getElementById('nav-avatar').textContent = initial;
        document.getElementById('profile-avatar').textContent = initial;
    }
    
    // Machine select for flag submission
    const select = document.getElementById('submit-machine');
    select.innerHTML = '<option value="">Select Machine...</option>';
    machines.forEach(m => {
        const id = String(m.id).padStart(2, '0');
        select.innerHTML += `<option value="${m.id}">${id} — ${m.name}</option>`;
    });
    
    // Category overview
    renderCategories();
}

function renderCategories() {
    const categories = {};
    machines.forEach(m => {
        if (!categories[m.category]) {
            categories[m.category] = { total: 0, owned: 0, points: 0, maxPoints: 0 };
        }
        categories[m.category].total++;
        categories[m.category].maxPoints += m.points;
        if (m.solved?.root) {
            categories[m.category].owned++;
            categories[m.category].points += m.points;
        }
    });
    
    const categoryColors = {
        'Web Server & Runtime': 'var(--accent-red)',
        'CMS & Web Application': 'var(--accent-orange)',
        'Framework & Library': 'var(--accent-amber)',
        'Enterprise Middleware': 'var(--accent-blue)',
        'Network Appliance & Proxy': 'var(--accent-purple)',
        'Data & File Transfer': 'var(--accent-cyan)',
        'Privilege Escalation': 'var(--accent-pink)',
        'Advanced Exploitation': 'var(--accent-green)',
    };
    
    const categoryIcons = {
        'Web Server & Runtime': '🌐',
        'CMS & Web Application': '📰',
        'Framework & Library': '📦',
        'Enterprise Middleware': '🏢',
        'Network Appliance & Proxy': '🔌',
        'Data & File Transfer': '📁',
        'Privilege Escalation': '⬆️',
        'Advanced Exploitation': '💀',
    };
    
    const container = document.getElementById('categories-overview');
    container.innerHTML = '';
    
    Object.entries(categories).forEach(([name, data]) => {
        const pct = data.total > 0 ? (data.owned / data.total) * 100 : 0;
        const color = categoryColors[name] || 'var(--accent-red)';
        const icon = categoryIcons[name] || '📋';
        
        container.innerHTML += `
            <div class="category-card" onclick="navigateToCategory('${name}')">
                <div class="category-header">
                    <div>
                        <span style="font-size: 20px;">${icon}</span>
                        <div class="category-name">${name}</div>
                    </div>
                    <span class="category-count">${data.owned}/${data.total}</span>
                </div>
                <div class="category-progress">
                    <div class="category-progress-fill" style="width: ${pct}%; background: ${color};"></div>
                </div>
            </div>
        `;
    });
}

// ── Machine Cards ────────────────────────────────────
function renderMachines(filter = {}) {
    const grid = document.getElementById('machines-grid');
    grid.innerHTML = '';
    
    let filtered = machines;
    
    if (filter.category && filter.category !== 'all') {
        filtered = filtered.filter(m => m.category === filter.category);
    }
    if (filter.difficulty && filter.difficulty !== 'all') {
        filtered = filtered.filter(m => m.difficulty === filter.difficulty);
    }
    if (filter.status && filter.status !== 'all') {
        if (filter.status === 'owned') filtered = filtered.filter(m => m.solved?.root);
        else if (filter.status === 'partial') filtered = filtered.filter(m => m.solved?.user && !m.solved?.root);
        else if (filter.status === 'unsolved') filtered = filtered.filter(m => !m.solved?.user && !m.solved?.root);
    }
    
    filtered.forEach(m => {
        const id = String(m.id).padStart(2, '0');
        const isOwned = !!m.solved?.root;
        const isPartial = !!m.solved?.user && !m.solved?.root;
        const statusClass = isOwned ? 'owned' : isPartial ? 'partial' : '';
        const diffClass = m.difficulty.toLowerCase();
        const cvssClass = m.cvss >= 9.0 ? 'cvss-critical' : 'cvss-high';
        
        grid.innerHTML += `
            <div class="machine-card ${statusClass}">
                <div class="machine-header">
                    <div>
                        <span class="machine-id">#${id}</span>
                        <div class="machine-name">${m.name}</div>
                        <span class="machine-cve">${m.cve}</span>
                    </div>
                    <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 6px;">
                        <span class="difficulty-badge ${diffClass}">${m.difficulty}</span>
                        <span class="machine-points">${m.points} pts</span>
                    </div>
                </div>
                <div class="machine-meta">
                    <span class="machine-meta-item">
                        <span class="cvss-badge ${cvssClass}">${m.cvss}</span>
                    </span>
                    <span class="machine-meta-item">📂 ${m.category}</span>
                </div>
                <div class="machine-flags">
                    <span class="flag-indicator ${m.solved?.user ? 'captured' : ''}">
                        👤 User ${m.solved?.user ? '✓' : ''}
                    </span>
                    <span class="flag-indicator ${m.solved?.root ? 'captured' : ''}">
                        🏴 Root ${m.solved?.root ? '✓' : ''}
                    </span>
                </div>
                <div class="machine-ip">📡 ${m.ip || '10.10.' + m.id + '.10'}</div>
            </div>
        `;
    });
}

function filterMachines() {
    renderMachines({
        category: document.getElementById('filter-category').value,
        difficulty: document.getElementById('filter-difficulty').value,
        status: document.getElementById('filter-status').value,
    });
}

function navigateToCategory(category) {
    switchSection('machines');
    document.getElementById('filter-category').value = category;
    filterMachines();
}

// ── Heatmap ──────────────────────────────────────────
function renderHeatmap() {
    const grid = document.getElementById('heatmap-grid');
    grid.innerHTML = '';
    
    const data = heatmapData.length > 0 ? heatmapData : machines.map(m => ({
        id: m.id,
        name: m.name,
        userSolved: !!m.solved?.user,
        rootSolved: !!m.solved?.root,
    }));
    
    data.forEach(m => {
        const id = String(m.id).padStart(2, '0');
        const cls = m.rootSolved ? 'owned' : m.userSolved ? 'user-only' : 'unsolved';
        
        grid.innerHTML += `
            <div class="heatmap-cell ${cls}" title="${id} — ${m.name}">
                ${id}
            </div>
        `;
    });
}

// ── Profile ──────────────────────────────────────────
function renderProfile() {
    if (!profile) return;
    
    document.getElementById('profile-name').textContent = profile.name || 'Anonymous';
    document.getElementById('profile-points').textContent = profile.points || 0;
    document.getElementById('profile-completion').textContent = `${profile.completion || 0}%`;
    document.getElementById('profile-solves').textContent = profile.totalSolves || 0;
    document.getElementById('profile-bloods').textContent = profile.firstBloods?.length || 0;
    
    // Rank based on points
    const rank = getRank(profile.points || 0);
    document.getElementById('profile-rank').textContent = rank;
}

function getRank(points) {
    if (points >= 1000) return '🏴 Elite Hacker';
    if (points >= 700) return '💀 Exploit Developer';
    if (points >= 500) return '🔴 Red Teamer';
    if (points >= 300) return '⚡ Penetration Tester';
    if (points >= 150) return '🔧 Bug Hunter';
    if (points >= 50) return '📡 Network Scout';
    if (points > 0) return '🌱 Noob Hacker';
    return '👶 Script Kiddie';
}

// ── Flag Submission ──────────────────────────────────
async function submitFlag() {
    const machineId = document.getElementById('submit-machine').value;
    const flag = document.getElementById('submit-flag').value.trim();
    const resultEl = document.getElementById('submit-result');
    const btn = document.getElementById('submit-btn');
    
    if (!machineId || !flag) {
        showResult(resultEl, 'error', 'Select a machine and enter a flag');
        return;
    }
    
    btn.disabled = true;
    btn.textContent = 'Checking...';
    
    try {
        const res = await fetch('/api/submit', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ machineId: parseInt(machineId), flag }),
        });
        
        const data = await res.json();
        
        if (data.correct) {
            showResult(resultEl, 'success', data.message);
            showToast('success', data.message);
            
            // Refresh data
            await loadData();
            renderDashboard();
            renderMachines();
            renderHeatmap();
            renderProfile();
            
            document.getElementById('submit-flag').value = '';
        } else {
            showResult(resultEl, 'error', data.error || 'Incorrect flag');
            showToast('error', '❌ Incorrect flag');
        }
    } catch (err) {
        showResult(resultEl, 'error', 'Connection failed');
    }
    
    btn.disabled = false;
    btn.textContent = 'Submit';
}

// ── Utilities ────────────────────────────────────────
function showResult(el, type, message) {
    el.className = `submit-result ${type}`;
    el.textContent = message;
    el.classList.remove('hidden');
    
    setTimeout(() => el.classList.add('hidden'), 5000);
}

function showToast(type, message) {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'toastOut 0.3s ease forwards';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

function animateValue(elementId, value) {
    const el = document.getElementById(elementId);
    if (!el) return;
    
    let current = 0;
    const increment = Math.max(1, Math.ceil(value / 30));
    const timer = setInterval(() => {
        current += increment;
        if (current >= value) {
            current = value;
            clearInterval(timer);
        }
        el.textContent = current;
    }, 30);
}

function setBarWidth(elementId, pct) {
    const el = document.getElementById(elementId);
    if (el) {
        el.style.width = `${Math.min(100, Math.max(0, pct))}%`;
    }
}
