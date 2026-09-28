<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">

<title>학교 주변 교통안전 관리 시스템</title>

<link rel="stylesheet"
	href="https://openlayers.org/en/v6.15.1/css/ol.css">

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/main.css">

</head>

<body>

	<!-- 상단 Header -->
	<header class="header">

		<div class="header-title">
			<strong>초등학교 통학안전 점검관리</strong> <span>서울시 지역교육지원청 Web GIS</span>
		</div>

		<!-- 지역 필터 -->
		<select id="regionFilter" class="region-filter">
			<option value="all">서울시 전체</option>
			<option value="" disabled>교육지원청 / 자치구 연동 예정</option>
		</select>

		<div class="header-divider"></div>

		<!-- 학교 검색 -->
		<div class="header-search">
			<input type="text" id="schoolSearch" placeholder="학교명 검색...">

			<button type="button" id="searchButton">검색</button>
		</div>

	</header>


	<main class="main-container">

		<!-- 왼쪽 목록 -->
		<section class="list-panel">

			<div class="list-title">

				<div class="list-title-row">
					<h2>학교 목록</h2>
					<span class="list-count">0개</span>
				</div>

				<!-- 상태 필터 -->
				<div class="status-filter">
					<button type="button" class="filter-button active">전체</button>

					<button type="button" class="filter-button">미확인</button>

					<button type="button" class="filter-button">점검예정</button>

					<button type="button" class="filter-button">점검완료</button>

					<button type="button" class="filter-button">검토제외</button>
				</div>

			</div>


			<div id="schoolList" class="school-list">

				<div class="empty-message">학교 목록(DB 연동 예정)</div>

			</div>

		</section>


		<!-- 오른쪽 지도 -->
		<section class="map-panel">

			<!-- 레이어 범례 -->
			<div class="map-legend" id="mapLegend">

				<button type="button" class="legend-header" id="legendToggle"
					aria-expanded="true">

					<span>레이어 범례</span>

					<svg class="legend-chevron" width="12" height="12"
						viewBox="0 0 12 12">
						<path d="M2 4l4 4 4-4" stroke="currentColor" stroke-width="1.5"
							fill="none" stroke-linecap="round" stroke-linejoin="round" />
					</svg>

				</button>

				<div class="legend-content">

					<div class="legend-section-title">안전시설</div>

					<label class="legend-item">
						<div class="legend-label">
							<span class="legend-color crosswalk"></span> <span>횡단보도</span>
						</div> <input type="checkbox" id="crosswalkToggle" checked> <span
						class="toggle-switch"></span>
					</label> <label class="legend-item">
						<div class="legend-label">
							<span class="legend-color signal"></span> <span>보행신호등</span>
						</div> <input type="checkbox" id="signalToggle" checked> <span
						class="toggle-switch"></span>
					</label> <label class="legend-item">
						<div class="legend-label">
							<span class="legend-color hump"></span> <span>과속방지턱</span>
						</div> <input type="checkbox" id="humpToggle" checked> <span
						class="toggle-switch"></span>
					</label>

					<div class="legend-section-title safety-title">행정구역</div>

					<label class="legend-item">
						<div class="legend-label">
							<span class="legend-line district"></span> <span>자치구 경계</span>
						</div> <input type="checkbox" id="districtToggle" checked> <span
						class="toggle-switch"></span>
					</label>

				</div>

			</div>


			<div id="map"></div>

			<!-- 학교 상세정보 영역 -->
			<aside id="detailPanel" class="detail-panel">

				<div class="detail-header">
					<h2>학교 상세</h2>
				</div>

				<div class="detail-content">

					<div class="detail-empty">
						지도 또는 목록에서 학교를 선택하면<br> 상세정보가 표시(DB 연동 예정)
					</div>

				</div>

			</aside>

		</section>

	</main>


	<script src="https://openlayers.org/en/v6.15.1/build/ol.js"></script>

	<script>
		window.contextPath = '${pageContext.request.contextPath}';
	</script>

	<script src="${pageContext.request.contextPath}/js/map.js"></script>

</body>
</html>