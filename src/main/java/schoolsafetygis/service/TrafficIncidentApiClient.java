package schoolsafetygis.service;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import schoolsafetygis.dto.TrafficIncidentApiDTO;

@Component
public class TrafficIncidentApiClient {

	@Value("${seoul.api.key}")
	private String apiKey;

	private static final String BASE_URL = "http://openapi.seoul.go.kr:8088/";

	public List<TrafficIncidentApiDTO> fetchTrafficIncidents() throws Exception {

		Document document = requestXml("AccInfo", 1, 1000);

		String resultCode = getText(document.getDocumentElement(), "CODE");

		String resultMessage = getText(document.getDocumentElement(), "MESSAGE");

		if (!"INFO-000".equals(resultCode)) {

			throw new IllegalStateException("서울 돌발정보 API 오류: " + resultCode + " / " + resultMessage);
		}

		String totalCountText = getText(document.getDocumentElement(), "list_total_count");

		int totalCount = Integer.parseInt(totalCountText);

		if (totalCount > 1000) {

			throw new IllegalStateException("서울 돌발정보가 1000건을 초과했습니다. " + "totalCount=" + totalCount);
		}

		NodeList rows = document.getElementsByTagName("row");

		if (rows.getLength() != totalCount) {

			throw new IllegalStateException(
					"서울 돌발정보 전체 건수와 " + "수신 건수가 다릅니다. totalCount=" + totalCount + ", rows=" + rows.getLength());
		}

		List<TrafficIncidentApiDTO> result = new ArrayList<TrafficIncidentApiDTO>();

		for (int i = 0; i < rows.getLength(); i++) {

			Element row = (Element) rows.item(i);

			TrafficIncidentApiDTO dto = new TrafficIncidentApiDTO();

			dto.setAccId(getText(row, "acc_id"));

			dto.setOccrDate(getText(row, "occr_date"));

			dto.setOccrTime(getText(row, "occr_time"));

			dto.setExpClrDate(getText(row, "exp_clr_date"));

			dto.setExpClrTime(getText(row, "exp_clr_time"));

			dto.setAccType(getText(row, "acc_type"));

			dto.setAccDetailType(getText(row, "acc_dtype"));

			dto.setLinkId(getText(row, "link_id"));

			dto.setAccInfo(getText(row, "acc_info"));

			dto.setGrs80tmX(parseDouble(getText(row, "grs80tm_x")));

			dto.setGrs80tmY(parseDouble(getText(row, "grs80tm_y")));

			result.add(dto);
		}

		return result;
	}

	/*
	 * 돌발 유형 코드 A01 -> 교통사고 A04 -> 공사 ...
	 */
	public Map<String, String> fetchIncidentMainCodes() throws Exception {

		return fetchCodeMap("AccMainCode", "acc_type", "acc_type_nm");
	}

	/*
	 * 돌발 세부유형 코드 04B01 -> 시설물보수 10B02 -> 집회 ...
	 */
	public Map<String, String> fetchIncidentSubCodes() throws Exception {

		return fetchCodeMap("AccSubCode", "acc_dtype", "acc_dtype_nm");
	}

	private Map<String, String> fetchCodeMap(String serviceName, String codeTag, String nameTag) throws Exception {

		Document document = requestXml(serviceName, 1, 1000);

		String resultCode = getText(document.getDocumentElement(), "CODE");

		String resultMessage = getText(document.getDocumentElement(), "MESSAGE");

		if (!"INFO-000".equals(resultCode)) {

			throw new IllegalStateException("서울 돌발 코드 API 오류: " + resultCode + " / " + resultMessage);
		}

		NodeList rows = document.getElementsByTagName("row");

		Map<String, String> result = new LinkedHashMap<String, String>();

		for (int i = 0; i < rows.getLength(); i++) {

			Element row = (Element) rows.item(i);

			String code = getText(row, codeTag);

			String name = getText(row, nameTag);

			if (code != null && !code.isEmpty()) {

				result.put(code, name);
			}
		}

		return result;
	}

	private Document requestXml(String serviceName, int startIndex, int endIndex) throws Exception {

		String encodedApiKey = URLEncoder.encode(apiKey.trim(), "UTF-8");

		String requestUrl = BASE_URL + encodedApiKey + "/xml/" + serviceName + "/" + startIndex + "/" + endIndex + "/";

		HttpURLConnection connection = null;
		InputStream inputStream = null;

		try {

			URL url = new URL(requestUrl);

			connection = (HttpURLConnection) url.openConnection();

			connection.setRequestMethod("GET");

			connection.setRequestProperty("Content-type", "application/xml");

			connection.setConnectTimeout(5000);
			connection.setReadTimeout(10000);

			int responseCode = connection.getResponseCode();

			if (responseCode != HttpURLConnection.HTTP_OK) {

				throw new IllegalStateException("서울 OpenAPI 호출 실패: " + responseCode);
			}

			inputStream = connection.getInputStream();

			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

			factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);

			factory.setFeature("http://xml.org/sax/features/external-general-entities", false);

			factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false);

			factory.setXIncludeAware(false);

			factory.setExpandEntityReferences(false);

			DocumentBuilder builder = factory.newDocumentBuilder();

			return builder.parse(inputStream);

		} finally {

			if (inputStream != null) {
				inputStream.close();
			}

			if (connection != null) {
				connection.disconnect();
			}
		}
	}

	private String getText(Element parent, String tagName) {

		NodeList nodes = parent.getElementsByTagName(tagName);

		if (nodes.getLength() == 0 || nodes.item(0) == null) {

			return null;
		}

		return nodes.item(0).getTextContent().trim();
	}

	private Double parseDouble(String value) {

		if (value == null || value.isEmpty()) {

			return null;
		}

		return Double.valueOf(value);
	}
}