import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Vulnerable Spring MVC Controller — CVE-2022-22965 (Spring4Shell)
 * 
 * The vulnerability is in Spring's data binding mechanism. When a form
 * is submitted, Spring binds request parameters to Java object properties.
 * On JDK 9+, the ClassLoader is accessible via:
 *   class.module.classLoader.resources.context.parent.pipeline.first.*
 * 
 * This allows an attacker to modify Tomcat's AccessLogValve to write
 * a JSP webshell to disk.
 */
@Controller
public class VulnController {

    @GetMapping("/")
    @ResponseBody
    public String index() {
        return "<!DOCTYPE html>\n" +
            "<html><head><title>HR Portal</title></head>\n" +
            "<body>\n" +
            "<h1>HR Management Portal</h1>\n" +
            "<p>Welcome to the internal HR management system.</p>\n" +
            "<ul>\n" +
            "  <li><a href='/springapp/employee'>Employee Form</a></li>\n" +
            "  <li><a href='/springapp/status'>System Status</a></li>\n" +
            "</ul>\n" +
            "<footer>Powered by Spring Framework 5.3.17</footer>\n" +
            "</body></html>";
    }

    @GetMapping("/employee")
    @ResponseBody
    public String employeeForm() {
        return "<!DOCTYPE html>\n" +
            "<html><head><title>Employee Form</title></head>\n" +
            "<body>\n" +
            "<h2>Add Employee</h2>\n" +
            "<form method='POST' action='/springapp/employee'>\n" +
            "  <label>Name:</label><br>\n" +
            "  <input name='name' placeholder='John Doe'><br><br>\n" +
            "  <label>Department:</label><br>\n" +
            "  <input name='department' placeholder='Engineering'><br><br>\n" +
            "  <label>Email:</label><br>\n" +
            "  <input name='email' placeholder='john@company.com'><br><br>\n" +
            "  <button type='submit'>Submit</button>\n" +
            "</form>\n" +
            "</body></html>";
    }

    // VULNERABLE: Spring data binding allows class loader manipulation
    @PostMapping("/employee")
    @ResponseBody
    public String submitEmployee(@ModelAttribute Employee employee) {
        return "Employee " + employee.getName() + " added successfully!";
    }

    @GetMapping("/status")
    @ResponseBody
    public String status() {
        return "{\"status\": \"running\", \"version\": \"5.3.17\", \"java\": \"" + 
            System.getProperty("java.version") + "\"}";
    }
}
