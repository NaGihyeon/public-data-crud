package schoolSafetyGIS.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import schoolSafetyGIS.dto.DistrictBoundaryDTO;
import schoolSafetyGIS.service.DistrictBoundaryService;

@RestController
public class DistrictBoundaryController {

	@Autowired
	private DistrictBoundaryService districtBoundaryService;

	@GetMapping("/district-boundaries.do")
	public List<DistrictBoundaryDTO> getDistrictBoundaries() {
		return districtBoundaryService.getDistrictBoundaries();
	}
}
