package schoolSafetyGIS.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TrafficIncidentApiDTO {

	private String accId;
	private String occrDate;
	private String occrTime;
	private String expClrDate;
	private String expClrTime;
	private String accType;
	private String accDetailType;
	private String linkId;
	private Double grs80tmX;
	private Double grs80tmY;
	private String accInfo;
}
