import { LightningElement ,wire,track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex'; 
import getPOlist from'@salesforce/apex/MulitplePOtoBill.getPOlist';
import fetchChannelandDC from'@salesforce/apex/MulitplePOtoBill.fetchChannelandDC';
import createLogistics from'@salesforce/apex/MulitplePOtoBill.createLogistics';
import updateLogistics from'@salesforce/apex/MulitplePOtoBill.updateLogistics';
import getNext from '@salesforce/apex/MulitplePOtoBill.getNext';
import getPrevious from '@salesforce/apex/MulitplePOtoBill.getPrevious';
import TotalRecords from '@salesforce/apex/MulitplePOtoBill.TotalRecords';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery';
import bootStrap from '@salesforce/resourceUrl/bootStrap';
import BankReconcile from '@salesforce/resourceUrl/BankReconcile';
import SLDS from '@salesforce/resourceUrl/SLDS';
import CMP_CSS from '@salesforce/resourceUrl/CMP_CSS';
import ProjectWorkbench from '@salesforce/resourceUrl/ProjectWorkbench';
export default class MulitplePOtoBill extends LightningElement {
		@track lstAllFiles = [];
		@track isLoading = false;
		@track searchKey = '';
		@track recordId = '';
		@track DChannelId = '';
		@track SelectedVandorId = '';
		@track ofVal = 0;
		@track limit = 10;
		@track  currChannel='';
		@track  currVendor='';
		@track  CurrDCId='';
		@track  CurrVendorId='';
		@track  qryDCId='';
		@track  currOrg='';
		@track  orgFilter=' ERP7__Account_Type__c = \''+'Organisation'+'\'';
		@track  qryVendorId='';
		@track  qryVendorContactId='';
		@track  qryVendorAddressId='';
		@api  showtab2 = false;
		@api  fromAp = false;
		@track  Bill = {Id: '',ERP7__Vendor__c:'', Name:'', ERP7__Organisation__c: '',ERP7__Vendor_Contact__c:'', ERP7__Vendor_Address__c : '', ERP7__Vendor_Bill_Number__c:'', ERP7__Vendor_Bill_Date__c:'', ERP7__Due_Date__c : ''};
		@track  logline = [];
		@track  catline = [];
		@track purchaseList = [];
		@track disablebtn = true;
		@track v_TotalRecords;
		@track pageSize = 10;
		@track pageNumber = 1;
		@track totalRecords = 0;
		@track totalPages = 0;
		@track recordEnd = 0;
		@track recordStart = 0;
		@track isPrev = true;
		@track isNext = true;
		@track ChannelSelected = false;
		@track DCSelected = false; 
		@track VendorSelected = false;
		@track showMmainSpin = false;
		@track Nolineitems = true;
		@api SelectedSalesOrderList = [];
		@api selectedPRLIid = [];
		@api selectedDemLIid = [];
		@track cols = [  
				{label:'Name',fieldName:'Name', type:'text'},  
				{label:'Total qty',fieldName:'ERP7__Total_Quantity__c', type:'Integer'},  
				{label:'Total Line Items',fieldName:'ERP7__Count_PO_Line_Items__c', type:'Integer'},
				{label:'Vendor',fieldName:'ERP7__Vendor__r.Name', type:'Text'},
				{label:'Vendor Contact',fieldName:'ERP7__Vendor_Contact__r.Name', type:'Text'},

		];
		@track  logcols = [  
				{label:'Name',fieldName:'Name', type:'text'},  
				{label:'Product',fieldName:'ERP7__Product__c', type:'text'},  
				{label:'Qty',fieldName:'ERP7__Quantity__c', type:'Integer'},
				{label:'Version',fieldName:'ERP7__Production_Version__c', type:'Text'},


		];
		@track message = 'No records to display'
		// @wire (getPOlist,{searchString: '$searchKey',DcId: '$DChannelId',Offset : '$ofVal',RecordLimit : '$limit'}) purchaseList;
		@wire(getPOlist, { searchString: '$searchKey',DcId: '$DChannelId',Offset : '$ofVal',RecordLimit : '$limit', venId : '$CurrVendorId' })
		wiredActivities({ error, data }) {
				console.log('data : ',data); 
				this.isLoading = true;

				if (data) 
				{
						let result = data;

						console.log('inside if result : ',result);
						var emptylst = [];
						if(data == emptylst || result.POlist.length == 0){
								this.purchaseList = undefined;
								console.log('inside else 1 if');
								this.isLoading = false;
								this.dispatchEvent(
										new ShowToastEvent({
												message: 'Sorry, No Records to display!! ',
												variant: "error"
										})
								);
						}
						else{

								this.purchaseList = result.POlist;
								this.v_TotalRecords = result.recsize;/* data.map(
										record => Object.assign(
												{ "ERP7__Vendor__r.Name": record.ERP7__Vendor__r.Name, "ERP7__Vendor_Contact__r.Name": record.ERP7__Vendor_Contact__r.Name},
												record
										)
								);*/
								this.isLoading = false;
						}


				}

				else if (error) {
						console.log('inside else 2 if');
						this.error = error;
						this.purchaseList = undefined;
						this.dispatchEvent(
								new ShowToastEvent({
										message:  error.body.message+' '+error.stack +' '+error.name,
										variant: "error"
								})
						);
						this.isLoading = false;
				}
		}
		
		
		renderedCallback() {

				Promise.all([
						loadScript(this, jQuery + '/js/jquery_3.5.0.min.js'),
						loadStyle(this, bootStrap + '/css/bootstrap-4.1.css'),
						loadStyle(this, BankReconcile + '/css/font-awesome.css'),
						loadStyle(this, SLDS + '/assets/styles/salesforce-lightning-design-system-vf.min.css'),
						loadStyle(this, SLDS + '/assets/styles/salesforce-lightning-design-system-vf.css'),
						loadStyle(this, ProjectWorkbench + '/css/main-style.css'),
						loadStyle(this, CMP_CSS + '/CSS/global-axolt.css'),
				])
						.then(() => {
						console.log('Files loaded.', this.fromAp);
						if(this.fromAp){
								this.fromAp = false;
								this.createlogistic()
						}
						
				})
						.catch(error => {
						console.log(error.body.message);
				});
		}
		
		handleUploadFinished(event) {
        // Get the list of uploaded files
        const lstUploadedFiles = event.detail.files;
        lstUploadedFiles.forEach(fileIterator => this.lstAllFiles.push(fileIterator.name));
    }
		
	
		connectedCallback() {

				fetchChannelandDC().then(res => {
						this.currChannel =res.channel;
						this.currVendor = res.vendor;
						this.CurrVendorId = res.vendor.Id;
						this.CurrDCId = res.distributionChannel;
						this.qryVendorId = ' ERP7__Account_Type__c = \''+'Vendor'+'\'';
						console.log('this.currChannel fetchChannelandDC: '+this.currChannel);

						console.log('this.CurrDCId fetchChannelandDC: '+JSON.stringify(this.CurrDCId));
						this.DChannelId=res.DchId;
						this.ChannelSelected = true;
						this.DCSelected = true;
						this.VendorSelected = true;
						console.log('this.DChannelId : '+this.DChannelId);
						return refreshApex(this.currChannel);
				})
						.catch(error => {
						this.dispatchEvent(
								new ShowToastEvent({
										message: error.body.message+' '+error.stack +' '+error.name,
										variant: "error"
								})
						);
				});
				TotalRecords({DCId :this.DChannelId}).then(result=>{
						this.v_TotalRecords = result;
				});
				/* if(this.DChannelId != null && this.DChannelId != ''){
      console.log('this.DChannelId after if: '+this.DChannelId);

      getPOlist({searchString: this.searchKey,DcId: this.DChannelId,Offset : this.ofVal,RecordLimit : this.limit}
        ).then(res => {
      console.log('getPOlist res : '+res.length);
      this.purchaseList=res;
      console.log('getPOlist res data: ',res);

      console.log('getPOlist res this.purchaseList : ',this.purchaseList);
      })
    .catch(error => {
      this.dispatchEvent(
      new ShowToastEvent({
          message: error.body.message+' '+error.stack +' '+error.name,
          variant: "error"
        })
      );
    });
    }
    else{
      console.log('this.DChannelId after else: '+this.DChannelId);
      this.DChannelId = '';
      getPOlist({searchString: this.searchKey,DcId: this.DChannelId,Offset : this.ofVal,RecordLimit : this.limit}
        ).then(res => {
      console.log('getPOlist res : '+res.length);

        this.purchaseList=res;


      console.log('getPOlist res data: ',res.data.map);

      console.log('getPOlist res this.purchaseList : ',this.purchaseList);
      return refreshApex(this.purchaseList);
      })
    .catch(error => {
      this.dispatchEvent(
      new ShowToastEvent({
          message: error.body.message+' '+error.stack +' '+error.name,
          variant: "error"
        })
      );
    });
    }*/

		}
		handleKeyChange(event){
				this.searchKey = event.target.value;
				console.log('event.target.value : ',this.searchKey);
				//this.ofVal = integer.valueOf(10);
				console.log('this.ofVal : ',this.ofVal);
				//this.limit = integer.valueOf(10);
				console.log('this.limit : ',this.limit);

				console.log('this.DChannelId : ',this.DChannelId);
				return refreshApex(this.searchKey);
				/* getPOlist({searchString: this.searchKey,DcId: this.DChannelId,Offset : this.ofVal,RecordLimit : this.limit}
      ).then(respose => {
    console.log('handleKeyChange res : '+respose.length);
    if(respose.length > 0){
      this.purchaseList=respose;
      console.log('handleKeyChange purchaseList : ',this.purchaseList);
      return refreshApex(this.purchaseList);
    }  
    else{
      this.dispatchEvent(

        new ShowToastEvent({
            message: 'No Records To Display',
            variant: "warning"
          })
        );
        this.purchaseList=null;
        return refreshApex(this.purchaseList);
    }
    })
  .catch(error => {
    this.dispatchEvent(

    new ShowToastEvent({
        message: error.body.message+' '+error.stack +' '+error.name,
        variant: "error"
      })
    );
    //this.purchaseList = null;
  });
*/
		}
		showWarningToast() {
				const evt = new ShowToastEvent({
						title: 'Toast Warning',
						message: '$message',
						variant: 'warning',
						mode: 'dismissable'
				});
				this.dispatchEvent(evt);
		}
		showWarningToast(){
				this.message = '';
		}
		onChannelSelect(event){
				console.log('onChannelSel called : ',event.detail);
				var selectId =event.detail.Id;
				console.log('this.currChannel : ',this.currChannel);
				var selectName = event.detail.Name;
				console.log('selectId : ',selectId,' NAme : ',selectName);
				this.currChannel = {Id: selectId,Name : selectName};
				console.log('this.currchannel : ',this.currChannel);
				this.qryDCId = ' ERP7__Channel__c = \''+this.currChannel.Id+'\'';//'ERP7__Channel__c =/' '+this.currChannel;
				console.log('qryDCId : ',this.qryDCId);
		}
		onDCSel(event){
				var selectId =event.detail.Id;
				console.log('this.currChannel : ',this.currChannel);
				var selectName = event.detail.Name;
				console.log('selectId : ',selectId,' NAme : ',selectName);
				this.CurrDCId = {Id: selectId,Name : selectName};
				console.log('this.currchannel : ',this.currChannel);
				this.DChannelId = selectId;
				//this.CurrDCId=event.detail.selectedValue;
				// console.log('CurrDCId onDCSel: ',this.CurrDCId);
				console.log('this.DChannelId onDCSel: ',this.CurrDCId);
				return refreshApex(this.DChannelId);
				/*getPOlist({searchString: this.searchKey,DcId: this.DChannelId,Offset : this.ofVal,RecordLimit : this.limit}
  ).then(results => {
      console.log('onDCSel res : '+results.length);
      console.log('onDCSel results : ',results);
      this.purchaseList=results;
      console.log('onDCSel purchaseList : ',this.purchaseList);
      return refreshApex(this.purchaseList);
     // this.purchaseList=results;
    //console.log('onDCSel purchaseList : ',this.purchaseList);
    //return refreshApex(this.purchaseList); 
  })
  .catch(error => {
      this.dispatchEvent(
      new ShowToastEvent({
          message: error.body.message+' '+error.stack +' '+error.name,
          variant: "error"
        })
      );
    });*/
		}

		onVendorSel(event){
				var selectId =event.detail.Id;
				console.log('this.currVednor : ',this.currVendor);
				this.Bill.ERP7__Vendor__c = selectId;
				this.CurrVendorId = selectId;
				var selectName = event.detail.Name;
				console.log('selectId : ',selectId,' NAme : ',selectName);
				this.CurrVendor = {Id: selectId,Name : selectName};
				console.log('this.currchannel : ',this.CurrVendorId);
				this.qryVendorContactId = ' AccountId = \''+selectId+'\'';
				this.qryVendorAddressId = ' ERP7__Customer__c = \''+selectId+'\'';
				//this.CurrDCId=event.detail.selectedValue;
				// console.log('CurrDCId onDCSel: ',this.CurrDCId);
				return refreshApex(this.CurrVendor);
				/*getPOlist({searchString: this.searchKey,DcId: this.DChannelId,Offset : this.ofVal,RecordLimit : this.limit}
  ).then(results => {
      console.log('onDCSel res : '+results.length);
      console.log('onDCSel results : ',results);
      this.purchaseList=results;
      console.log('onDCSel purchaseList : ',this.purchaseList);
      return refreshApex(this.purchaseList);
     // this.purchaseList=results;
    //console.log('onDCSel purchaseList : ',this.purchaseList);
    //return refreshApex(this.purchaseList); 
  })
  .catch(error => {
      this.dispatchEvent(
      new ShowToastEvent({
          message: error.body.message+' '+error.stack +' '+error.name,
          variant: "error"
        })
      );
    });*/
		}

		fields = ["Name"];
		displayFields = 'Name';

		selectAll(event){
				var checked = event.getSource().get("v.checked");
				console.log('checked : ',checked);
				if(checked){
						var boxpackval = this.template.querySelector('[data-id="boxpack"]');



				}
		}
		createlogistic(event){
				try {
						console.log('createlogistic called');
						//var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();  
						//if(selectedRecords.length > 0) {this.disablebtn = false; }
						console.log('selectedRecords.length : ',this.SelectedSalesOrderList.length);
						console.log('selectedRecords : ',this.SelectedSalesOrderList);
						//console.log('Vendor-->', result.bill);
						if(this.SelectedSalesOrderList.length  > 0){
								this.isLoading = true;
								console.log('inside if');
								createLogistics({'POLst':JSON.stringify(this.SelectedSalesOrderList)}).then(result=>{  
										console.log('result : ',result);
										this.showtab2 = true;
										this.Bill = result.bill;
										this.Bill.ERP7__Vendor__c = result.bill.ERP7__Vendor__c;
										this.SelectedVandorId = result.vendorName;
										this.Bill.ERP7__Organisation__c = result.bill.ERP7__Organisation__c;
										this.currOrg = result.Org;
										this.logline = result.lineWrapper;
										this.catline = result.options;
										this.isLoading = false;
										return refreshApex(this.purchaseList);  
								})  
										.catch(error=>{  

										console.log('could not create logistic',error);  
										this.isLoading = false;
								}) 
						}
						else if(this.SelectedSalesOrderList.length == 0){
								console.log('inside else');
								this.dispatchEvent(

										new ShowToastEvent({
												message: 'Please select Records to proceed!!',
												variant: "warning"
										})
								);
								this.isLoading = false; 
						}  
				} catch (error) {
						console.log('error 2'+JSON.stringify(error));
				}


		}
		navigateToRecordPage() {
				this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
								recordId: '$recordId',
								objectApiName: 'ERP7__Logistic__c',
								actionName: 'view'
						}
				});
		}
		NavRecord(event){
				console.log('NavRecord called : ',event.detail );
				var RecId =event.target.title;
				console.log('RecId : '+RecId);
				this.recordId = RecId;
				var RecUrl = "/lightning/r/ERP7__Logistic__c/" + RecId + "/view";
				window.open(RecUrl,'_blank');
		}
		NavRecordPO(event){
				console.log('NavRecord called : ',event.detail );
				var RecId =event.target.title;
				console.log('RecId : '+RecId);
				this.recordId = RecId;
				var RecUrl = "/lightning/r/ERP7__PO__c/" + RecId + "/view";
				window.open(RecUrl,'_blank');
		}
		previousHandler2(){
				this.isLoading = true;
				getPrevious({v_Offset: this.ofVal, v_pagesize: this.limit}).then(result=>{
						console.log('result : ',result);  
						this.ofVal = result;
						if(this.ofVal === 0){
								this.template.querySelector('c-do-pagination').changeView('trueprevious');
								this.template.querySelector('c-do-pagination').changeView('falsenext');
								this.isLoading = false;
						}else{
								this.template.querySelector('c-do-pagination').changeView('falsenext');
								this.isLoading = false;
						}
				});
		}
		nextHandler2(){
				this.isLoading = true;
				getNext({v_Offset: this.ofVal, v_pagesize: this.limit}).then(result=>{
						this.ofVal = result;
						console.log('this.ofVal : ',this.ofVal);
						console.log('this.v_TotalRecords : ',this.v_TotalRecords);
						console.log('this.Limit : ',this.limit);
						if(this.ofVal + this.limit > this.v_TotalRecords){
								this.template.querySelector('c-do-pagination').changeView('truenext');
								this.template.querySelector('c-do-pagination').changeView('falseprevious');
								this.isLoading = false;
						}else{
								this.template.querySelector('c-do-pagination').changeView('falseprevious');
								this.isLoading = false;
						}
				});
		}

		changeHandler2(event){
				this.isLoading = true;
				console.log('changeHandler2 calles');
				const det = event.detail;
				console.log('det : ',det);
				this.limit = det;
				return refreshApex(this.limit);
				this.isLoading = false;
		}
		firstpagehandler(){
				this.ofVal = 0;
				this.template.querySelector('c-do-pagination').changeView('trueprevious');
				this.template.querySelector('c-do-pagination').changeView('falsenext');
		}
		lastpagehandler(){
				this.ofVal = this.v_TotalRecords - (this.v_TotalRecords)%(this.limit);
				console.log('this.offVal : '+this.ofVal);
				this.template.querySelector('c-do-pagination').changeView('falseprevious');
				this.template.querySelector('c-do-pagination').changeView('truenext');
		}
		setvaluebarcode(event){
				var value= event.target.value;
				console.log('value : ',value);
				this.log.ERP7__Logistic_Barcode__c = value;
		}
		setvaluedate(event){
				var value= event.target.value;
				console.log('value : ',value);
				this.Bill.ERP7__Vendor_Bill_Date__c = value;
		}
		setduedate(event){
				var value= event.target.value;
				console.log('value : ',value);
				this.Bill.ERP7__Due_Date__c = value;
		}
		setBillNumber(event){
				var value= event.target.value;
				console.log('value : ',value);
				this.Bill.ERP7__Vendor_Bill_Number__c = value;
		}
		
		updateLogistic(event){
				this.isLoading = true;
				console.log('log : ',this.Bill);
				var validation = true;
				if(this.Bill.ERP7__Vendor_Contact__c == null || this.Bill.ERP7__Vendor_Contact__c == undefined){
						this.dispatchEvent(

								new ShowToastEvent({
										message: 'Please select the Vendor Contact!',
										variant: "error"
								})
						);
						this.isLoading = false;
						return refreshApex(this.Bill);
						validation = false;
						
						return;
				}
				
				
				
				if(this.Bill.ERP7__Vendor_Bill_Number__c == null || this.Bill.ERP7__Vendor_Bill_Number__c == undefined){
						this.dispatchEvent(

								new ShowToastEvent({
										message: 'Please  Enter the  Vendor Bill Number!',
										variant: "error"
								})
						);
						this.isLoading = false;
						return refreshApex(this.Bill);
						validation = false;
						
						return;
				}
				
				if(this.Bill.ERP7__Organisation__c == null || this.Bill.ERP7__Organisation__c == undefined){
						this.dispatchEvent(

								new ShowToastEvent({
										message: 'Please select the Organisation!',
										variant: "error"
								})
						);
						this.isLoading = false;
						return refreshApex(this.Bill);
						validation = false;
						
						return;
				}
				
				if(this.Nolineitems){
						this.dispatchEvent(

								new ShowToastEvent({
										message: 'Please select the Line Items!',
										variant: "error"
								})
						);
						this.isLoading = false;
						return refreshApex(this.Bill);
						
						return;
				}
				
				if(this.lstAllFiles.length <= 0){
						this.dispatchEvent(

								new ShowToastEvent({
										message: 'Please add the Attachments!',
										variant: "error"
								})
						);
						this.isLoading = false;
						return refreshApex(this.Bill);
						
						return;
				}
				
				
				//console.log('log : ',this.log.Name);
				updateLogistics({'Logistic' : this.Bill, 'LOLI':JSON.stringify(this.selectedPRLIid),  'VendorId':this.currVendor.Id}).then(result=>{
						this.Bill = result;
						this.dispatchEvent(

								new ShowToastEvent({
										message: 'Bill Created Successfully!',
										variant: "success"
								})
						);
						//return refreshApex(this.Bill);
						this.isLoading = false;
						var url = '/'+this.Bill.Id;
            window.location.replace(url);
						/*this[NavigationMixin.Navigate]({
								type: 'standard__recordPage',
								attributes: {
										recordId: this.Bill.Id,
										objectApiName: 'ERP7__Bill__c',
										actionName: 'view'
								}
						});*/
				})
						.catch(error=>{  
						this.isLoading = false;
						console.log('could not create Bill'+JSON.stringify(error));  
				}) 
		}
		navigatetoInbound(){
				var RecUrl = "/lightning/n/ERP7__Logistics_Inbound";// + RecId + "/view";
				window.open(RecUrl,'_blank');
		}
		viewRecord(event){
				console.log(event.detail.action.name);
				console.log(event.detail.row.name);
				console.log(event.detail.row.Id);
				var RecId = event.detail.row.Id;
				var RecUrl = "/lightning/r/ERP7__PO__c/" + RecId + "/view";
				window.open(RecUrl,'_blank');
		}
		removeClicked(event){
				this.currChannel = '';
				this.ChannelSelected = false;
				//this.removeSelectedDC(event);
				return refreshApex(this.currChannel);
		}

		removeClickedVendor(event){
				this.currVendor = '';
				this.VendorSelected = false;
				//this.removeSelectedDC(event);
				return refreshApex(this.currVendor);
		}
		
		selectContact(event) {
        console.log('selectAccount called : ', JSON.stringify(event.detail));
        this.Bill.ERP7__Vendor_Contact__c = event.detail.Id;
    }
		
		
		selectAddress(event) {
        console.log('selectAccount called : ', JSON.stringify(event.detail));
        this.Bill.ERP7__Vendor_Address__c = event.detail.Id;
    }
		
		selectOrg(event) {
        console.log('selectAccount called : ', JSON.stringify(event.detail));
        this.Bill.ERP7__Organisation__c = event.detail.Id;
    }
		
		
		removeSelectedDC(event){
				console.log('removeSelectedDC This.currChannel : '+this.currChannel);
				this.CurrDCId = '';
				this.DCSelected = false;
				this.qryDCId = ' ERP7__Channel__c = \''+this.currChannel.Id+'\'';//'ERP7__Channel__c =/' '+this.currChannel;
				console.log('removeSelectedDC qryDCId : ',this.qryDCId);
				return refreshApex(this.CurrDCId);
		}
		navigatetohome(){
				var returl = '/lightning/n/ERP7__Purchase_Orders_to_Bill';
				window.open(returl,'_parent');

		}
		getSelected(event){
				var val = event.target.title;
				console.log('val : ',val);
				var checkval = event.target.checked;
				console.log('checkval : ',checkval);
				if(this.SelectedSalesOrderList == null || this.SelectedSalesOrderList == undefined || this.SelectedSalesOrderList == ''){
						this.SelectedSalesOrderList = [];
				}
				let selectedlst = this.SelectedSalesOrderList;
				console.log('selectedlst : ',selectedlst);
				if(!checkval){
						for(let x in this.selectedlst){
								console.log(this.selectedlst[x]);
								if(this.selectedlst[x].Id === val){
										console.log('value match in selected');
										selectedlst.splice(x,1);
								}
						}
				}
				else if(checkval){
						console.log('inside checvl');
						let selectedlst = [];
						for(let acc in this.purchaseList){
								console.log(this.purchaseList[acc].Id);
								if(this.purchaseList[acc].Id === val){
										console.log('value match : ',this.purchaseList[acc]);
										this.SelectedSalesOrderList.push(val);
										console.log('this.SelectedSalesOrderList : ',this.SelectedSalesOrderList);
								}
						}
						console.log('selectedlst : ',selectedlst);
						//this.SelectedSalesOrderList = selectedlst;
						console.log('this.SelectedSalesOrderList length : ',this.SelectedSalesOrderList.length);
						console.log('this.SelectedSalesOrderList  : ',this.SelectedSalesOrderList);
						return refreshApex(this.SelectedSalesOrderList);
				}
		}
		
		
		
		selectAll(event){
				console.log('event.target.checked callled');
				var checked = event.target.checked; //event.getSource().get("v.checked");
				console.log('checked : ',checked);

				var boxpackval = this.template.querySelectorAll('[data-id="boxpack"]');
				for (const toggleElement of boxpackval) {
						toggleElement.checked = event.target.checked;
				}
				if(checked){
						this.logline.forEach(element => {
								this.selectedPRLIid.push(element.billItem);
								this.selectedDemLIid.push(element.Allocations);
						});
				}
				else{
						this.selectedPRLIid = [];
						this.selectedDemLIid = [];
				}
				if(!checked) this.Nolineitems = true;
				else this.Nolineitems = false;
				this.updateBillTaxAmount(event);
				console.log(this.selectedPRLIid.length);

		}
		
		
		
		updateBillTaxAmount(event){
				  let amount = 0;
				  let tax = 0;
					for( var i = 0; i < this.selectedPRLIid.length; i++){ 
							 amount = amount + this.selectedPRLIid[i].ERP7__Quantity__c * this.selectedPRLIid[i].ERP7__Amount__c;
							 if(this.selectedPRLIid[i].ERP7__Tax_Amount__c!=undefined || this.selectedPRLIid[i].ERP7__Tax_Amount__c != null ) tax = tax + this.selectedPRLIid[i].ERP7__Tax_Amount__c;
							 
					}
				  this.Bill.ERP7__Amount__c = amount;
				  this.Bill.ERP7__VAT_TAX_Amount__c = tax;
				  this.Bill.ERP7__Discount_Amount__c = 0;
				  this.Bill.ERP7__Total_Amount__c = amount + tax;
		}
		
		
		selectsingle(event){
				let checkedval =  event.target.checked;
				console.log(checkedval);
				if(checkedval){
						let checkedlst =event.currentTarget.dataset.record;
						let index = event.target.name;
						for( var i = 0; i < this.logline.length; i++){ 
								console.log(this.logline[i]);
								if ( i == index) {
										this.selectedPRLIid.push(this.logline[i].billItem);
								}
						}
				}
				else if(!checkedval){
						let checkedlst = event.currentTarget.dataset.recordId;
						console.log('checkedlst : ',checkedlst);
						let index = event.target.name;
						console.log('index : ',index);
						//this.template.querySelectorAll('[data-id="CheckAll"]').checked = false;
						console.log(this.selectedPRLIid);
						for( var i = 0; i < this.selectedPRLIid.length; i++){ 
								console.log(this.selectedPRLIid[i]);
								if ( i == index) {

										this.selectedPRLIid.splice(i, 1); 
								}

						}

						console.log(this.selectedPRLIid);
				}
				if(this.selectedPRLIid.length == 0) this.Nolineitems = true;
				else this.Nolineitems = false;
				this.updateBillTaxAmount(event);
				return refreshApex(this.selectedPRLIid);
		}
		
		
		updateBillQuantity(event){
				var checkedlst =event.currentTarget.dataset.record;
				
				for( var i = 0; i < this.logline.length; i++){ 
						console.log(this.logline[i]);
						if ( this.logline[i].billItem.ERP7__Purchase_Order_Line_Items__c === checkedlst) {
								    let qty =  event.currentTarget.value;
										this.logline[i].billItem.ERP7__Quantity__c = qty;
								    this.logline[i].billItem.ERP7__Total_Amount__c = this.logline[i].billItem.ERP7__Quantity__c * this.logline[i].billItem.ERP7__Amount__c - this.logline[i].billItem.ERP7__Discount__c;
						}
				}
				/*if(this.selectedPRLIid.length > 0){
						for( var i = 0; i < this.selectedPRLIid.length; i++){ 
								var inte = this.selectedPRLIid[i];
								alert(inte.ERP7__Purchase_Order_Line_Items__c);
								for( var j = 0; j < this.logline.length; j++){ 
										if ( this.logline[j].billItem === this.selectedPRLIid[i]) {
												alert('called');
												let sumTotal = this.logline[j].ERP7__Total_Amount__c;
								    }
								}
						}
						//alert(sumTotal);
						//this.Bill.ERP7__Amount__c = sumTotal;
				}*/
				this.updateBillTaxAmount(event);
				return refreshApex(this.logline);
		}
		
		
		updateBillAmount(event){
				var checkedlst =event.currentTarget.dataset.record;
				
				for( var i = 0; i < this.logline.length; i++){ 
						console.log(this.logline[i]);
						if ( this.logline[i].billItem.ERP7__Purchase_Order_Line_Items__c === checkedlst) {
								    let amount =  event.currentTarget.value;
										this.logline[i].billItem.ERP7__Amount__c = amount;
								    this.logline[i].billItem.ERP7__Total_Amount__c = this.logline[i].billItem.ERP7__Quantity__c * this.logline[i].billItem.ERP7__Amount__c - this.logline[i].billItem.ERP7__Discount__c;
						}
				}
				this.updateBillTaxAmount(event);
				return refreshApex(this.logline);
		}
		
		
		updateBillDiscount(event){
				var checkedlst =event.currentTarget.dataset.record;
				
				for( var i = 0; i < this.logline.length; i++){ 
						console.log(this.logline[i]);
						if ( this.logline[i].billItem.ERP7__Purchase_Order_Line_Items__c === checkedlst) {
								    let dis =  event.currentTarget.value;
										this.logline[i].billItem.ERP7__Discount__c = dis;
								    this.logline[i].billItem.ERP7__Total_Amount__c = this.logline[i].billItem.ERP7__Quantity__c * this.logline[i].billItem.ERP7__Amount__c - this.logline[i].billItem.ERP7__Discount__c;
						}
				}
				this.updateBillTaxAmount(event);
				return refreshApex(this.logline);
		}
		
		updateBillTax(event){
				var checkedlst =event.currentTarget.dataset.record;
				
				for( var i = 0; i < this.logline.length; i++){ 
						console.log(this.logline[i]);
						if ( this.logline[i].billItem.ERP7__Purchase_Order_Line_Items__c === checkedlst) {
								    let taxper =  event.currentTarget.value;
										this.logline[i].billItem.ERP7__Tax_Rate__c = taxper;
								    this.logline[i].billItem.ERP7__Tax_Amount__c = (this.logline[i].billItem.ERP7__Total_Amount__c * taxper)/100;
						}
				}
				this.updateBillTaxAmount(event);
				return refreshApex(this.logline);
		}
		
		updateBillTaxPer(event){
				var checkedlst =event.currentTarget.dataset.record;
				
				for( var i = 0; i < this.logline.length; i++){ 
						console.log(this.logline[i]);
						if ( this.logline[i].billItem.ERP7__Purchase_Order_Line_Items__c === checkedlst) {
								    let tax =  event.currentTarget.value;
										this.logline[i].billItem.ERP7__Tax_Amount__c = tax;
								    this.logline[i].billItem.ERP7__Tax_Rate__c = (this.logline[i].billItem.ERP7__Tax_Amount__c / this.logline[i].billItem.ERP7__Total_Amount__c) * 100;
						}
				}
				this.updateBillTaxAmount(event);
				return refreshApex(this.logline);
		}
		
		
		

}