import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            return DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/fyp",
                "root", ""
            );
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}