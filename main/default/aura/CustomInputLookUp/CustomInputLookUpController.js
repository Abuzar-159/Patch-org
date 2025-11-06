({
    doInit : function(component,event,helper){
        //console.log('customInputLookUp doInit called component.get("v.selectedRecordId") : ',component.get("v.selectedRecordId"));
        if(component.get("v.selectedRecord") != null){        	
        }
        if(component.get("v.objectAPIName") == "OrderItem") component.set("v.SearchField","OrderItemNumber");
        //if((!$A.util.isEmpty(component.get("v.selectedRecordId")) && !$A.util.isUndefined(component.get("v.selectedRecordId"))) || (!$A.util.isEmpty(component.get("v.selectedRecord")) && $A.util.isUndefined(component.get("v.selectedRecord")))){
        
        if((!$A.util.isEmpty(component.get("v.selectedRecordId")) && !$A.util.isUndefined(component.get("v.selectedRecordId"))) && ($A.util.isEmpty(component.get("v.selectedRecord")) || $A.util.isUndefined(component.get("v.selectedRecord")))){ 
            //console.log('customInputLookUp doInit In If');
            helper.fetchRecordById(component,event);
            
        }
        else if((!$A.util.isEmpty(component.get("v.selectedRecordId")) && !$A.util.isUndefined(component.get("v.selectedRecordId")))){
            //console.log('customInputLookUp doInit In Else');
            helper.fetchRecordById(component,event);
        }
        
        if(($A.util.isEmpty(component.get("v.selectedRecordId")) || $A.util.isUndefined(component.get("v.selectedRecordId")))){//&& ($A.util.isEmpty(component.get("v.selectedRecord")) || $A.util.isUndefined(component.get("v.selectedRecord")))           
            //console.log('customInputLookUp doInit calling clearAll');
            component.clearAll();
            //$A.get('e.force:refreshView').fire();
            //console.log('component.get("v.selectedRecordId") after: ',component.get("v.selectedRecordId"));
            try {
                //console.log('fromFlow : ',component.get("v.fromFlow"));
                if(component.get("v.fromFlow")){
                    var errmsg = 'Please Complete Required information';
                    component.set('v.validate',function(){
                        if(component.get("v.required") && !component.get("v.selectedRecordId")){
                            return{ isValid : false, errorMessage : errmsg}
                        }
                    });
                }
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
        //console.log('customInputLookUp onSelectedChange called');
        var selectedAccountGetFromEvent = component.get("v.selectedRecord");
        for(var x in selectedAccountGetFromEvent){
            if(x === component.get("v.SearchField")){
                component.set("v.NameValue" , selectedAccountGetFromEvent[x]);
                component.set("v.selectedRecordId",selectedAccountGetFromEvent['Id']);
                break;
            }
        }
    },

    
   

    
   handleValueChange: function (component, event, helper) {
        // Fire the onChange action if defined
        const onChangeAction = component.get("v.onChange");
        if (onChangeAction) {
            console.log("Firing onChange action...");
            $A.enqueueAction(onChangeAction);
        } else {
            console.warn("No onChange action defined!");
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
            //console.log('customInputLookUp clear called');
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
            //console.log('selectedAccountGetFromEvent~>',selectedAccountGetFromEvent);
            
           // if(!$A.util.isUndefined(selectedAccountGetFromEvent)){
           // Update this line by Saqlain khan, so that the  clear method with null/undefined safety checks before trying to set fields:
           if (selectedAccountGetFromEvent && !$A.util.isUndefined(selectedAccountGetFromEvent)) {

                //console.log('inhere1');
                for(var x in selectedAccountGetFromEvent){
                    if(x === component.get("v.SearchField")){
                        //console.log('inhere2');
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
        //console.log('CustomInputLookUp handleComponentEvent called');
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
                //console.log('CustomInputLookUp handleComponentEvent selectedRecordId setting~>'+selectedAccountGetFromEvent['Id']);
                component.set("v.selectedRecordId",selectedAccountGetFromEvent['Id']);
                component.set("v.errors",null);
                break;
            }
        }
        //console.log('CustomInputLookUp handleComponentEvent selectedRecord setting~>'+record);
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
        console.log('chgval : ',chgval);
        if(chgval){
            component.clearAll();
            //component.initialise();
            //$A.get('e.force:refreshView').fire();
        }
    },
    CreateNewPopup : function(component, event, helper){
        try{
            
            var objname = component.get('v.APIName');
            console.log('objname : ',objname);
            var defaultvalues = component.get('v.defaultvalues');
            console.log('defaultvalues : ',JSON.stringify(defaultvalues));
            
            //Changed made by Arshad 15/06/2023
            var recordTypeId = '';
            if(!$A.util.isEmpty(defaultvalues) && !$A.util.isUndefinedOrNull(defaultvalues)){
                if(!$A.util.isUndefinedOrNull(defaultvalues.RecordTypeId)){
                    if(!$A.util.isEmpty(defaultvalues.RecordTypeId)){
                        recordTypeId = defaultvalues.RecordTypeId;
                    }
                }
            }
            console.log('arsh recordTypeId~>'+recordTypeId);
            
            
            var windowHash = window.location;
            if(recordTypeId != '' && recordTypeId != null && recordTypeId != null){
                var createRecordEvent = $A.get("e.force:createRecord");
                console.log('createRecordEvent 1:',createRecordEvent);
                if(!$A.util.isUndefined(createRecordEvent)){
                    var createEvent = $A.get("e.force:createRecord");
                    createEvent.setParams({
                        "entityApiName": objname,
                        'defaultFieldValues' : defaultvalues,
                        'recordTypeId' : recordTypeId,
                        "navigationLocation" : "LOOKUP",
                        "panelOnDestroyCallback": function(event) {
                            var navigateEvent = $A.get("e.force:navigateToComponent");           
                            navigateEvent.setParams({
                                componentDef : component.get('v.cmpName'),
                                componentAttributes: {
                                    'QueryRecentRecord':true,
                                    'ObjectAPIName':objname,
                                    'FieldToAssign':component.get("v.FieldValue"),
                                    'PO':component.get("v.POC"),
                                    'poli' : component.get("v.PoliItems"),
                                    'showPOType' : false,
                                }
                            });
                            navigateEvent.fire();
                        }
                        
                    });                
                    createEvent.fire(); 
                }
            }
            else{
                var createRecordEvent = $A.get("e.force:createRecord");
                console.log('createRecordEvent:',createRecordEvent);
                if(!$A.util.isUndefined(createRecordEvent)){
                    var createEvent = $A.get("e.force:createRecord");
                    createEvent.setParams({
                        "entityApiName": objname,
                        'defaultFieldValues' : defaultvalues,
                        "navigationLocation" : "LOOKUP",
                        "panelOnDestroyCallback": function(event) {
                            var navigateEvent = $A.get("e.force:navigateToComponent");           
                            navigateEvent.setParams({
                                componentDef : component.get('v.cmpName'),
                                componentAttributes: {
                                    'QueryRecentRecord':true,
                                    'ObjectAPIName':objname,
                                    'FieldToAssign':component.get("v.FieldValue"),
                                    'PO':component.get("v.POC"),
                                    'poli' : component.get("v.PoliItems"),
                                    'showPOType' : false,
                                }
                            });
                            navigateEvent.fire();
                        }
                        
                    });                
                    createEvent.fire(); 
                }  
            }
            
        }
        catch(e){console.log('Lookup Error:',e);} 
    },
    
})