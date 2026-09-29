package schoolsafetygis.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import schoolsafetygis.dto.DistrictBoundaryDTO;
import schoolsafetygis.service.DistrictBoundaryService;

@RestController
public class DistrictBoundaryController {

	@Autowired
	private DistrictBoundaryService districtBoundaryService;

	@GetMapping("/district-boundaries.do")
	public List<DistrictBoundaryDTO> getDistrictBoundaries() {
		return districtBoundaryService.getDistrictBoundaries();
	}
}
