package schoolsafetygis.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PedestrianSignalDTO {

	private Long signalId;
	private Long sourceSequence;
	private String districtName;
	private String address;
	private String managementNo;
	private String signalType;
	private Boolean pedestrianButtonYn;
	private Boolean acousticSignalYn;
	private Boolean remainingTimeDisplayYn;
	private Double longitude;
	private Double latitude;
}
