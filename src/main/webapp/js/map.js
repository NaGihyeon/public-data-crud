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

	// 횡단보도 레이어 (파란색)
	var crosswalkSource = new ol.source.Vector();

	var crosswalkLayer = new ol.layer.Vector({
		source: crosswalkSource,
		style: new ol.style.Style({
			image: new ol.style.Circle({
				radius: 5,
				fill: new ol.style.Fill({
					color: '#3478f6'
				}),
				stroke: new ol.style.Stroke({
					color: '#ffffff',
					width: 1.5
				})
			})
		})
	});

	map.addLayer(crosswalkLayer);
	crosswalkLayer.setZIndex(10);

	// 과속방지턱 레이어 (초록색)
	var humpSource = new ol.source.Vector();

	var humpLayer = new ol.layer.Vector({
		source: humpSource,
		style: new ol.style.Style({
			image: new ol.style.Circle({
				radius: 5,
				fill: new ol.style.Fill({
					color: '#22c55e'
				}),
				stroke: new ol.style.Stroke({
					color: '#ffffff',
					width: 1.5
				})
			})
		})
	});

	map.addLayer(humpLayer);
	humpLayer.setZIndex(10);

	// 보행신호등 레이어 (보라색)
	var signalSource = new ol.source.Vector();

	var signalLayer = new ol.layer.Vector({
		source: signalSource,
		style: new ol.style.Style({
			image: new ol.style.Circle({
				radius: 5,
				fill: new ol.style.Fill({
					color: '#8b5cf6'
				}),
				stroke: new ol.style.Stroke({
					color: '#ffffff',
					width: 1.5
				})
			})
		})
	});

	map.addLayer(signalLayer);
	signalLayer.setZIndex(10);


	// 실시간 돌발정보 레이어
	var incidentSource = new ol.source.Vector();

	var incidentLayer = new ol.layer.Vector({
		source: incidentSource,
		zIndex: 30,
		style: new ol.style.Style({
			image: new ol.style.Circle({
				radius: 6,
				fill: new ol.style.Fill({
					color: '#ef4444'
				}),
				stroke: new ol.style.Stroke({
					color: '#ffffff',
					width: 2
				})
			})
		})
	});

	map.addLayer(incidentLayer);
	incidentLayer.setZIndex(10);




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


	// 안전시설 레이어 ON/OFF
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







	// 횡단보도 조회 및 표시
	fetch(window.contextPath + '/safety-facility/crosswalks.do')
		.then(function(response) {
			if (!response.ok) {
				throw new Error(
					'횡단보도 조회 실패: ' + response.status
				);
			}
			return response.json();
		})
		.then(function(data) {
			var features = [];

			data.forEach(function(item) {
				if (item.longitude == null ||
					item.latitude == null) {
					return;
				}

				var feature = new ol.Feature({
					geometry: new ol.geom.Point(
						ol.proj.fromLonLat([
							Number(item.longitude),
							Number(item.latitude)
						])
					),
					facilityType: 'crosswalk',
					crosswalkId: item.crosswalkId,
					managementNo: item.managementNo,
					districtName: item.districtName,
					lotAddress: item.lotAddress,
					crosswalkType: item.crosswalkType,
					raisedYn: item.raisedYn,
					pedestrianSignalYn: item.pedestrianSignalYn,
					acousticSignalYn: item.acousticSignalYn
				});

				features.push(feature);
			});

			crosswalkSource.addFeatures(features);

			console.log(
				'횡단보도 지도 표시 완료:',
				features.length + '건'
			);
		})
		.catch(function(error) {
			console.error('횡단보도 오류:', error);
		});

	// 과속방지턱 조회 및 표시
	fetch(window.contextPath + '/safety-facility/humps.do')
		.then(function(response) {
			if (!response.ok) {
				throw new Error(
					'과속방지턱 조회 실패: ' + response.status
				);
			}
			return response.json();
		})
		.then(function(data) {
			var features = [];

			data.forEach(function(item) {
				if (item.longitude == null ||
					item.latitude == null) {
					return;
				}

				var feature = new ol.Feature({
					geometry: new ol.geom.Point(
						ol.proj.fromLonLat([
							Number(item.longitude),
							Number(item.latitude)
						])
					),
					facilityType: 'speedHump',
					humpId: item.humpId,
					managementNo: item.managementNo,
					humpType: item.humpType,
					installationDate: item.installationDate,
					districtCode: item.districtCode,
					status: item.status
				});

				features.push(feature);
			});

			humpSource.addFeatures(features);

			console.log(
				'과속방지턱 지도 표시 완료:',
				features.length + '건'
			);
		})
		.catch(function(error) {
			console.error('과속방지턱 오류:', error);
		});

	// 보행신호등 조회 및 표시
	fetch(window.contextPath + '/safety-facility/signals.do')
		.then(function(response) {
			if (!response.ok) {
				throw new Error(
					'보행신호등 조회 실패: ' + response.status
				);
			}
			return response.json();
		})
		.then(function(data) {
			var features = [];

			data.forEach(function(item) {
				if (item.longitude == null ||
					item.latitude == null) {
					return;
				}

				var feature = new ol.Feature({
					geometry: new ol.geom.Point(
						ol.proj.fromLonLat([
							Number(item.longitude),
							Number(item.latitude)
						])
					),
					facilityType: 'pedestrianSignal',
					signalId: item.signalId,
					sourceSequence: item.sourceSequence,
					districtName: item.districtName,
					address: item.address,
					managementNo: item.managementNo,
					signalType: item.signalType,
					pedestrianButtonYn: item.pedestrianButtonYn,
					acousticSignalYn: item.acousticSignalYn,
					remainingTimeDisplayYn: item.remainingTimeDisplayYn
				});

				features.push(feature);
			});

			signalSource.addFeatures(features);

			console.log(
				'보행신호등 지도 표시 완료:',
				features.length + '건'
			);
		})
		.catch(function(error) {
			console.error('보행신호등 오류:', error);
		});


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
	fetch(window.contextPath + '/traffic-incidents.do')
		.then(function(response) {

			if (!response.ok) {
				throw new Error(
					'돌발정보 조회 실패: ' + response.status
				);
			}

			return response.json();
		})
		.then(function(data) {

			var features = [];

			data.forEach(function(item) {

				if (item.longitude == null
					|| item.latitude == null) {
					return;
				}

				var feature = new ol.Feature({
					geometry: new ol.geom.Point(
						ol.proj.fromLonLat([
							Number(item.longitude),
							Number(item.latitude)
						])
					),

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
				});

				features.push(feature);
			});

			incidentSource.addFeatures(features);

			console.log(
				'돌발정보 지도 표시 완료:',
				features.length + '건'
			);
		})
		.catch(function(error) {
			console.error('돌발정보 오류:', error);
		});


	// 자치구 경계 조회 및 표시
	fetch(window.contextPath + '/district-boundaries.do')
		.then(function(response) {
			if (!response.ok) {
				throw new Error(
					'자치구 경계 조회 실패: ' + response.status
				);
			}

			return response.json();
		})
		.then(function(data) {

			var geoJsonFormat = new ol.format.GeoJSON();
			var features = [];

			data.forEach(function(item) {

				if (!item.geoJson) {
					return;
				}

				var geometry = geoJsonFormat.readGeometry(
					JSON.parse(item.geoJson),
					{
						dataProjection: 'EPSG:4326',
						featureProjection: 'EPSG:3857'
					}
				);

				var feature = new ol.Feature({
					geometry: geometry,
					districtCode: item.districtCode,
					districtName: item.districtName
				});

				features.push(feature);
			});

			districtSource.addFeatures(features);

			console.log(
				'자치구 경계 지도 표시 완료:',
				features.length + '건'
			);
		})
		.catch(function(error) {
			console.error('자치구 경계 오류:', error);
		});


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
