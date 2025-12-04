({
	fetchCustomerDetails : function(component, event, helper) {
        var stockTakeStatus = component.get("c.fetchAllCustomerReceivables");
        stockTakeStatus.setParams({
            ReceivableDate : component.get('v.Instance.transSdate')
        });
        stockTakeStatus.setCallback(this,function(response){
            component.set("v.CustomerReceivableWrap",response.getReturnValue());
        });
        $A.enqueueAction(stockTakeStatus);
	},
    
    fetchVendorDetails : function(component, event, helper) {
        var stockTakeStatus = component.get("c.fetchAllVendorPayables");
        stockTakeStatus.setParams({
            ReceivableDate : component.get('v.Instance.transSdate')
        });
        stockTakeStatus.setCallback(this,function(response){
            component.set("v.vendorPayableWrap",response.getReturnValue());
        });
        $A.enqueueAction(stockTakeStatus);
	},
    
    
})