package schoolsafetygis.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import schoolsafetygis.dto.TrafficIncidentDTO;
import schoolsafetygis.service.TrafficIncidentService;

@RestController
public class TrafficIncidentController {

	@Autowired
	private TrafficIncidentService trafficIncidentService;


	@GetMapping("/traffic-incidents.do")
	public List<TrafficIncidentDTO> getTrafficIncidents() {

		return trafficIncidentService.getTrafficIncidents();
	}

	@GetMapping("/traffic-incident-codes.do")
	public Map<String, Map<String, String>> getTrafficIncidentCodes() throws Exception {

		return trafficIncidentService.getTrafficIncidentCodes();
	}

}
