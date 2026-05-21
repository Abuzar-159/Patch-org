({
    doInit: function(cmp, event, helper) {
        
        helper.retrievePageLayout(cmp, helper);
        var api=cmp.get("v.PageLayoutName");
        if(api=='ERP7__PO__c' || api=='ERP7__WO__c' || api=='ERP7__Bill__c' || api=='ERP7__Payment__c' || api=='ERP7__Request__c' || api=='ERP7__Expense__c' || api=='ERP7__Timesheet__c' || api=='Contract'){
          
        if(api == 'ERP7__PO__c'){
            cmp.set("v.ObListName",'Purchase Line Items');
            helper.getFieldsSetApiNameHandler(cmp,'ERP7__Purchase_Line_Items__c','ERP7__PurchaseOrderRelatedList');
            helper.getRelatedId(cmp,'ERP7__Purchase_Line_Items__c','ERP7__Purchase_Orders__c');
            
        }
        if(api == 'ERP7__WO__c'){
            cmp.set("v.ObListName",'Work Order Line Items');
            helper.getFieldsSetApiNameHandler(cmp,'ERP7__Work_Order_Line_Items__c','ERP7__WorkOrderRelatedList');
            helper.getRelatedId(cmp,'ERP7__Work_Order_Line_Items__c','ERP7__Work_Orders__c');
        }
        if(api == 'ERP7__Bill__c'){
            cmp.set("v.ObListName",'Bill Line Items');
            helper.getFieldsSetApiNameHandler(cmp,'ERP7__Bill_Line_Item__c','ERP7__BillRelatedList');
            helper.getRelatedId(cmp,'ERP7__Bill_Line_Item__c','ERP7__Bill__c');
        }
        if(api == 'ERP7__Payment__c'){
            cmp.set("v.ObListName",'Transactions');
            helper.getFieldsSetApiNameHandler(cmp,'ERP7__Transaction__c','ERP7__TransactionRelatedList');
            helper.getRelatedId(cmp,'ERP7__Transaction__c','ERP7__Payment__c');
        }
        if(api == 'ERP7__Request__c'){
            cmp.set("v.ObListName",'Request Suppliers');
            helper.getFieldsSetApiNameHandler(cmp,'ERP7__Request_Supplier__c','ERP7__RequestSupplierRelatedList');
            helper.getRelatedId(cmp,'ERP7__Request_Supplier__c','ERP7__Request__c'); 
        }
        if(api == 'ERP7__Expense__c'){
            cmp.set("v.ObListName",'Expense Line Items');
            helper.getFieldsSetApiNameHandler(cmp,'ERP7__Expense_Line_Item__c','ERP7__ExpenseLineItemRelatedList');
            helper.getRelatedId(cmp,'ERP7__Expense_Line_Item__c','ERP7__Expense__c');
        }
        if(api == 'ERP7__Timesheet__c'){
            cmp.set("v.ObListName",'Time Card Entries');
            helper.getFieldsSetApiNameHandler(cmp,'ERP7__Time_Card_Entry__c','ERP7__TimeCardEntryRelatedList');
            helper.getRelatedId(cmp,'ERP7__Time_Card_Entry__c','ERP7__Timesheet__c');
        }
        if(api == 'Contract'){
            cmp.set("v.ObListName",'Contract Terms');
            helper.getFieldsSetApiNameHandler(cmp,'ERP7__Contract_Terms__c','ERP7__ContractRelatedListItems');
            helper.getRelatedId(cmp,'ERP7__Contract_Terms__c','ERP7__Contracts__c');
            
        }
        }
    },
    customHandler : function(cmp, event, helper) {
        alert("It's custom action!")
    },
    
    
    updateCase: function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": event.target.dataset.record
        });
        editRecordEvent.fire();
    },
    
    /*openRelatedList: function(component, _event){
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        var idstr = event.target.getAttribute("data-recId")
        relatedListEvent.setParams({
            RecordId: idstr
        });
        relatedListEvent.fire();
    }*/
    navigateBack : function(component, event, helper) {
       
        var name=component.get("v.ObName");
        if(name == 'Purchase Orders'){
            $A.createComponent("c:SupplierPortalPO",{
                "AccId":component.get("v.AccId"),  
                "aura:id": "SupplierPortalPO",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        
        if(name == 'Work Orders'){
            $A.createComponent("c:SupplierPortalWO",{
                "AccId":component.get("v.AccId"),  
                "aura:id": "SupplierPortalWO",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        if(name == 'Bills'){
            $A.createComponent("c:SupplierPortalBills",{
                "AccId":component.get("v.AccId"),  
                "aura:id": "SupplierPortalBills",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        if(name == 'Payments'){
            $A.createComponent("c:SupplierPortalPayments",{
                "AccId":component.get("v.AccId"),  
                "aura:id": "SupplierPortalPayments",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        if(name == 'RFPs'){
            $A.createComponent("c:SupplierRequests",{
                "currentSupplier":component.get("v.AccId"),  
                "aura:id": "SupplierRequests",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        if(name == 'Expenses'){
            $A.createComponent("c:SupplierPortalExpense",{
                "AccId":component.get("v.AccId"),  
                "aura:id": "SupplierPortalExpense",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        if(name == 'Timesheets'){
            $A.createComponent("c:SupplierPortalTimesheets",{
                "AccId":component.get("v.AccId"),  
                "aura:id": "SupplierPortalTimesheets",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        if(name == 'Contracts'){
            $A.createComponent("c:SupplierPortalContracts",{
                "AccId":component.get("v.AccId"),  
                "aura:id": "SupplierPortalContracts",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
    }, 
    DownloadPdf: function (component, event, helper) {
        //var recordId = event.target.dataset.record;
        //var url=$A.get("$Label.c.CommunityURL");
        var url='/SupplierPortal/PurchaseOrderCommunityPdf?Id='+component.get("v.RecordId");
        //var url = $A.get("$Label.c.CommunityURL");
        //var url ='/SupplierPortal/PurchaseOrderPDFCommunity?id='+recordId;
        window.open(url,"_blank");
    }, 
    home:function(component, event, helper){
		//location.reload();
        $A.createComponent("c:SupplierPortalCommHome",{
            AccId:component.get("v.AccId")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    }
})