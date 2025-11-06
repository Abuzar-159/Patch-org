import { LightningElement ,wire,track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex'; 
import getPOlist from'@salesforce/apex/MulitplePOtoLogistic.getPOlist';
import fetchChannelandDC from'@salesforce/apex/MulitplePOtoLogistic.fetchChannelandDC';
import createLogistics from'@salesforce/apex/MulitplePOtoLogistic.createLogistics';
import getNext from '@salesforce/apex/MulitplePOtoLogistic.getNext';
import getPrevious from '@salesforce/apex/MulitplePOtoLogistic.getPrevious';
import TotalRecords from '@salesforce/apex/MulitplePOtoLogistic.TotalRecords';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery';
import bootStrap from '@salesforce/resourceUrl/bootStrap';
import BankReconcile from '@salesforce/resourceUrl/BankReconcile';
import SLDS from '@salesforce/resourceUrl/SLDS';
import ProjectWorkbench from '@salesforce/resourceUrl/ProjectWorkbench';
import updateLogistics from '@salesforce/apex/MulitplePOtoLogistic.updateLogistics';
export default class MultiplePOtoLogistic extends LightningElement {
		@track isLoading = false;
		@track Nolineitems = false;
		@track channelURL = '';
		@track DCURL = '';
		@track ACURL = '';
		@track ConURL = '';
		@track pageSize = 10;
		@track pageNumber = 1;
		@track totalRecords = 0;
		@track totalPages = 0;
		@track recordEnd = 0;
		@track recordStart = 0;
		@track isPrev = true;
		@track isNext = true;
		@track searchKey = '';
		@track recordId = '';
		@track DChannelId = '';
		@track ofVal = 0;
		@track limit = 10;	
		@track  currChannel='';
		@track  CurrDCId='';
		@track  qryDCId='';
		@track  qryCon='';
		@track  showtab2 = false;
		@track  log = {Id: '',Name:'',ERP7__Logistic_Barcode__c : '',ERP7__Logistic_Expected_Date__c : ''};
		@track  logline = [];
		loglst = [];
		@track purchaseList = [];
		@track disablebtn = true;
		@track v_TotalRecords;
		@track v_selectedval;
		@track pageSize = 50;
		@track pageNumber = 1;
		@track totalRecords = 0;
		@track totalPages = 0;
		@track recordEnd = 0;
		@track recordStart = 0;
		@track isPrev = true;
		@track isNext = true;
		@track ChannelSelected = false;
		@track DCSelected = false;  
		SelectedSalesOrderList = [];
		selectedPRLIid = [];
	
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
		/*@wire(getPOlist, { searchString: '$searchKey',DcId: '$DChannelId',pageSize : '$pageSize',pageNumber : '$pageNumber'})
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
							this.pageNumber = result.pageNumber;
							this.totalRecords = result.totalRecords;
							this.recordStart = result.recordStart;
							this.recordEnd = result.recordEnd;
							this.totalPages = Math.ceil(result.totalRecords / this.pageSize);
							this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
							this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);// data.map(
										record => Object.assign(
												{ "ERP7__Vendor__r.Name": record.ERP7__Vendor__r.Name, "ERP7__Vendor_Contact__r.Name": record.ERP7__Vendor_Contact__r.Name},
												record
										)
								);//
								//console.log('this.v_TotalRecords : ',this.v_TotalRecords);
								
								if(this.v_TotalRecords <= 10) {
									this.v_selectedval = this.v_TotalRecords;
									this.template.querySelector('c-do-pagination').changeView('truenext');
									console.log('the value is less than 10');
								}
								else{
									this.v_selectedval = 10;
									this.template.querySelector('c-do-pagination').changeView('falsenext');
									console.log('the value is greater than 10');
								}//
								
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
		}*/

		renderedCallback() {

				Promise.all([
						loadScript(this, jQuery + '/js/jquery_3.5.0.min.js'),
						loadStyle(this, bootStrap + '/css/bootstrap-4.1.css'),
						loadStyle(this, BankReconcile + '/css/font-awesome.css'),
						loadStyle(this, SLDS + '/assets/styles/salesforce-lightning-design-system-vf.min.css'),
						loadStyle(this, SLDS + '/assets/styles/salesforce-lightning-design-system-vf.css'),
						loadStyle(this, ProjectWorkbench + '/css/main-style.css'),
				])
						.then(() => {
						console.log('Files loaded.');
				})
						.catch(error => {
						console.log(error.body.message);
				});
		}
		connectedCallback() {

				fetchChannelandDC().then(res => {
						this.currChannel =res.channel;
						this.channelURL = '/'+ this.currChannel.Id;
						this.CurrDCId = res.distributionChannel;
						console.log('this.currChannel fetchChannelandDC: '+this.currChannel);
						this.DCURL = '/' + this.CurrDCId.Id;
						console.log('this.CurrDCId fetchChannelandDC: '+JSON.stringify(this.CurrDCId));
						this.DChannelId=res.DchId;
						this.ChannelSelected = true;
						this.DCSelected = true;
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

				this.getPOdata();
				
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
		getPOdata(){
			this.isLoading = true;
			getPOlist({searchString : this.searchKey,DcId : this.DChannelId,pageSize: this.pageSize, pageNumber : this.pageNumber})
			.then(result => {
				this.isLoading = false;
				if(result){
					var resultData = JSON.parse(result);
					this.purchaseList = resultData.POlist;
					console.log(resultData);
					this.pageNumber = resultData.pageNumber;
					this.totalRecords = resultData.totalRecords;
					this.recordStart = resultData.recordStart;
					this.recordEnd = resultData.recordEnd;
					this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
					this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
					this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
				}
			})
			.catch(error => {
				this.isLoading = false;
				this.dispatchEvent(
					new ShowToastEvent({
						message: error.body.message+' '+error.stack +' '+error.name,
						variant: "error"
					  })
					);
			});
		}
		handleKeyChange(event){
			if(event.keyCode === 13){
				this.searchKey = event.target.value;
				console.log('event.target.value : ',this.searchKey);
				//this.ofVal = integer.valueOf(10);
				console.log('this.ofVal : ',this.ofVal);
				//this.limit = integer.valueOf(10);
				console.log('this.limit : ',this.limit);

				console.log('this.DChannelId : ',this.DChannelId);
				this.getPOdata();
			  }
				
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
		onAccSel(event){
			var selectId =event.detail.Id;
			var selectName = event.detail.Name;
			this.log.ERP7__Account__c = selectId;
			this.qryCon = 'AccountId = \''+this.log.ERP7__Account__c+'\'';
			console.log('qryCon : ',this.qryCon);
			
		}
		onconSel(event){
			var selectId =event.detail.Id;
			var selectName = event.detail.Name;
			this.log.ERP7__Contact__c = selectId;
			
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
				this.getPOdata();
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
	

		
		createlogistic(event){
				try {
						console.log('createlogistic called');
						//var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();  
						//if(selectedRecords.length > 0) {this.disablebtn = false; }
						console.log('selectedRecords.length : ',this.SelectedSalesOrderList.length);
						console.log('selectedRecords : ',this.SelectedSalesOrderList);
						if(this.SelectedSalesOrderList.length  > 0){
								this.isLoading = true;
								console.log('inside if');
								createLogistics({'POLst':JSON.stringify(this.SelectedSalesOrderList)}).then(result=>{  
										console.log('result : ',result);
										this.showtab2 = true;
										this.log = result.logistic;
										let loglist = result.logisticlines;
										for(let x in loglist){
											this.selectedPRLIid.push(loglist[x].ERP7__Purchase_Line_Items__c);
											console.log('this.selectedPRLIid :  ',this.selectedPRLIid);
											if(loglist[x].ERP7__Quantity__c > 0 && loglist[x].ERP7__Price_Product__c > 0) loglist[x].Total = loglist[x].ERP7__Quantity__c * loglist[x].ERP7__Price_Product__c;
											else loglist[x].Total = 0;
											console.log('loglist total : ',loglist[x]);
										}
										this.logline = loglist;
										if(this.log.ERP7__Account__c) this.ACURL = '/' + this.log.ERP7__Account__c;
										if(this.log.ERP7__Contact__c)  this.ConURL = '/' + this.log.ERP7__Contact__c;
										this.isLoading = false;
										if(this.selectedPRLIid.length == 0) this.Nolineitems = true;
										this.template.querySelectorAll('[data-id="CheckAll"]').checked = true;
										this.template.querySelectorAll('[data-id="checkbox"]').checked = true;
										console.log('checked : ',this.template.querySelectorAll('[data-id="CheckAll"]').checked);
										
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
												message: 'Please select Purchase orders to proceed!!',
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
				var Id = event.target.id;
				console.log('RecId : '+RecId);
				console.log('Id : '+Id+' length : ',Id.length);
				if(Id.length > 18) Id = Id.substring(0,18);
				this.recordId = Id;
				console.log('Id : '+Id);
				var RecUrl = "/lightning/r/ERP7__PO__c/" + Id + "/view";
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
				console.log(typeof(value));
				var today = new Date();
				var dd = String(today.getDate()).padStart(2, '0');
				var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
				var yyyy = today.getFullYear();
				today = yyyy  + '-' + mm  + '-' + dd;
				console.log(today);
				if(value < today){
					console.log('date is in past');
					this.dispatchEvent(

						new ShowToastEvent({
								message: 'Date cannot be in past',
								variant: "warning"
						})
				);
				this.log.ERP7__Logistic_Expected_Date__c = today;
				}
				else this.log.ERP7__Logistic_Expected_Date__c = value;
		}
		updateLogistic(event){
				this.isLoading = true;
				console.log('log : ',this.log);
				console.log('logline : ',JSON.stringify(this.logline));
				console.log('selectedPRLIid : ',this.selectedPRLIid);
				if(this.selectedPRLIid.length == 0){
					this.dispatchEvent(

						new ShowToastEvent({
								message: 'Select Line items to create a Logistic!',
								variant: "warning"
						})
				);
				this.isLoading = false;
				}
				else{
					updateLogistics({'Logistic' : this.log,'SelectedPRLIs' : this.selectedPRLIid,'LOLI' : JSON.stringify(this.logline)}).then(result=>{
						this.log = result;
						console.log(result);
						this.dispatchEvent(

								new ShowToastEvent({
										message: 'Logistic Created Successfully!',
										variant: "success"
								})
						);
						this.isLoading = false;
						var RecUrl = "/lightning/r/ERP7__Logistic__c/" + this.log.Id + "/view";
						window.open(RecUrl,'_parent');
						return refreshApex(this.log);
						
				})
						.catch(error=>{  
						this.isLoading = false;
						console.log('could not create logistic'+JSON.stringify(error));  
				}) 
				}
				
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
				this.template.querySelector(".DC").handleRemovePill();
				//this.removeSelectedDC(event);
				//return refreshApex(this.currChannel);
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
				var returl = '/lightning/n/ERP7__Purchase_Order_To_Logistic';
				window.open(returl,'_parent');

		}
		getSelected(event){
			var val = event.currentTarget.dataset.recordId;
			console.log('val : ',val);
			var checkval = event.target.checked;
			console.log('checkval : ',checkval);
			if(this.SelectedSalesOrderList == null || this.SelectedSalesOrderList == undefined || this.SelectedSalesOrderList == ''){
			  this.SelectedSalesOrderList = [];
			}
			let selectedlst = this.SelectedSalesOrderList;
console.log('selectedlst : ',selectedlst);
if(!checkval){
  for(let x in this.SelectedSalesOrderList){
    console.log(this.SelectedSalesOrderList[x]);
    if(this.SelectedSalesOrderList[x] === val){
      console.log('value match in selected');
      this.SelectedSalesOrderList.splice(x,1);
    }
}
		 this.purchaseList.forEach(element => {
            if(element.PO.Id === val){
                console.log(element.isSelected);
                element.isSelected = false;
            }
        });
        console.log(JSON.stringify(this.purchaseList));
}
else if(checkval){
  console.log('inside checvl');
  let selectedlst = [];
  for(let acc in this.purchaseList){
    console.log(this.purchaseList[acc].PO.Id);
    if(this.purchaseList[acc].PO.Id === val){
				this.purchaseList[acc].isSelected= true;
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

/*
selectAll(event) {
	let i;
	let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]');
	for(i=0; i<checkboxes.length; i++) {
		checkboxes[i].checked = event.target.checked;
	}
	var check = event.target.checked;
	if(check){
		this.logline.forEach(element => {
			this.selectedPRLIid.push(element.ERP7__Purchase_Line_Items__c);
		});
	}
	else{
		this.selectedPRLIid = [];
	}
	console.log(this.selectedPRLIid.length)
}*/
selectsingle(event){
	let checkedval =  event.target.checked;
	console.log(checkedval);
	if(checkedval){
		let checkedlst =event.currentTarget.dataset.recordId;
		console.log('checkedlst : ',checkedlst);
		this.selectedPRLIid.push(checkedlst);
		console.log(this.selectedPRLIid);
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
			if ( this.selectedPRLIid[i] === checkedlst) { 
		
				this.selectedPRLIid.splice(i, 1); 
			}
		
		}
		
		console.log(this.selectedPRLIid);
	}
	if(this.selectedPRLIid.length == 0) this.Nolineitems = true;
    else this.Nolineitems = false;
	return refreshApex(this.selectedPRLIid);
}
verifyQuantity(event){
	let qty =  event.currentTarget.value;
	console.log(qty);
	let POliID =  event.target.name;
	console.log(POliID);
	
	if(qty != undefined && qty != null && POliID != undefined && POliID != null){
		for(var c in this.logline){
			if(this.logline[c].ERP7__Purchase_Line_Items__c == POliID){
				console.log(this.logline[c].ERP7__Purchase_Line_Items__r.ERP7__Quantity__c);
				console.log(this.logline[c].ERP7__Purchase_Line_Items__r.ERP7__Logistic_Quantity__c);
				console.log(this.logline[c].ERP7__Quantity__c);
				if(qty <= 0){
					this.dispatchEvent(
		  
					  new ShowToastEvent({
						  message: 'Quantity Should be greater than zero for : '+this.logline[c].Name,
						  variant: "warning"
					  })
				  );
				  }
				  else if(qty > (this.logline[c].ERP7__Purchase_Line_Items__r.ERP7__Quantity__c  - this.logline[c].ERP7__Purchase_Line_Items__r.ERP7__Logistic_Quantity__c)){
					  console.log('qty is greater');
					this.dispatchEvent(
		  
						new ShowToastEvent({
							message: 'Quantity cannot exceed total Remainig Line item qty '+(this.logline[c].ERP7__Purchase_Line_Items__r.ERP7__Quantity__c  - this.logline[c].ERP7__Purchase_Line_Items__r.ERP7__Logistic_Quantity__c)+' for : '+this.logline[c].Name,
							variant: "warning"
						})
					);
				  }
				  else{
				this.logline[c].ERP7__Quantity__c = qty;
				if(qty > 0 && this.logline[c].ERP7__Price_Product__c > 0) this.logline[c].Total = qty * this.logline[c].ERP7__Price_Product__c;
				else this.logline[c].Total = 0;
				console.log('loglist total : ',this.logline[c].Total);
				  }
				
			}
			
		}
	}
	
	console.log('logline : ',JSON.stringify(this.logline));
	//this.logline = this.logline;
	return refreshApex(this.logline);
	
}
getupdatedval(event){
	let lst = event.target;
	console.log('getupdatedval :' ,lst);
}
setName(event){
	var value= event.target.value;
	console.log('value : ',value);
	if(value == '' || value == null || value == undefined){
		this.dispatchEvent(
			new ShowToastEvent({
				message: 'Please Enter the Name for Logistic',
				variant: "warning"
			})
		);
	}
	else{
		this.log.Name = value;
	}
	
}
goback(){
  this.showtab2 = false;
  

}
handleNext(){
	this.pageNumber = this.pageNumber+1;
	this.getPOdata();
}

//handle prev
handlePrev(){
	this.pageNumber = this.pageNumber-1;
	this.getPOdata();
}
get isDisplayNoRecords() {
	var isDisplay = true;
	if(this.purchaseList){
		if(this.purchaseList.length == 0){
			isDisplay = true;
		}else{
			isDisplay = false;
		}
	}
	return isDisplay;
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
						this.selectedPRLIid.push(element.ERP7__Purchase_Line_Items__c);
					});
				}
				else{
					this.selectedPRLIid = [];
				}
				if(!checked) this.Nolineitems = true;
				else this.Nolineitems = false;
				console.log(this.selectedPRLIid.length);
	
}
refreshPage(){
    eval("$A.get('e.force:refreshView').fire();");
	console.log('Re-Fresh');
}
setpagesize(event){
	var show = event.target.value;
	this.pageSize = show;
	console.log('page size : ',this.pageSize);
	this.getPOdata();
}

}