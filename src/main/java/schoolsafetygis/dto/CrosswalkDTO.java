package schoolsafetygis.dto;

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


    public Long getCrosswalkId() {
        return crosswalkId;
    }

    public void setCrosswalkId(Long crosswalkId) {
        this.crosswalkId = crosswalkId;
    }

    public String getManagementNo() {
        return managementNo;
    }

    public void setManagementNo(String managementNo) {
        this.managementNo = managementNo;
    }

    public String getDistrictName() {
        return districtName;
    }

    public void setDistrictName(String districtName) {
        this.districtName = districtName;
    }

    public String getLotAddress() {
        return lotAddress;
    }

    public void setLotAddress(String lotAddress) {
        this.lotAddress = lotAddress;
    }

    public String getCrosswalkType() {
        return crosswalkType;
    }

    public void setCrosswalkType(String crosswalkType) {
        this.crosswalkType = crosswalkType;
    }

    public Boolean getRaisedYn() {
        return raisedYn;
    }

    public void setRaisedYn(Boolean raisedYn) {
        this.raisedYn = raisedYn;
    }

    public Boolean getPedestrianSignalYn() {
        return pedestrianSignalYn;
    }

    public void setPedestrianSignalYn(Boolean pedestrianSignalYn) {
        this.pedestrianSignalYn = pedestrianSignalYn;
    }

    public Boolean getAcousticSignalYn() {
        return acousticSignalYn;
    }

    public void setAcousticSignalYn(Boolean acousticSignalYn) {
        this.acousticSignalYn = acousticSignalYn;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }
}
