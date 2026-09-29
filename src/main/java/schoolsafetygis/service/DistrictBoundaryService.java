package schoolsafetygis.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolsafetygis.dto.DistrictBoundaryDTO;
import schoolsafetygis.mapper.DistrictBoundaryMapper;

@Service
public class DistrictBoundaryService {

	@Autowired
	private DistrictBoundaryMapper districtBoundaryMapper;

	public List<DistrictBoundaryDTO> getDistrictBoundaries() {
		return districtBoundaryMapper.selectDistrictBoundaries();
	}
}
