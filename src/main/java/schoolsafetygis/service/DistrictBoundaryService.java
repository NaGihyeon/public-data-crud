package schoolsafetygis.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import schoolsafetygis.dto.DistrictBoundaryDTO;
import schoolsafetygis.mapper.DistrictBoundaryMapper;

/**
 * 자치구 경계 조회 관련 비즈니스 로직을 처리하는 서비스 클래스입니다.
 *
 * @author 나기현
 * @since 2026.09.29
 * @version 1.0
 */
@Service
public class DistrictBoundaryService {

	@Autowired
	private DistrictBoundaryMapper districtBoundaryMapper;

	public List<DistrictBoundaryDTO> getDistrictBoundaries() {
		return districtBoundaryMapper.selectDistrictBoundaries();
	}
}
