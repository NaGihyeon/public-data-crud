package schoolSafetyGIS;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.sql.DataSource;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class DbConnectionTest {

	public static void main(String[] args) {

		ApplicationContext context = new ClassPathXmlApplicationContext("egovframework/spring/context-datasource.xml");

		DataSource dataSource = (DataSource) context.getBean("dataSource");

		try (Connection conn = dataSource.getConnection();
				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery("SELECT 1")) {

			if (rs.next()) {
				System.out.println("DB 연결 성공");
				System.out.println("SELECT 1 결과: " + rs.getInt(1));
			}

		} catch (Exception e) {
			System.out.println("DB 연결 실패");
			e.printStackTrace();
		}

		((ClassPathXmlApplicationContext) context).close();
	}
}
