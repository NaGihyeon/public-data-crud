(function() {

	'use strict';


	/*
	 * OpenLayers 로딩 실패 시
	 * 흰 화면 대신 오류를 화면에 표시한다.
	 */
	function showMapError(message) {

		var mapElement = document.getElementById('map');

		if (!mapElement) {
			return;
		}

		mapElement.innerHTML =
			'<div class="map-error">'
			+ message
			+ '</div>';
	}


	/*
	 * OpenLayers가 제대로 로드되었는지 확인
	 */
	if (typeof ol === 'undefined') {

		showMapError(
			'OpenLayers를 불러오지 못했습니다. '
			+ '네트워크 또는 라이브러리 경로를 확인하세요.'
		);

		return;
	}


	/*
	 * 지도 생성
	 */
	var map = new ol.Map({

		target: 'map',

		layers: [

			/*
			 * 현재는 기본 배경지도로
			 * OpenStreetMap 사용
			 */
			new ol.layer.Tile({

				source: new ol.source.OSM()

			})

		],

		view: new ol.View({

			/*
			 * 서울 중심 좌표
			 *
			 * 입력값:
			 * EPSG:4326
			 *
			 * OpenLayers 화면 좌표:
			 * EPSG:3857
			 */
			center: ol.proj.fromLonLat([
				126.9780,
				37.5665
			]),

			zoom: 11

		})

	});


	/*
	 * 개발 중 Console에서 확인하기 위함
	 */
	console.log('OpenLayers 로딩 성공');
	console.log('지도 생성 성공');


	/*
	 * 나중에 다른 JavaScript에서도
	 * 지도를 사용할 수 있도록 보관
	 */
	window.schoolSafetyMap = map;

}());