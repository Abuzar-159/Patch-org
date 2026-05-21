({
    doInit : function(component,event,helper){
       
        var ik = component.get("v.selectedRecordId");
        var ikk = component.get("v.selectedRecord");
        if(component.get("v.selectedRecord") != null){        	
        }
        if(component.get("v.objectAPIName") == "OrderItem") component.set("v.SearchField","OrderItemNumber");
        //if((!$A.util.isEmpty(component.get("v.selectedRecordId")) && !$A.util.isUndefined(component.get("v.selectedRecordId"))) || (!$A.util.isEmpty(component.get("v.selectedRecord")) && $A.util.isUndefined(component.get("v.selectedRecord")))){
        
        if((!$A.util.isEmpty(component.get("v.selectedRecordId")) && !$A.util.isUndefined(component.get("v.selectedRecordId"))) && ($A.util.isEmpty(component.get("v.selectedRecord")) || $A.util.isUndefined(component.get("v.selectedRecord")))){ 
            //alert('In If');
            helper.fetchRecordById(component,event);
           
        }
        else if((!$A.util.isEmpty(component.get("v.selectedRecordId")) && !$A.util.isUndefined(component.get("v.selectedRecordId")))){
            //alert('In Else');
            helper.fetchRecordById(component,event);
        }
            
        if(($A.util.isEmpty(component.get("v.selectedRecordId")) || $A.util.isUndefined(component.get("v.selectedRecordId")))){//&& ($A.util.isEmpty(component.get("v.selectedRecord")) || $A.util.isUndefined(component.get("v.selectedRecord")))           
            component.clearAll();
            try { 
                //component.clearAll(); 
            } 
            catch(err) { 
                //alert("Exception : "+err.message);
                console.log('err.message :',err.message);
            }
        }
        /*
          if((!$A.util.isEmpty(component.get("v.selectedRecordId")) && !$A.util.isUndefined(component.get("v.selectedRecordId"))) || (!$A.util.isEmpty(component.get("v.selectedRecord")) && !$A.util.isUndefined(component.get("v.selectedRecord")))){
            helper.fetchRecordById(component,event);
        }
            
        if(($A.util.isEmpty(component.get("v.selectedRecordId")) || $A.util.isUndefined(component.get("v.selectedRecordId")))){//&& ($A.util.isEmpty(component.get("v.selectedRecord")) || $A.util.isUndefined(component.get("v.selectedRecord")))
            component.clearAll();
        }
        */
    },
    onSelectedChange : function(component,event,helper){
        //alert('onSelectedChange');
        var selectedAccountGetFromEvent = component.get("v.selectedRecord");
        for(var x in selectedAccountGetFromEvent){
            if(x === component.get("v.SearchField")){
                component.set("v.NameValue" , selectedAccountGetFromEvent[x]);
                component.set("v.selectedRecordId",selectedAccountGetFromEvent['Id']);
                break;
            }
        }
    },
   onfocus : function(component,event,helper){
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
    },
    keyPressController : function(component, event, helper) {        
       // get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
         
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
      try {
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      	 component.set("v.NameValue" , '');
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         var selectedAccountGetFromEvent = component.get("v.selectedRecord");
        if(!$A.util.isUndefined(selectedAccountGetFromEvent)){
            for(var x in selectedAccountGetFromEvent){
                if(x === component.get("v.SearchField")){
                    selectedAccountGetFromEvent[x] = '';
                    selectedAccountGetFromEvent['Id'] = '';
                    component.set("v.selectedRecordId",'');
                    break;
                }
            }
            component.set("v.selectedRecord",selectedAccountGetFromEvent);
        }
      }catch(err) {
           console.log('c:CustomInputLookUp->clear :',err);
        }
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
       var record =  component.get("v.selectedRecord");
       if(record === null || record === undefined )record = {};
	   //component.set("v.selectedRecord" , record);
        for(var x in selectedAccountGetFromEvent){
           if(x === component.get("v.SearchField")){
                component.set("v.NameValue" , selectedAccountGetFromEvent[x]);
               // var prop = '"'+x+'"';
                record[x] = selectedAccountGetFromEvent[x];
                record['Id'] = selectedAccountGetFromEvent['Id'];
                component.set("v.selectedRecordId",selectedAccountGetFromEvent['Id']);
                component.set("v.errors",null);
                break;
            }
        }
        component.set("v.selectedRecord" ,record);
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	},
  // automatically call when the component is done waiting for a response to a server request.  
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('iconspinner');
        $A.util.addClass(spinner, "slds-hide");    
    },
 // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        var spinner = component.find('iconspinner');
         $A.util.removeClass(spinner, "slds-hide");   
    },
    
    onblur : function (component, event, helper) {
        var forclose = component.find("searchRes");
         if(!component.get("v.showList")){
             $A.util.addClass(forclose, 'slds-is-close');
             $A.util.removeClass(forclose, 'slds-is-open');
         }
    },
    showList : function(component, event, helper){ 
        component.set("v.showList",true);
    },
    hideList : function(component, event, helper){ 
        component.set("v.showList",false);
    },
    clearval : function(component, event, helper){ 
    	var chgval = component.get('v.remove');
        if(chgval){
            component.clearAll();
            //component.initialise();
            //$A.get('e.force:refreshView').fire();
        }
    },
    
})