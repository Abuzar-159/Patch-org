({
	doInit : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var defaultOrg = component.get("c.DefaultOrganisation");	
        defaultOrg.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.Organisation",response.getReturnValue());
                $A.enqueueAction(component.get("c.fetchInvoice"));
            }  
        });
        $A.enqueueAction(defaultOrg);
        
        
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
            case 'Expenses':
                $A.enqueueAction(component.get("c.fetchExpense"));
                 break;
           default:
        }
    }, 
    
    
    fetchInvoice : function(component, event, helper) {
        component.set("v.selectedTab",'Invoices');
        var action=component.get("c.fetchInvoices");
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
        $A.enqueueAction(action);
    },
    
    fetchBill : function(component, event, helper) {
        component.set("v.selectedTab",'Bills');
        var action=component.get("c.fetchBills");
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
        $A.enqueueAction(action);
    },
    
    fetchPayment : function(component, event, helper) {
        component.set("v.selectedTab",'Payments');
        var action=component.get("c.fetchPayments");
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
        $A.enqueueAction(action);
    },
    
    
    fetchCreditNote: function(component, event, helper) {
        component.set("v.selectedTab",'Credit_notes');
        var action=component.get("c.fetchCreditNotes");
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
        $A.enqueueAction(action);
    },
    
    
    fetchDebitNote: function(component, event, helper) {
        component.set("v.selectedTab",'Credit_Debit_notes');
        var action=component.get("c.fetchDebitNotes");
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
        $A.enqueueAction(action);
    },
    
    fetchExpense : function(component, event, helper) {
        component.set("v.selectedTab",'Expenses');
        var action=component.get("c.fetchExpenses");
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
        $A.enqueueAction(action);
    },
    
})