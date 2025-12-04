({
    doInit : function(component, event, helper) {
        console.log('SupplierPortalCommHome called');
        console.log('AccId from SupplierPortalCommHome',component.get("v.AccId"));
        //component.set("v.AccId",event.getParam("AccId"));
        component.set("v.PortalUser", true);
    },
    
    purchaseOrder : function(component, event, helper) {
        $A.createComponent( "c:SupplierPortalPO", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);        
            }
        });
    }, 
    
    poBills :function(component, event, helper){
        $A.createComponent( "c:SupplierPortalBills", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);        
            }
        });
    }, 
    
    payments : function(component, event, helper){
        $A.createComponent( "c:SupplierPortalPayments", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);        
            }
        });
    },
    
    poRFPs : function(component, event, helper){
        console.log('SupplierPortalCommHome RFP called');
        //var action=component.get("c.fetchAllDetails");
        $A.createComponent("c:SupplierRequests",{
            currentSupplier : component.get("v.AccId"),
            fromSite : true,
        },function(newCmp, status, errorMessage){
            if (component.isValid() && status === "SUCCESS") {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);
            }
            else{
                
            }
        });
    }, 
    
    workOrders : function(component, event, helper){
        $A.createComponent( "c:SupplierPortalWO", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);        
            }
        });
    }, 
  
    expense : function(component, event, helper){
        $A.createComponent( "c:SupplierPortalExpense", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);        
            }
        });
    }, 
    
    timesheets : function(component, event, helper){
        $A.createComponent( "c:SupplierPortalTimesheets", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);        
            }
        });
    },
    
    contracts : function(component, event, helper){
        $A.createComponent( "c:SupplierPortalContracts", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);        
            }
        });
    }
})