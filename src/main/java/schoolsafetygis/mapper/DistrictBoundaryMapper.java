package schoolsafetygis.mapper;

import java.util.List;

import schoolsafetygis.dto.DistrictBoundaryDTO;

public interface DistrictBoundaryMapper {

	List<DistrictBoundaryDTO> selectDistrictBoundaries();
}
