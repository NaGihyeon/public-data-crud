package schoolsafetygis.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TrafficIncidentDTO {

	private String accId;
	private String occurredAt;
	private String expectedClearAt;
	private String accType;
	private String accDetailType;
	private String linkId;
	private String accInfo;
	private Double longitude;
	private Double latitude;
}
