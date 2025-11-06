import { LightningElement, track, api} from "lwc";
import findRecords from "@salesforce/apex/InputLookUp.findRecords";
import fetchLookUpValues from "@salesforce/apex/InputLookUp.fetchLookUpValues";
export default class InputLookupWEB extends LightningElement {
@track recordsList;
@track searchKey = "";
@api selectedValue;
@api selectedRecordId;
@api objectApiName;
@api iconName;
@api lookupLabel;
@track message;
@api item;
@api qry='';
@api searchField='Name';


onLeave(event){
    try{
        this.searchKey = "";
        this.recordsList = null;
}catch(e){
    
    
    
}
}

onRecordSelection(event){
    try{
    this.selectedRecordId = event.target.dataset.key;
    this.selectedValue = event.target.dataset.name;
    var index=event.target.dataset.index;
    this.item=this.recordsList[index];
    this.searchKey = "";
    this.onSeletedRecordUpdate();
}catch(e){
    
    
}
}

handleKeyChange(event){
    try{
    const searchKey = event.target.value;
    this.searchKey = searchKey;
    this.getLookupResult();
}catch(e){
    
    
}
}

removeRecordOnLookup(event){
    try{
    this.searchKey = "";
    this.selectedValue = null;
    this.selectedRecordId = null;
    this.recordsList = null;
    this.item=null;
    this.onSeletedRecordUpdate();
}catch(e){
    
    
}
}


getLookupResult(){
    try{
        
        fetchLookUpValues({ searchKeyWord: this.searchKey, ObjectName : this.objectApiName, queryFilter:this.qry,SearchField: this.searchField })
    .then((result) => {
        if (result.length===0){
            this.recordsList = [];
            this.message = "No Records Found";
        }
        else{
            this.recordsList = result;
            this.message = "";
        }
        this.error = undefined;
    })
    .catch((error) => {
        this.error = error;
        this.recordsList = undefined;
    });

}catch(e){
    
}
}

onSeletedRecordUpdate(){
    try{
    const passEventr = new CustomEvent('recordselection',{
        detail:{
            selectedRecordId: this.selectedRecordId,
            selectedValue: this.selectedValue,
            item:this.item
        }
    });
    
    this.dispatchEvent(passEventr);
}catch(e){
    
}
}
}