({
	doInit : function(component, event, helper) {
        //component.set("v.showMmainSpin",true);
        /*var defaultOrg = component.get("c.DefaultOrganisation");	
        defaultOrg.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.Organisation",response.getReturnValue());
                $A.enqueueAction(component.get("c.fetchInvoice"));
            }  
        });
        $A.enqueueAction(defaultOrg);*/
        
        
        /*var action=component.get("c.fetchInvoices");
        alert('Organisation-->'+component.get("v.Organisation.Id"));
        action.setParams({
            "OrgId":component.get("v.Organisation.Id"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                component.set("v.StartDate",response.getReturnValue().StartDate);
                component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);*/
        if(component.get("v.fromAP") || component.get("v.fromAR") || component.get("v.fromCash")){
            $A.enqueueAction(component.get("c.switchTab"));
        }
    },
    
    hideModal : function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Accounts_Payable",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    hideModalCash : function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BankingOverview",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    hideModalReceivable : function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AccountsReceivable",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    switchTab : function(component,event,helper){
        component.set("v.showMmainSpin",true);
        var currentTab = component.get("v.selectedTab");
        switch(currentTab) {
            case 'Invoices':
                $A.enqueueAction(component.get("c.fetchInvoice"));
                 break;
            case 'Bills':
                $A.enqueueAction(component.get("c.fetchBill"));
                 break;
            case 'Payments':
                $A.enqueueAction(component.get("c.fetchPayment"));
                 break;
            case 'Credit_notes':
                $A.enqueueAction(component.get("c.fetchCreditNote"));
                 break;
            case 'Credit_Debit_notes':
                $A.enqueueAction(component.get("c.fetchDebitNote"));
                 break;
            default:
        }
    }, 
    
    
    fetchInvoice : function(component, event, helper) {
        component.set("v.selectedTab",'Invoices');
        var action=component.get("c.fetchInvoices");
        action.setParams({
            "customerVendorId":component.get("v.customerVendorId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    fetchBill : function(component, event, helper) {
        component.set("v.selectedTab",'Bills');
        var action=component.get("c.fetchBills");
        action.setParams({
            "customerVendorId":component.get("v.customerVendorId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    fetchPayment : function(component, event, helper) {
        component.set("v.selectedTab",'Payments');
        var action=component.get("c.fetchPayments");
        action.setParams({
            "customerVendorId":component.get("v.customerVendorId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    
    fetchCreditNote: function(component, event, helper) {
        component.set("v.selectedTab",'Credit_notes');
        var action=component.get("c.fetchCreditNotes");
        action.setParams({
            "customerVendorId":component.get("v.customerVendorId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    
    fetchDebitNote: function(component, event, helper) {
        component.set("v.selectedTab",'Credit_Debit_notes');
        var action=component.get("c.fetchDebitNotes");
        action.setParams({
            "customerVendorId":component.get("v.customerVendorId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    handledebitmenu: function(cmp,event,helper){
        var url = $A.get("$Label.c.Invoice_Document");
        url = url + 'custId=' + event.detail.menuItem.get("v.title")+'&name='+event.detail.menuItem.get("v.value");
        window.open(url, '_blank');
        
    },
    
    sendStatement : function(cmp,event,helper){
        var AccountStatementURL='/apex/ERP7__AccountsStatement?AccountId='+cmp.get("v.customerVendorId");
        window.open(AccountStatementURL,'_blank');
    }
    
    
})