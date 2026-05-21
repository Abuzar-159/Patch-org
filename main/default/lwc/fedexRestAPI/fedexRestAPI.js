import { api, track, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import validateAddress from "@salesforce/label/c.Validate_Address";
import shipmentGoing from "@salesforce/label/c.X1_Where_is_this_shipment_going";
import CompanyLabel from "@salesforce/label/c.CompanyLabel";
import ContactLabel from "@salesforce/label/c.ContractConsole_Contact";
import PhoneLabel from "@salesforce/label/c.Phone_AddTimeCardEntry";

//calling apex methodf
import { refreshApex } from '@salesforce/apex';
import getInitialData from '@salesforce/apex/FedexLWCRestAPI.getDefaultData';
import fetchToAddress from '@salesforce/apex/Fedex.fetchToAddress';
import fetchFromAddress from '@salesforce/apex/Fedex.fetchFromAddress';
import fetchingPackages from '@salesforce/apex/Fedex.fetchingPackages';
import fetchingPackageLists from '@salesforce/apex/Fedex.fetchingPackageLists';

import getInitialDataUPS from '@salesforce/apex/UPSRestAPI.getDefaultData';
import getRatesUPS from '@salesforce/apex/UPSRestAPI.Service_And_Rate_Request';
import Shipping_Request_ResponseUPS from '@salesforce/apex/UPSRestAPI.Shipping_Request_Response';

import getStatusConfirmation from '@salesforce/apex/Fedex.getStatusConfirmation';
import getShipmentTerms from '@salesforce/apex/Fedex.getTermsOfShipment';
import getReasonForExport from '@salesforce/apex/Fedex.getReasonForExport';
import getSignatureServices from '@salesforce/apex/Fedex.getSignatureServices';
import getBillingOptions from '@salesforce/apex/Fedex.getBillingOptions';
import ValidateAddressfromServer from '@salesforce/apex/FedexLWCRestAPI.ValidateAddress';
import getRates from '@salesforce/apex/FedexLWCRestAPI.getRates';
import getSpecialServices from '@salesforce/apex/FedexLWCRestAPI.getSpecialServices';
import getLabelOptions from '@salesforce/apex/FedexLWCRestAPI.getLabelOptions';
import shippingRequestResponse from '@salesforce/apex/FedexLWCRestAPI.shippingRequestResponse';
import TrackShipment from '@salesforce/apex/FedexLWCRestAPI.TrackShipment';
import cancelShipment from '@salesforce/apex/FedexLWCRestAPI.cancelShipment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



//Load scripts
import { loadStyle } from 'lightning/platformResourceLoader';
import CMP_CSS from '@salesforce/resourceUrl/CMP_CSS';
import PickPackShipResource from '@salesforce/resourceUrl/PickPackShipResource';
import SLDS from '@salesforce/resourceUrl/SLDS';
import UpsRest from 'c/uPSRest';


export default class FedexRestAPI extends NavigationMixin(LightningElement) {
    @track isLoading = false;
    @track toCompany = '';
    @track selectedServiceType = '';
    @track selectedCurrency = '';
    @track ShowInitiateShipment = false;
    @track specialServices = [];
    @track ShipmentStatus = [];
    @track LabelOptions = [];
    @api logisticIds = '';
    @track packageItems = [];
    @track Credentials;
    errorList = [];
    @track RateMsg = [];
    @api packageIds = []; //a0L0600000SwaYZEAZ // a0L0600000Sui9GEAR
    @api shipmentIds = '';
    @api shipId = '';
    @track fromAddress = { 'Id': '', Name: '', ERP7__Address_Line1__c: '', ERP7__Address_Line2__c: '', ERP7__City__c: '', ERP7__State__c: '', ERP7__Postal_Code__c: '', ERP7__Country__c: '', ERP7__Contact__c: '', ERP7__Contact__r: { Id: '', Name: '', ERP7__Company__c: '' } };
    @track suggestedAddress = { 'Id': '', Name: '', ERP7__Address_Line1__c: '', ERP7__Address_Line2__c: '', ERP7__City__c: '', ERP7__State__c: '', ERP7__Postal_Code__c: '', ERP7__Country__c: '', ERP7__Contact__c: '', ERP7__Contact__r: { Id: '', Name: '', ERP7__Company__c: '' } };

    @track toAddress = { 'Id': '', Name: '', ERP7__Address_Line1__c: '', ERP7__Address_Line2__c: '', ERP7__City__c: '', ERP7__State__c: '', ERP7__Postal_Code__c: '', ERP7__Country__c: '' };
    @track showFromAddress = false;
    @track showToAddress = true;
    @track ShowAddressbutton = false;
    @track toAddressSelected = false;
    @track toAddressUrl = '';
    @track toEmail = '';
    @track toPhone = '';
    @api isforRMA;
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
    @track packageList;
    @track TermsOfShipment = [];
    @track reasonforexportOptions = [];
    @track signatureserviceOptions = [];
    @track billingOptions = [];
    @track showTabTwo = false;
    @track showTabOne = true;
    @track shipment = { Id: null, Name: '', ERP7__Status__c: '', ERP7__TrackingNumber__c: '', ERP7__Label_options__c: 'LABEL', ERP7__Label_format__c : '', ERP7__Invoice_Number__c: '', ERP7__Purchase_Order_Number__c: '', ERP7__Terms_Of_Shipment__c: '', ERP7__Reason_For_Export__c: 'SAMPLE', ERP7__Declaration_Statement__c: '', ERP7__Shipment_Date__c: '', ERP7__Description__c: '', ERP7__Signature_Services__c: '', ERP7__Shipment_Billing_options__c: 'SENDER', ERP7__Fedex_Special_Services__c: '', ERP7__Billing_Account_Number__c: '', ERP7__Billing_Contact__c: '', ERP7__Billing_Contact__r: { Id: '', Name: '' }, ERP7__Billing_Address__c: '', ERP7__Billing_Address__r: { Id: '', Name: '' } };
    @track masterShipmentId = '';
    @track shipmentFlows;
    label = {
        validateAddress,
        shipmentGoing,
        CompanyLabel,
        ContactLabel,
        PhoneLabel
    };
    @track showAddressValidationPopUp = false;
    @track ShowGetRate = true;
    @track rateResponse;
    @track ShowLabels = false;
    @track ShowCancelShipment = false;
    @track sucessMsg = '';
    @track fromContact = { Id: '', Name: '', ERP7__Company__c: '', Email: '', Phone: '', AccountId: '', Account: { Id: '', Name: '', Phone: '', ERP7__Email__c: '' } };
    @track toContact = { Id: '', Name: '', ERP7__Company__c: '', Email: '', Phone: '', AccountId: '', Account: { Id: '', Name: '', Phone: '', ERP7__Email__c: '' } };
    @track defaulWrap = {};
    @track allowUPSReturnShipmentFromFedex = false;
    @track selectedLogisticReturnShipType = false;
    @track allowReturnShipment = false;
    @track showUPSReturnType = false;
    @track showFedexReturnType = false;
    @track returnShipment = { Id: null, Name: '', Shipment_Identification_Number__c: '', ERP7__Status__c: '', ERP7__TrackingNumber__c: '', ERP7__Label_options__c: 'LABEL', ERP7__Invoice_Number__c: '', ERP7__Purchase_Order_Number__c: '', ERP7__Terms_Of_Shipment__c: '', ERP7__Reason_For_Export__c: 'SAMPLE', ERP7__Declaration_Statement__c: '', ERP7__Shipment_Date__c: '', ERP7__Description__c: '', ERP7__Signature_Services__c: '', ERP7__Shipment_Billing_options__c: 'SENDER', ERP7__Fedex_Special_Services__c: '', ERP7__Billing_Account_Number__c: '', ERP7__Billing_Contact__c: '', ERP7__Billing_Contact__r: { Id: '', Name: '' }, ERP7__Billing_Address__c: '', ERP7__Billing_Address__r: { Id: '', Name: '' } };
    @track logoUrl = '';
    @track isReturnShipment = false;
    @track defaulWrapUPS = {};
    @track CredentialsUPS = {};
    @track showReturnModal = false;
    @track returnShipmentDate = '';
    @track disableEditBillOptReturnShipment = false;
    @track selectedServiceTypeReturn = '';
    @track selectedServiceCodeReturn = '';
    @track selectedCurrencyReturn = '';
    @track rateResponseReturn;
    @track ReturnShipTypeUPS = false;

    validateAddressCall() {
        console.log('validateAddressCall called');
        this.showAddressValidationPopUp = true;
        console.log('showAddressValidationPopUp : ', this.showAddressValidationPopUp);
    }
    closeAddressModel() {
        this.showAddressValidationPopUp = false;
    }
    showFromAddresses() {
        console.log('showFromAddresses called');
        this.showFromAddress = true;
        this.showToAddress = false;
        this.showSuggestedAddress = false;
    }
    showToAddresses() {
        this.showFromAddress = false;
        this.showToAddress = true;
        this.showSuggestedAddress = false;
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
    connectedCallback() {
        try {
            this.isLoading = true;
            console.log('this.shipmentIds : ', this.shipmentIds);
            
            getInitialData({ ShipId: this.shipmentIds, packIds: JSON.stringify(this.packageIds) })
                .then(result => {
                    console.log('getInitialData res : ',result);
                    if (result) {
                        if (result.alertlist && result.alertlist.length > 0) {
                            this.errorList = Object.assign([], this.errorList);
                            this.errorList = result.alertlist;
                            this.ShowGetRate = false;
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

                            if (result.toAddress && Object.keys(result.toAddress).length !== 0) this.toAddress = result.toAddress;
                            else this.errorList.push('To Address is missing on your logistics.');

                            if (result.fromAddress && Object.keys(result.fromAddress).length !== 0) this.fromAddress = result.fromAddress;
                            else this.errorList.push('From Address is missing on your logistics.');

                            if (this.fromAddress.Id) {
                                this.FromAddressSelected = true;
                                this.fromAddressUrl = '/' + this.fromAddress.Id;
                            }

                            if (this.toAddress.Id) {
                                this.toAddressSelected = true;
                                this.toAddressUrl = '/' + this.toAddress.Id;
                            }
                            console.log('result.fromContact : ', JSON.stringify(result.fromContact));
                            if (result.fromContact && Object.keys(result.fromContact).length !== 0) this.fromContact = result.fromContact;
                            else this.errorList.push('From contact is missing on your logistics.');
                            if (result.toContact && Object.keys(result.toContact).length !== 0) this.toContact = result.toContact;
                            else this.errorList.push('To contact is missing on your logistics.');
                            for (var x in result.packList) {
                                result.packList[x].packUrl = '/' + result.packList[x].Id;
                            }
                            this.allowReturnShipment = result.allowReturnShipment;
                            this.allowUPSReturnShipmentFromFedex = result.allowUPSReturnShipmentFromFedex;
                            this.disableEditBillOptReturnShipment = result.disableEditBillOptReturnShipment;
                       
                            if(result.packList && result.packList.length > 0){
                                console.log("entered result packlist:",JSON.stringify(result.packList));
                                if (result.packList[0].ERP7__Logistic__r != null) {if (result.packList[0].ERP7__Logistic__r.ERP7__Billing_options__c) this.shipment.ERP7__Shipment_Billing_options__c = result.packList[0].ERP7__Logistic__r.ERP7__Billing_options__c;}
                                else this.shipment.ERP7__Shipment_Billing_options__c = 'SENDER';
                                this.shipment.ERP7__Billing_Contact__c =  result.packList[0].ERP7__Logistic__r != null ? result.packList[0].ERP7__Logistic__r.ERP7__Billing_Contact__c : result.packList[0].ERP7__Logistic__r.ERP7__Billing_Contact__c ='';
                                if(result.packList[0].ERP7__Logistic__r != null && result.packList[0].ERP7__Logistic__r.ERP7__Account__c != null &&  result.packList[0].ERP7__Logistic__r.ERP7__Account__r) this.toCompany = result.packList[0].ERP7__Logistic__r.ERP7__Account__r.Name;
                                if (result.packList[0].ERP7__Logistic__r != null && result.packList[0].ERP7__Logistic__r.ERP7__Billing_Contact__c) {
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
                                        if (this.allowUPSReturnShipmentFromFedex) this.showFedexReturnType = true;
                                    }
                                }
                                if (this.allowReturnShipment && this.selectedLogisticReturnShipType == '') {
                                    if (this.allowUPSReturnShipmentFromFedex) this.showUPSReturnType = true;
                                    this.showFedexReturnType = true;

                                }
                    }
                        
                            console.log('this.showUPSReturn : ', this.showUPSReturnType);
                            // console.log('10');
                            this.packageList = result.packList;
                            console.log('packageList==>'+JSON.stringify(this.packageList));
                            this.packageItems = result.packItems;
                            //console.log('11');
                            var today = new Date();
                            if (!this.shipmentIds) this.shipment.ERP7__Shipment_Date__c = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
                            if (this.shipmentIds) {
                                this.ShowLabels = true;
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
            this.upsRest = new UpsRest();
        } catch (error) {
            console.log('Error: getInitialData==>', error);
        }

    }
    checkAddress() {
        var addressTocheck = (this.showToAddress) ? JSON.stringify(this.toAddress) : JSON.stringify(this.fromAddress);
        ValidateAddressfromServer({ address: addressTocheck, creds: JSON.stringify(this.Credentials) }).then(result => {
            if (result) {
                console.log('ValidateAddressfromServer result: ', result);
                var addWrap = result;
                if (addWrap.errMsg) {
                    this.errorList = Object.assign([], this.errorList);
                    this.errorList.push(addWrap.errMsg);
                }
                else {
                    this.suggestedAddress = addWrap.address;
                    this.showSuggestedAddress = true;
                }
            }
        }).catch(error => {
            console.log('Error:', error);
            this.errorList = Object.assign([], this.errorList);
            if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
            if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
        });
    }
    getToaddress() {
        fetchToAddress({ packId: JSON.stringify(this.packageIds) })
            .then(result => {
                if (result) {
                    console.log('result fetchToAddress: ', result);
                    this.toAddress = result;
                    this.toAddress.Id = result.Id;
                    this.toAddress.Name = result.Name;
                    this.toAddressUrl = '/' + this.toAddress.Id;
                    if (result.ERP7__Contact__c && result.ERP7__Contact__r.ERP7__Company__c) this.isCompanyAvailable = true;
                    if (result.ERP7__Contact__c && result.ERP7__Contact__r.Name) this.isShiptoContactAvailable = true;
                    this.toEmail = (result.ERP7__Contact__c && result.ERP7__Contact__r.Email) ? result.ERP7__Contact__r.Email : result.ERP7__Customer__r.ERP7__Email__c;
                    this.toPhone = (result.ERP7__Contact__c && result.ERP7__Contact__r.Phone) ? result.ERP7__Contact__r.Phone : result.ERP7__Customer__r.Phone;
                    this.toAddressSelected = true;
                }
            })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            })
    }
    getFromAddress() {
        fetchFromAddress({ packId: JSON.stringify(this.packageIds) })
            .then(result => {
                if (result) {
                    console.log('result fetchFromoAddress: ', result);
                    this.fromAddress = result;
                    this.fromAddress.Id = result.Id;
                    this.fromAddress.Name = result.Name;
                    this.fromAddressUrl = '/' + this.fromAddress.Id;
                    if (result.ERP7__Contact__c && result.ERP7__Contact__r.ERP7__Company__c) this.isCompanyAvailable = true;
                    if (result.ERP7__Contact__c && result.ERP7__Contact__r.Name) this.isShiptoContactAvailable = true;
                    this.FromEmail = (result.ERP7__Contact__c && result.ERP7__Contact__r.Email) ? result.ERP7__Contact__r.Email : result.ERP7__Customer__r.ERP7__Email__c;
                    this.fromPhone = (result.ERP7__Contact__c && result.ERP7__Contact__r.Phone) ? result.ERP7__Contact__r.Phone : result.ERP7__Customer__r.Phone;
                    this.FromAddressSelected = true;
                }
            })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            })
    }
    getPackageDetails() {
        fetchingPackages({ packId: JSON.stringify(this.packageIds) })
            .then(result => {
                if (result) {
                    console.log('result fetchingPackages: ', result);
                    for (var x in result) {
                        result[x].packUrl = '/' + result[x].Id;
                    }
                    this.packageList = result;
                }
            })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            })
    }
    getPackageItemsDetails() {
        fetchingPackageLists({ packId: JSON.stringify(this.packageIds) })
            .then(result => {
                if (result) {
                    console.log('result fetchingPackageLists: ', result);
                    for (var x in result) {
                        result[x].packUrl = result[x].Id;
                    }
                    this.packageItems = result;
                }
            })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            })
    }
    setToShipmentType(event) {
        this.toShipmentType = event.currentTarget.checked;
    }
    setFromShipmentType(event) {
        this.fromShipmentType = event.currentTarget.checked;
    }
    setShipName(event) {
        this.shipment.Name = event.currentTarget.value;
    }
    handleStatusChange(event) {
        this.shipment.ERP7__Status__c = event.currentTarget.value;
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
                    this.logoUrl = PickPackShipResource + '/assets/images/logo-header-fedex-gb.png';
                })
                .catch(error => {
                    console.log('Static Resource Error', error);
                });
        } catch (e) {
            console.log('Error:', e);
        }
    }
    handleTermsofShipment(event) {
        this.shipment.ERP7__Terms_Of_Shipment__c = event.detail.value;
    }
    handleBillAccNum(event) {
        this.shipment.ERP7__Billing_Account_Number__c = event.detail.value;
    }
    getTermsofShipment() {
        getShipmentTerms().then(result => {
            if (result) {
                var options = [];
                for (var x in result) {
                    options.push({ label: result[x], value: result[x] });
                }
                this.TermsOfShipment = options;
            }
        })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    getExportReason() {
        getReasonForExport().then(result => {
            if (result) {
                var options = [];
                for (var x in result) {
                    options.push({ label: result[x], value: result[x] });
                }
                this.reasonforexportOptions = options;
            }
        })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    getStatus() {
        getStatusConfirmation().then(result => {
            if (result) {
                var options = [];
                for (var x in result) {
                    options.push({ label: result[x], value: result[x] });
                }
                this.ShipmentStatus = options;
            }
        })
    }
    getSignature() {
        getSignatureServices().then(result => {
            if (result) {
                var options = [];
                for (var x in result) {
                    options.push({ label: result[x], value: result[x] });
                }
                this.signatureserviceOptions = options;
            }
        })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    getBillOptions() {
        getBillingOptions().then(result => {
            if (result) {
                console.log('getBillingOptions result : ', result);
                var options = [];
                for (var x in result) {
                    options.push({ label: result[x], value: result[x] });
                }
                this.billingOptions = options;
            }
        })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    getSpecialServiceOptions() {
        getSpecialServices().then(result => {
            if (result) {
                console.log('getSpecialServices result : ', result);
                var options = [];
                for (var x in result) {
                    options.push({ label: result[x], value: result[x] });
                }
                this.specialServices = options;
            }
        })
            .catch(error => {
                console.log('Error:', error);
                this.errorList = Object.assign([], this.errorList);
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            });
    }
    getLabels() {
        getLabelOptions().then(result => {
            if (result) {
                console.log('getLabelOptions result : ', result);
                var options = [];
                for (var x in result) {
                    options.push({ label: result[x], value: result[x] });
                }
                this.LabelOptions = options;
            }
        })
    }
    handleShipDate(event) {
        this.shipment.ERP7__Shipment_Date__c = event.detail.value;
    }
    handleDescription(event) {
        this.shipment.ERP7__Description__c = event.detail.value;
    }
    handlebillOptionsChange(event) {
        this.shipment.ERP7__Shipment_Billing_options__c = event.detail.value;
    }
    handleLabelChange(event) {
        this.shipment.ERP7__Label_options__c = event.detail.value;
    }
    handleLabelformatChange(event) {
        this.shipment.ERP7__Label_format__c = event.detail.value;
    }
    handlesignatureService(event) {
        this.shipment.ERP7__Signature_Services__c = event.detail.value;
    }
    Shipping_Rate() {
        this.isLoading = true;
        console.log('PackageItems : ', JSON.stringify(this.packageList));
        var shipdetails = (this.isReturnShipment) ? this.returnShipment : this.shipment;
        var fromAddress = (this.isReturnShipment) ? this.toAddress : this.fromAddress;
        var toAddress = (this.isReturnShipment) ? this.fromAddress : this.toAddress;
        var shimentDate = (this.isReturnShipment) ? this.returnShipmentDate : this.shipment.ERP7__Shipment_Date__c;
        getRates({ PackageItems: this.packageList, consVar: JSON.stringify(this.Credentials), fromAddress: JSON.stringify(fromAddress), ToAddress: JSON.stringify(toAddress), shipDate: shimentDate, shipmentDetails: JSON.stringify(shipdetails), isReturnShipment: this.isReturnShipment }).then(result => {
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
                            if (this.isReturnShipment) {
                                var returRates = [];
                                for (var x in rateSample) {
                                    returRates.push({ index: x, code: x, service: rateSample[x].serviceType, totalCharges: rateSample[x].totalNetCharge, currencycode: rateSample[x].netChargeCurrency });
                                }
                                this.rateResponseReturn = returRates;
                                this.showReturnModal = true;
                            }
                            else this.rateResponse = rateSample;
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
                //if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                //if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
                this.isLoading = false;
            });
    }
    closeErrorList() { this.errorList = []; }
    get isErrorList() {
        if (this.errorList) {
            console.log('this.errorList : ', this.errorList.length);
            if (this.errorList.length > 0)
                return true;
            else
                return false;
        } else {
            return false;
        }

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
    handleServiceTypeChange(event) {
        this.selectedServiceType = event.target.value;
        console.log('Selected Service Type:', this.selectedServiceType);
        var index = event.target.label;
        console.log('Selected index :', index);
        this.selectedCurrency = this.rateResponse[index - 1].netChargeCurrency;
        console.log('Selected Currency :', this.selectedCurrency);
        if (this.selectedServiceType) {
            this.ShowGetRate = false;
            this.ShowInitiateShipment = true;
        }
    }
    Shipping_Request() {
        if (this.selectedServiceType || this.selectedServiceTypeReturn) {
            this.isLoading = true;
            var shipdetails = (this.isReturnShipment) ? this.returnShipment : this.shipment;
            var fromAddress = (this.isReturnShipment) ? this.toAddress : this.fromAddress;
            var toAddress = (this.isReturnShipment) ? this.fromAddress : this.toAddress;
            var shimentDate = (this.isReturnShipment) ? this.returnShipmentDate : this.shipment.ERP7__Shipment_Date__c;
            var fromCont = (this.isReturnShipment) ? this.toContact : this.fromContact;
            var toCont = (this.isReturnShipment) ? this.fromContact : this.toContact;
            var rateSerive = (this.isReturnShipment) ? this.selectedServiceTypeReturn : this.selectedServiceType;
            var rateCurrency = (this.isReturnShipment) ? this.selectedCurrencyReturn : this.selectedCurrency;
            var shipId = (this.isReturnShipment) ? this.shipment.Id : '';
            console.log('ship : ', JSON.stringify(shipdetails));
            shippingRequestResponse({ packList: this.packageList, fromAddress: JSON.stringify(fromAddress), ToAddress: JSON.stringify(toAddress), fromContact: JSON.stringify(fromCont), toContact: JSON.stringify(toCont), ShipDateStamp: shimentDate, myConsVar: JSON.stringify(this.Credentials), Shipment: JSON.stringify(shipdetails), rateService: rateSerive, rateCurrency: rateCurrency, isReturnShipment: this.isReturnShipment, packageItems: this.packageItems, masterShipmentId: shipId }).then(result => {
                if (result) {
                    console.log('result shippingRequestResponse : ', result);
                    if (result.errMsgs && result.errMsgs.length > 0) {
                        this.errorList = Object.assign([], this.errorList);
                        this.errorList = result.errMsgs;
                    }
                    else {
                        if (this.isReturnShipment) {
                            this.returnShipment = result.ShipDetails;
                            this.showLabel = true;
                            this.ShowCancelShipment = true;
                            this.ShowInitiateShipment = false;
                            this.showReturnModal = false;
                            this.showReturnLabel = true;
                            const event = new ShowToastEvent({
                                title: 'Success',
                                message: 'Shipment created succesfully!',
                                variant: 'success'
                            });
                            this.dispatchEvent(event);
                        }
                        else this.shipment = result.ShipDetails;
                        this.sucessMsg = 'Shipment Created succesfully!';
                        if (this.shipment.Id != null) {
                            this.ShowCancelShipment = true;
                            this.ShowLabels = true;
                            this.ShowInitiateShipment = false;
                            this.rateResponse = null;
                            this.RateMsg = null;
                        }
                        if (this.allowReturnShipment && this.packageList[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c) {
                            this.selectedLogisticReturnShipType = this.packageList[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c;
                            console.log('this.selectedLogisticReturnShipType : ', this.selectedLogisticReturnShipType);
                            if (this.selectedLogisticReturnShipType == 'UPS') {
                                this.showUPSReturnType = true;
                                this.showFedexReturnType = false;
                            }
                            else if (this.selectedLogisticReturnShipType == 'FedEx') {
                                this.showUPSReturnType = false;
                                if (this.allowUPSReturnShipmentFromFedex) this.showFedexReturnType = true;
                            }
                        }
                        if (this.allowReturnShipment && this.selectedLogisticReturnShipType == '') {
                            if (this.allowUPSReturnShipmentFromFedex) this.showUPSReturnType = true;
                            this.showFedexReturnType = true;
                        }

                    }
                    this.isLoading = false;

                }
            })
                .catch(error => {
                    console.log('Error:', error);
                    this.errorList = Object.assign([], this.errorList);
                    if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                    if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
                    this.isLoading = false;

                });
        } else {
            this.errorList = Object.assign([], this.errorList);
            this.errorList.push('Please select service to proceed');
            // this.isLoading = false;

        }
    }
    viewLabels() {
        try {
            console.log('label ');

            var shipmentsId = this.shipment.Id;
            console.log('shipmentsId ');
            var fileName = 'Fedex_Label';
            var val = 'nopdf';
            console.log('val ');
            var showIframe = false;
            // Construct the URL
            var fromAddress = this.fromAddress.ERP7__Country__c;
            var toAddress = this.toAddress.ERP7__Country__c;
            if(fromAddress != toAddress) showIframe = true;
            var url = '/apex/ERP7__PrintUPSLabel?shipmentsId=' + shipmentsId + '&fileName=' + fileName + '&val=' + val + '&showframe=' + showIframe;

            // Open the URL in a new tab
            window.open(url, '_blank');

            console.log('URL opened in new tab');
        } catch (e) {
            console.log(e);
        }
    }
    cancelSelectedShipment() {
        var proceedCancel = confirm("Are you sure you want to cancel this shipment?")
        console.log('proceedCancel : ', proceedCancel);
        if (proceedCancel) {
            this.isLoading = true;
            cancelShipment({ Shipment: JSON.stringify(this.shipment), packList: this.packageList, TimeStamp: this.shipment.ERP7__Shipment_Date__c, myConsVar: JSON.stringify(this.Credentials) })
                .then(result => {
                    if (result) {
                        console.log('result cancelShipment : ', result);
                        if (result.errMsgs && result.errMsgs.length > 0) {
                            console.log('in');
                            this.errorList = Object.assign([], this.errorList);
                            this.errorList = result.errMsgs;
                        }
                        console.log('this.errorList : ', this.errorList);
                        if (result.successMsg) this.sucessMsg = result.successMsg;
                        console.log('this.sucessMsg : ', this.sucessMsg);
                        if (result.ShipDetails && result.ShipDetails.ERP7__Status__c) this.shipment.ERP7__Status__c = result.ShipDetails.ERP7__Status__c;
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
    }

    trackingShipment() {
        this.isLoading = true;
        TrackShipment({ Shipment: JSON.stringify(this.shipment), packList: this.packageList, TimeStamp: this.shipment.ERP7__Shipment_Date__c })
            .then(result => {
                if (result) {
                    console.log('result TrackShipment : ', result);
                    if (result.errMsgs && result.errMsgs.length > 0) {
                        this.errorList = Object.assign([], this.errorList);
                        this.errorList = result.errMsgs;
                    }
                    else {
                        this.shipmentFlows = result.ShipFlows;
                        this.shipment = result.ShipDetails;
                    }
                    this.isLoading = false;
                }
                else {
                    console.log('No result');
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
    generateReturnShipment() {
        this.ReturnShipTypeUPS = true;
        this.isLoading = true;
        var today = new Date();
        this.returnShipmentDate = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
        console.log('returnShipmentDate : ', this.returnShipmentDate);
        getInitialDataUPS({ ShipId: this.shipmentIds, packIds: JSON.stringify(this.packageIds), ReturnShip: true })
            .then(result => {
                console.log('getInitialData res : ', result);
                if (result) {
                    if (result.alertlist && result.alertlist.length > 0) {
                        this.errorList = Object.assign([], this.errorList);
                        this.errorList = result.alertlist;
                        this.isLoading = false;
                    }
                    else {
                        this.defaulWrapUPS = result;
                        this.CredentialsUPS = result.credsWrap;
                        //this.showReturnModal = true;
                        this.getUPSRates();
                        this.isLoading = false;
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
    getUPSRates() {
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
        getRatesUPS({ packList: this.packageList, myConsVar: JSON.stringify(this.CredentialsUPS), fromAdd: JSON.stringify(this.toAddress), toAdd: JSON.stringify(this.fromAddress), fromContact: JSON.stringify(this.toContact), toContact: JSON.stringify(this.fromContact), shipDate: this.returnShipmentDate, Shipment: JSON.stringify(this.returnShipment), isReturnShipment: true }).then(result => {
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
                    this.rateResponseReturn = rateSample;
                    console.log('rateResponseReturn : ', this.rateResponseReturn);
                    if (result.alertlist) {
                        this.RateMsg = result.alertlist;
                    }
                    this.showReturnModal = true;
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
    handleCloseModal() {
        this.showReturnModal = false;
        this.errorList = [];
        this.RateMsg = [];
        this.ReturnShipTypeUPS = false;
    }
    handleBillingOptionsChange(event) {
        this.returnShipment.erp7__Shipment_Billing_options__c = event.detail.value;
    }
    handleShipmentDateChange(event) {
        this.returnShipmentDate = event.detail.value;
    }
    handleDescription(event) {
        this.shipment.ERP7__Description__c = event.detail.value;
        console.log('this.shipment.Description__c: ', this.shipment.ERP7__Description__c);
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
    handleGenerateReturnShipment() {
        if (this.selectedServiceTypeReturn) {
            this.isLoading = true;
            Shipping_Request_ResponseUPS({ packList: this.packageList, myConsVar: JSON.stringify(this.CredentialsUPS), fromAdd: JSON.stringify(this.toAddress), toAdd: JSON.stringify(this.fromAddress), fromContact: JSON.stringify(this.toContact), toContact: JSON.stringify(this.fromContact), shipDate: this.returnShipmentDate, Shipment: JSON.stringify(this.returnShipment), isReturnShipment: true, packageItems: this.packageItems, service: this.selectedServiceTypeReturn, serviceCode: this.selectedServiceCodeReturn, currencyCode: this.selectedCurrencyReturn, masterShipmentId: this.shipment.Id }).then(result => {
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
                        console.log('this.errorList : ', this.errorList);
                    }
                    else {
                        //if (this.isReturnShipment) this.returnShipment = result.shipment;
                        this.returnShipment = result.shipment;
                        this.showLabel = true;
                        this.ShowCancelShipment = true;
                        this.ShowInitiateShipment = false;
                        this.showReturnModal = false;
                        this.showReturnLabel = true;
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'Shipment created succesfully!',
                            variant: 'success'
                        });
                        this.dispatchEvent(event);
                        /*  if (this.allowReturnShipment && this.packageList[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c) {
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
                          }*/
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
        else {
            const event = new ShowToastEvent({
                title: 'warning',
                message: 'Please select shipment service to proceed!',
                variant: 'warning'
            });
            this.dispatchEvent(event);
        }
    }
    viewReturnLabels() {
        try {
            console.log('label ');

            var shipmentsId = this.returnShipment.Id;
            console.log('shipmentsId ');
            var fileName = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? 'Fedex_Label' : 'UPS_Label';
            var val = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? 'nopdf' : 'pdf';
            console.log('val ');
            var fromAddress = this.fromAddress.ERP7__Country__c;
            var toAddress = this.toAddress.ERP7__Country__c;
            
            var showIframe = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? true : false;
            console.log('showIframe 1: ',showIframe);
            if(fileName == 'Fedex_Label') {
                if(fromAddress != toAddress) showIframe = true;
                else showIframe = false;
            }
            console.log('showIframe 2: ',showIframe);
            // Construct the URL
            var url = '/apex/ERP7__PrintUPSLabel?shipmentsId=' + shipmentsId + '&fileName=' + fileName + '&val=' + val + '&showframe=' + showIframe;

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
            //var val = 'pdf';
            var shiptype = 'return';
            var contactId = '';
            if (this.toContact && this.toContact.Id != undefined && this.toContact.Id != null && this.toContact.Id != '') {
                contactId = this.toContact.Id;
            }
            console.log('contactId :  ', contactId);
            var showIframe = (this.returnShipment.ERP7__Tracking_Unique_Id__c && this.returnShipment.ERP7__Tracking_Unique_Id__c == "FEDEX") ? true : false;
           
            // Construct the URL
            var url = '/apex/ERP7__PrintUPSLabel?shipmentsId=' + shipmentsId + '&fileName=' + fileName + '&contactId=' + contactId + '&shiptype=' + shiptype+'&showframe=' + showIframe;

            // Open the URL in a new tab
            window.open(url, '_blank');

            console.log('URL opened in new tab');
        } catch (e) {
            console.log(e);
        }
    }
    generateFedexReturnShipment() {
        try {
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
        } catch (error) {
            console.log('err : ', error);
        }
    }
    handleGenerateReturnShipmentFedex() {
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