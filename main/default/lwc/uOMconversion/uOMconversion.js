import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllUOMConversions from "@salesforce/apex/uomApex.getAllUOMConversions";
import createUOMConv from "@salesforce/apex/uomApex.createUOMConv";
import searchMethod from "@salesforce/apex/uomApex.searchMethod";
import updateUoM from "@salesforce/apex/uomApex.updateUoM";

export default class UOMconversion extends LightningElement {
    uomConversions;
    newUoM;
    editUoM;
    editrec;
    devName;
    statusMessage;
		uomId;
		searchItem;
    //label=Work_Orders;

    rec={
        id:'',
        Label:'',
        From_Value__c:0.0,
        To_Value__c:0.0,
        From_UOM__c:'',
        To_UOM__c:''
       
    }
   

    @wire(getAllUOMConversions)
    wiredUOMConversions(result) {
        if (result.data) {
            this.uomConversions = result.data;
            
        } else if (result.error) {
            console.log('Error',result.error);
        }
    }
    
    editRecord(event){
        this.editUoM= true;
        const recordIndex = event.target.dataset.recordindex;
        const recordId = event.target.dataset.recordid;
				this.uomId = recordId;
        console.log('recindex', recordIndex);
        console.log('recordId', recordId);
				console.log('this.uomId', this.uomId);
        this.devName = this.uomConversions[recordIndex].DeveloperName;
        this.editrec=this.uomConversions[recordIndex];
        this.rec.Label=this.uomConversions[recordIndex].MasterLabel;
        this.rec.From_Value__c=this.uomConversions[recordIndex].From_Value__c;
        this.rec.To_Value__c=this.uomConversions[recordIndex].To_Value__c;
        this.rec.From_UOM__c=this.uomConversions[recordIndex].From_UOM__c;
        this.rec.To_UOM__c=this.uomConversions[recordIndex].To_UOM__c;
        //this.rec.From_UOM__c=this.uomConversions[recordIndex].From_UOM__c;
        //this.rec.To_UOM__c=this.uomConversions[recordIndex].To_UOM__c;
        
    }
    handleNewConversion() {
        this.newUoM= true;
    }
    closeModal(){
        this.newUoM= false;
        this.editUoM= false;
        this.rec.Label='';
        this.rec.From_Value__c='';
        this.rec.To_Value__c='';
        this.rec.From_UOM__c='';
        this.rec.To_UOM__c='';
    }
    handleNameChange(event){
				var labelcheck = event.target.value;
        this.rec.Label = event.target.value;
				const specialCharacterRegex = /[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]/;
        if (specialCharacterRegex.test(labelcheck)) {
            const event = new ShowToastEvent({
                title: 'Warning!',
                variant: 'warning',
                message:
                    'Cannot include special characters!',
            });
            this.dispatchEvent(event);   
        } else {
            this.rec.Label = event.target.value;
        }
				
    }
    handleFrom(event) {
        
        this.rec.From_Value__c = event.target.value;
    }
    handleFuom(event) {
        
        this.rec.From_UOM__c = event.target.value;
    }
    handleTouom(event) {
        
        this.rec.To_UOM__c = event.target.value;
    }
    handleTo(event) {
        
        this.rec.To_Value__c = event.target.value;
        console.log('Inside new handle save', this.rec.To_Value__c);
        
    }
    handleTuom(event) {
        this.rec.To_UOM__c = event.target.value;
    }
		handleSearchChange(event) {
				 this.searchItem = event.target.value;
				 console.log('Inside new handle save', this.searchItem);
				searchMethod({
            searchItem: this.searchItem,
        })
            .then(result => {
						console.log('Inside new handle save', this.searchItem);
              this.uomConversions = result;
            })
            .catch(error => {
            });
		}

    /*  refreshData() {
        refreshApex(this.wiredUOMConversions);
       }
    handleRefreshComponent() {
        try {
            this.refreshData;
            eval("$A.get('e.force:refreshView').fire();");
        } catch (e) {
            console.log('Error:', e);
        }
    }*/

    handleSave() {
        // Call the Apex method with input values
        console.log('Inside new handle save', this.rec.To_Value__c);
				let errorLabel = false;
				let sameLabel = false;
				let uomList = this.uomConversions;
				for(var x in uomList){
						if(uomList[x].MasterLabel == this.rec.Label) sameLabel = true;
				}
				
				const specialCharacterRegex = /[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]/;
        if (specialCharacterRegex.test(this.rec.Label)) {
						errorLabel = true;  
				}
        if (
            !this.rec.Label || 
            !this.rec.From_Value__c || 
            !this.rec.To_Value__c || 
            !this.rec.From_UOM__c || 
            !this.rec.To_UOM__c
        ){
            const event = new ShowToastEvent({
                title: 'Warning!',
                variant: 'warning',
                message:
                    'Enter Required Fields',
            });
            this.dispatchEvent(event);   
        }else if(errorLabel == true){
						 const event = new ShowToastEvent({
                title: 'Warning!',
                variant: 'warning',
                message:
                    'Name cannot include special characters!',
            });
            this.dispatchEvent(event);
				}else if(sameLabel == true){
						 const event = new ShowToastEvent({
                title: 'Warning!',
                variant: 'warning',
                message:
                    'UoM with same name already exists!',
            });
            this.dispatchEvent(event);
				}
				else{
        createUOMConv({
            label: this.rec.Label ,
            fromValue:  this.rec.From_Value__c,
            toValue: this.rec.To_Value__c,
            fromUOM: this.rec.From_UOM__c,
            toUOM: this.rec.To_UOM__c,
        })
            .then(result => {
                // Handle success or perform any necessary actions
                this.newUoM= false;
                this.editUoM= false;
                this.rec.Label='';
                this.rec.From_Value__c='';
                this.rec.To_Value__c='';
                this.rec.From_UOM__c='';
                this.rec.To_UOM__c='';
                //this.statusMessage = result;
                console.log('UOM Conversion created successfully:', result);
                //this.handleRefreshComponent();
                const event = new ShowToastEvent({
                    title: 'Success!',
                    variant: 'success',
                    message:
                        'Meta data created successfully! Please refresh the page',
                });
                this.dispatchEvent(event);
                console.log('is it working?', JSON.stringify(this.uomConversions));
                return refreshApex(this.wiredUOMConversions);
            })
            .catch(error => {
                this.newUoM= false;
                //this.statusMessage = 'Error during deployment: ' + error.body.message;
                // Handle errors or display error messages
                console.error('Error creating UOM Conversion:', error);
                const event = new ShowToastEvent({
                    title: 'Error!',
                    variant: 'error',
                    message:  'Meta data creation failed',
                });
                this.dispatchEvent(event);
            });
        }
    }
    handleeditSave() {
        console.log('Inside edit handle save');
        console.log('this.rec.From_UOM__c',this.rec.From_UOM__c);
        console.log('this.rec.To_UOM__c', this.rec.To_UOM__c,);
				let errorLabel = false;
				const specialCharacterRegex = /[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]/;
        if (specialCharacterRegex.test(this.rec.Label)) {
						errorLabel = true;  
				}
				let sameLabel = false;
				let uomList = this.uomConversions;
				for(var x in uomList){
						if(uomList[x].Id != this.uomId){
								if(uomList[x].MasterLabel == this.rec.Label) sameLabel = true;
						}
				}
				if (
            !this.rec.Label || 
            !this.rec.From_Value__c || 
            !this.rec.To_Value__c || 
            !this.rec.From_UOM__c || 
            !this.rec.To_UOM__c
        ){
            const event = new ShowToastEvent({
                title: 'Warning!',
                variant: 'warning',
                message:
                    'Enter Required Fields',
            });
            this.dispatchEvent(event);   
        }else if(sameLabel == true){
						 const event = new ShowToastEvent({
                title: 'Warning!',
                variant: 'warning',
                message:
                    'UoM with same name already exists!',
            });
            this.dispatchEvent(event);
				}else if(errorLabel == true){
						 const event = new ShowToastEvent({
                title: 'Warning!',
                variant: 'warning',
                message:
                    'Name cannot include special characters!',
            });
            this.dispatchEvent(event);
				}else{
				this.editUoM = false;
        updateUoM({
            id: this.devName,
            Label: this.rec.Label,
            fromValue: this.rec.From_Value__c,
            toValue: this.rec.To_Value__c,
            fromUOM: this.rec.From_UOM__c,
            toUOM: this.rec.To_UOM__c,
        })
            .then(result => {
                
                this.newUoM= false;
                console.log('UOM Conversion created successfully:');
               // this.handleRefreshComponent();
                const event = new ShowToastEvent({
                    title: 'Success!',
                    variant: 'success',
                    message:
                        'Meta data updated successfully! Please refresh the page',
                });
                this.dispatchEvent(event);
                return refreshApex(this.wiredUOMConversions);
            })
            .catch(error => {
                this.newUoM= false;
                
                console.error('Error creating UOM Conversion:', error);
                const event = new ShowToastEvent({
                    title: 'Warning!',
                    variant: 'warning',
                    message:
                        'Meta data update failed',
                });
                this.dispatchEvent(event);
            });
				}
    }
}