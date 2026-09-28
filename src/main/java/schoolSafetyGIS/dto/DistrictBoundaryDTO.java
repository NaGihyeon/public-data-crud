package schoolSafetyGIS.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DistrictBoundaryDTO {

	private String districtCode;
	private String districtName;
	private String geoJson;
}
