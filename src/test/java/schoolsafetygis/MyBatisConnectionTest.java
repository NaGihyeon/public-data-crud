package schoolsafetygis;

import org.springframework.context.support.ClassPathXmlApplicationContext;

import schoolsafetygis.mapper.DbTestMapper;

public class MyBatisConnectionTest {

	public static void main(String[] args) {

		ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(
				"egovframework/spring/context-datasource.xml", "egovframework/spring/context-mapper.xml");

		try {

			DbTestMapper mapper = context.getBean(DbTestMapper.class);

			int result = mapper.selectOne();

			System.out.println("MyBatis 연결 성공");
			System.out.println("SELECT 1 결과: " + result);

		} catch (Exception e) {

			System.out.println("MyBatis 연결 실패");
			e.printStackTrace();

		} finally {

			context.close();
		}
	}
}
