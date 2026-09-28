package schoolSafetyGIS.mapper;

import java.util.List;
import schoolSafetyGIS.dto.CrosswalkDTO;
import schoolSafetyGIS.dto.SpeedHumpDTO;
import schoolSafetyGIS.dto.PedestrianSignalDTO;

public interface SafetyFacilityMapper {

	List<CrosswalkDTO> selectCrosswalkList();

	List<SpeedHumpDTO> selectSpeedHumpList();

	List<PedestrianSignalDTO> selectPedestrianSignalList();

}
