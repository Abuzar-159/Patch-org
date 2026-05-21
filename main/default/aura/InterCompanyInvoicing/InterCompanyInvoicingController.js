({
	doInit : function(component, event, helper) {
        var defaultOrg = component.get("c.DefaultOrganisation");	
        defaultOrg.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.organisationId",response.getReturnValue().Id);
            }  
        });
        $A.enqueueAction(defaultOrg);
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
            case 'Customer_Orders':
                $A.enqueueAction(component.get("c.fetchOrdersCMP"));
                 break;
            case 'Inter_Company_Orders':
                $A.enqueueAction(component.get("c.fetchOrdersInterCompany"));
                 break;
            case 'Purchase_Orders':
                $A.enqueueAction(component.get("c.fetchPurchaseOrdersCMP"));
                 break;
            default:
        }
    }, 
    
    
    fetchOrdersCMP : function(component, event, helper) {
        component.set("v.selectedTab",'Customer_Orders');
        var action=component.get("c.fetchOrders");
        action.setParams({
            "orgId":component.get("v.organisationId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                //helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    
    fetchOrdersInterCompany : function(component, event, helper) {
        component.set("v.selectedTab",'Inter_Company_Orders');
        var action=component.get("c.fetchInterCompanyOrders");
        action.setParams({
            "orgId":component.get("v.organisationId"),
            "prodOrgId":component.get("v.procurementOrgId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                //helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    fetchInvoice : function(component, event, helper) {
        component.set("v.selectedTab",'Invoices');
        var action=component.get("c.fetchInvoices");
        action.setParams({
            "orgId":component.get("v.organisationId"),
            "prodOrgId":component.get("v.procurementOrgId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                //helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    fetchPurchaseOrdersCMP : function(component, event, helper) {
        component.set("v.selectedTab", 'Purchase_Orders');
        var action = component.get("c.fetchPurchaseOrders");
        action.setParams({
            "orgId": component.get("v.organisationId"),
            "prodOrgId": component.get("v.procurementOrgId"),
            "StartDate": component.get("v.StartDate"),
            "EndDate": component.get("v.EndDate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.TransactionWrapper", response.getReturnValue());
                component.set("v.showMmainSpin", false);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
                component.set("v.showMmainSpin", false);
            }
        });
        $A.enqueueAction(action);
    },

    
    fetchBill : function(component, event, helper) {
        component.set("v.selectedTab",'Bills');
        var action=component.get("c.fetchBills");
        action.setParams({
            "orgId":component.get("v.organisationId"),
            "prodOrgId":component.get("v.procurementOrgId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionWrapper",response.getReturnValue());
                //helper.fetchAmountDetails(component, event, helper);
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    handledebitmenu: function(cmp,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreatePurchaseOrder",
            componentAttributes: {
                orderId : event.detail.menuItem.get("v.title")
            }
        });
        evt.fire();
    },
    
    handleinvoicemenu: function(cmp,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreateInvoice",
            componentAttributes: {
                StdId : event.detail.menuItem.get("v.title")
            }
        });
        evt.fire();
    },
    
    handleinvDocmenu: function(cmp,event,helper){
        var operation = event.detail.menuItem.get("v.label");
        if(operation == 'Send Invoice Payment Remainder'){
            var url = $A.get("$Label.c.Invoice_Document");
            url = url + 'custId=' + event.detail.menuItem.get("v.title")+'&name='+event.detail.menuItem.get("v.value");
            window.open(url, '_blank');
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:RecordPayment",
                componentAttributes: {
                    "aura:id": "recordPayment",
                    "navigateToRecord":false,
                    "recordId":event.detail.menuItem.get("v.value"),
                    "ShowPaymentType":false,
                    "showPage":true,
                    "OrgId" : cmp.get("v.organisationId")
                }
            });
            evt.fire();
        }
        
    },

    switchTabOrganisation : function(component,event,helper){
        component.set("v.showMmainSpin",true);
        var currentTab = component.get("v.selectedTab");
        switch(currentTab) {
            case 'Invoices':
                $A.enqueueAction(component.get("c.fetchInvoice"));
                 break;
            case 'Bills':
                $A.enqueueAction(component.get("c.fetchBill"));
                 break;
            case 'Customer_Orders':
                $A.enqueueAction(component.get("c.fetchOrdersCMP"));
                 break;
            case 'Inter_Company_Orders':
                $A.enqueueAction(component.get("c.fetchOrdersInterCompany"));
                 break;
            case 'Purchase_Orders':
                $A.enqueueAction(component.get("c.fetchPurchaseOrdersCMP"));
                 break;
            default:
        }
        
    },
    
    
    selectedCustomerOrders : function(component, event, helper) {
        var SelectedId = event.getSource().get("v.name");
        var selectedordList = component.get("v.SelectedcusOrders");
        if(event.getSource().get("v.value")){
            selectedordList.push(event.getSource().get("v.name"));
        } else{
            for(var x =0;x < selectedordList.length;x++){
                if(selectedordList[x] === SelectedId){
                    selectedordList.splice(x,1);
                    break;
                } 
                
            }
        }
        component.set("v.SelectedcusOrders",selectedordList);
        
    },
    
    selectedPurchaseOrders : function(component, event, helper) {
        var SelectedId = event.getSource().get("v.name");
        var selectedordList = component.get("v.SelectedpoOrders");
        if(event.getSource().get("v.value")){
            selectedordList.push(event.getSource().get("v.name"));
        } else{
            for(var x =0;x < selectedordList.length;x++){
                if(selectedordList[x] === SelectedId){
                    selectedordList.splice(x,1);
                    break;
                } 
                
            }
        }
        component.set("v.SelectedpoOrders",selectedordList);
        
    },
    
    handleClick : function(cmp,event,helper){
        var selectedordList = cmp.get("v.SelectedcusOrders");console.log('selectedordList ',selectedordList.length);
        if(selectedordList.length==1){console.log('s1');
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreatePurchaseOrder",
                componentAttributes: {
                    orderId : selectedordList[0],
                    interCompanyPO : true
                }
            });
            evt.fire();console.log('s2');
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreatePurchaseOrder",
                componentAttributes: {
                    SelectedcustomerOrders : selectedordList,
                    interCompanyPO : true
                }
            });
            evt.fire();
        }
        
    },
    
    handleClickOrder : function(cmp,event,helper){
        /*var selectedordList = cmp.get("v.SelectedpoOrders");
        if(selectedordList.length==1){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreatePurchaseOrder",
                componentAttributes: {
                    orderId : selectedordList[0],
                    interCompanyPO : true
                }
            });
            evt.fire();
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreatePurchaseOrder",
                componentAttributes: {
                    orderId : selectedordList[0],
                    interCompanyPO : true
                }
            });
            evt.fire();
        }*/
        var selectedordList = cmp.get("v.SelectedpoOrders");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreateOrder",
            componentAttributes: {
                SelectedPos : selectedordList,
                vendorId : cmp.get("v.organisationId"),
                orgId : cmp.get("v.procurementOrgId"),
                resetKey: Date.now()
            }
        });
        evt.fire();
        
    },
    
    
})