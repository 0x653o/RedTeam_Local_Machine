<%@ page language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Internal Management Portal</title>
    <style>
        body { font-family: monospace; background:#1a1a2e; color:#e0e0e0; padding:20px; }
        h1 { color:#f0a500; }
        .box { background:#16213e; padding:15px; border-left:3px solid #f0a500; margin:10px 0; }
    </style>
</head>
<body>
<h1>📊 Internal Management Portal</h1>
<div class="box">
    <strong>Hostname:</strong> <%= java.net.InetAddress.getLocalHost().getHostName() %><br>
    <strong>Server:</strong> Apache Tomcat <%= application.getServerInfo() %><br>
    <strong>Java:</strong> <%= System.getProperty("java.version") %>
</div>
<div class="box">
    <p>Welcome to the internal dashboard. Please contact your administrator for access.</p>
    <p>Management interface: <a href="/manager/html" style="color:#f0a500">/manager/html</a></p>
</div>
</body>
</html>
