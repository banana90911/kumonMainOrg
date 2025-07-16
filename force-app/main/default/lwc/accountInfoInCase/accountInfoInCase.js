import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getChildren from '@salesforce/apex/AccountChildrenController.getChildren';
import FAMILY_IMAGE from '@salesforce/resourceUrl/Mother';
import BABY_IMAGE from '@salesforce/resourceUrl/Baby'
import { NavigationMixin } from 'lightning/navigation';
const FIELDS = [
    'Case.AccountId__c',
    'Case.AccountId__r.Name',
    'Case.AccountId__r.CityName__c',
    'Case.AccountId__r.State__c',
    'Case.AccountId__r.Street__c',
    'Case.AccountId__r.Phone'
];

export default class AccountInfoInCase extends NavigationMixin(LightningElement) {
    @api recordId;
    accountId;
    accountName;
    cityName;
    state;
    street;
    phoneNumber;
    familyImageUrl = FAMILY_IMAGE;
    babyImageUrl = BABY_IMAGE;

    //아동 정보 가져오기
    children = [];
    hasChildren = false;


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            const acc = data.fields.AccountId__r;
            this.accountId = data.fields.AccountId__c.value;
            this.accountName = acc.displayValue || acc.value.fields.Name.value;
            this.cityName = acc.value.fields.CityName__c.value;
            this.state = acc.value.fields.State__c.value;
            this.street = acc.value.fields.Street__c.value;
            this.phoneNumber = acc.value.fields.Phone.value;
        } else if (error) {
            this.accountName = '정보를 불러올 수 없습니다';
            this.cityName = this.state = this.street = '-';
            console.error('getRecord error:', error);
        }
    }

    @wire(getChildren, { accountId: '$accountId' })
    wiredChildren({ error, data }) {
        if (data) {
            console.log('✅ 자녀 데이터 수신:', data);
            this.children = data;
            this.hasChildren = data.length > 0;
        } else if (error) {
            console.error('❌ Apex 오류 발생:', error);
        }
    }

    handleChildClick(event) {
        const contactId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }
}