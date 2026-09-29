package schoolsafetygis.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolsafetygis.dto.TrafficCctvDTO;
import schoolsafetygis.mapper.TrafficCctvMapper;

/**
 * 교통 CCTV 조회 관련 비즈니스 로직을 처리하는 서비스 클래스입니다.
 *
 * @author 나기현
 * @since 2026.09.29
 * @version 1.0
 */
@Service
public class TrafficCctvService {

	@Autowired
	private TrafficCctvMapper trafficCctvMapper;

	public List<TrafficCctvDTO> getTrafficCctvs() {

		return trafficCctvMapper.selectTrafficCctvs();
	}
}
