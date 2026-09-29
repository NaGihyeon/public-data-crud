package schoolsafetygis.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TrafficCctvDTO {

	private String cctvId;
	private String cctvName;
	private String centerName;
	private Boolean movieYn;
	private Double longitude;
	private Double latitude;
}
