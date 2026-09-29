package schoolsafetygis.mapper;

import java.util.List;

import schoolsafetygis.dto.CrosswalkDTO;
import schoolsafetygis.dto.PedestrianSignalDTO;
import schoolsafetygis.dto.SpeedHumpDTO;

public interface SafetyFacilityMapper {

	List<CrosswalkDTO> selectCrosswalkList();

	List<SpeedHumpDTO> selectSpeedHumpList();

	List<PedestrianSignalDTO> selectPedestrianSignalList();

}
