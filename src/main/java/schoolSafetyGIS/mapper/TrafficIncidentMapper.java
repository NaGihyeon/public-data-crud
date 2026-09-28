package schoolSafetyGIS.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import schoolSafetyGIS.dto.TrafficIncidentApiDTO;
import schoolSafetyGIS.dto.TrafficIncidentDTO;

public interface TrafficIncidentMapper {

	int upsertTrafficIncident(TrafficIncidentApiDTO incident);

	int deleteStaleTrafficIncidents(@Param("accIds") List<String> accIds);

	int deleteAllTrafficIncidents();

	List<TrafficIncidentDTO> selectTrafficIncidents();
}
