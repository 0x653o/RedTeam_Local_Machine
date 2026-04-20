<?php
// PHPocalypse — Internal Inventory System
// Running on PHP 5.6 (CGI mode) — CVE-2012-1823 exploitable
$page = isset($_GET['page']) ? $_GET['page'] : 'home';
?>
<!DOCTYPE html>
<html>
<head>
    <title>Inventory System v1.0</title>
    <style>
        body { font-family: monospace; background: #1a1a2e; color: #e0e0e0; padding: 20px; }
        h1 { color: #00d4aa; }
        .info { background: #16213e; padding: 10px; border-left: 3px solid #00d4aa; margin: 10px 0; }
        a { color: #00d4aa; }
        form input { background: #16213e; border: 1px solid #00d4aa; color: #e0e0e0; padding: 5px; }
        form button { background: #00d4aa; color: #1a1a2e; border: none; padding: 6px 12px; cursor: pointer; }
    </style>
</head>
<body>
<h1>📦 Internal Inventory System</h1>
<div class="info">
    <strong>Server:</strong> <?php echo php_uname('n'); ?><br>
    <strong>PHP Version:</strong> <?php echo PHP_VERSION; ?><br>
    <strong>SAPI:</strong> <?php echo PHP_SAPI; ?>
</div>
<nav>
    <a href="?page=home">Home</a> |
    <a href="?page=search">Search</a> |
    <a href="?page=about">About</a>
</nav>
<hr>
<?php
if ($page === 'search') {
    $q = isset($_GET['q']) ? htmlspecialchars($_GET['q']) : '';
    echo "<h2>Search Inventory</h2>";
    echo "<form method='GET'><input type='hidden' name='page' value='search'>";
    echo "<input name='q' value='$q' placeholder='Item name...'>";
    echo "<button type='submit'>Search</button></form>";
    if ($q) echo "<p>No results found for: $q</p>";
} elseif ($page === 'about') {
    echo "<h2>About</h2><p>Inventory System v1.0 — Internal use only.</p>";
    echo "<p>Powered by PHP " . PHP_VERSION . " CGI</p>";
} else {
    echo "<h2>Dashboard</h2>";
    echo "<ul>";
    echo "<li>Total Items: 1,042</li>";
    echo "<li>Last Sync: " . date('Y-m-d H:i:s') . "</li>";
    echo "<li>Status: <span style='color:lime'>ONLINE</span></li>";
    echo "</ul>";
}
?>
</body>
</html>
