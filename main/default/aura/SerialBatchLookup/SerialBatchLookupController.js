({
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
    handleComponentEvent : function(component, event, helper) {
     var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent);
        component.set("v.AllowNew",true);
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
})