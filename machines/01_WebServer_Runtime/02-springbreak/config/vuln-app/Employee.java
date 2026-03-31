/**
 * Simple POJO for Spring data binding.
 * Spring4Shell works because Spring binds ALL request parameters
 * to object properties recursively — including inherited properties
 * from java.lang.Object like class.module.classLoader.
 */
public class Employee {
    private String name;
    private String department;
    private String email;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
