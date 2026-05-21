import { LightningElement, api, track } from 'lwc';
import {refreshApex} from '@salesforce/apex';
/* eslint-disable no-console */
 /* eslint-disable no-alert */
export default class doPagination extends LightningElement {
    previousval = true;
    nextval = false;
    @api showval;
   @api totalRecords;
    @api
    changeView(str){
        console.log('str : '+str);
        if(str == 'trueprevious'){
            
            this.previousval = true;
            console.log('trueprevious is enabled then : ',this.previousval);
            return refreshApex(this.previousval);
            //this.template.querySelector('lightning-button.Previous').disabled = true;
        }
        if(str == 'falsenext'){
            this.nextval = false;
            console.log('falsenext is enabled then : ',this.nextval);
            return refreshApex(this.nextval);
            //this.template.querySelector('lightning-button.Next').disabled = false;
        }
        if(str == 'truenext'){
            this.nextval = true;
            console.log('truenext is enabled then : ',this.nextval);
            return refreshApex(this.nextval);
            //this.template.querySelector('lightning-button.Next').disabled = true;
        }
        if(str == 'falseprevious'){
            console.log('falsePrevious is disabled first ');
            this.previousval = false;
            //this.template.querySelector('lightning-button.Previous').disabled = false;
            console.log('falsePrevious is enabled then : ',this.previousval);
            return refreshApex(this.previousval);
        }
    }
    /*renderedCallback(){
        this.previousval = true;
console.log('renderedCallback called');
        document.addEventListener("DOMContentLoaded", function(event) {
            this.template.querySelector('lightning-button.Previous').disabled = true;
                  });
    }*/
    previousHandler1() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextHandler1() {
        this.dispatchEvent(new CustomEvent('next'));
    }
    FirstPageHandler1(){
        this.dispatchEvent(new CustomEvent('firstpage'));
    }
    LastPageHandler1(){
        this.dispatchEvent(new CustomEvent('lastpage'));
    }
    changeHandler(event){
        console.log('changeHandler : ',event.target.value);
        event.preventDefault();
        const s_value = event.target.value;
        console.log('this.totalRecords : ',this.totalRecords);
        if(this.totalRecords < s_value)  this.showval = this.totalRecords;
        else this.showval = s_value;
        const selectedEvent = new CustomEvent('selected', { detail: s_value});
        console.log('selectedEvent : ',selectedEvent);
        this.dispatchEvent(selectedEvent);
        console.log('last reached : ');
        return refreshApex(this.showval);
    }
}