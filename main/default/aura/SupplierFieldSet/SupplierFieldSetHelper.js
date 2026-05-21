({
     retrievePageLayout : function(component, helper) {
        var action = component.get("c.getPageLayoutMetadata");
        var pageLayoutName = component.get("v.PageLayoutName");
 

        var actionParams = {
            "pageLayoutName" : pageLayoutName
        };

        action.setParams(actionParams);
        action.setCallback(this, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var pageLayout = response.getReturnValue();
                
                component.set("v.PageLayout", pageLayout);
                component.set("v.recordIds",true);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getpurchaseOrderLineItems : function(component,event){
        var action = component.get("c.getPOLis");
        action.setParams({
            "recordId" : component.get("v.RecordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                component.set("v.POList",response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getFieldsSetApiNameHandler : function(component,objectApiName,fieldSetApiName){
        var action = component.get("c.getFieldsSetApiName2");
        action.setParams({
            sObjectName : objectApiName,
            fieldSetApiName :fieldSetApiName});
        action.setCallback(this,function(response){
           // if(objectApiName==='ERP7__Purchase_Line_Items__c')
            component.set("v.poFields",response.getReturnValue());
            var poFields=[];
            poFields=component.get("v.poFields");
            component.set("v.length",poFields.length);
            
        });
        $A.enqueueAction(action);
    },
    
	 getRelatedId : function(component,objectApiName,relationship){
        var action = component.get("c.RelatedList");
        action.setParams({
            	"RecordId" : component.get("v.RecordId"),
            	sObjectName : objectApiName,
                relationship :relationship
            });
        action.setCallback(this,function(response){
             component.set("v.RelatedId",response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
        
    
})