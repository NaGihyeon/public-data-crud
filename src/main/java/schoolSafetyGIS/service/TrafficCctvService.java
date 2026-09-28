package schoolSafetyGIS.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolSafetyGIS.dto.TrafficCctvDTO;
import schoolSafetyGIS.mapper.TrafficCctvMapper;

@Service
public class TrafficCctvService {

	@Autowired
	private TrafficCctvMapper trafficCctvMapper;

	public List<TrafficCctvDTO> getTrafficCctvs() {

		return trafficCctvMapper.selectTrafficCctvs();
	}
}
