import { LightningElement ,wire,track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
import getSOlist from'@salesforce/apex/SalesOrdersToaLogistic.getSOlist';
import fetchChannelandDC from'@salesforce/apex/MulitplePOtoLogistic.fetchChannelandDC';
import createLogistics from'@salesforce/apex/SalesOrdersToaLogistic.createLogistics';
import getNext from '@salesforce/apex/MulitplePOtoLogistic.getNext';
import getPrevious from '@salesforce/apex/MulitplePOtoLogistic.getPrevious';
//import TotalRecords from '@salesforce/apex/SalesOrdersToaLogistic.TotalRecords';
import updateLogistics from '@salesforce/apex/SalesOrdersToaLogistic.updateLogistics';
import getDC from '@salesforce/apex/SalesOrdersToaLogistic.getDC';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery';
import bootStrap from '@salesforce/resourceUrl/bootStrap';
import BankReconcile from '@salesforce/resourceUrl/BankReconcile';
import SLDS from '@salesforce/resourceUrl/SLDS';
import ProjectWorkbench from '@salesforce/resourceUrl/ProjectWorkbench';

export default class SalesOrdersToLogistic extends LightningElement {
@track ChannelSelected = false;
@track channelURL = '';
@track DCURL = '';
@track ACURL = '';
@track ConURL = '';
@track AddURL = '';
@track Nolineitems = false;
@track DCSelected = false;
@track isLoading = false;
@track pageSize = 10;
@track pageNumber = 1;
@track totalRecords = 0;
@track totalPages = 0;
@track recordEnd = 0;
@track recordStart = 0;
@track isPrev = true;
@track isNext = true;
@track searchKey = '';
@track ofVal = 0;
@track limit = 10;
@track  currChannel='';
@track  CurrDCId='';
@track  qryDCId='';
@track  showtab2 = false;
@track  StandardOrder = false;
@track  log = {};
@track  logline = [];
@track SalesOrderList = [];
 SelectedSalesOrderList = [];
@track v_TotalRecords;
@track v_selectedval;
selectedLIid = [];
@track currChannelId = '';
@track cols = [  
{label:'Name',fieldName:'Name', type:'text'},  
{label:'Total qty',fieldName:'ERP7__Total_Quantity__c', type:'Integer'},  
{label:'Total Line Items',fieldName:'ERP7__Total_Number_of_Items__c', type:'Integer'},
{label:'Account',fieldName:'ERP7__Account__r.Name', type:'Text'},
{label:'Vendor Contact',fieldName:'ERP7__Contact__r.Name', type:'Text'},
{label:'Ship To Address',fieldName:'ERP7__Ship_To_Address__r.Name', type:'Text'}
];
result;
/*@wire(getSOlist, { searchString: '$searchKey',ChannelId: '$currChannelId',Offset : '$ofVal',RecordLimit : '$limit' })
wiredActivities({ error, data }) {
  console.log('@wire getSOlist called');
this.isLoading = true;
console.log('data : ',data); 
//this.result = [];
this.result= JSON.stringify(data);
console.log('result : ',this.result);
console.log('result.chanel : ',this.result.channel);//

if (data) 
{
    console.log('inside if');
    var emptylst = [];
    let result = data;
    if(result == emptylst || result.SOlist.length == 0){
    this.SalesOrderList = undefined;
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
        console.log('inside else');
      
        this.SalesOrderList = result.SOlist;
        this.v_TotalRecords = result.recsize;
        console.log(this.v_TotalRecords);
        if(this.v_TotalRecords <= 10) {
          this.v_selectedval = this.v_TotalRecords;
          console.log('the value is less than 10');
          if(this.template.querySelector('c-do-pagination') != null) this.template.querySelector('c-do-pagination').changeView('truenext');
          
        }
        else{
          this.v_selectedval = 10;
          console.log('the value is greater than 10');
          if(this.template.querySelector('c-do-pagination') != null) this.template.querySelector('c-do-pagination').changeView('falsenext');
          
        }
        this.isLoading = false;//.map(
        record => Object.assign(
    { "ERP7__Account__r.Name": record.ERP7__Account__r.Name, "ERP7__Contact__r.Name": record.ERP7__Contact__r.Name,"ERP7__Ship_To_Address__r.Name":record.ERP7__Ship_To_Address__r.Name},
    record
        )
            );//
            console.log('inside else this.SalesOrderList : ',this.SalesOrderList);
    }
    
    
}

else if (error) {
console.log('inside else 2 if');
    this.error = error;
    this.purchaseList = undefined;
    this.isLoading = false;
    this.dispatchEvent(
        new ShowToastEvent({
            message:  error.body.message+' '+error.stack +' '+error.name,
            variant: "error"
        })
        );
    
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
  this.isLoading = true;
  fetchChannelandDC().then(res => {
    this.currChannel =res.channel;
    this.CurrDCId = res.distributionChannel;
    console.log('this.currChannel fetchChannelandDC: '+this.currChannel);
    this.channelURL = '/'+ this.currChannel.Id;
    console.log('this.CurrDCId fetchChannelandDC: '+JSON.stringify(this.CurrDCId));
    this.DChannelId=res.DchId;
    this.DCURL = '/' + this.CurrDCId.Id;
    this.ChannelSelected = true;
    this.DCSelected = true;
    console.log('this.DChannelId : '+this.DChannelId);
    this.isLoading = false;
    return refreshApex(this.currChannel);

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
this.getSOdata();


}
getSOdata(){
    this.isLoading = true;
    getSOlist({searchString : this.searchKey,ChannelId : this.currChannelId,pageSize: this.pageSize, pageNumber : this.pageNumber})
    .then(result => {
      this.isLoading = false;
      if(result){
        var resultData = JSON.parse(result);
        this.SalesOrderList = resultData.SOlist;
        console.log('result SO data : ',resultData);
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
this.searchKey = event.target.value;
console.log('event.target.value : ',this.searchKey);
//this.ofVal = integer.valueOf(10);
console.log('this.ofVal : ',this.ofVal);
//this.limit = integer.valueOf(10);
console.log('this.limit : ',this.limit);

console.log('this.DChannelId : ',this.DChannelId);
this.getSOdata();
}
onChannelSelect(event){
console.log('onChannelSel called : ',event.detail);
var selectId =event.detail.Id;
console.log('this.currChannel : ',this.currChannel);
var selectName = event.detail.Name;
console.log('selectId : ',selectId,' NAme : ',selectName);
this.currChannel = {Id: selectId,Name : selectName};
console.log('this.currchannel : ',this.currChannel);
this.currChannelId = selectId;
this.qryDCId = ' ERP7__Channel__c = \''+this.currChannel.Id+'\'';//'ERP7__Channel__c =/' '+this.currChannel;
console.log('qryDCId : ',this.qryDCId);
getDC({'ChId': this.currChannel.Id}).then(result =>{
  console.log(result);
  if(result != null){
    this.CurrDCId = {Id: result.Id,Name : result.Name};
    console.log('this.CurrDCId : ',JSON.stringify(this.CurrDCId));
    this.DChannelId = result.Id;
    console.log('this.DChannelId onDCSel: ',this.DChannelId);
    this.DCSelected = true;
  }
  
}).catch(error=>{  
  console.log('getDC error : '+JSON.stringify(error));  
  this.isLoading = false;
}) 
this.getSOdata();
}
onDCSel(event){
var selectId =event.detail.Id;
console.log('selectId : ',selectId);
var selectName = event.detail.Name;
console.log('selectId : ',selectId,' Name : ',selectName);
if(selectId != null && selectId != undefined && selectId != ''){
  this.CurrDCId = {Id: selectId,Name : selectName};
  console.log('this.CurrDCId : ',JSON.stringify(this.CurrDCId));
  this.DChannelId = selectId;
  console.log('this.DChannelId onDCSel: ',this.DChannelId);
  this.DCSelected = true;
  return refreshApex(this.DChannelId);
}


}
fields = ["Name"];
displayFields = 'Name';

createlogistic(event){
try {
    console.log('createlogistic called');
    //var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();  
    //if(selectedRecords.length > 0) {this.disablebtn = false; }
    console.log('selectedRecords.length : ',this.SelectedSalesOrderList.length);
    // console.log('selectedRecords : ',selectedRecords);
    if(this.SelectedSalesOrderList.length > 0){
      this.isLoading = true;
      console.log('inside if');
    createLogistics({'SOList':JSON.stringify(this.SelectedSalesOrderList),'DCId': this.DChannelId}).then(result=>{  
        console.log('result : ',result);
        this.showtab2 = true;
        this.log = result.logistic;
       // this.logline = result.logisticlines;
        this.StandardOrder = result.StandardOrder;
        if(this.log.ERP7__Account__c) this.ACURL = '/' + this.log.ERP7__Account__c;
       
        if(this.log.ERP7__Contact__c)  this.ConURL = '/' + this.log.ERP7__Contact__c;
        if(this.log.ERP7__To_Address__c)  this.AddURL = '/' + this.log.ERP7__To_Address__c;
        let loglist = result.logisticlines;
       
        for(let x in loglist){
          if(this.StandardOrder) { if(loglist[x].ERP7__Order_Product__r.ERP7__Is_Back_Order__c == false) this.selectedLIid.push(loglist[x].ERP7__Order_Product__c);}
          else  { if(loglist[x].ERP7__Sales_Order_Line_Item__r.ERP7__Is_Back_Order__c == false) this.selectedLIid.push(loglist[x].ERP7__Sales_Order_Line_Item__c); }
          
          console.log('this.selectedLIid :  ',this.selectedLIid);
          if(loglist[x].ERP7__Quantity__c > 0 && loglist[x].ERP7__Price_Product__c > 0) loglist[x].Total = loglist[x].ERP7__Quantity__c * loglist[x].ERP7__Price_Product__c;
          else loglist[x].Total = 0;
          console.log('loglist total : ',loglist[x]);
        }
        if(this.selectedLIid.length == 0) this.Nolineitems = true;
        this.logline = loglist;
        this.isLoading = false;
        //console.log('logline : ',this.logline[0].ERP7__Product__r.Name);
        //console.log('logline : ',this.log.ERP7__Channel__r.Name);
        return refreshApex(this.SalesOrderList); 
         
      })  
      .catch(error=>{  
        console.log('could not create logistic'+JSON.stringify(error));  
        this.isLoading = false;
      }) 
    }
    else if(this.SelectedSalesOrderList.length == 0){
      console.log('inside else');
      this.isLoading = false;
      this.dispatchEvent(
    
        new ShowToastEvent({
            message: 'Please select Orders to proceed!!',
            variant: "warning"
          })
        );
        
    }  
} catch (error) {
    console.log('error 2'+JSON.stringify(error));
}


}
NavRecord(event){
console.log('NavRecord called : ',event.detail );
var RecId =event.target.title;
var Id = event.target.id;
console.log('RecId : '+RecId);
console.log('Id : '+Id+' length : ',Id.length);
if(Id.length > 18) Id = Id.substring(0,18);
console.log('Id : '+Id);
this.recordId = RecId;
var RecUrl = "/lightning/r/ERP7__Logistic__c/" + Id + "/view";
window.open(RecUrl,'_blank');
}
previousHandler2(){
this.isLoading = true;
getPrevious({v_Offset: this.ofVal, v_pagesize: this.limit}).then(result=>{
  console.log('result : ',result);  
  this.ofVal = result;
  console.log('this.ofVal : ',this.ofVal);
    if(this.ofVal == 0){
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
    if(this.ofVal + 10 > this.v_TotalRecords){
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
this.isLoading = false;
return refreshApex(this.limit);

}
updateLogistic(event){
  this.isLoading = true;
  console.log('log : ',this.log);
  console.log('logline : ',JSON.stringify(this.logline));
  console.log('selectedLIid : ',this.selectedLIid);
  if(this.selectedLIid.length == 0){
    this.dispatchEvent(

      new ShowToastEvent({
          message: 'Select Line Items to create Logistic!',
          variant: "warning"
      })
  );
  this.isLoading = false;
  }
  else{
    updateLogistics({'Logistic' : this.log,'SelectedLIs' : this.selectedLIid,'LOLI' : JSON.stringify(this.logline)}).then(result=>{
      //this.log = result;
      console.log(result);
      console.log(result.length);
      if(result == '' || result == null || result == undefined ||  result.length != 18){
        this.dispatchEvent(

          new ShowToastEvent({
              message: 'Error Occurred!'+result,
              variant: "error"
          })
      );
      this.isLoading = false;
      }
      else{
        this.dispatchEvent(

          new ShowToastEvent({
              message: 'Logistic Created Successfully!',
              variant: "success"
          })
      );
      this.isLoading = false;
      var RecUrl = "/lightning/r/ERP7__Logistic__c/" + result + "/view";
      window.open(RecUrl,'_parent');
      //return refreshApex(this.log);
      }
      
      
  })
      .catch(error=>{  
      this.isLoading = false;
      console.log('could not create logistic'+JSON.stringify(error));  
  })
  }
   
}
/*updateLogistic(event){
this.isLoading = true;
  updateLogistics({'Logistic' : this.log}).then(result=>{
    this.log = result;
    this.dispatchEvent(
    
        new ShowToastEvent({
            message: 'Logistic updated Successfully!',
            variant: "success"
          })
        );
    return refreshApex(this.log);
    this.isLoading = false;
  })
  .catch(error=>{  
    this.isLoading = false;
    console.log('could not create logistic'+JSON.stringify(error));  
  }) 
}*/
navigatetoOutbound(){
var RecUrl = "/lightning/n/ERP7__Logistics_Outbound";// + RecId + "/view";
window.open(RecUrl,'_parent');
}
navigatetohome(){
var returl = '/lightning/n/ERP7__Sales_Orders_to_a_Logistic';
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
}
else if(checkval){
  console.log('inside checvl');
  let selectedlst = [];
  for(let acc in this.SalesOrderList){
    console.log(this.SalesOrderList[acc].Id);
    if(this.SalesOrderList[acc].Id === val){
      console.log('value match : ',this.SalesOrderList[acc]);
      if(this.SalesOrderList[acc].ERP7__Is_Back_Order__c){
        this.dispatchEvent(

          new ShowToastEvent({
              message: 'The Selected Order has Back Ordered Items!!',
              variant: "warning"
          })
      );
      }
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
removeClicked(event){
this.currChannel = '';
this.ChannelSelected = false;
this.currChannelId = '';
//this.removeSelectedDC(event);
return refreshApex(this.currChannelId);
}
removeSelectedDC(event){
console.log('removeSelectedDC This.currChannel : '+this.currChannel);
this.CurrDCId = '';
this.DCSelected = false;
this.qryDCId = ' ERP7__Channel__c = \''+this.currChannel.Id+'\'';//'ERP7__Channel__c =/' '+this.currChannel;
console.log('removeSelectedDC qryDCId : ',this.qryDCId);
return refreshApex(this.CurrDCId);
}
setName(event){
	var value= event.target.value;
	console.log('value : ',value);
	this.log.Name = value;
}
verifySOLIQuantity(event){
  let qty =  event.currentTarget.value;
	console.log(qty);
	let SOliID =  event.currentTarget.dataset.recordId;
	console.log(SOliID);
	
	if(qty != undefined && qty != null && qty != '' && SOliID != undefined && SOliID != null && SOliID != ''){
		for(var c in this.logline){
      if(this.StandardOrder){
        if(this.logline[c].ERP7__Order_Product__c == SOliID){
          if(qty <= 0){
            this.logline[c].ERP7__Quantity__c = qty;
            this.dispatchEvent(
  
              new ShowToastEvent({
                  message: 'Quantity Should be greater than zero for : '+this.logline[c].Name,
                  variant: "warning"
              })
          );
          }
          else if(qty > this.logline[c].ERP7__Order_Product__r.Quantity){
            this.logline[c].ERP7__Quantity__c = this.logline[c].ERP7__Order_Product__r.Quantity;
            this.dispatchEvent(
  
              new ShowToastEvent({
                  message: 'Quantity cannot be greater than Line item qty : '+this.logline[c].ERP7__Order_Product__r.ERP7__Name__c,
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
      else{
        if(this.logline[c].ERP7__Sales_Order_Line_Item__c == SOliID){
          if(qty <= 0){
            this.logline[c].ERP7__Quantity__c = qty;
            this.dispatchEvent(
  
              new ShowToastEvent({
                  message: 'Quantity Should be greater than zero for : '+this.logline[c].Name,
                  variant: "warning"
              })
          );
          }
          else if(qty > this.logline[c].ERP7__Sales_Order_Line_Item__r.ERP7__Quantity__c){
            this.logline[c].ERP7__Quantity__c = this.logline[c].ERP7__Sales_Order_Line_Item__r.ERP7__Quantity__c;
            this.dispatchEvent(
  
              new ShowToastEvent({
                  message: 'Quantity cannot be greater than Line item qty : '+this.logline[c].ERP7__Sales_Order_Line_Item__r.Name,
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
  }
}
selectsingle(event){
	let checkedval =  event.target.checked;
	console.log(checkedval);
  let checkedlst = event.currentTarget.dataset.recordId;
  console.log('checkedlst : ',checkedlst);
	if(checkedval){
    console.log('if');
		this.selectedLIid.push(checkedlst);
		console.log(this.selectedLIid);
	}
	else if(!checkedval){
		//this.template.querySelectorAll('[data-id="CheckAll"]').checked = false;
		console.log('else');
		for( var i = 0; i < this.selectedLIid.length; i++){ 
console.log(this.selectedLIid[i]);
			if ( this.selectedLIid[i] === checkedlst) { 
		
				this.selectedLIid.splice(i, 1); 
			}
		
		}
		if(this.selectedLIid.length == 0) this.Nolineitems = true;
    else this.Nolineitems = false;
		console.log(this.selectedLIid);
	}
	return refreshApex(this.selectedLIid);
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
selectAll(event){
  let i; 
  var checkval = event.target.checked;
        let checkboxes = this.template.querySelectorAll('[data-id="boxpack"]')
        for(i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = checkval;
        }
        if(!checkval) this.Nolineitems = true;
        else this.Nolineitems = false;
}
goback(){
  this.showtab2 = false;
  this.SelectedSalesOrderList = [];
	console.log('This.SelectedSalesOrderList : ',this.SelectedSalesOrderList);
}
handleNext(){
	this.pageNumber = this.pageNumber+1;
	this.getSOdata();
}

//handle prev
handlePrev(){
	this.pageNumber = this.pageNumber-1;
	this.getSOdata();
}
get isDisplayNoRecords() {
	var isDisplay = true;
	if(this.SalesOrderList){
		if(this.SalesOrderList.length == 0){
			isDisplay = true;
		}else{
			isDisplay = false;
		}
	}
	return isDisplay;
}
refreshPage(){
  eval("$A.get('e.force:refreshView').fire();");
}
}