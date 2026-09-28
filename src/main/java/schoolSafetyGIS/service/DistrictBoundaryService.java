package schoolSafetyGIS.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolSafetyGIS.dto.DistrictBoundaryDTO;
import schoolSafetyGIS.mapper.DistrictBoundaryMapper;

@Service
public class DistrictBoundaryService {

	@Autowired
	private DistrictBoundaryMapper districtBoundaryMapper;

	public List<DistrictBoundaryDTO> getDistrictBoundaries() {
		return districtBoundaryMapper.selectDistrictBoundaries();
	}
}
