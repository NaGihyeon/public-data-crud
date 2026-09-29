package schoolsafetygis.service;

import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import schoolsafetygis.dto.TrafficIncidentApiDTO;
import schoolsafetygis.dto.TrafficIncidentDTO;
import schoolsafetygis.mapper.TrafficIncidentMapper;

/**
 * 실시간 교통 돌발정보 조회 및 동기화 관련 비즈니스 로직을 처리하는 서비스 클래스입니다.
 *
 * @author 나기현
 * @since 2026.09.29
 * @version 1.0
 */

@Service
public class TrafficIncidentService {

	@Autowired
	private TrafficIncidentApiClient trafficIncidentApiClient;

	@Autowired
	private TrafficIncidentMapper trafficIncidentMapper;

	@Transactional
	public int syncTrafficIncidents() throws Exception {

		List<TrafficIncidentApiDTO> incidents = trafficIncidentApiClient.fetchTrafficIncidents();

		List<String> syncedAccIds = new ArrayList<String>();

		int count = 0;

		for (TrafficIncidentApiDTO incident : incidents) {

			if (incident.getAccId() == null || incident.getOccrDate() == null || incident.getOccrTime() == null
					|| incident.getGrs80tmX() == null || incident.getGrs80tmY() == null) {

				continue;
			}

			count += trafficIncidentMapper.upsertTrafficIncident(incident);

			syncedAccIds.add(incident.getAccId());
		}

		if (syncedAccIds.isEmpty()) {

			trafficIncidentMapper.deleteAllTrafficIncidents();

		} else {

			trafficIncidentMapper.deleteStaleTrafficIncidents(syncedAccIds);
		}

		return count;
	}

	public List<TrafficIncidentDTO> getTrafficIncidents() {

		return trafficIncidentMapper.selectTrafficIncidents();
	}

	public Map<String, Map<String, String>> getTrafficIncidentCodes() throws Exception {

		Map<String, Map<String, String>> result = new LinkedHashMap<String, Map<String, String>>();

		result.put("main", trafficIncidentApiClient.fetchIncidentMainCodes());

		result.put("sub", trafficIncidentApiClient.fetchIncidentSubCodes());

		return result;
	}

}
