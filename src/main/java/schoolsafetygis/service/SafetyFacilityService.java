package schoolsafetygis.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolsafetygis.dto.CrosswalkDTO;
import schoolsafetygis.dto.PedestrianSignalDTO;
import schoolsafetygis.dto.SpeedHumpDTO;
import schoolsafetygis.mapper.SafetyFacilityMapper;

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
