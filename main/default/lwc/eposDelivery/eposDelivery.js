import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import ERPCustomIcons from '@salesforce/resourceUrl/ERPCustomIcons';
import UPSServices from "@salesforce/apex/Epos.UPSServices";
import FedServices from "@salesforce/apex/Epos.FedServices";
//import DHLServices from "@salesforce/apex/Epos.DHLServices";
import saveEstimateService from "@salesforce/apex/Epos.saveEstimateService";

//Label
import Name from '@salesforce/label/c.StockTakeName';
import Type from '@salesforce/label/c.Type_ManageLeave';
import Tracking_No from '@salesforce/label/c.UPS_Tracking_No';
import Delivery_Date from '@salesforce/label/c.UPS_Delivery_Date';
import Status from '@salesforce/label/c.EmployeeReviewV2_Status';
import Shipment from '@salesforce/label/c.UPS_Shipment';
import not_found from '@salesforce/label/c.not_found';
import Package_Type from '@salesforce/label/c.UPS_Package_Type';
import Shipment_Date from '@salesforce/label/c.UPS_Shipment_Date';
import Select from '@salesforce/label/c.Select';
import Service_Type from '@salesforce/label/c.Service_Type';
import Total from '@salesforce/label/c.AddSubscriptions_Total';
import Cancel from '@salesforce/label/c.Cancel_ManageLeave';
import Save from '@salesforce/label/c.Shipment_Save';
import Get_Rates from '@salesforce/label/c.Get_Rates';
import Shipment_Details from '@salesforce/label/c.UPS_Shipment_Details';
import Total_Quantity from '@salesforce/label/c.Acc_Pay_Total_Quantity';
import Picked_qty from '@salesforce/label/c.Pick_PICKED_QTY';
import Packed from '@salesforce/label/c.Packed';
import Quantity from '@salesforce/label/c.InventoryConsole_Quantity';
import Shipped from '@salesforce/label/c.Shipped';
import Estimated_Delivery_Date from '@salesforce/label/c.Estimated_Delivery_Date';
import Tax from '@salesforce/label/c.QuotationPDF_Tax';
import Estimate_Delivery from '@salesforce/label/c.Estimate_Delivery';
import Available_Services from '@salesforce/label/c.Available_Services';
import Service_Code from '@salesforce/label/c.Service_Code';
import Service_From from '@salesforce/label/c.Service_From';
import Services from '@salesforce/label/c.Servies';
import Estimated_cost from '@salesforce/label/c.Estimated_cost';

export default class EposDelivery extends LightningElement {
    @track labels={Estimated_cost, Services, Service_From, Service_Code, Available_Services, Estimate_Delivery, Name,Type, Tracking_No, Delivery_Date, Status, Shipment, not_found, Package_Type,Shipment_Date, Select, Service_Type, Total, Cancel, Save, Get_Rates, Shipment_Details, Total_Quantity, Picked_qty,Packed, Quantity, Shipped, Estimated_Delivery_Date, Tax};
    @api order;
    copyOrderForSave;
    @api shipmentsList;
    @api isShipmentsList = false;
    @api isOrderHasId=false;
    spinner = false;
    UPSLogo = ERPCustomIcons + '/erpicons/glo_ups_brandmark.gif';
    FedexLogo = ERPCustomIcons + '/erpicons/FedEx.png';
    DHLLogo = ERPCustomIcons + '/erpicons/dhl.png';
    isEstimateModal = false;
    shipmentError;
    shipDate;
    adminFee = 0;
    selectedUPSPack;
    UPSPackages;
    FedexPackages;
    selectedFedexPack;
    @track allServices = [];
    @track showLoader = true;
    @track loaderText = 'Fetching UPS Services';

    get isServiceAvl() {
        return this.allServices.length > 0 ? true : false;
    }

    sortOrder = 'ASC';
    selectedService;

    isInternalShipment=false;
    get disableExtimateSave() {
        return this.selectedService ? false : true;
    }
    UPS_Services = { Services: [] };
    FEDEX_Services = { Services: [] };
    /*DHL_Services = { Services: [] };

    showUPSLoader=true;
    showFedexLoader=true;
    showDHLLoader=true;

    get isUPS_ServicesAvl() {
        return this.UPS_Services.Services.length > 0 ? true : false;
    }
    get isFEDEX_ServicesAvl() {
        return this.FEDEX_Services.Services.length > 0 ? true : false;
    }
    get isDHL_ServicesAvl() {
        return this.DHL_Services.Services.length > 0 ? true : false;
    }*/

    handleUPSPackage(event) {
        this.selectedUPSPack = event.detail.value;
    }
    handleFedexPackage(event) {
        this.selectedFedexPack = event.detail.value;
    }
    handleShipDate(event) {
        this.shipDate = event.detail.value;
    }
    handleAdminFee(event) {
        this.adminFee = event.currentTarget.value;
    }
    handleRadio(event) {
        console.log('value:', JSON.stringify(event.currentTarget.value));
        console.log('allServices:', this.allServices[event.currentTarget.value]);
        this.selectedService = this.allServices[event.currentTarget.value];

    }

    sortServices() {
        console.log('inside sortServices');
        //this.allServices.sort( compare );
        //this.allServices.sort( this.compare(this.allServices,this.allServices) );
        //if (this.sortOrder == 'ASC') {
        this.allServices.sort(function (a, b) {
            console.log('inside sort ASC');
            if (a.isShowTotalCharges) {
                return a.totalCharges - b.totalCharges;
            }
            if (!a.isShowTotalCharges) {
                return a.negotiatedCharges - b.negotiatedCharges;
            }
        });
        /*}
        if (this.sortOrder == 'DESC') {
            this.allServices.sort(function (a, b) {
                console.log('inside sort DESC');
                if (a.isShowTotalCharges) {
                    return b.totalCharges - a.totalCharges;
                }
                if (!a.isShowTotalCharges) {
                    return b.negotiatedCharges - a.negotiatedCharges;
                }
            });
        }

        console.log('after sort');
        this.sortOrder=this.sortOrder =='ASC' ?'DESC':'ASC';   */
    }






    /*get showUPS(){
        return this.order.ERP7__Shipment_Type__c == 'UPS' || this.order.ERP7__Shipment_Type__c == 'Any' ? true :false;
    }
    get showFedex(){
        return this.order.ERP7__Shipment_Type__c == 'FedEx' || this.order.ERP7__Shipment_Type__c == 'Any' ? true :false;
    }
    get showDHL(){
        return this.order.ERP7__Shipment_Type__c == 'DHL' || this.order.ERP7__Shipment_Type__c == 'Any' ? true :false;
    }
    get showShipment(){
        return this.order.ERP7__Shipment_Type__c == 'Shipment' || this.order.ERP7__Shipment_Type__c == 'Any' ? true :false;
    }*/

    estimateDeliveryModalOpen() {
        console.log('inside open modal');
        //this.showUPSLoader=true;
        //this.showFedexLoader=true;
        //this.showDHLLoader=true;
        this.spinner = true;
        this.showLoader = true;
        this.UPSServices();
        console.log('before isUPSModal');
        this.isEstimateModal = true;

    }
    estimateDeliveryModalClose() {
        this.isEstimateModal = false;
    }
    UPSServices() {
        this.allServices = [];
        try {
            UPSServices({
                OrdId: this.order.Id,
                packType: this.selectedUPSPack,
                shipDate: this.shipDate,
            })
                .then(result => {
                    console.log('result of UPSServices:', result);
                    this.shipDate = result.ShipmentDate;
                    this.UPSPackages = result.PackageTypes;
										console.log('Package options::~>',this.UPSPackages);
                    this.selectedUPSPack = result.PackageType;
										console.log('selectedUPSPack::~>',this.selectedUPSPack);
                    //this.showUPSLoader=false;
                    this.UPS_Services = result;

                    for (let i in result.Services) {
                        result.Services[i].serviceFrom = 'UPS';
                        result.Services[i].keyId = result.Services[i].ServiceManual;
                        if (result.Services[i].negotiatedCharges == '')
                            result.Services[i].isShowTotalCharges = true;
                        else
                            result.Services[i].isShowTotalCharges = false;

                        if (result.Services[i].DeliveryDate != '')
                            result.Services[i].isShowDeliveryDate = true;
                        else
                            result.Services[i].isShowDeliveryDate = false;

                        this.allServices = result.Services;

                    }
                    this.spinner = false;
                    this.FedexServices();
                })
                .catch(error => {
                    console.log('Error:', error);
                    this.FedexServices();
                    this.showLoader = true;
                    this.spinner = false;
                })
        } catch (e) {
            console.log('Error:', e);
        }
    }

    FedexServices() {
        this.loaderText = 'Fetching Fedex Services';
        try {
            FedServices({
                OrdId: this.order.Id,
                packType: this.selectedFedexPack,
                shipDate: this.shipDate,
            })
                .then(result => {
                    console.log('result of FedServices:', result);

                    //this.showFedexLoader=false;
                    this.FEDEX_Services = result;
                    this.FedexPackages = result.PackageTypes;
                    this.selectedFedexPack = result.PackageType;
                    this.shipDate = result.ShipmentDate;
                    for (let i in result.Services) {
                        result.Services[i].serviceFrom = 'FedEx';
                        result.Services[i].keyId = result.Services[i].Service;
                        if (result.Services[i].negotiatedCharges == '')
                            result.Services[i].isShowTotalCharges = true;
                        else
                            result.Services[i].isShowTotalCharges = false;
                        this.allServices.push(result.Services[i]);
                    }

                    console.log('this.allServices:', this.allServices);
                    this.showLoader = false;
                    this.loaderText = '';
                    //this.DHLServices();
                })
                .catch(error => {
                    console.log('Error:', error);
                    this.loaderText = '';
                    //this.DHLServices();
                    this.showLoader = false;
                })
        } catch (e) {
            console.log('Error:', e);
        }
    }

    /*DHLServices() {
        this.loaderText = 'Fetching DHL Services';
        try {
            DHLServices({
                OrdId: this.order.Id,
                packType: null,
                shipDate: null,
            })
                .then(result => {
                    console.log('result of DHLServices:', result);
                    //this.showDHLLoader=false;
                    //this.DHL_Services = result;
                    for (let i in result.Services) {
                        result.Services[i].serviceFrom = 'DHL';
                        this.allServices.push(result.Services[i]);
                    }
                    console.log('this.allServices:', this.allServices);
                    this.showLoader = false;
                    this.loaderText = '';
                })
                .catch(error => {
                    console.log('Error:', error);
                    this.showLoader = false;
                })
        } catch (e) {
            console.log('Error:', e);
        }
    }*/

    saveEstimateDelivery() {
        try {
            console.log('inside saveEstimateDelivery');
            this.shipmentError = undefined;
            if (!this.selectedService) {
                this.shipmentError = 'Please select service.'
                return;
            }
            let selectedService = this.selectedService;
            let ord = {};
            ord.Id = this.order.Id;
            if (selectedService.serviceFrom == "UPS") {
                if (selectedService.negotiatedCharges != null && selectedService.negotiatedCharges != '' && selectedService.negotiatedCharges != '-') {
                    let negotiatedCharge = (parseFloat(selectedService.negotiatedCharges) + ((parseFloat(selectedService.negotiatedCharges) * parseFloat(this.UPS_Services.Additional)) / 100));
                    ord.ERP7__Estimated_Shipping_Amount__c = negotiatedCharge.toFixed(2);
                    ord.ERP7__Total_Shipping_Amount__c = negotiatedCharge.toFixed(2);

                } else if (selectedService.totalCharges != null && selectedService.totalCharges != '' && selectedService.totalCharges != '-') {
                    let totalCharge = (parseFloat(selectedService.totalCharges) + ((parseFloat(selectedService.totalCharges) * parseFloat(this.UPS_Services.Additional)) / 100));
                    ord.ERP7__Estimated_Shipping_Amount__c = totalCharge.toFixed(2);
                    ord.ERP7__Total_Shipping_Amount__c = totalCharge.toFixed(2);
                }
                ord.ERP7__Shipment_Type__c = 'UPS';
                if (selectedService.ServiceManual != null) ord.ERP7__UPS_Service__c = selectedService.ServiceManual;
                if (selectedService.isShowDeliveryDate && selectedService.DeliveryDate != '') {
                    ord.ERP7__Estimated_Delivery_Date__c = selectedService.DeliveryDate;
                } else if (!selectedService.isShowDeliveryDate && selectedService.DeliveryDateS != '') {
                    ord.ERP7__Estimated_Delivery_Date__c = selectedService.DeliveryDateS;
                } else {
                    ord.ERP7__Estimated_Delivery_Date__c = null;
                }
            }
            if (selectedService.serviceFrom == "FedEx") {
                if (selectedService.totalCharges != null && selectedService.totalCharges != '' && selectedService.totalCharges != '-') {
                    let totalCharge = (parseFloat(selectedService.totalCharges) + ((parseFloat(selectedService.totalCharges) * this.FEDEX_Services.additionalPercent) / 100));
                    ord.Estimated_Shipping_Amount__c = totalCharge.toFixed(2);
                    ord.ERP7__Total_Shipping_Amount__c = totalCharge.toFixed(2);
                }

                ord.ERP7__Shipment_Type__c = 'FedEx';
                if (selectedService.service != null && selectedService.service != '') {
                    ord.ERP7__UPS_Service__c = selectedService.service;
                }
            }
            this.spinner=true;
            if (ord.Id && ord.Id != '') {
                saveEstimateService({
                    ord: JSON.stringify(ord),
                })
                    .then(result => {
                        if (result.includes('Shipping estimate save successfully.')) {
                            this.isEstimateModal = false;
                            this.spinner=false;
                            const event = new ShowToastEvent({
                                variant: 'success',
                                message: result,
                            });
                            this.dispatchEvent(event);

                            const estEvent = new CustomEvent('shipment', {});
                            this.dispatchEvent(estEvent);
                        } else {
                            this.shipmentError =result;
                            this.spinner=false;
                        }
                    }).catch(error => {
                        console.log('Error:', error);
                        this.spinner=false;
                        this.shipmentError = error.body.message;
                    })
            } else {
                this.shipmentError = 'Please save order.';
                this.spinner=false;
            }




        } catch (e) {
            console.log('Error:', e);
        }
    }


    shipmentModalOpen(){
        this.shipmentError=undefined;
        this.copyOrderForSave=JSON.parse(JSON.stringify(this.order));
        this.isInternalShipment=true;
    }
    shipmentModalClose(){
        this.isInternalShipment=false;
    }

    handleService(event){
        this.copyOrderForSave.ERP7__UPS_Service__c=event.currentTarget.value;
    }
    handleEstDate(event){
        try{
            this.copyOrderForSave.ERP7__Estimated_Delivery_Date__c=event.detail.value;
        }catch(e){console.log('Error:',e);}
        
    }
    handleTracNo(event){
        this.copyOrderForSave.ERP7__Tracking_Number__c=event.currentTarget.value;
    }
    handleEstAmount(event){
        this.copyOrderForSave.ERP7__Estimated_Shipping_Amount__c=event.currentTarget.value;
    }
    handleShipTax(event){
        this.copyOrderForSave.ERP7__Shipping_VAT__c=event.currentTarget.value;
    }
    handleShipTotal(event){
        this.copyOrderForSave.ERP7__Total_Shipping_Amount__c=event.currentTarget.value;
    }
    saveShipment(){
        try{
            this.spinner=true;
            if (this.copyOrderForSave.Id && this.copyOrderForSave.Id != '') {
                delete this.copyOrderForSave.CurrencyIsoCode;
                saveEstimateService({
                    ord: JSON.stringify(this.copyOrderForSave),
                })
                    .then(result => {
                        if (result.includes('Shipping estimate save successfully.')) {
                            this.isInternalShipment=false;
                            this.spinner=false;
                            const event = new ShowToastEvent({
                                variant: 'success',
                                message: result,
                            });
                            this.dispatchEvent(event);

                            const estEvent = new CustomEvent('shipment', {});
                            this.dispatchEvent(estEvent);
                        } else {
                            this.shipmentError =result;
                            this.spinner=false;
                        }
                    }).catch(error => {
                        console.log('Error:', error);
                        this.spinner=false;
                        this.shipmentError = error.body.message;
                    })
            } else {
                this.shipmentError = 'Please save order.';
                this.spinner=false;
            }
        }catch(e){
            console.log('Error:',e);
        }
    }




    renderedCallback() {
        try {

            Promise.all([
                //loadStyle(this, ERPCustomIcons + '/CSS/global-axolt.css'),
            ])
                .then(() => {
                    console.log('Static Resource Loaded');
                })
                .catch(error => {
                    console.log('Static Resource Error', error);
                });
        } catch (e) {
            console.log('Error:', e);
        }
    }

}