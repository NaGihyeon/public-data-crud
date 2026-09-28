package schoolSafetyGIS.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import schoolSafetyGIS.dto.TrafficCctvDTO;
import schoolSafetyGIS.service.TrafficCctvService;

@RestController
public class TrafficCctvController {

	@Autowired
	private TrafficCctvService trafficCctvService;

	@GetMapping("/traffic-cctvs.do")
	public List<TrafficCctvDTO> getTrafficCctvs() {

		return trafficCctvService.getTrafficCctvs();
	}
}
