package schoolsafetygis.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolsafetygis.dto.CrosswalkDTO;
import schoolsafetygis.dto.PedestrianSignalDTO;
import schoolsafetygis.dto.SpeedHumpDTO;
import schoolsafetygis.mapper.SafetyFacilityMapper;

/**
 * 안전시설 조회 관련 비즈니스 로직을 처리하는 서비스 클래스입니다.
 *
 * @author 나기현
 * @since 2026.09.29
 * @version 1.0
 */
@Service
public class SafetyFacilityService {

	@Autowired
	private SafetyFacilityMapper safetyFacilityMapper;

	public List<CrosswalkDTO> selectCrosswalkList() {
		return safetyFacilityMapper.selectCrosswalkList();
	}

	public List<SpeedHumpDTO> selectSpeedHumpList() {
		return safetyFacilityMapper.selectSpeedHumpList();
	}

	public List<PedestrianSignalDTO> selectPedestrianSignalList() {
		return safetyFacilityMapper.selectPedestrianSignalList();
	}

}
