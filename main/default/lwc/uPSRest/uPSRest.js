import { track, api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import validateAddress from "@salesforce/label/c.Validate_Address";
import shipmentGoing from "@salesforce/label/c.X1_Where_is_this_shipment_going";
import CompanyLabel from "@salesforce/label/c.CompanyLabel";
import ContactLabel from "@salesforce/label/c.ContractConsole_Contact";
import PhoneLabel from "@salesforce/label/c.Phone_AddTimeCardEntry";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Load scripts
import { loadStyle } from 'lightning/platformResourceLoader';
import CMP_CSS from '@salesforce/resourceUrl/CMP_CSS';
import PickPackShipResource from '@salesforce/resourceUrl/PickPackShipResource';
import SLDS from '@salesforce/resourceUrl/SLDS';


import getInitialData from '@salesforce/apex/UPSRestAPI.getDefaultData';
import getRates from '@salesforce/apex/UPSRestAPI.Service_And_Rate_Request';
import Shipping_Request_Response from '@salesforce/apex/UPSRestAPI.Shipping_Request_Response';
import voidShipment from '@salesforce/apex/UPSRestAPI.voidShipment';
import trackShipment from '@salesforce/apex/UPSRestAPI.getTrackingDetails';
import PickupRateRequest from '@salesforce/apex/UPSRestAPI.Pickup_Rate_Request';
import getFedexmyConstructor from '@salesforce/apex/UPSLightning.getFedexmyConstructor';
import getFedexServicesWrapperList from '@salesforce/apex/UPSLightning.getFedexServicesWrapperList';
import generateFedexShipment from '@salesforce/apex/UPSLightning.generateFedexShipment';

import getInitialDataFedex from '@salesforce/apex/FedexLWCRestAPI.getDefaultData';
import getRatesFedex from '@salesforce/apex/FedexLWCRestAPI.getRates';
import shippingRequestResponseFedex from '@salesforce/apex/FedexLWCRestAPI.shippingRequestResponse';

export default class UPSRest extends NavigationMixin(LightningElement) {
    @track rateResponseReturn;
    @track shipmentFlows;
    @track toCompany = '';
    @track isLoading = false;
    @track RateMsg = [];
    @track sucessMsg = '';
    @track ShowAddressbutton = true;
    @track masterShipmentId = '';
    @api shipmentIds = ''; //= 'a0i0600000Eh9ztAAB,a0i0600000EhA5dAAF';
    @api packageIds = [];// = ['a0L0600000SxPFkEAN'];
    @track fromAddress = { 'Id': '', Name: '', ERP7__Address_Line1__c: '', ERP7__Address_Line2__c: '', ERP7__City__c: '', ERP7__State__c: '', ERP7__Postal_Code__c: '', ERP7__Country__c: '', ERP7__Contact__c: '', ERP7__Contact__r: { Id: '', Name: '', ERP7__Company__c: '' } };
    @track suggestedAddress = { 'Id': '', Name: '', ERP7__Address_Line1__c: '', ERP7__Address_Line2__c: '', ERP7__City__c: '', ERP7__State__c: '', ERP7__Postal_Code__c: '', ERP7__Country__c: '', ERP7__Contact__c: '', ERP7__Contact__r: { Id: '', Name: '', ERP7__Company__c: '' } };
    @track ShowCancelShipment = false;
    @track toAddress = { 'Id': '', Name: '', ERP7__Address_Line1__c: '', ERP7__Address_Line2__c: '', ERP7__City__c: '', ERP7__State__c: '', ERP7__Postal_Code__c: '', ERP7__Country__c: '' };
    @track showFromAddress = false;
    @track showToAddress = true;
    @track ShowAddressbutton = false;
    @track toAddressSelected = false;
    @track toAddressUrl = '';
    @track toEmail = '';
    @track toPhone = '';
    @track isCompanyAvailable = false;
    @track isShiptoContactAvailable = false;
    @track toShipmentType = false;
    @track showSuggestedAddress = false;
    @track FromAddressSelected = false;
    @track billingAddressSelected = false;
    @track billContactSelected = false;
    @track fromAddressUrl = '';
    @track FromEmail = '';
    @track fromPhone = '';
    @track fromShipmentType = false;
    @track packageList = [];
    @track packageItems = [];
    @track TermsOfShipment = [];
    @track reasonforexportOptions = [];
    @track signatureserviceOptions = [];
    @track billingOptions = [];
    @track showTabTwo = false;
    @track showTabOne = true;
    @track ShowInitiateShipment = false;
    @track shipment = { Id: null, Name: '', Shipment_Identification_Number__c: '', ERP7__Status__c: '', ERP7__TrackingNumber__c: '', ERP7__Label_options__c: 'LABEL', ERP7__Invoice_Number__c: '', ERP7__Purchase_Order_Number__c: '', ERP7__Terms_Of_Shipment__c: '', ERP7__Reason_For_Export__c: 'SAMPLE', ERP7__Declaration_Statement__c: '', ERP7__Shipment_Date__c: '', ERP7__Description__c: '', ERP7__Signature_Services__c: '', ERP7__Shipment_Billing_options__c: 'SENDER', ERP7__Fedex_Special_Services__c: '', ERP7__Billing_Account_Number__c: '', ERP7__Billing_Contact__c: '', ERP7__Billing_Contact__r: { Id: '', Name: '' }, ERP7__Billing_Address__c: '', ERP7__Billing_Address__r: { Id: '', Name: '' }, ERP7__Package_Ready_Time__c: '', ERP7__Customer_Close_Time__c: '', ERP7__Pickup_Confirmation_Number__c: '' };
    @track returnShipment = { Id: null, Name: '', Shipment_Identification_Number__c: '', ERP7__Status__c: '', ERP7__TrackingNumber__c: '', ERP7__Label_options__c: 'LABEL', ERP7__Invoice_Number__c: '', ERP7__Purchase_Order_Number__c: '', ERP7__Terms_Of_Shipment__c: '', ERP7__Reason_For_Export__c: 'SAMPLE', ERP7__Declaration_Statement__c: '', ERP7__Shipment_Date__c: '', ERP7__Description__c: '', ERP7__Signature_Services__c: '', ERP7__Shipment_Billing_options__c: 'SENDER', ERP7__Fedex_Special_Services__c: '', ERP7__Billing_Account_Number__c: '', ERP7__Billing_Contact__c: '', ERP7__Billing_Contact__r: { Id: '', Name: '' }, ERP7__Billing_Address__c: '', ERP7__Billing_Address__r: { Id: '', Name: '' } };
    @track ShowGetRate = true;
    @track disableBillingOption = false;
    @track showReturnLabel = false;
    @track selectedDate;
    @track selectedTime;
    label = {
        validateAddress,
        shipmentGoing,
        CompanyLabel,
        ContactLabel,
        PhoneLabel
    };
    @track isReturnShipment = false;
    @track defaulWrap = {};
    @track selectedServiceType = '';
    @track selectedServiceCode = '';
    @track selectedCurrency = '';
    @track errorList = [];
    @track Credentials;
    @track fromContact = { Id: '', Name: '', ERP7__Company__c: '', Email: '', Phone: '', AccountId: '', Account: { Id: '', Name: '', Phone: '', ERP7__Email__c: '' } };
    @track toContact = { Id: '', Name: '', ERP7__Company__c: '', Email: '', Phone: '', AccountId: '', Account: { Id: '', Name: '', Phone: '', ERP7__Email__c: '' } };
    @track rateResponse;
    @track showLabel = false;
    @track allowReturnShipment = false;
    @track allowFedExReturnShipmentFromUPS = false;
    @track selectedLogisticReturnShipType = '';
    @track showReturnShipmentTab = false;
    @track showUPSReturnType = false;
    @track showFedexReturnType = false;
    @track showReturnModal = false;
    @track returnShipmentDate = '';
    @track disableEditBillOptReturnShipment = false;
    @track fedexServices = {};
    @track FedexmyConsW = {};
    @track logoUrl = '';
    @track selectedServiceTypeReturn = '';
    @track selectedServiceCodeReturn = '';
    @track selectedCurrencyReturn = '';
    @track ReturnShipTypeUPS = false;

    validateAddressCall() {

    }
    connectedCallback() {
        this.isLoading = true;
        console.log('returnshipment : ',this.isReturnShipment);
        console.log('packageIds : ', JSON.stringify(this.packageIds));
        getInitialData({ ShipId: this.shipmentIds, packIds: JSON.stringify(this.packageIds) })
            .then(result => {
                console.log('getInitialData res : ', result);
                if (result) {
                    if (result.alertlist && result.alertlist.length > 0) {
                        this.errorList = Object.assign([], this.errorList);
                        this.errorList = result.alertlist;
                        this.isLoading = false;
                    }
                    else {


                        this.defaulWrap = result;
                        //console.log('1');
                        this.Credentials = result.credsWrap;
                        if (this.shipmentIds) {
                            if (!result.ship.ERP7__Billing_Contact__c) {
                                result.ship.ERP7__Billing_Contact__c = '';
                                result.ship.ERP7__Billing_Contact__r = { Id: '', Name: '' };
                            }
                            if (!result.ship.ERP7__Billing_Address__c) {
                                result.ship.ERP7__Billing_Address__c = '';
                                result.ship.ERP7__Billing_Address__r = { Id: '', Name: '' };
                            }
                            this.shipment = result.ship;
                            console.log('Name : ', this.shipment.Name);
                        }
                        //console.log('shipment :',JSON.stringify(this.shipment));
                        //console.log('2');
                        if (result.toAddress && Object.keys(result.toAddress).length !== 0) this.toAddress = result.toAddress;
                        else this.errorList.push('To Address is missing on your logistics.');
                        //console.log('3');
                        if (result.fromAddress && Object.keys(result.fromAddress).length !== 0) this.fromAddress = result.fromAddress;
                        else this.errorList.push('From Address is missing on your logistics.');
                        //console.log('4');
                        if (this.fromAddress.Id) {
                            this.FromAddressSelected = true;
                            this.fromAddressUrl = '/' + this.fromAddress.Id;
                        }
                        //console.log('5');
                        if (this.toAddress.Id) {
                            this.toAddressSelected = true;
                            this.toAddressUrl = '/' + this.toAddress.Id;
                        }
                        console.log('result.fromContact : ', result.fromContact);
                        if (result.fromContact && Object.keys(result.fromContact).length !== 0) this.fromContact = result.fromContact;
                        else this.errorList.push('From contact is missing on your logistics.');
                        // console.log('7');
                        if (result.toContact && Object.keys(result.toContact).length !== 0) this.toContact = result.toContact;
                        else this.errorList.push('To contact is missing on your logistics.');
                        // console.log('8');
                        for (var x in result.packList) {
                            result.packList[x].packUrl = '/' + result.packList[x].Id;
                        }
                        this.allowReturnShipment = result.allowReturnShipment;
                        this.allowFedExReturnShipmentFromUPS = result.allowFedExReturnShipmentFromUPS;
                        this.disableEditBillOptReturnShipment = result.disableEditBillOptReturnShipment;
                        //console.log('9');
                        if (result.packList && result.packList.length > 0) {
                            this.shipment.ERP7__Shipment_Billing_options__c = result.packList[0].ERP7__Logistic__r.ERP7__Billing_options__c;
                            this.shipment.ERP7__Billing_Contact__c = result.packList[0].ERP7__Logistic__r.ERP7__Billing_Contact__c;
                            if(result.packList[0].ERP7__Logistic__r != null && result.packList[0].ERP7__Logistic__r.ERP7__Account__c != null &&  result.packList[0].ERP7__Logistic__r.ERP7__Account__r) this.toCompany = result.packList[0].ERP7__Logistic__r.ERP7__Account__r.Name;
                            if (result.packList[0].ERP7__Logistic__r.ERP7__Billing_Contact__c) {
                                this.billContactSelected = true;
                                this.shipment.ERP7__Billing_Contact__r.Id = result.packList[0].ERP7__Logistic__r.ERP7__Billing_Contact__c;
                                this.shipment.ERP7__Billing_Contact__r.Name = result.packList[0].ERP7__Logistic__r.ERP7__Billing_Contact__r.Name;

                            }
                            else {
                                this.billContactSelected = false;
                                this.shipment.ERP7__Billing_Contact__r = { Id: '', Name: '' };
                            }
                            this.shipment.ERP7__Billing_Address__c = result.packList[0].ERP7__Logistic__r.ERP7__Billing_Address__c;
                            if (result.packList[0].ERP7__Logistic__r.ERP7__Billing_Address__c) {
                                this.billingAddressSelected = true;
                                this.shipment.ERP7__Billing_Address__r.Id = result.packList[0].ERP7__Logistic__r.ERP7__Billing_Address__c;
                                this.shipment.ERP7__Billing_Address__r.Name = result.packList[0].ERP7__Logistic__r.ERP7__Billing_Address__r.Name;
                            }
                            else {
                                this.billContactSelected = false;
                                this.shipment.ERP7__Billing_Address__r = { Id: '', Name: '' };
                            }
                            this.shipment.ERP7__Billing_Account_Number__c = result.packList[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c;
                            if (this.allowReturnShipment && result.packList[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c) {
                                this.selectedLogisticReturnShipType = result.packList[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c;
                                console.log('this.selectedLogisticReturnShipType : ', this.selectedLogisticReturnShipType);
                                if (this.selectedLogisticReturnShipType == 'UPS') {
                                    this.showUPSReturnType = true;
                                    this.showFedexReturnType = false;
                                }
                                else if (this.selectedLogisticReturnShipType == 'FedEx') {
                                    this.showUPSReturnType = false;
                                    if (this.allowFedExReturnShipmentFromUPS) this.showFedexReturnType = true;
                                }
                            }
                            if (this.allowReturnShipment && this.selectedLogisticReturnShipType == '') {
                                if (this.allowFedExReturnShipmentFromUPS) this.showFedexReturnType = true;
                                this.showUPSReturnType = true;
                            }
                        }
                        console.log('this.showUPSReturn : ', this.showUPSReturnType);
                        // console.log('10');
                        this.packageList = result.packList;
                        this.packageItems = result.packItems;
                        //console.log('11');
                        var today = new Date();
                        if (!this.shipmentIds) this.shipment.ERP7__Shipment_Date__c = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
                        if (this.shipmentIds) {
                            this.showLabel = true;
                            this.ShowGetRate = false;
                            this.ShowCancelShipment = true;
                        }
                        if (result.returnShip && Object.keys(result.returnShip).length !== 0) {
                            this.showFedexReturnType = false;
                            this.showUPSReturnType = false;
                            this.showReturnLabel = true;
                            this.returnShipment = result.returnShip;
                        }
                        else this.returnShipmentDate = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
                        //console.log('12');
                        this.disableBillingOption = result.disableBillingDetails;

                        this.isLoading = false;
                    }
                }
            }).
            catch(error => {
                this.isLoading = false;
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    get ShowRateMsg() {
        if (this.RateMsg) {
            if (this.RateMsg.length > 0)
                return true;
            else
                return false;
        } else {
            return false;
        }

    }
    get isShipmentShipped() {
        return this.shipment.ERP7__Status__c === 'Shipped';
    }
    renderedCallback() {
        try {
            Promise.all([
                loadStyle(this, CMP_CSS + '/CSS/global-axolt.css'),
                loadStyle(this, PickPackShipResource + '/assets/styles/erp_mark7_bootstrap.css'),
                loadStyle(this, SLDS + '/assets/styles/salesforce-lightning-design-system-vf.css'),
            ])
                .then(() => {
                    console.log('Static Resource Loaded');
                    this.logoUrl = PickPackShipResource + '/assets/images/LOGO_S1.png';
                    console.log('logoUrl : ',this.logoUrl);
                })
                .catch(error => {
                    console.log('Static Resource Error', error);
                });
        } catch (e) {
            console.log('Error:', e);
        }
    }
    get showReturnShipment() {
        if (this.shipment) {
            if (this.shipment.Id && this.allowReturnShipment && !this.returnShipment.Id && this.shipment.ERP7__Status__c != 'Cancelled') {
                console.log('true return ship');
                return true;
            }
            else return false;
        }
        else return false;
    }
    handlebillOptionsChange(event) {
        this.shipment.ERP7__Shipment_Billing_options__c = event.target.value;
    }
    closeErrorList() { this.errorList = []; }
    get isErrorList() {
        if (this.errorList) {
            if (this.errorList.length > 0)
                return true;
            else
                return false;
        } else {
            return false;
        }

    }
    Shipping_Rate() {
        this.isLoading = true;
        console.log('PackageItems : ', JSON.stringify(this.packageList));
        console.log('isReturnShipment : ', this.isReturnShipment);
        this.RateMsg = [];
        var fromadd = (this.isReturnShipment) ? this.toAddress : this.fromAddress;
        var toadd = (this.isReturnShipment) ? this.fromAddress  : this.toAddress;
        var fromCon = (this.isReturnShipment) ? this.toContact   : this.fromContact;
        var toCon = (this.isReturnShipment) ? this.fromContact  : this.toContact;
        var shipDate = (this.isReturnShipment) ? this.returnShipmentDate : this.shipment.ERP7__Shipment_Date__c;
        var ShipDetails = (this.isReturnShipment) ? this.returnShipment :this.shipment;
        getRates({ packList: this.packageList, myConsVar: JSON.stringify(this.Credentials), fromAdd: JSON.stringify(fromadd), toAdd: JSON.stringify(toadd), fromContact: JSON.stringify(fromCon), toContact: JSON.stringify(toCon), shipDate: shipDate, Shipment: JSON.stringify(ShipDetails), isReturnShipment: this.isReturnShipment }).then(result => {
            if (result) {
                console.log('getRates result : ', result);

                if (result.error != null && result.error != '' && result.error != undefined) {
                    this.errorList = Object.assign([], this.errorList);
                    this.errorList.push(result.error);
                    let responseObject = JSON.parse(result.response);
                    if (responseObject && responseObject.response && responseObject.response.errors && responseObject.response.errors.length > 0) {
                        let errorMessage = responseObject.response.errors[0].message;
                        this.errorList.push(errorMessage);
                    }
                }
                else {
                    var rateSample = result.ratesList;
                    if(this.isReturnShipment){
                        this.rateResponseReturn = rateSample;
                        this.showReturnModal = true;
                    }
                    else{
                        this.rateResponse = rateSample;
                       
                    }
                    if (result.alertlist) {
                        this.RateMsg = result.alertlist;
                    }
                }
                this.isLoading = false;

            }
        })
            .catch(error => {
                this.isLoading = false;
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    handleServiceTypeChange(event) {
        this.selectedServiceType = event.target.value;
        console.log('Selected Service Type:', this.selectedServiceType);
        var servicecode = event.target.label;
        console.log('Selected servicecode :', servicecode);
        this.selectedServiceCode = servicecode;
        var index = event.target.dataset.index;
        console.log('Selected index :', index);
        this.selectedCurrency = this.rateResponse[index].currencycode;
        console.log('Selected Currency :', this.selectedCurrency);
        if (this.selectedServiceType) {
            this.ShowGetRate = false;
            this.ShowInitiateShipment = true;
        }
    }
    handleReturnServiceTypeChange(event) {
        var rateWrap = this.fedexServices.Services;
        var index = event.target.dataset.index;
        console.log('index : ', index);
        rateWrap[index].Selected = true;
        this.fedexServices.Services = rateWrap;

    }
    Shipping_Request() {
        this.isLoading = true;
        this.RateMsg = [];
        var shipdetails = (this.isReturnShipment) ? this.returnShipment : this.shipment;
        var fromAddress = (this.isReturnShipment) ? this.toAddress : this.fromAddress;
        var toAddress = (this.isReturnShipment) ? this.fromAddress : this.toAddress;
        var shimentDate = (this.isReturnShipment) ? this.returnShipmentDate : this.shipment.ERP7__Shipment_Date__c;
        var fromCont = (this.isReturnShipment) ? this.toContact : this.fromContact;
        var toCont = (this.isReturnShipment) ? this.fromContact : this.toContact;
        var rateSerive = (this.isReturnShipment) ? this.selectedServiceTypeReturn : this.selectedServiceType;
        var rateCurrency = (this.isReturnShipment) ? this.selectedCurrencyReturn : this.selectedCurrency;
        var rateCode = (this.isReturnShipment) ? this.selectedServiceCodeReturn : this.selectedServiceCode;
        var shipId = (this.isReturnShipment) ? this.shipment.Id : '';
        console.log('isReturnShipment : ', this.isReturnShipment);
        Shipping_Request_Response({ packList: this.packageList, myConsVar: JSON.stringify(this.Credentials), fromAdd: JSON.stringify(fromAddress), toAdd: JSON.stringify(toAddress), fromContact: JSON.stringify(fromCont), toContact: JSON.stringify(toCont), shipDate: shimentDate, Shipment: JSON.stringify(shipdetails), isReturnShipment: this.isReturnShipment, packageItems: this.packageItems, service: rateSerive, serviceCode: rateCode, currencyCode: rateCurrency, masterShipmentId: shipId }).then(result => {
            if (result) {
                console.log('res : ', result);
                if (result.error != null && result.error != '' && result.error != undefined) {
                    this.errorList = Object.assign([], this.errorList);
                    this.errorList.push(result.error);
                    let responseObject = JSON.parse(result.response);
                    if (responseObject && responseObject.response && responseObject.response.errors && responseObject.response.errors.length > 0) {
                        let errorMessage = responseObject.response.errors[0].message;
                        this.errorList.push(errorMessage);
                    }
                }
                else {
                    if (this.isReturnShipment) {
                        this.returnShipment = result.shipment;
                        this.showReturnModal = false;
                        this.showReturnLabel = true;
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'Shipment created succesfully!',
                            variant: 'success'
                        });
                        this.dispatchEvent(event);
                    }
                    else this.shipment = result.shipment;
                    this.showLabel = true;
                    this.ShowCancelShipment = true;
                    this.ShowInitiateShipment = false;
                    this.rateResponse = null;
                    this.sucessMsg = 'Shipment created succesfully!';
                    if (this.allowReturnShipment && this.packageList[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c) {
                        this.selectedLogisticReturnShipType = this.packageList[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c;
                        console.log('this.selectedLogisticReturnShipType : ', this.selectedLogisticReturnShipType);
                        if (this.selectedLogisticReturnShipType == 'UPS') {
                            this.showUPSReturnType = true;
                            this.showFedexReturnType = false;
                        }
                        else if (this.selectedLogisticReturnShipType == 'FedEx') {
                            this.showUPSReturnType = false;
                            if (this.allowFedExReturnShipmentFromUPS) this.showFedexReturnType = true;
                        }
                    }
                    if (this.allowReturnShipment && this.selectedLogisticReturnShipType == '') {
                        if (this.allowFedExReturnShipmentFromUPS) this.showFedexReturnType = true;
                        this.showUPSReturnType = true;
                    }
                }
                this.isLoading = false;
            }
        })
            .catch(error => {
                console.log('Error:', error);
                this.isLoading = false;
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    viewReturnLabels() {
        try {
            console.log('label ');

            var shipmentsId = this.returnShipment.Id;
            console.log('shipmentsId ');
            var fileName = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? 'Fedex_Label' : 'UPS_Label';
            var val = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? 'nopdf' : 'pdf';
            var fromAddress = this.fromAddress.ERP7__Country__c;
            var toAddress = this.toAddress.ERP7__Country__c;
            
            console.log('val ');
            var showIframe = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? true : false;
            console.log('showIframe 1: ',showIframe);
            if(fileName == 'Fedex_Label') {
                if(fromAddress != toAddress) showIframe = true;
                else showIframe = false;
            }
            console.log('showIframe 2: ',showIframe);

            // Construct the URL
            var url = '/apex/ERP7__PrintUPSLabel?shipmentsId=' + shipmentsId + '&fileName=' + fileName + '&val=' + val+ '&showframe=' + showIframe;

            // Open the URL in a new tab
            window.open(url, '_blank');

            console.log('URL opened in new tab');
        } catch (e) {
            console.log(e);
        }
    }
    viewLabels() {
        try {
            console.log('label ');

            var shipmentsId = this.shipment.Id;
            console.log('shipmentsId ');
            var fileName = 'UPS_Label';
            var val = 'pdf';
            console.log('val ');

            // Construct the URL
            var url = '/apex/ERP7__PrintUPSLabel?shipmentsId=' + shipmentsId + '&fileName=' + fileName + '&val=' + val;

            // Open the URL in a new tab
            window.open(url, '_blank');

            console.log('URL opened in new tab');
        } catch (e) {
            console.log(e);
        }
    }
    sendReturnLabels() {
        try {
            console.log('label ');

            var shipmentsId = this.returnShipment.Id;
            console.log('shipmentsId ');
            var fileName = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? 'Fedex_Label' : 'UPS_Label';
            var val = 'pdf';
            var shiptype = 'return';
            var contactId = '';
            var fromAddress = this.fromAddress.ERP7__Country__c;
            var toAddress = this.toAddress.ERP7__Country__c;

            if (this.toContact && this.toContact.Id != undefined && this.toContact.Id != null && this.toContact.Id != '') {
                contactId = this.toContact.Id;
            }
            console.log('contactId :  ', contactId);
            var showIframe = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? true : false;
            console.log('showIframe 1: ',showIframe);
            if(fileName == 'Fedex_Label') {
                if(fromAddress != toAddress) showIframe = true;
                else showIframe = false;
            }
            console.log('showIframe 2: ',showIframe);
            // Construct the URL
            var url = '/apex/ERP7__PrintUPSLabel?shipmentsId=' + shipmentsId + '&fileName=' + fileName + '&contactId=' + contactId + '&shiptype=' + shiptype+'&showframe=' + showIframe;

            // Open the URL in a new tab
            window.open(url, '_blank');

            console.log('URL opened in new tab');
        } catch (e) {
            console.log(e);
        }
    }
    viewcommercialLabels() {
        var shipmentsId =  this.shipment.Id;
        console.log('viewcommercialLabels shipmentsId---->'+shipmentsId);
        var url = '/apex/ERP7__UPSCommercialInvoice?shipmentsId=' + shipmentsId;
        console.log('url    ----    '+url);
        // Open the URL in a new tab
        window.open(url, '_blank');
    }
    cancelShipment() {
        this.isLoading = true;
        voidShipment({ packList: this.packageList, myConsVar: JSON.stringify(this.Credentials), Shipment: JSON.stringify(this.shipment) }).then(result => {
            if (result) {
                console.log('res : ', result);
                if (result.error != null && result.error != '' && result.error != undefined) {
                    this.errorList = Object.assign([], this.errorList);
                    this.errorList.push(result.error);
                    let responseObject = JSON.parse(result.response);
                    if (responseObject && responseObject.response && responseObject.response.errors && responseObject.response.errors.length > 0) {
                        let errorMessage = responseObject.response.errors[0].message;
                        this.errorList.push(errorMessage);
                    }
                    this.isLoading = false;
                }
                else {
                    if (result.shipment && Object.keys(result.shipment).length > 0) {
                        this.shipment = result.shipment;
                    }
                    this.showLabel = false;
                    this.ShowCancelShipment = false;
                    this.ShowInitiateShipment = false;
                    this.ShowGetRate = true;
                    this.rateResponse = null;
                    this.sucessMsg = 'Shipment Deleted succesfully!';
                    this.isLoading = false;
                }

            }
        })
            .catch(error => {
                console.log('Error:', error);

                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
                this.isLoading = false;
            });
    }
    handleStatusChange(event) {
        this.shipment.ERP7__Status__c = event.currentTarget.value;
    }
    trackingShipment() {
        this.sucessMsg = '';
        this.isLoading = true;
        trackShipment({ packList: this.packageList, myConsVar: JSON.stringify(this.Credentials), Shipment: JSON.stringify(this.shipment) }).then(result => {
            if (result) {
                console.log('res : ', result);
                if (result.error != null && result.error != '' && result.error != undefined) {
                    this.errorList = Object.assign([], this.errorList);
                    this.errorList.push(result.error);
                    let responseObject = JSON.parse(result.response);
                    if (responseObject && responseObject.response && responseObject.response.errors && responseObject.response.errors.length > 0) {
                        let errorMessage = responseObject.response.errors[0].message;
                        this.errorList.push(errorMessage);
                    }
                    this.isLoading = false;
                }
                else {
                    this.shipment = result.shipment;
                    this.shipmentFlows = result.Shipmentflows;
                    this.showLabel = true;
                    if (this.shipment.ERP7__Status__c != 'Cancelled' && !this.isReturnShipment) this.ShowCancelShipment = true;
                    this.ShowInitiateShipment = false;
                    this.ShowGetRate = false;
                    this.rateResponse = null;
                    this.isLoading = false;
                    // this.sucessMsg = 'Shipment Deleted succesfully!';
                }
            }
        })
            .catch(error => {
                this.isLoading = false;
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    handleqvNotification(event) {
        this.shipment.ERP7__QV_Notification__c = event.target.value;
        console.log('QV : ', this.shipment.ERP7__QV_Notification__c);
    }
    handleCarbonNeutral(event) {
        this.shipment.ERP7__Carbon_Neutral__c = event.target.value;
        console.log('CN : ', this.shipment.ERP7__Carbon_Neutral__c);
    }
    handleCOD(event) {
        this.shipment.ERP7__COD__c = event.target.value;
        console.log('COD : ', this.shipment.ERP7__COD__c);
    }
    handleDryIce(event) {
        this.shipment.ERP7__Dry_Ice__c = event.target.value;
        console.log('ice : ', this.shipment.ERP7__Dry_Ice__c);
    }
    handleReturnService(event) {
        this.shipment.ERP7__Return_Service__c = event.target.value;
        console.log('return service : ', this.shipment.ERP7__Return_Service__c);
    }
    handleAdditionalHandling(event) {
        this.shipment.ERP7__Additional_Handling__c = event.target.value;
        console.log('additional : ', this.shipment.ERP7__Additional_Handling__c);
    }
    handleVerbalConfirmation(event) {
        this.shipment.ERP7__Verbal_Confirmation__c = event.target.value;
        console.log('verbal  : ', this.shipment.ERP7__Verbal_Confirmation__c);
    }
    generateReturnShipment() {
        this.isLoading = true;
        this.ReturnShipTypeUPS = true;
        this.sucessMsg = '';
        this.isReturnShipment = true;

        if (this.packageList.length > 0) {
            if (this.packageList[0].ERP7__Logistic__c) {
                if (this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c) {
                    this.returnShipment.ERP7__Billing_Account_Number__c = this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c;
                }
                if (this.packageList[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c) this.returnShipment.ERP7__Shipment_Billing_options__c = this.packageList[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c;
                if (this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c) {
                    this.returnShipment.ERP7__Billing_Contact__c = this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c;
                    this.returnShipment.ERP7__Billing_Contact__r = { Id: this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c, Name: this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__r.Name };
                }
                if (this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c) {
                    this.returnShipment.ERP7__Billing_Address__c = this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c;
                    this.returnShipment.ERP7__Billing_Address__r = { Id: this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c, Name: this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.Name };
                }

            }
        }
        this.returnShipment.ERP7__Shipment_Date__c = this.returnShipmentDate;
        this.returnShipment.ERP7__Description__c = (this.shipment.ERP7__Description__c ? this.shipment.ERP7__Description__c : 'DESCRIPTION');
        this.Shipping_Rate();
    //this.isLoading = false;

    }
    backToOldShipment() {
        this.isReturnShipment = false;
        this.connectedCallback();
        this.rateResponse = null;
        this.RateMsg = [];
        this.sucessMsg = '';
    }

    handlePickupRate() {
        console.log('Inside handlePickupRate: ');
        this.errorMsg = '';
        //this.UPS_Services.UPSErrorMsg = '';

        const fromAddress = this.fromAddress.Id;
        const toAddress = this.toAddress.Id;
        const myConsVariable = JSON.stringify(this.Credentials);
        let errorFlag = true;
        let errorMsg = '';
        console.log('this.shipment.ERP7__Package_Ready_Time__c: ', this.shipment.ERP7__Package_Ready_Time__c);
        console.log('this.shipment.ERP7__Customer_Close_Time__c: ', this.shipment.ERP7__Customer_Close_Time__c);
        if (this.shipment.ERP7__Pickup_Requested__c) {
            errorFlag = false;
            errorMsg = 'Shipment Pickup Is Already Active For This Package.';
        }

        if (this.shipment.ERP7__Status__c === 'Delivered') {
            errorFlag = false;
            errorMsg += ' Shipment Delivered : Request Cannot Be Processed.';
        }

        if (this.shipment.ERP7__Status__c !== 'Shipped') {
            errorFlag = false;
            errorMsg += ' Shipment Status Must Be shipped To Process, Pickup Rate Request.';
        }

        if (!this.shipment.ERP7__Package_Ready_Time__c) {
            errorFlag = false;
            errorMsg += ' Pickup Ready Time Unavailable.';
        }

        if (!this.shipment.ERP7__Customer_Close_Time__c) {
            errorFlag = false;
            errorMsg += ' Pickup Close Time Unavailable.';
        }

        if (this.shipment.ERP7__Customer_Close_Time__c !== this.shipment.ERP7__Package_Ready_Time__c) {
            errorFlag = false;
            errorMsg += ' Pickup Ready Time And Pickup Close Time Must Be Same.';
        }

        if (errorMsg) {
            this.errorMsg = errorMsg;
            console.log('Error: ', errorMsg);
            //this.showToast('Error', errorMsg, 'error');
        }

        if (errorFlag) {
            console.log('Inside errorFlag: ');
            console.log('Inside errorFlag: ');
            PickupRateRequest({
                fromAdd: fromAddress,
                toAdd: toAddress,
                Shipment: JSON.stringify(this.shipment),
                dispatchDate: this.shipment.ERP7__Shipment_Date__c,
                PackageReadyTime: this.shipment.ERP7__Package_Ready_Time__c,
                CustomerCloseTime: this.shipment.ERP7__Customer_Close_Time__c,
                myConsVar: myConsVariable
            })
                .then(result => {
                    console.log('Inside success: ');
                    this.UPS_Services = result;
                    this.errorMsg = result.Error;
                    this.ShowGetRate = false;
                })
                .catch(error => {
                    console.log('Inside error: ', error);
                    this.errorMsg = error.body.message;
                    console.log('Error: ', errorMsg);
                    //this.showToast('Error', this.errorMsg, 'error');
                });
        }
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
        this.combineDateTime();
    }

    handleTimeChange(event) {
        this.selectedTime = event.target.value;
        this.combineDateTime();
    }

    combineDateTime() {
        if (this.selectedDate && this.selectedTime) {
            const formattedTime = this.selectedTime.substr(0, 5) + ':00.000Z';
            const combinedDateTime = `${this.selectedDate}T${formattedTime}`;
            this.shipment.ERP7__Package_Ready_Time__c = combinedDateTime;
            this.shipment.ERP7__Customer_Close_Time__c = combinedDateTime;
            console.log('this.shipment.ERP7__Package_Ready_Time__c: ', this.shipment.ERP7__Package_Ready_Time__c);
            console.log('this.shipment.ERP7__Customer_Close_Time__c: ', this.shipment.ERP7__Customer_Close_Time__c);
        }
    }
    generateFedexReturnShipment() {
        try {


            this.isLoading = true;
            var today = new Date();
            this.returnShipmentDate = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
            console.log('returnShipmentDate : ', this.returnShipmentDate);
            getInitialDataFedex({ ShipId: this.shipmentIds, packIds: JSON.stringify(this.packageIds), ReturnShip: true})
            .then(result => {
                console.log('getInitialData res : ', result);
                if (result) {
                    if (result.alertlist && result.alertlist.length > 0) {
                        this.errorList = Object.assign([], this.errorList);
                        this.errorList = result.alertlist;
                        this.isLoading = false;
                    }
                    else {
                       // this.defaulWrapUPS = result;
                        this.FedexmyConsW = result.credsWrap;
                        //this.showReturnModal = true;
                        this.getFedexRates();
                       // this.isLoading = false;
                    }
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
            /* getFedexmyConstructor({ shipId: this.shipment.Id, retValue: '' })
                .then(result => {
                    console.log('Inside success: ');
                    var obj = result;
                    console.log('getFedexmyConstructor obj~>', obj);
                    if (obj != null) {
                        var wrError = result.wrapError;
                        if (wrError != null && wrError != '' && wrError != undefined) this.errorList.push(wrError);
                        this.FedexmyConsW = obj;
                        this.fedexServices = obj.uWrap;
                        var FedexmyConsVariable = JSON.stringify(this.FedexmyConsW);
                        console.log('FedexmyConsVariable~>', FedexmyConsVariable);
                        this.showReturnModal = true;
                        this.getFedexRates();

                    }

                })
                .catch(error => {
                    console.log('Inside error: ', error);
                    this.errorList.push(error.body.message);
                    console.log('Error: ', errorMsg);
                    this.isLoading = false;
                    //this.showToast('Error', this.errorMsg, 'error');
                });*/
        } catch (error) {
            console.log('Inside error: ', error);
            this.isLoading = false;
        }

    }
    getFedexRates() {
        this.isLoading = true;
        if (this.packageList.length > 0) {
            if (this.packageList[0].ERP7__Logistic__c) {
                if (this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c) {
                    this.returnShipment.ERP7__Billing_Account_Number__c = this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c;
                }
                if (this.packageList[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c) this.returnShipment.ERP7__Shipment_Billing_options__c = this.packageList[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c;
                if (this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c) {
                    this.returnShipment.ERP7__Billing_Contact__c = this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c;
                    this.returnShipment.ERP7__Billing_Contact__r = { Id: this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c, Name: this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__r.Name };
                }
                if (this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c) {
                    this.returnShipment.ERP7__Billing_Address__c = this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c;
                    this.returnShipment.ERP7__Billing_Address__r = { Id: this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c, Name: this.packageList[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.Name };
                }

            }
        }
        this.returnShipment.ERP7__Shipment_Date__c = this.returnShipmentDate;
        this.returnShipment.ERP7__Description__c = (this.shipment.ERP7__Description__c ? this.shipment.ERP7__Description__c : 'DESCRIPTION');
       
        getRatesFedex({ PackageItems: this.packageList, consVar: JSON.stringify(this.FedexmyConsW), fromAddress: JSON.stringify(this.toAddress), ToAddress: JSON.stringify(this.fromAddress), shipDate:  this.returnShipmentDate, shipmentDetails: JSON.stringify(this.returnShipment), isReturnShipment:true })
        .then(result => {
            if (result) {
                console.log('getRates result : ', result);
                if (result) {                // Parse the JSON response
                    if (result.errMsgs != undefined) {
                        this.errorList = Object.assign([], this.errorList);
                        this.errorList = result.errMsgs;
                    }

                    var jsonResponse = result.response;/* Your JSON response */;
                    if (jsonResponse != undefined) {
                        var response = JSON.parse(jsonResponse);

                        // Extract alerts

                        if (!this.RateMsg || typeof this.RateMsg !== 'object' || !Array.isArray(this.RateMsg)) {
                            this.RateMsg = [];
                        }
                        if (response.output && response.output.alerts) {
                            var alerts = response.output.alerts;
                            alerts.forEach((alert) => {
                                console.log("Alert: " + alert.message + " (Type: " + alert.alertType + ")");
                                this.RateMsg.push(alert.alertType + ':' + alert.message);
                            });
                        }
                        // Extract rate details
                        var rateDetails = response.output.rateReplyDetails;
                        var rateSample = [];
                        var rateindex = 1;
                        if (rateDetails != undefined && rateDetails != null && rateDetails.length > 0) {
                            rateDetails.forEach(function (detail) {
                                var singleRatevalues = {};
                                singleRatevalues.index = rateindex;
                                // Extract serviceType
                                if (detail.serviceType) {
                                    singleRatevalues.serviceType = detail.serviceType;
                                    console.log("Service Type: " + singleRatevalues.serviceType);

                                }

                                // Extract totalSurcharges and totalNetCharge
                                if (detail.ratedShipmentDetails && detail.ratedShipmentDetails.length > 0) {
                                    var shipmentRateDetail = detail.ratedShipmentDetails[0].shipmentRateDetail;
                                    if (shipmentRateDetail) {
                                        singleRatevalues.totalSurcharges = shipmentRateDetail.totalSurcharges;
                                        singleRatevalues.totalNetCharge = detail.ratedShipmentDetails[0].totalNetCharge;
                                        singleRatevalues.netChargeCurrency = detail.ratedShipmentDetails[0].currency;

                                        console.log("Total Surcharges: " + singleRatevalues.totalSurcharges);
                                        console.log("Total Net Charge: " + singleRatevalues.totalNetCharge);
                                    }
                                }

                                rateSample.push(singleRatevalues);
                                rateindex++;
                            });
                        } else {
                            this.RateMsg.push('No services available');
                        }

                        if (rateSample.length > 0) {
                           
                                var returRates = [];
                                for (var x in rateSample) {
                                    returRates.push({ index: rateSample[x].index, code: x, service: rateSample[x].serviceType, totalCharges: rateSample[x].totalNetCharge, currencycode: rateSample[x].netChargeCurrency });
                                }
                                this.rateResponseReturn = returRates;
                                this.showReturnModal = true;
                            console.log('showReturnModal : ',this.showReturnModal);
                            
                        }
                        //this.isLoading = false;
                    }
                    this.isLoading = false;

                }

            }
        })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (error.body) {
                    this.errorList.push(error.body.message);
                }
                this.isLoading = false;
            });
          
      /*  getFedexServicesWrapperList({ packList: this.packageList, fromAdd: this.toAddress.Id, tAddress: this.fromAddress.Id, shipDate: this.returnShipmentDate, myConsVar: JSON.stringify(this.FedexmyConsW), isReturnShipment: true })
            .then(result => {
                console.log('Inside success 2: ', result);
                var obj = result;
                if (obj.Services) {
                    this.fedexServices.Services = obj.Services;
                }
                var rateWrapperList = this.fedexServices.Services;
                if (rateWrapperList) {
                    var subString = 'GROUND';
                    for (var x in rateWrapperList) {
                        if (rateWrapperList[x].Service != undefined && rateWrapperList[x].Service != null && rateWrapperList[x].Service != '') {
                            if (rateWrapperList[x].Service.toLowerCase().includes(subString.toLowerCase())) {
                                console.log('Fedex Ground exists');
                                rateWrapperList[x].Selected = true;
                                break;
                            }
                        }
                    }
                    this.fedexServices.Services = rateWrapperList;
                    if (obj.Error) this.errorList.push(obj.Error);
                    this.isLoading = false;
                }
            }).catch(error => {
                console.log('Inside error: ', error);
                this.errorList.push(error.body.message);
                console.log('Error: ', errorMsg);
                this.isLoading = false;
            });*/
    }
    handleServiceTypeChangeReturn(event) {
        this.selectedServiceTypeReturn = event.target.value;
        console.log('Selected Service Type:', this.selectedServiceTypeReturn);
        var servicecode = event.target.label;
        console.log('Selected servicecode :', servicecode);
        this.selectedServiceCodeReturn = servicecode;
        var index = event.target.dataset.index;
        console.log('Selected index :', index);
        if (this.rateResponseReturn[index].currencycode) this.selectedCurrencyReturn = this.rateResponseReturn[index].currencycode;
        console.log('Selected Currency :', this.selectedCurrencyReturn);

    }
    handleCloseModal() {
        this.showReturnModal = false;
        this.ReturnShipTypeUPS = false;
    }
    handleBillingOptionsChange(event) {
        this.returnShipment.erp7__Shipment_Billing_options__c = event.detail.value;
    }
    handleShipmentDateChange(event) {
        this.returnShipmentDate = event.detail.value;
    }
		handleDescription(event){
        this.shipment.ERP7__Description__c=event.detail.value;
        console.log('this.shipment.Description__c: ',this.shipment.ERP7__Description__c);
    }

    handleGenerateReturnShipment() {
        try {

            this.isLoading = true;
            this.errorList = [];
            var today = new Date();
            var monthDigit = today.getMonth() + 1;
            if (monthDigit <= 9) {
                monthDigit = '0' + monthDigit;
            }
            var dayDigit = today.getDate();
            if (dayDigit <= 9) {
                dayDigit = '0' + dayDigit;
            }
            var todayDate = today.getFullYear() + '-' + monthDigit + '-' + dayDigit;
           
            var errorFlag = true;
            if (this.returnshipmentdate < todayDate) {
                errorFlag = false;
                this.errorList.push('The Shipment Date Should Not Be In Past');
            }
            if (this.selectedServiceTypeReturn == '' || this.selectedServiceTypeReturn == null) {
                errorFlag = false;
                this.errorList.push('Please Select At Least One Service');
            }
           
            if (errorFlag) {
                var masterShipmentId = '';
                console.log('returnShipmentDate : ', this.returnShipmentDate);
                if (this.shipment && this.shipment.Id) masterShipmentId = this.shipment.Id;
                this.returnShipment.ERP7__Shipment_Date__c = this.returnShipmentDate;
                shippingRequestResponseFedex({ packList: this.packageList, fromAddress: JSON.stringify(this.toAddress), ToAddress: JSON.stringify(this.fromAddress), fromContact: JSON.stringify(this.toContact), toContact: JSON.stringify(this.fromContact), ShipDateStamp: this.returnShipmentDate, myConsVar: JSON.stringify(this.FedexmyConsW), Shipment: JSON.stringify(this.returnShipment), rateService: this.selectedServiceTypeReturn, rateCurrency: this.selectedCurrencyReturn, isReturnShipment: true, packageItems: this.packageItems, masterShipmentId: masterShipmentId })
                    .then(result => {
                        var obj = result;
                        console.log('Fedex ship : ',result);
                        if (result.errMsgs && result.errMsgs.length > 0) {
                            this.errorList = Object.assign([], this.errorList);
                            this.errorList = result.errMsgs;
                            this.isLoading = false;
                        }
                        else {
                            this.returnShipment = result.ShipDetails;
                            this.showReturnModal = false;
                            this.showReturnLabel = true;
                            const event = new ShowToastEvent({
                                title: 'Success',
                                message: 'Shipment created succesfully!',
                                variant: 'success'
                            });
                            this.dispatchEvent(event);
                            this.isLoading = false;
                            console.log('show shipment : ',this.shipment);
                            console.log('show shipment : ',this.returnShipment);
                        }
                    })
                    .catch(error => {
                        console.log('Inside error: ', error);
                        this.errorList.push(error.body.message);
                        console.log('Error: ', errorMsg);
                        this.isLoading = false;
                    });
            }
            else {
                this.isLoading = false;
            }

        } catch (error) {
            console.log('Inside error: ', error);
            this.isLoading = false;
        }
    }
    handleGenerateReturnShipmentUPS(){
        if (this.selectedServiceTypeReturn) {
            this.isReturnShipment = true;
            this.Shipping_Request();
        } else {
            const event = new ShowToastEvent({
                title: 'warning',
                message: 'Please select shipment service to proceed!',
                variant: 'warning'
            });
            this.dispatchEvent(event);
        }
    }

}