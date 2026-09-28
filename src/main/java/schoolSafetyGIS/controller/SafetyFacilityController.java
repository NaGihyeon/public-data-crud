package schoolSafetyGIS.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import schoolSafetyGIS.dto.CrosswalkDTO;
import schoolSafetyGIS.dto.SpeedHumpDTO;
import schoolSafetyGIS.dto.PedestrianSignalDTO;
import schoolSafetyGIS.service.SafetyFacilityService;

@Controller
public class SafetyFacilityController {

	@Autowired
	private SafetyFacilityService safetyFacilityService;

	@RequestMapping(value = "/safety-facility/crosswalks.do", produces = "application/json; charset=UTF-8")
	@ResponseBody
	public List<CrosswalkDTO> selectCrosswalkList() {
		return safetyFacilityService.selectCrosswalkList();
	}

	@RequestMapping(value = "/safety-facility/humps.do", produces = "application/json; charset=UTF-8")
	@ResponseBody
	public List<SpeedHumpDTO> selectSpeedHumpList() {
		return safetyFacilityService.selectSpeedHumpList();
	}

	@RequestMapping(value = "/safety-facility/signals.do", produces = "application/json; charset=UTF-8")
	@ResponseBody
	public List<PedestrianSignalDTO> selectPedestrianSignalList() {
		return safetyFacilityService.selectPedestrianSignalList();
	}

}
