package schoolsafetygis.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolsafetygis.dto.TrafficCctvDTO;
import schoolsafetygis.mapper.TrafficCctvMapper;

@Service
public class TrafficCctvService {

	@Autowired
	private TrafficCctvMapper trafficCctvMapper;

	public List<TrafficCctvDTO> getTrafficCctvs() {

		return trafficCctvMapper.selectTrafficCctvs();
	}
}
