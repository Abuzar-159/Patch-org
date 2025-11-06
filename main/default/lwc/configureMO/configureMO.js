import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import MO_All from '@salesforce/apex/ManufacturingOrder.getAll';
import localTimezone from '@salesforce/i18n/timeZone'
import { loadStyle } from 'lightning/platformResourceLoader';
import momentJS from "@salesforce/resourceUrl/momentJS";
import bootstrap from '@salesforce/resourceUrl/bootStrap';
import { loadScript } from "lightning/platformResourceLoader";

export default class DynamicRecordForm extends LightningElement {
    @api recordId;
    @api recordName;
    @api objectApiName;
    @api MOWrap;
    @api WOS;
    @api manuOrder;
    @api SILIs;
    @api moSerialNos; 
    @api moBatchNos;
    @track error; // to show error message from apex controller.
    @track success; // to show succes message in ui.
    @track showMainSpin;
    @track hasWOS = false;
    status = 'init';
    myTimezone = localTimezone;

    renderedCallback() {
        if(this.status == 'init'){
            MO_All({vmoy : this.recordId})
                .then(result => {
                    //alert("success");
                    this.MOWrap = result;
                    this.manuOrder = result.manuOrders;
                    this.SILIs = result.SILIs;
                    this.WOS = result.WOs;
                    this.moSerialNos = result.moSerialNos;
                    this.moBatchNos = result.moBatchNos;
                    this.error = undefined;
                    this.status = 'success';
                    this.hasWOS = (this.MOWrap.WOs.length > 0)? true: false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'MO data Retrieve successfully',
                            message: 'Order details Retrieve successfully',
                            variant: 'success',
                        }),
                    );
                })
                .catch(error => {
                    //alert("error");
                    this.error = error;
                    this.status = 'failed';
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while getting Details',
                            message: error.message,
                            variant: 'error',
                        }),
                    );
                    this.MOWrap = undefined;
                });
        }
    }
}