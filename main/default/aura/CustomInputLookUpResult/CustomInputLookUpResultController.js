({
    doInit : function(component,event,helper){
        var selectedAccountGetFromEvent = component.get("v.oRecord");
        
        for(var x in selectedAccountGetFromEvent){
            if(x === component.get("v.SearchField")){
                //console.log('CustomInputResult : ',JSON.stringify(selectedAccountGetFromEvent[x]));
                component.set("v.NameValue" , selectedAccountGetFromEvent[x]);
                break;
            }
        }
    },
    
    selectRecord : function(component, event, helper){      
        // get the selected record from list  
        var getSelectRecord = component.get("v.oRecord");
        //console.log('CustomInputResult getSelectRecord~>'+JSON.stringify(getSelectRecord));
        // call the event   
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.  
        compEvent.setParams({"recordByEvent" : getSelectRecord });  
        // fire the event  
        compEvent.fire();
    },
})