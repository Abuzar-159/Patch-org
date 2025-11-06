({
	doInit : function(cmp, event, helper) {
        
        var action=cmp.get("c.fetchOrderLines");
        action.setParams({
            salesId : cmp.get("v.salesId"),
            invoiceId : cmp.get("v.invoiceId")
        });
        action.setCallback(this,function(response){
            var state=response.getState();	
            if(state=="SUCCESS"){
                var res=response.getReturnValue();
                
                if(cmp.get("v.salesId") != ''){
                	cmp.set("v.salesName",res.SalesOrder.Name);
                	cmp.set("v.listOfSOLI",res.Solis);    
                }
                if(cmp.get("v.invoiceId") != ''){
                    cmp.set("v.salesName",res.Invoice.Name);
                	cmp.set("v.listOfSOLI",res.Invlis);
                }
                cmp.set("v.errorMsg",res.errorMsg);
            }
        });
        $A.enqueueAction(action);
	},
    
    updateLine : function(cmp,event,helper){
        
        var action=cmp.get("c.updateSortOrder");
        action.setParams({
            listOfSOLI:JSON.stringify(cmp.get("v.listOfSOLI")),
            salesId : cmp.get("v.salesId"),
            invoiceId : cmp.get("v.invoiceId")
        });
        action.setCallback(this,function(response){
            var state=response.getState();	
            if(state=="SUCCESS"){
                if(response.getReturnValue() == '' && cmp.get("v.salesId") != ''){
                    var RecUrl = "/" + cmp.get("v.salesId");
                    window.open(RecUrl,'_Self');
                }
                if(response.getReturnValue() == '' && cmp.get("v.invoiceId") != ''){
                    var RecUrl = "/" + cmp.get("v.invoiceId");
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
        if(cmp.get("v.salesId") != '') RecUrl = "/" + cmp.get("v.salesId");
        if(cmp.get("v.invoiceId") != '') RecUrl = "/" + cmp.get("v.invoiceId");
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
        var listOfLineItems = cmp.get("v.listOfSOLI"); 
        var ShiftElement = listOfLineItems[DragIndex];
        listOfLineItems.splice(DragIndex, 1);                                          
        listOfLineItems.splice(indexVal, 0 , ShiftElement);
        cmp.set("v.listOfSOLI", listOfLineItems);
    },
})