({
  doInit : function(cmp, event, helper) {
        var action=cmp.get("c.fetchOrderLines");
        action.setParams({purchaseId : cmp.get("v.purchaseId")});
        action.setCallback(this,function(response){
            var state=response.getState();  
            if(state=="SUCCESS"){
                var res=response.getReturnValue();
                if(cmp.get("v.purchaseId") != ''){
                  cmp.set("v.salesName",res.PurchaseOrder.Name);
                  cmp.set("v.listOfPOLI",res.Polis);    
                }
                cmp.set("v.errorMsg",res.errorMsg);
            }
        });
        $A.enqueueAction(action);
  },
    
    updateLine : function(cmp,event,helper){
        
        var listOfPOLI=cmp.get("v.listOfPOLI");
        for(var i in listOfPOLI){
            if(listOfPOLI[i].ERP7__Sort_Order__c=='' || listOfPOLI[i].ERP7__Sort_Order__c==undefined){
                cmp.set('v.errorMsg',$A.get('$Label.c.All_fields_are_mandatory'));
                return;
            }                
        }
        var action=cmp.get("c.updateSortOrder");
        action.setParams({
            listOfPOLI:JSON.stringify(cmp.get("v.listOfPOLI")),
            purchaseId : cmp.get("v.purchaseId")
        });
        action.setCallback(this,function(response){
            var state=response.getState();  
            if(state=="SUCCESS"){
                if(response.getReturnValue() == '' && cmp.get("v.purchaseId") != ''){
                    var RecUrl = "/" + cmp.get("v.purchaseId");
                    window.open(RecUrl,'_Self');
                }
            }            
        });
        $A.enqueueAction(action);
    },
    
    showSpinner: function(cmp, event, helper) {
        cmp.set("v.Spinner", true); 
    },
    
    hideSpinner : function(cmp,event,helper){
        cmp.set("v.Spinner", false);
    },
    
    closeError : function(cmp,event){
        cmp.set("v.errorMsg",'');
    },
    
    cancelLine: function(cmp,event,helper){
        var RecUrl = '';
        if(cmp.get("v.purchaseId") != '') RecUrl = "/" + cmp.get("v.purchaseId");
        window.open(RecUrl,'_Self');
    },
    
    handleDrag : function(cmp, event, helper) {
        cmp.set("v.DragIndex", event.target.id);
    },
    
    allowDrop : function(cmp, event, helper) {
        event.preventDefault();
    },
    
    handleDrop : function(cmp, event, helper) {        
        var DragIndex = parseInt(cmp.get("v.DragIndex"));
        var indexVal=parseInt(event.currentTarget.getAttribute('data-index'));
        var listOfLineItems = cmp.get("v.listOfPOLI"); 
        var ShiftElement = listOfLineItems[DragIndex];
        if($A.util.isUndefinedOrNull(ShiftElement)) return;
        listOfLineItems.splice(DragIndex, 1);                                          
        listOfLineItems.splice(indexVal, 0 , ShiftElement);
        cmp.set("v.listOfPOLI", listOfLineItems);
    },
    
})