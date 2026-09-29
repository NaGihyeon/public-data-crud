package schoolsafetygis.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CrosswalkDTO {

        private Long crosswalkId;
        private String managementNo;
        private String districtName;
        private String lotAddress;
        private String crosswalkType;
        private Boolean raisedYn;
        private Boolean pedestrianSignalYn;
        private Boolean acousticSignalYn;
        private Double longitude;
        private Double latitude;
}
