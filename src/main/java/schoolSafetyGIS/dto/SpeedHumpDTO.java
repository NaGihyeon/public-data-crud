package schoolSafetyGIS.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SpeedHumpDTO {

	private Long humpId;
	private String managementNo;
	private String humpType;
	private String installationDate;
	private String districtCode;
	private String status;
	private Double longitude;
	private Double latitude;
}
