package schoolSafetyGIS.mapper;

import java.util.List;

import schoolSafetyGIS.dto.DistrictBoundaryDTO;

public interface DistrictBoundaryMapper {

	List<DistrictBoundaryDTO> selectDistrictBoundaries();
}
