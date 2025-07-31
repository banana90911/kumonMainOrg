import { LightningElement, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import LEAFLET from '@salesforce/resourceUrl/leaflet';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Account.CityName__c',
    'Account.State__c',
    'Account.Street__c'
];

export default class LocationMap extends LightningElement {
    @api recordId;
    leafletInitialized = false;
    address = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount({ data }) {
        if (data) {
            const city = data.fields.CityName__c?.value || '';
            const district = data.fields.State__c?.value || '';
            const street = data.fields.Street__c?.value || '';
            this.address = `${city} ${district} ${street}`.trim();
            this.initLeaflet(); // 주소 준비된 후 지도 초기화
        }
    }

    renderedCallback() {
        if (this.leafletInitialized || !this.address) return;
        this.initLeaflet();
    }

    initLeaflet() {
        this.leafletInitialized = true;

        Promise.all([
            loadScript(this, LEAFLET + '/leaflet.js'),
            loadStyle(this, LEAFLET + '/leaflet.css')
        ]).then(() => {
            this.loadMap();
        }).catch(error => {
            console.error('Leaflet load error:', error);
        });
    }

    loadMap() {
        const mapContainer = this.template.querySelector('.map');
        mapContainer.innerHTML = ''; // reset

        // 지도 기본 위치 설정 (서울 중심, 실제 주소는 이후 geocoding으로)
        const map = L.map(mapContainer).setView([37.5665, 126.9780], 13);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: 'Map data © OpenStreetMap contributors'
        }).addTo(map);

        // 지오코딩 API (OpenStreetMap Nominatim 사용)
        const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(this.address)}`;
        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (data && data.length > 0) {
                    const lat = data[0].lat;
                    const lon = data[0].lon;
                    map.setView([lat, lon], 16);
                    L.marker([lat, lon]).addTo(map).bindPopup(this.address).openPopup();
                } else {
                    console.warn('위치를 찾을 수 없습니다:', this.address);
                }
            });
    }
}