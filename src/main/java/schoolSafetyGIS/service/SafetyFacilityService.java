package schoolSafetyGIS.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolSafetyGIS.dto.CrosswalkDTO;
import schoolSafetyGIS.dto.SpeedHumpDTO;
import schoolSafetyGIS.dto.PedestrianSignalDTO;
import schoolSafetyGIS.mapper.SafetyFacilityMapper;

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
