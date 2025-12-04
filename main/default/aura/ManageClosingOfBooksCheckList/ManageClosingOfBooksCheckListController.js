({
    lookupChangeAccountingPeriod : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        let action = component.get("c.getAccountingAccountDetails");
        action.setParams({ 
            AccPeriodId: component.get("v.AP.Id")
        });
        action.setCallback(this,function(response){
            let resList = response.getReturnValue();
            component.set("v.AP.ERP7__Start_Date__c",resList.ERP7__Start_Date__c);
            component.set("v.AP.ERP7__End_Date__c",resList.ERP7__End_Date__c);
            component.set("v.AP.ERP7__Status__c",resList.ERP7__Status__c);
            //component.set("v.OrgId", resList.ERP7__Organisation__c);
            if(resList.ERP7__Start_Date__c!=undefined) $A.enqueueAction(component.get("c.doInit"));
            else{
                component.set("v.TransactionWrapper", []);
                component.set("v.unReconciledTransactions", []);
                component.set("v.AssetWrapper", []);
                component.set("v.ArWrapper", []);
                component.set("v.ApWrapper", []);
                component.set("v.IncomeExpenseWrapper", []);
                component.set("v.showMmainSpin",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    lookupClickOrg :function(component,helper){
        
        var acc = component.get("v.OrgId");
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = 'And ERP7__Organisation__c = \''+acc+'\'';
        component.set("v.qry",qry);
        component.set("v.AP.Id", null);
    },
    
    doInit : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        let accStatus = component.get("c.getStatus");
        accStatus.setCallback(this,function(response){
            let resList = response.getReturnValue();
            component.set("v.AccPeriodStatusoptions",resList);                
        });
        $A.enqueueAction(accStatus);
        $A.enqueueAction(component.get("c.fetchInvoice"));
    },
    
    showConfirmation : function(component, event, helper) {
        component.set("v.showDialog", true);
    },

    hideConfirmation : function(component, event, helper) {
        component.set("v.showDialog", false);
    },

    handleOK : function(component, event, helper) {
        // Handle the logic when OK is clicked
        component.set("v.showDialog", false);
        var action = component.get("c.updateAccountingStatus");
        action.setParams({ 
            accPeriod: component.get("v.AP")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast($A.get('$Label.c.Success'),'success','Successfully Updated Accounting Period Status');
                component.set("v.isStatusUnchanged", true);
            }else{
                var errors = response.getError();
                try{
                    if(errors != undefined && errors.length >0){
                        let err = errors[0].message;
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',err);
                    }
                }catch(e){ helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',errors[0].message); }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleStatusChange: function(component, event, helper) {
        var selectedStatus = component.find("poStatus").get("v.value");
        var currentStatus = component.get("v.AP.ERP7__Status__c");

        // Check if the status has changed
        if(selectedStatus === currentStatus){
            component.set("v.isStatusUnchanged", false);
        }
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
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
                console.log('Response-->',JSON.stringify(response.getReturnValue()));
                /*component.set("v.showMmainSpin",false);*/
            }  
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchBill : function(component, event, helper) {
        component.set("v.selectedTab",'Bills');
        var action=component.get("c.fetchBills");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
                /*component.set("v.showMmainSpin",false);*/
            }  
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchPayment : function(component, event, helper) {
        component.set("v.selectedTab",'Payments');
        var action=component.get("c.fetchPayments");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
                /*component.set("v.showMmainSpin",false);*/
            } 
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    
    fetchCreditNote: function(component, event, helper) {
        component.set("v.selectedTab",'Credit_notes');
        var action=component.get("c.fetchCreditNotes");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
            }  
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    
    fetchDebitNote: function(component, event, helper) {
        component.set("v.selectedTab",'Credit_Debit_notes');
        var action=component.get("c.fetchDebitNotes");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
            } 
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchExpense : function(component, event, helper) {
        component.set("v.selectedTab",'Expenses');
        var action=component.get("c.fetchExpenses");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
            }  
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchData : function(component,event,helper){
        component.set("v.showMmainSpin",true);
        var clickedCardId = event.currentTarget.getAttribute('data-id');
        var currentHighlightedId = component.get('v.highlightedCardId');

        // Remove highlight from the previously highlighted card
        var previousCard = component.find(currentHighlightedId);
        $A.util.removeClass(previousCard, 'activeppr');

        // Set the new highlighted card ID and highlight the clicked card
        component.set('v.highlightedCardId', clickedCardId);
        var clickedCard = component.find(clickedCardId);
        $A.util.addClass(clickedCard, 'activeppr');
        if(clickedCardId == 'unreconciledTrans'){
            $A.enqueueAction(component.get("c.fetchUnReconciledTransaction"));
        }
        if(clickedCardId == 'assetInventory'){
            $A.enqueueAction(component.get("c.fetchAsset"));
        }
        if(clickedCardId == 'AR'){
            $A.enqueueAction(component.get("c.fetchReceivable"));
        }
        if(clickedCardId == 'AP'){
            $A.enqueueAction(component.get("c.fetchPayable"));
        }
        if(clickedCardId == 'incomeRevenue'){
            $A.enqueueAction(component.get("c.fetchincomeRevenue"));
        }
        if(clickedCardId == 'pendingPost'){
            component.set("v.showMmainSpin",false);
        }
     },
    
    navigateToMyComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ClosingOfBooksCheckList",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    handleAdjustmentEntries : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AdjustmentEntries",
            componentAttributes: {
                AccoutingPeriod : component.get("v.AP"),
                FromClosing : true,
                COBOrgId : component.get("v.OrgId")
            }
        });
        evt.fire();
    },
    
    handleReconcilation : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ManageBankReconciliation",
            componentAttributes: {
                AccoutingPeriod : component.get("v.AP"),
                FromClosing : true,
                COBOrgId : component.get("v.OrgId")
            }
        });
        evt.fire();
    },
    
    fetchUnReconciledTransaction: function(component, event, helper) {
        var action=component.get("c.unReconciledTransactions");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.unReconciledTransactions",response.getReturnValue());
                component.set("v.showMmainSpin",false);
            }  
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchAsset: function(component, event, helper) {
        var action=component.get("c.assetInventory");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.AssetWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
            }  
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchReceivable: function(component, event, helper) {
        var action=component.get("c.Receivable");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.ArWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
            } 
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchPayable: function(component, event, helper) {
        var action=component.get("c.Payable");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.ApWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
            }  
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchincomeRevenue: function(component, event, helper) {
        var action=component.get("c.incomeRevenue");
        action.setParams({
            "OrgId":component.get("v.AP.ERP7__Organisation__c"),
            "StartDate":component.get("v.AP.ERP7__Start_Date__c"),
            "EndDate":component.get("v.AP.ERP7__End_Date__c")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.IncomeExpenseWrapper",response.getReturnValue());
                component.set("v.showMmainSpin",false);
            }  
            component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(action);
    },
    
    handleInvoicePost : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.getInvoiceUpdate");    
        action.setParams({
            "InvoiceId":event.detail.menuItem.get("v.value")             
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                try{ 
                    if(response.getReturnValue()==''){ 
                        helper.showToast('Success!','success','Successfully Posted !');
                        $A.enqueueAction(component.get("c.fetchInvoice"));
                    }else if(response.getReturnValue()!='' && response.getReturnValue()!=null){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',response.getReturnValue());
                        component.set("v.showMmainSpin",false);
                    }
                }catch(ex){
                     helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');   
                     component.set("v.showMmainSpin",false);
                }
            }else{
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');
                component.set("v.showMmainSpin",false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    fetchPaymentPost : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.getPaymentUpdate");    
        action.setParams({
            "PaymentId":event.detail.menuItem.get("v.value")             
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                try{ 
                    if(response.getReturnValue()==''){ 
                        helper.showToast('Success!','success','Successfully Posted !');
                        $A.enqueueAction(component.get("c.fetchPayment"));
                    }else if(response.getReturnValue()!='' && response.getReturnValue()!=null){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',response.getReturnValue());
                        component.set("v.showMmainSpin",false);
                    }
                }catch(ex){
                     helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!'); 
                    component.set("v.showMmainSpin",false);
                }
            }else{
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');
                component.set("v.showMmainSpin",false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    fetchBillPost : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.getBillUpdate");    
        action.setParams({
            "BillId":event.detail.menuItem.get("v.value")             
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                try{ 
                    if(response.getReturnValue()==''){ 
                        helper.showToast('Success!','success','Successfully Posted !');
                        $A.enqueueAction(component.get("c.fetchBill"));
                    }else if(response.getReturnValue()!='' && response.getReturnValue()!=null){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',response.getReturnValue());
                        component.set("v.showMmainSpin",false);
                    }
                }catch(ex){
                     helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');   
                    component.set("v.showMmainSpin",false);
                }
            }else{
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');
                component.set("v.showMmainSpin",false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    fetchCreditNotePost : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.getCreditNoteUpdate");    
        action.setParams({
            "CreditId":event.detail.menuItem.get("v.value")             
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                try{ 
                    if(response.getReturnValue()==''){ 
                        helper.showToast('Success!','success','Successfully Posted !');
                        $A.enqueueAction(component.get("c.fetchCreditNote"));
                    }else if(response.getReturnValue()!='' && response.getReturnValue()!=null){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',response.getReturnValue());
                        component.set("v.showMmainSpin",false);
                    }
                }catch(ex){
                     helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');  
                     component.set("v.showMmainSpin",false);
                }
            }else{
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');
                component.set("v.showMmainSpin",false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    fetchDebitNotePost : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.getDebitNoteUpdate");    
        action.setParams({
            "DebitId":event.detail.menuItem.get("v.value")             
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                try{ 
                    if(response.getReturnValue()==''){ 
                        helper.showToast('Success!','success','Successfully Posted !');
                        $A.enqueueAction(component.get("c.fetchDebitNote"));
                    }else if(response.getReturnValue()!='' && response.getReturnValue()!=null){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',response.getReturnValue());
                        component.set("v.showMmainSpin",false);
                    }
                }catch(ex){
                     helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');   
                     component.set("v.showMmainSpin",false);
                }
            }else{
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');
                component.set("v.showMmainSpin",false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    fetchExpensePost : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.getExpenseUpdate");    
        action.setParams({
            "ExpenseId":event.detail.menuItem.get("v.value")             
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                try{ 
                    if(response.getReturnValue()==''){ 
                        helper.showToast('Success!','success','Successfully Posted !');
                        $A.enqueueAction(component.get("c.fetchDebitNote"));
                    }else if(response.getReturnValue()!='' && response.getReturnValue()!=null){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',response.getReturnValue());
                        component.set("v.showMmainSpin",false);
                    }
                }catch(ex){
                     helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');   
                     component.set("v.showMmainSpin",false);
                }
            }else{
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Some unexpected error occured, Please try again!');
                component.set("v.showMmainSpin",false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    getPaymentPopup : function(component,event,helper){
        var getInvId = event.detail.menuItem.get("v.value");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:RecordPayment",
            componentAttributes: {
                navigateToRecord:false,
                recordId:getInvId,
                ShowPaymentType:false,
                showPage:true,
                AccoutingPeriod:component.get("v.AP"),
                FromClosing:true
            }
        });
        evt.fire();
        /*$A.createComponent("c:RecordPayment",{
            "aura:id": "recordPayment",
            "navigateToRecord":false,
            "recordId":getInvId,
            "ShowPaymentType":false,
            "showPage":true
            //"OrgId" : component.get("v.Organisation.Id"),
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
    }, 
    
    getPaymentPopupPayable : function(component,event,helper){
        var getInvId = event.detail.menuItem.get("v.value");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Accounts_Payable",
            componentAttributes: {
                "AccoutingPeriod" : component.get("v.AP"),
                "selectedTab" : 'Bills',
                "setSearch" : getInvId,
                 FromClosing:true
            }
        });
        evt.fire();
    }, 

})