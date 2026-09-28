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

	// 1. 기본 지도
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

	// 2. 횡단보도 레이어 (파란색)
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

	// 3. 과속방지턱 레이어 (주황색)
	var humpSource = new ol.source.Vector();

	var humpLayer = new ol.layer.Vector({
		source: humpSource,
		style: new ol.style.Style({
			image: new ol.style.Circle({
				radius: 5,
				fill: new ol.style.Fill({
					color: '#f97316'
				}),
				stroke: new ol.style.Stroke({
					color: '#ffffff',
					width: 1.5
				})
			})
		})
	});

	map.addLayer(humpLayer);

	// 4. 보행신호등 레이어 (초록색)
	var signalSource = new ol.source.Vector();

	var signalLayer = new ol.layer.Vector({
		source: signalSource,
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

	map.addLayer(signalLayer);


	// 5. 횡단보도 조회 및 표시
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

	// 6. 험프 조회 및 표시
	fetch(window.contextPath + '/safety-facility/humps.do')
		.then(function(response) {
			if (!response.ok) {
				throw new Error(
					'험프 조회 실패: ' + response.status
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
				'험프 지도 표시 완료:',
				features.length + '건'
			);
		})
		.catch(function(error) {
			console.error('험프 오류:', error);
		});

	// 7. 보행신호등 조회 및 표시
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


	console.log('OpenLayers 로딩 성공');
	console.log('지도 생성 성공');

	window.schoolSafetyMap = map;

}());
