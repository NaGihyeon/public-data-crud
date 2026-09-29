(function() {
	'use strict';

	function showMapError(message) {
		var mapElement = document.getElementById('map');

		if (mapElement) {
			mapElement.innerHTML =
				'<div class="map-error">' + message + '</div>';
		}
	}

	if (typeof ol === 'undefined') {
		showMapError('OpenLayers를 불러오지 못했습니다.');
		return;
	}

	// 기본 지도
	var map = new ol.Map({
		target: 'map',
		layers: [
			new ol.layer.Tile({
				source: new ol.source.OSM()
			})
		],
		view: new ol.View({
			center: ol.proj.fromLonLat([126.9780, 37.5665]),
			zoom: 11
		})
	});


	var incidentMainCodes = {};
	var incidentSubCodes = {};


	// Point 레이어 생성
	function createPointLayer(source, color) {

		var layer = new ol.layer.Vector({
			source: source,
			style: new ol.style.Style({
				image: new ol.style.Circle({
					radius: 5,
					fill: new ol.style.Fill({
						color: color
					}),
					stroke: new ol.style.Stroke({
						color: '#ffffff',
						width: 1.5
					})
				})
			})
		});

		layer.setZIndex(10);
		map.addLayer(layer);

		return layer;
	}



	// 횡단보도
	var crosswalkSource = new ol.source.Vector();
	var crosswalkLayer =
		createPointLayer(crosswalkSource, '#3478f6');

	// 과속방지턱
	var humpSource = new ol.source.Vector();
	var humpLayer =
		createPointLayer(humpSource, '#22c55e');

	// 보행신호등
	var signalSource = new ol.source.Vector();
	var signalLayer =
		createPointLayer(signalSource, '#8b5cf6');

	// 실시간 돌발정보
	var incidentSource = new ol.source.Vector();
	var incidentLayer =
		createPointLayer(incidentSource, '#ef4444');

	// 교통 CCTV
	var cctvSource = new ol.source.Vector();
	var cctvLayer =
		createPointLayer(cctvSource, '#0f766e');


	// 자치구 경계 레이어
	var districtSource = new ol.source.Vector();

	var districtLayer = new ol.layer.Vector({
		source: districtSource,
		style: new ol.style.Style({
			fill: new ol.style.Fill({
				color: 'rgba(100, 116, 139, 0.04)'
			}),
			stroke: new ol.style.Stroke({
				color: '#64748b',
				width: 1.5
			})
		})
	});

	districtLayer.setZIndex(1);
	map.addLayer(districtLayer);


	// 레이어 ON/OFF
	function bindLayerToggle(elementId, layer) {
		var checkbox = document.getElementById(elementId);

		if (!checkbox) {
			return;
		}

		layer.setVisible(checkbox.checked);

		checkbox.addEventListener('change', function() {
			layer.setVisible(this.checked);
		});
	}

	bindLayerToggle('crosswalkToggle', crosswalkLayer);
	bindLayerToggle('signalToggle', signalLayer);
	bindLayerToggle('humpToggle', humpLayer);
	bindLayerToggle('incidentToggle', incidentLayer);
	bindLayerToggle('cctvToggle', cctvLayer);
	bindLayerToggle('districtToggle', districtLayer);


	// 레이어 범례 접기 / 펼치기
	var mapLegend = document.getElementById('mapLegend');
	var legendToggle = document.getElementById('legendToggle');

	// 범례에서 브라우저 기본 드래그 방지
	if (mapLegend) {
		mapLegend.addEventListener('dragstart', function(event) {
			event.preventDefault();
		});
	}


	if (mapLegend && legendToggle) {

		legendToggle.addEventListener('click', function() {

			var collapsed =
				mapLegend.classList.toggle('collapsed');

			legendToggle.setAttribute(
				'aria-expanded',
				String(!collapsed)
			);
		});
	}


	// 데이터 조회 및 지도 Feature 추가
	function loadFeatures(
		url,
		source,
		dataName,
		createFeature
	) {

		fetch(window.contextPath + url)
			.then(function(response) {

				if (!response.ok) {
					throw new Error(
						dataName + ' 조회 실패: '
						+ response.status
					);
				}

				return response.json();
			})
			.then(function(data) {

				var features = [];

				data.forEach(function(item) {

					var feature = createFeature(item);

					if (feature) {
						features.push(feature);
					}
				});

				source.addFeatures(features);

				console.log(
					dataName + ' 지도 표시 완료:',
					features.length + '건'
				);
			})
			.catch(function(error) {

				console.error(
					dataName + ' 오류:',
					error
				);
			});
	}

	// Point Feature 생성
	function createPointFeature(item, properties) {

		if (item.longitude == null
			|| item.latitude == null) {
			return null;
		}

		properties.geometry =
			new ol.geom.Point(
				ol.proj.fromLonLat([
					Number(item.longitude),
					Number(item.latitude)
				])
			);

		return new ol.Feature(properties);
	}





	// 횡단보도 조회 및 지도 표시
	loadFeatures(
		'/safety-facility/crosswalks.do',
		crosswalkSource,
		'횡단보도',
		function(item) {

			return createPointFeature(
				item,
				{
					facilityType: 'crosswalk',
					crosswalkId: item.crosswalkId,
					managementNo: item.managementNo,
					districtName: item.districtName,
					lotAddress: item.lotAddress,
					crosswalkType: item.crosswalkType,
					raisedYn: item.raisedYn,
					pedestrianSignalYn: item.pedestrianSignalYn,
					acousticSignalYn: item.acousticSignalYn
				}
			);
		}
	);


	// 과속방지턱 조회 및 지도 표시
	loadFeatures(
		'/safety-facility/humps.do',
		humpSource,
		'과속방지턱',
		function(item) {

			return createPointFeature(
				item,
				{
					facilityType: 'speedHump',
					humpId: item.humpId,
					managementNo: item.managementNo,
					humpType: item.humpType,
					installationDate: item.installationDate,
					districtCode: item.districtCode,
					status: item.status
				});
		}
	);

	// 보행신호등 조회 및 지도 표시
	loadFeatures(
		'/safety-facility/signals.do',
		signalSource,
		'보행신호등',
		function(item) {

			return createPointFeature(
				item,
				{
					facilityType: 'pedestrianSignal',
					signalId: item.signalId,
					sourceSequence: item.sourceSequence,
					districtName: item.districtName,
					address: item.address,
					managementNo: item.managementNo,
					signalType: item.signalType,
					pedestrianButtonYn: item.pedestrianButtonYn,
					acousticSignalYn: item.acousticSignalYn,
					remainingTimeDisplayYn:
						item.remainingTimeDisplayYn
				});
		}
	);


	// 돌발정보 유형 코드 조회
	fetch(window.contextPath + '/traffic-incident-codes.do')
		.then(function(response) {

			if (!response.ok) {
				throw new Error(
					'돌발정보 코드 조회 실패: '
					+ response.status
				);
			}

			return response.json();
		})
		.then(function(data) {

			incidentMainCodes =
				data.main || {};

			incidentSubCodes =
				data.sub || {};

			console.log(
				'돌발정보 코드 조회 완료'
			);
		})
		.catch(function(error) {
			console.error(
				'돌발정보 코드 오류:',
				error
			);
		});


	// 실시간 돌발정보 조회 및 표시
	loadFeatures(
		'/traffic-incidents.do',
		incidentSource,
		'돌발정보',
		function(item) {

			return createPointFeature(
				item,
				{
					dataType: 'trafficIncident',
					accId: item.accId,
					occurredAt: item.occurredAt,
					expectedClearAt: item.expectedClearAt,
					accType: item.accType,
					accDetailType: item.accDetailType,
					linkId: item.linkId,
					accInfo: item.accInfo,
					longitude: Number(item.longitude),
					latitude: Number(item.latitude)
				}
			);
		}
	);





	// CCTV 조회 및 표시
	loadFeatures(
		'/traffic-cctvs.do',
		cctvSource,
		'CCTV',
		function(item) {

			return createPointFeature(
				item,
				{
					dataType: 'trafficCctv',
					cctvId: item.cctvId,
					cctvName: item.cctvName,
					centerName: item.centerName,
					movieYn: item.movieYn,
					longitude: Number(item.longitude),
					latitude: Number(item.latitude)
				}
			);
		}
	);




	// 자치구 경계 조회 및 표시
	var geoJsonFormat = new ol.format.GeoJSON();

	loadFeatures(
		'/district-boundaries.do',
		districtSource,
		'자치구 경계',
		function(item) {

			if (!item.geoJson) {
				return null;
			}

			var geometry =
				geoJsonFormat.readGeometry(
					JSON.parse(item.geoJson),
					{
						dataProjection: 'EPSG:4326',
						featureProjection: 'EPSG:3857'
					}
				);

			return new ol.Feature({
				geometry: geometry,
				districtCode: item.districtCode,
				districtName: item.districtName
			});
		}
	);


	// =========================
	// 실시간 돌발정보 상세 팝업
	// =========================

	var incidentPopupElement =
		document.getElementById('incidentPopup');

	var incidentPopupClose =
		document.getElementById('incidentPopupClose');

	var incidentPopup =
		new ol.Overlay({
			element: incidentPopupElement,
			positioning: 'bottom-center',
			offset: [0, -12],
			stopEvent: true
		});

	map.addOverlay(incidentPopup);


	// 지도 클릭
	map.on('singleclick', function(event) {

		var incidentFeature =
			map.forEachFeatureAtPixel(
				event.pixel,
				function(feature, layer) {

					if (layer === incidentLayer) {
						return feature;
					}

					return null;
				}
			);

		if (!incidentFeature) {

			incidentPopup.setPosition(
				undefined
			);

			if (incidentPopupElement) {
				incidentPopupElement.style.display =
					'none';
			}

			return;
		}


		var accType =
			incidentFeature.get('accType');

		var accDetailType =
			incidentFeature.get(
				'accDetailType'
			);

		var accTypeName =
			incidentMainCodes[accType]
			|| accType
			|| '-';

		var accDetailTypeName =
			incidentSubCodes[accDetailType]
			|| accDetailType
			|| '-';


		document.getElementById(
			'incidentType'
		).textContent =
			accTypeName;

		document.getElementById(
			'incidentDetailType'
		).textContent =
			accDetailTypeName;

		document.getElementById(
			'incidentOccurredAt'
		).textContent =
			incidentFeature.get(
				'occurredAt'
			) || '-';

		document.getElementById(
			'incidentExpectedClearAt'
		).textContent =
			incidentFeature.get(
				'expectedClearAt'
			) || '-';


		var longitude =
			incidentFeature.get(
				'longitude'
			);

		var latitude =
			incidentFeature.get(
				'latitude'
			);

		if (longitude != null
			&& latitude != null) {

			document.getElementById(
				'incidentLocation'
			).textContent =
				longitude.toFixed(6)
				+ ', '
				+ latitude.toFixed(6);

		} else {

			document.getElementById(
				'incidentLocation'
			).textContent = '-';
		}


		document.getElementById(
			'incidentInfo'
		).textContent =
			incidentFeature.get(
				'accInfo'
			) || '-';


		incidentPopupElement.style.display =
			'block';

		incidentPopup.setPosition(
			incidentFeature
				.getGeometry()
				.getCoordinates()
		);
	});


	// 팝업 닫기
	if (incidentPopupClose) {

		incidentPopupClose
			.addEventListener(
				'click',
				function() {

					incidentPopup.setPosition(
						undefined
					);

					incidentPopupElement
						.style.display =
						'none';
				}
			);
	}



	console.log('OpenLayers 로딩 성공');
	console.log('지도 생성 성공');

	window.schoolSafetyMap = map;

}());
