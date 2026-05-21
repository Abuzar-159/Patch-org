({
    doInit : function(component, event, helper) {
        
        var defaultOrg = component.get("c.DefaultOrganisation");	
        defaultOrg.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.Organisation",response.getReturnValue());
                helper.displayCreditNotes(component, event, helper); 
            }  
        });
        $A.enqueueAction(defaultOrg);
        var payRT = component.get("c.getPaymentRecordType");
        payRT.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var recordtypeList = JSON.parse(response.getReturnValue());
                var recordArray = [];
                for(var rt in recordtypeList)
                    if(recordtypeList[rt].available && !recordtypeList[rt].master){
                        if(recordtypeList[rt].name=='Card Payments')
                            recordArray.push(recordtypeList[rt]);
                        if(recordtypeList[rt].name=='Bank Payments')
                            recordArray.push(recordtypeList[rt]);
                    }
                component.set("v.paymentRecordType",recordArray);
            }            
        });
        $A.enqueueAction(payRT);
        
        var payRTS = component.get("c.getPaymentGateways");
        payRTS.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                //alert(response.getReturnValue());
                var recordtypeList = response.getReturnValue();
                var recordArray = [];
                for(var rt in recordtypeList)
                    recordArray.push(recordtypeList[rt]);
                //}
                component.set("v.paymentGatewayList",recordArray);
            }            
        });
        $A.enqueueAction(payRTS);
    }, 
    
    
    calledVendor : function(component,event,helper){
        component.set("v.selectedTab", 'Vendor');
    },
    
    calledPO : function(component,event,helper){
        component.set("v.selectedTab", 'Purchase_Orders');
    },
    
    calledBill : function(component,event,helper){
        component.set("v.selectedTab", 'Bills');
    },
    
    calledVou : function(component,event,helper){
        component.set("v.selectedTab", 'Vouchers');
    },
    
    calledPay : function(component,event,helper){
        component.set("v.selectedTab", 'Payments');
    },
    
    calledDebit : function(component,event,helper){
        component.set("v.selectedTab", 'Credit_debit_notes');
    },
    
    openReport : function(component,event,helper){
        /*var name=event.currentTarget.dataset.service;
        var reportUrl = $A.get("$Label.c.Vendor_Ledger");
        reportUrl = reportUrl + 'fv0=' + name;
        window.open(reportUrl,'_blank');*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CustomerVendorDetails",
            componentAttributes: {    
                'customerVendorId':event.currentTarget.dataset.service,
                'fromAP':true,
                'selectedTab':'Bills'
            }
        });
        evt.fire();
    },
    
    createCredit : function(component,event,helper){
        /*var orgId;
        if(component.get("v.Organisation.Id")!='' && component.get("v.Organisation.Id")!=undefined) orgId=component.get("v.Organisation.Id");
        var defaults = {'ERP7__Organisation__c':orgId,'ERP7__Account__c':event.currentTarget.dataset.service} 
        helper.createRecord(component,event,'ERP7__Credit_Note__c',defaults);*/
        
        var purId = event.target.dataset.record;
        $A.createComponent("c:CreateCreditNote",{
            "aura:id": "mBill",
            "invId": purId,
            "navigateToRecord":true,
            "fromAP":true,
            "showPage" : true,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.saveBill")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    createDebit : function(component,event,helper){
        var orgId;
        if(component.get("v.Organisation.Id")!='' && component.get("v.Organisation.Id")!=undefined) orgId=component.get("v.Organisation.Id");
        var defaults = {'ERP7__Organisation__c':orgId,'ERP7__Account__c':event.currentTarget.dataset.service} 
        helper.createRecord(component,event,'ERP7__Debit_Note__c',defaults);
    },
    
    SortRecodEventHandler : function(cmp, event, helper) {
        var RecordList = event.getParam("RecordList"); 
        var currentTab = cmp.get("v.selectedTab");
        if(currentTab=='Vendor') cmp.set("v.vendorAccounts",RecordList);
        else if(currentTab=='Purchase_Orders') cmp.set("v.POList",RecordList);
            else if(currentTab=='Bills') cmp.set("v.Bills",RecordList);
                else if(currentTab=='Payments') cmp.set("v.Payments",RecordList);
                    else if(currentTab=='Credit_debit_notes') cmp.set("v.DebitNotes",RecordList);
                        else if(currentTab=='Credit_notes') cmp.set("v.creditNotes",RecordList);
                            else if(currentTab=='Vouchers') cmp.set("v.Vouchers",RecordList);      
    }, 
    
    getSortedRecords : function(component,event,helper){
        component.set("v.OrderBy",event.currentTarget.id);
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');          
        var currentTab = component.get("v.selectedTab");        
        if(currentTab=='Bills') helper.getBills(component,event);
        else if(currentTab=='Vouchers')  helper.getVouchers(component,event); 
            else if(currentTab=='Payments') helper.getPayments(component,event);
                else if(currentTab=='Credit_debit_notes') helper.getDebitNotes(component,event);
    }, 
    
    FilterByOrg : function(component,event,helper){
        var currentTab = component.get("v.selectedTab");
        switch(currentTab) {
            case 'Vendor': helper.helper_getSupplierAccounts(component, event); 
                break;
            case 'Purchase_Orders': helper.getpurchaseOrder(component,event);
                break;
            case 'Bills':
                helper.getBills(component,event);
                break;
            case 'Payments':
                helper.getPayments(component,event);
                break;
            case 'Credit_debit_notes':
                helper.getDebitNotes(component,event);
                break;
            case 'Vouchers':
                helper.getVouchers(component,event);
                
                break;    
            default:
                //('currentTab '+currentTab);
        }
        
    },
    selectedPO : function(component, event, helper) {
        var SelectedId = event.getSource().get("v.name");
        
        
        var selectedPOSList =[];
        selectedPOSList =  component.get("v.SelectedPOS");
        if(selectedPOSList=='')selectedPOSList.pop();
        if(event.getSource().get("v.value")){
            selectedPOSList.push(SelectedId);
        }else{
            for(var x =0;x < selectedPOSList.length;x++){
                if(selectedPOSList[x] === SelectedId){
                    selectedPOSList.splice(x,1);
                    break;
                } 
                
            }
        }
        if(selectedPOSList.length>1){
            var AllPOSList =[];
            var vendorIdList =[];
            AllPOSList = component.get("v.POList");
            for(var x =0;x < selectedPOSList.length;x++){
                for(var y=0; y < AllPOSList.length;y++){
                    if(AllPOSList[y].Id === selectedPOSList[x]){
                        vendorIdList.push(AllPOSList[y].ERP7__Vendor__r.Id);
                    }
                }
            }
            component.set("v.displayMultipleBill", true);
            if(vendorIdList.length>0){
                for(var z=0; z < vendorIdList.length-1; z++){
                    var firstValue = vendorIdList[z];
                    var secondValue = vendorIdList[z+1];
                    if(firstValue!=secondValue){
                        component.set("v.displayMultipleBill", false);
                    }
                }
            }
        }else{
            component.set("v.displayMultipleBill", false); 
        }
        component.set("v.SelectedPOS",selectedPOSList);
        console.log('SelectedPOS:', component.get("v.SelectedPOS"));
    },
    selectedAccount : function(component, event, helper) {
        component.set("v.SelectedAccounts",'');
        var SelectedId = event.getSource().get("v.name");
        var selectedAccList = component.get("v.SelectedAccounts");
        var accountsList = component.get("v.vendorAccounts");
        var vendids = component.get('v.SelectedVen');
        if(event.getSource().get("v.value")){
            for(var x =0;x < accountsList.length;x++){
                if(accountsList[x].Id === SelectedId){
                    selectedAccList.push(accountsList[x]);
                    vendids.push(accountsList[x].Id);
                } 
                
            }
            
        } else{
            for(var x =0;x < selectedAccList.length;x++){
                if(selectedAccList[x].Id === SelectedId){
                    selectedAccList.splice(x,1);
                    vendids.splice(x,1);
                    //break;
                } 
                
            }
        }
        component.set("v.SelectedAccounts",selectedAccList);
        component.set('v.SelectedVen',vendids);
        
    },
    handleRemoveOnly : function(component, event, helper) {
        var selectedId = event.getSource().get("v.name");
        var selectedAccList = component.get("v.SelectedAccounts");
        for(var x =0;x < selectedAccList.length;x++){
            if(selectedAccList[x].Id === selectedId){
                var allbbox = component.find("cbox");
                var currentTab = component.get("v.selectedTab");
                switch(currentTab) {
                    case 'Vendor':
                        if(!$A.util.isUndefined(allbbox)){
                            if(allbbox.length>0){
                                for(var y in allbbox)
                                    if(allbbox[y].get("v.name") === selectedId){
                                        allbbox[y].set("v.value",false);
                                        break;
                                    }    
                            }else{
                                if(allbbox.get("v.name") === selectedId)
                                    allbbox.set("v.value",false);
                            }
                        }
                        if(selectedAccList.length === 0)
                            component.find("selectAllAcc").set("v.value",false);
                        break;
                    case 'Purchase_Orders':
                        helper.getpurchaseOrder(component,event);
                        break;
                    case 'Bills':
                        //helper.getBills(component,event);
                        break;
                    case 'Payments':
                        helper.getPayments(component,event);
                        break;
                    case 'Credit_debit_notes':
                        break;
                    case 'Vouchers':
                        helper.getVouchers(component,event);
                        break;    
                    default:
                        //('currentTab '+currentTab);
                }
                
                selectedAccList.splice(x,1);
                break;
            }
        }
        component.set("v.SelectedAccounts",selectedAccList);
        
    },
    selectAllAccount : function(component, event, helper) {
        var allbbox = component.find("cbox");
        if(allbbox.length>0){
            for(var x in allbbox)
                allbbox[x].set("v.value",event.getSource().get("v.value"));
        }else
            allbbox.set("v.value",event.getSource().get("v.value"));
        var selectedAccList = component.get("v.SelectedAccounts");
        var accountsList = component.get("v.vendorAccounts");
        if(event.getSource().get("v.value")){
            for(var x =0;x < accountsList.length;x++)
                selectedAccList.push(accountsList[x]);
        } else{
            selectedAccList = [];
        }
        component.set("v.SelectedAccounts",selectedAccList);
    },
    switchTab : function(component,event,helper){
        var currentTab = component.get("v.selectedTab");
        switch(currentTab) {
            case 'Vendor':
                component.set("v.SelectedVouchers",'');
                component.set("v.SelectedBillIds",'');
                component.set('v.SelectedVen','');
                component.set('v.setSearch',null);
                component.set("v.startCount", 0);
                component.set("v.endCount", 0);
                component.set("v.Offset", 0);
                helper.helper_getSupplierAccounts(component, event); 
                component.set("v.SelectedAccounts",null);
                break;
            case 'Purchase_Orders':
                component.set("v.SelectedVouchers",'');
                component.set("v.SelectedBillIds",'');
                component.set('v.SelectedVen','');
                component.set('v.setSearch',null);
                component.set("v.startCount", 0);
                component.set("v.endCount", 0);
                component.set("v.Offset", 0);
                helper.getpurchaseOrder(component,event);
                component.set('v.SelectedPOS','');
                break;
            case 'Bills':
                component.set("v.SelectedVouchers",'');
                component.set("v.SelectedBillIds",[]);
                component.set('v.setSearch',null);
                component.set("v.startCount", 0);
                component.set("v.endCount", 0);
                component.set("v.Offset", 0);
                helper.getBills(component,event);
                break;
            case 'Payments':
                component.set('v.setSearch',null);
                component.set("v.startCount", 0);
                component.set("v.endCount", 0);
                component.set("v.Offset", 0);
                helper.getPayments(component,event);
                break;
            case 'Credit_debit_notes':
                component.set('v.setSearch',null);
                component.set("v.startCount", 0);
                component.set("v.endCount", 0);
                component.set("v.Offset", 0);
                helper.getDebitNotes(component,event);
                break;
            case 'Credit_notes':
                component.set('v.setSearch',null);
                component.set("v.startCount", 0);
                component.set("v.endCount", 0);
                component.set("v.Offset", 0);
                helper.getCreditNotes(component,event);
                break;
            case 'Vouchers':
                component.set("v.SelectedVouchers",'');
                component.set('v.setSearch',null);
                component.set("v.startCount", 0);
                component.set("v.endCount", 0);
                component.set("v.Offset", 0);
                helper.getVouchers(component,event);
                
                break;    
            default:
                //('currentTab '+currentTab);
        }
    }, 
    createDebitNote : function(component,event,helper){
        /*var defaults = {'ERP7__Organisation__c':component.get("v.Organisation.Id"),'ERP7__Account__c':event.target.dataset.record}
        helper.createRecord(component,event,'ERP7__Debit_Note__c',defaults);*/
        $A.createComponent("c:CreateDebitNote",{
            "aura:id": "mBill",
            "navigateToRecord":true,
            "fromAP":true,
            "showPage" : true,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.saveBill")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    createAccount : function(component,event,helper){
        var defaultRecType = component.get("c.fetchRecordType");	
        defaultRecType.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var defaults = {'ERP7__Organisation__c':component.get("v.Organisation.Id"),'ERP7__Account_Type__c': 'Vendor'}
                helper.createAccount(component,event,'Account',defaults, response.getReturnValue());
            }else{
                var defaults = {'ERP7__Organisation__c':component.get("v.Organisation.Id"),'ERP7__Account_Type__c': 'Vendor'}
                helper.createRecord(component,event,'Account',defaults);
            }  
        });
        $A.enqueueAction(defaultRecType);
        
    },
    
    
    //_____________________________________
    
    createPayment : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DirectPayment",
            componentAttributes: {    
            }
        });
        evt.fire();
    },
    
    //______________________________________
    
    createPO : function(component,event,helper){
        //  component.set("v.ShowPOType", true);
        //  
        //Moin added "fromAP":true on 20th july 2023
        $A.createComponent("c:CreatePurchaseOrder",{
            "aura:id": "poModal",
            "navigateToRecord":false,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.save_PO"),
            "fromAP":true
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    createBill : function(component,event,helper){ 
        console.log('createBill called');
        var orgId=component.get('v.Organisation.Id');
        var obj = {'ERP7__Organisation__c':orgId,'ERP7__Amount__c':0.00,'ERP7__Discount_Amount__c':0.00,'ERP7__VAT_TAX_Amount__c':0.00};
        if(!$A.util.isUndefined(event.target.dataset.record))
            obj['ERP7__Vendor__r'] = {'Id':event.target.dataset.record,'Name':event.target.dataset.name};
        $A.createComponent("c:CreateBill",{
            "aura:id": "mBill",
            "Bill": obj,
            "navigateToRecord":false,
            "fromAP":true,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.saveBill"),
            "vId":event.target.dataset.record
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }else{
                console.log('errorMessage>~'+errorMessage);
            }
        });   
    },
    
    NavigateToManagePO: function(component,event,helper){
        var url = '/apex/ERP7__CreatePurchaseOrderLC?PoId='+event.target.dataset.record;
        window.open(url,"_self");
    },
    
    createBill_PO : function(component,event,helper){         
        console.log('CreateBill calling here3');
        var fetchpoliAction = component.get("c.fetch_Polis");
        fetchpoliAction.setParams({"Id":event.target.dataset.record});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    var po = JSON.parse(resultList[0]);
                    var poliList = JSON.parse(resultList[1]);
                    //alert('1==>'+JSON.stringify(poliList));
                    if(!$A.util.isEmpty(poliList)){
                        var obj = {'ERP7__Amount__c':0.00,'ERP7__Discount_Amount__c':0.00,'ERP7__VAT_TAX_Amount__c':0.00};
                        if(!$A.util.isUndefined(event.target.dataset.record))
                            //obj['ERP7__Purchase_Order__r'] = {'Id':event.target.dataset.record,'Name':event.target.dataset.name};
                            $A.createComponent("c:CreateBill",{
                                "showExpenseAccount":false,
                                "aura:id": "mBill",
                                "Bill": obj,
                                "navigateToRecord":false,
                                "fromAP":true,
                                "cancelclick":component.getReference("c.backTO"),
                                "saveclick":component.getReference("c.saveBill")
                            },function(newCmp, status, errorMessage){
                                if (status === "SUCCESS") {
                                    var body = component.find("body");
                                    newCmp.set('v.Bill.ERP7__Purchase_Order__c',event.target.dataset.record);
                                    newCmp.set('v.Bill.ERP7__Organisation__c',component.get("v.Organisation.Id"));
                                    body.set("v.body", newCmp);
                                }
                            });
                        //
                    }else{
                        helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_Bill_Has_Already_Been_Created'));
                        
                        
                    }
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
    },
    
    createDebit : function(component, event, helper){
        var purId = event.target.dataset.record;
        $A.createComponent("c:CreateDebitNote",{
            "aura:id": "mBill",
            "pId": purId,
            "navigateToRecord":true,
            "fromAP":true,
            "showPage" : true,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.saveBill")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    createVoucher : function(component,event,helper){
        var defaults = {'ERP7__Vendor__c':event.getSource().get("v.name")}
        helper.createRecord(component,event,'ERP7__Voucher__c',defaults);
        
    },
    ShowcreatePO : function(component,event,helper){
        console.log('ShowcreatePO called');
        //"PO": {ERP7__Vendor__c:event.target.dataset.record},
        //"PO": {ERP7__Vendor__c:{'Id':event.target.dataset.record,'Name':event.target.dataset.name}},
        $A.createComponent("c:CreatePurchaseOrder",{
            
            "aura:id": "poModal",
            "navigateToRecord":false,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.save_PO"),
            "vId":event.target.dataset.record,
            "fromAP":true,
            "navigateToRecord":false
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                newCmp.set('v.PO.ERP7__Vendor__r',{'Id':event.target.dataset.record,'Name':event.target.dataset.name});
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
        
        
        //$A.util.toggleClass(component.find("createPO"),'slds-hide');
    },
    backTO : function(component,event,helper){
        $A.createComponent("c:Accounts_Payable",{
            "aura:id": "AccountsPayable",
            "selectedTab":component.get("v.selectedTab")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        }); 
    },
    matchBill : function(component,event,helper){
        
        var selectedBillList = component.get("v.SelectedBillIds");
        var BillList = component.get("v.Bills");
        
        for(var x =0;x < BillList.length;x++){
            for(var y=0; y<selectedBillList.length;y++){
                if(BillList[x].Id === selectedBillList[y]){
                    if(BillList[x].RecordType.DeveloperName == 'Advance_to_vendor'){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Advance_bills_not_allowed_to_match')); 
                        return;
                    }
                }
            }
        }
        
        for(var x =0;x < BillList.length;x++){
            for(var y=0; y<selectedBillList.length;y++){
                if(BillList[x].Id === selectedBillList[y]){
                    selectedBillList.push(BillList[x]);break;
                } 
            }
        }
        
        if(selectedBillList.length>0){
            component.set("v.showMatchBill",true);
            component.set("v.HideMatchBill",true);
            component.set("v.displayPagination", true);
            component.find("mBill").matchBill();
        }else{
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_MatchBill_Please_Select_a_Bill')); 
        }
        
    },
    selectedBill : function(component, event, helper) {
        var SelectedId = event.getSource().get("v.name");
        var selectedBillList = component.get("v.SelectedBills");
        var BillList = component.get("v.Bills");
        if(event.getSource().get("v.value")){
            for(var x =0;x < BillList.length;x++){
                if(BillList[x].Id === SelectedId){
                    selectedBillList.push(BillList[x]);break;
                } 
                
            }
            
        } else{
            for(var x =0;x < selectedBillList.length;x++){
                if(selectedBillList[x].Id === SelectedId){
                    selectedBillList.splice(x,1);
                    break;
                } 
                
            }
        }
        component.set("v.SelectedBills",selectedBillList);
        
    },
    selectAllBills : function(component, event, helper) {
        var allbbox = component.find("cbox_bill");
        if(allbbox.length>0){
            for(var x in allbbox)
                allbbox[x].set("v.value",event.getSource().get("v.value"));
        }else
            allbbox.set("v.value",event.getSource().get("v.value"));
        var selectedBillList = component.get("v.SelectedBills");
        var billList = component.get("v.Bills");
        if(event.getSource().get("v.value")){
            for(var x =0;x < billList.length;x++)
                selectedBillList.push(billList[x]);
        } else{
            selectedBillList = [];
        }
        component.set("v.SelectedBills",selectedBillList);
    },
    selectedVoucher : function(component, event, helper) {
        var SelectedId = event.getSource().get("v.name");
        var selectedVoucherList = component.get("v.SelectedVouchers");
        if(selectedVoucherList=='')selectedVoucherList.pop();
        var voucherList = component.get("v.Vouchers");
        if(event.getSource().get("v.value")){
            for(var x =0;x < voucherList.length;x++){
                if(voucherList[x].Id === SelectedId){
                    selectedVoucherList.push(voucherList[x]);break;
                } 
                
            }
            
        } else{
            for(var x =0;x < selectedVoucherList.length;x++){
                if(selectedVoucherList[x].Id === SelectedId){
                    selectedVoucherList.splice(x,1);
                    break;
                } 
                
            }
        }
        component.set("v.SelectedVouchers",selectedVoucherList);
    },
    selectAllVouchers : function(component, event, helper) {
        var allbbox = component.find("cbox_voucher");
        if(allbbox.length>0){
            for(var x in allbbox)
                allbbox[x].set("v.value",event.getSource().get("v.value"));
        }else
            allbbox.set("v.value",event.getSource().get("v.value"));
        var selectedVoucherList = component.get("v.SelectedVouchers");
        var voucherList = component.get("v.Vouchers");
        
        if(event.getSource().get("v.value")){
            for(var x =0;x < voucherList.length;x++)
                selectedVoucherList.push(voucherList[x]);
        } else{
            selectedVoucherList = [];
        }
        component.set("v.SelectedVouchers",selectedVoucherList);
    },
    
    handleComponentEvent : function(component,event,helper){
        try{
            component.set("v.startCount", 0);
            component.set("v.endCount", 0);
            component.set("v.Offset", 0);
            var currentTab = component.get("v.selectedTab");
            console.log('component.get("v.setSearch")~>'+component.get("v.setSearch"));
            var searchString = (component.get("v.setSearch") != undefined && component.get("v.setSearch") != null) ? component.get("v.setSearch") : '';// event.getParam("searchString");
            console.log('searchString~>'+searchString);
            
            switch(currentTab) {
                case 'Vendor':
                    if(searchString.length > 1){
                        /* var vendorAccounts = component.get("v.vendorAccountsSL"); // vendorAccounts
                    vendorAccounts = vendorAccounts.filter(function (el) {
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                    });
                     var currList=[];var count=0;var limit=parseInt(component.get("v.show"));
                    for(var inv in vendorAccounts){
                        if(count<limit){
                            currList.push(vendorAccounts[count]);
                            count=count+1;
                        }else break;
                     }
                    component.set("v.vendorAccounts",currList);
                    */
                    helper.helper_getSupplierAccounts(component,event);
                }else{
                    if(searchString.length == 0) helper.helper_getSupplierAccounts(component,event);
                }
                break;
            case 'Purchase_Orders':
                if(searchString.length>1){
                    /* var POList = component.get("v.POListSL"); //POList
                    POList = POList.filter(function (el) {
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                    });
                    var currList=[];var count=0;var limit=parseInt(component.get("v.show"));
                    for(var inv in POList){
                        if(count<limit){
                            currList.push(POList[count]);
                            count=count+1;
                        }else break;
                     }
                    component.set("v.POList",currList);
                    */
                    helper.getpurchaseOrder(component,event);
                }else{
                    if(searchString.length==0)  helper.getpurchaseOrder(component,event);
                }
                break;
            case 'Bills':
                //helper.getBills(component,event);
                if(searchString.length>1){
                    helper.getBills(component,event);
                }else{
                    if(searchString.length==0)  helper.getBills(component,event);
                }
                break;
            case 'Payments':
                if(searchString.length>1){
                    /*var Payments = component.get("v.PaymentsSL"); //Payments
                    Payments = Payments.filter(function (el) {
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                    });
                    var currList=[];var count=0;var limit=parseInt(component.get("v.show"));
                    for(var inv in Payments){
                        if(count<limit){
                            currList.push(Payments[count]);
                            count=count+1;
                        }else break;
                     }
                    component.set("v.Payments",currList);
                    */
                    helper.getPayments(component,event);
                }else{
                    if(searchString.length==0)helper.getPayments(component,event);
                }
                break;
            case 'Credit_debit_notes':
                if(searchString.length>1){
                    /* var DebitNotes = component.get("v.DebitNotesSL"); //DebitNotes
                    DebitNotes = DebitNotes.filter(function (el) {
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                    });
                    var currList=[];var count=0;var limit=parseInt(component.get("v.show"));
                    for(var inv in DebitNotes){
                        if(count<limit){
                            currList.push(DebitNotes[count]);
                            count=count+1;
                        }else break;
                     }
                    component.set("v.DebitNotes",currList);
                    */
                    helper.getDebitNotes(component,event);
                }else{
                    if(searchString.length==0)helper.getDebitNotes(component,event);
                }
                break;
            case 'Vouchers':
                if(searchString.length>1){
                    /*var VouchersList = component.get("v.VouchersSL"); //Vouchers
                    VouchersList = VouchersList.filter(function (el) {
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                    });
                    var currList=[];var count=0;var limit=parseInt(component.get("v.show"));
                    for(var inv in VouchersList){
                        if(count<limit){
                            currList.push(VouchersList[count]);
                            count=count+1;
                        }else break;
                     }
                    component.set("v.Vouchers",currList);*/
                    helper.getVouchers(component,event);
                }else{
                    if(searchString.length==0)helper.getVouchers(component,event);
                }
                
                break;    
            default:
                //('currentTab '+currentTab);
        }        
        }catch(ex){ 
            console.log('exception~>'+ex);
        } 
    },
    saveBill : function(component,event,helper){
        try{
            var cmp = ($A.util.isUndefined(component.find("mBill").length))?component.find("mBill"):component.find("mBill")[0]
            cmp.BillSave(function(response){
                $A.createComponent("c:Accounts_Payable",{
                    "aura:id": "AccountsPayable",
                    "selectedTab":component.get("v.selectedTab")
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {  
                        
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                }); 
            }); 
        }catch(ex){ }    
    },
    save_PO : function(component,event,helper){
        component.find("poModal").save_PO(function(response){
            $A.createComponent("c:Accounts_Payable",{
                "aura:id": "AccountsPayable",
                "selectedTab":component.get("v.selectedTab")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            }); 
        }); 
        
    },
    updatevoucher : function(component,event,helper){
        var voucherAction =  component.get("c.update_Voucher");
        let recId = event.target.dataset.record;
        var item = {};
        var vouchers = component.get("v.Vouchers");
        for(var x in vouchers){
            if(vouchers[x].Id === recId){ 
                vouchers[x].ERP7__Posted__c = !(vouchers[x].ERP7__Posted__c);
                item = vouchers[x];
                break;
            }
            
        }
        voucherAction.setParams({"recordId":recId,"fieldValue":item.ERP7__Posted__c}); 
        voucherAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.Vouchers",vouchers);
                let msg = (item.ERP7__Posted__c)?'Voucher #'+item.Name+' Approved Successfully':'Voucher #'+item.Name+' Un-Approved Successfully'
                helper.showToast($A.get('$Label.c.Success'),'success',msg);
            }
        });
        $A.enqueueAction(voucherAction);
        
    },
    updatePayment : function(component,event,helper){
        var paymentAction =  component.get("c.save_Payment");
        let recId = event.target.dataset.record;
        var item = {};
        var Payments = component.get("v.Payments");
        for(var x in Payments){
            if(Payments[x].pay.Id === recId){ 
                Payments[x].pay.ERP7__Posted__c = !(Payments[x].pay.ERP7__Posted__c);
                item = Payments[x].pay;
                break;
            }
            
        }
        paymentAction.setParams({"record":JSON.stringify(item)}); 
        paymentAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.Payments",Payments);
                let msg = (item.ERP7__Posted__c)?'Post Payment #'+item.Name+' Successfully':'UnPost Payment #'+item.Name+' Successfully'
                helper.showToast($A.get('$Label.c.Success'),'success',msg);
            }
        });
        $A.enqueueAction(paymentAction);
        
    },
    
    
    updatePaymentRecord : function(component,event,helper){
        var paymentAction =  component.get("c.save_Payment_Record");
        let recId = event.target.dataset.record;
        var item = {};
        var Payments = component.get("v.Payments");
        for(var x in Payments){
            if(Payments[x].pay.Id === recId){ 
                Payments[x].pay.ERP7__Posted__c = !(Payments[x].pay.ERP7__Posted__c);
                item = Payments[x].pay;
                break;
            }
            
        }
        paymentAction.setParams({"record":JSON.stringify(item)}); 
        paymentAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.Payments",Payments);
                let msg = (item.ERP7__Posted__c)?$A.get("$Label.c.Acc_Recev_Posted") + ' #'+item.Name:$A.get("$Label.c.Acc_Recev_Unpost")+ ' #'+item.Name +' '+$A.get("$Label.c.Success");//let msg = (item.ERP7__Posted__c)?'Post Payment #'+item.Name+' Successfully':'UnPost Payment #'+item.Name+' Successfully'
                helper.showToast($A.get('$Label.c.Success'),'success',msg);
            }else{
                var errors = response.getError();
                helper.showToast('Error!','error',$A.get("$Label.c.Entries_not_matched")); 
            }
        });
        $A.enqueueAction(paymentAction);
        
    },
    
    hideModal : function(component,event,helper){
        component.set("v.showModal",false);
        component.set("v.AcctErrMsg",null);
        component.set("v.AmtErrMsg",null);
        
    },
    getCOADetails : function(component,event,helper){
        var coaAction =  component.get("c.getPaymentAccInfo");
        coaAction.setParams({"recordId":component.get("v.voucherPayment.ERP7__Payment_Account__c")});
        coaAction.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var paymentAcc = response.getReturnValue().coa;
                component.set("v.PaymentAccountBalance",response.getReturnValue().coa.ERP7__Calculated_Ending_Balance__c);
                component.set("v.PaymentAccountBalanceConversion",response.getReturnValue().coaConCurrency.ERP7__Calculated_Ending_Balance__c);
                component.set('v.currencyType',response.getReturnValue().currencyType);
                component.set('v.currCode',response.getReturnValue().isoCode);                
            }
        });  
        $A.enqueueAction(coaAction);
    },
    
    updatePaymentAmount : function(c,e,h){
        var list = c.get("v.debitNotes1");
        var ccAmount = 0*1;
        for(var x in list){
            if(list[x].debitAmount!=null){
                ccAmount = ccAmount + list[x].debitAmount*1;
            }
        }
        c.set("v.cnAmount",ccAmount);
        if(c.get("v.cnAmount")!=0){
            /*if(c.get("v.cnAmount")==c.get("v.voucherPayment.ERP7__Amount__c")){
                c.set("v.voucherPayment.ERP7__Amount__c",ccAmount);
            }else{
                c.set("v.voucherPayment.ERP7__Amount__c",0);
            }*/
            var amount = c.get("v.payAmount") - ccAmount;
            c.set("v.voucherPayment.ERP7__Amount__c",amount);
            if(c.get("v.cnAmount")==c.get("v.payAmount")){
                c.set("v.NoPayment",true);
            }else{
                c.set("v.NoPayment",false);
            }
        }else{
            c.set("v.NoPayment",false);
        }
    },
    
    updatePaymentAmountMulti : function(c,e,h){
        var list = c.get("v.debitNotes1");
        var ccAmount = 0*1;
        for(var x in list){
            if(list[x].debitAmount!=null){
                ccAmount = ccAmount + list[x].debitAmount*1;
            }
        }
        c.set("v.cnAmount",ccAmount);
        if(c.get("v.cnAmount")!=0){
            /*if(c.get("v.cnAmount")==c.get("v.voucherPayment.ERP7__Amount__c")){
                c.set("v.voucherPayment.ERP7__Amount__c",ccAmount);
            }else{
                c.set("v.voucherPayment.ERP7__Amount__c",0);
            }*/
            var amount = c.get("v.multiTotalAmount") - ccAmount;
            c.set("v.MultiVoucherPaymentInfo.ERP7__Amount__c",amount);
            if(c.get("v.cnAmount")==c.get("v.multiTotalAmount")){
                c.set("v.NoPayment",true);
            }else{
                c.set("v.NoPayment",false);
            }
        }else{
            c.set("v.NoPayment",false);
        }
    },
    
    displayCreditNote : function(c,e,h){
        if(c.get("v.displayCN")){
            c.set("v.displayCN",false);
        }else{
            c.set("v.displayCN",true);
        }
    },
    
    
    payvoucher : function(component,event,helper){
        var recId = event.target.dataset.record;
        /*var action=component.get("c.getPayment");
        action.setParams({
            voucherId:recId
        });
        action.setCallback(this,function(r){
             if(r.getState() === 'SUCCESS'){
             });
            $A.enqueueAction(*/
        var item = {};
        var vouchers = component.get("v.Vouchers");
        for(var x in vouchers){
            if(vouchers[x].Id === recId){ 
                item = vouchers[x];
                break;
            }   
        }
        var amount=0;
        amount=item.ERP7__Amount__c-item.ERP7__Amount_Paid_Rollup__c-item.ERP7__Credit_Applied__c;
        if(amount<=0) helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.Payment_Has_Already_Been_Created'));
        else{
            component.set("v.singleVoucherToPay",item.Id);
            component.set("v.vouchered",item);
            let voucherPayment = {};
            voucherPayment['Name'] =item.Name;
            voucherPayment['ERP7__Accounts__c'] = item.ERP7__Vendor__c;
            voucherPayment['ERP7__Amount__c'] = item.ERP7__Amount__c-item.ERP7__Amount_Paid_Rollup__c-item.ERP7__Credit_Applied__c;
            //voucherPayment['ERP7__Voucher__c'] = item.Id;
            if(item.ERP7__Vendor_invoice_Bill__c != undefined) voucherPayment['ERP7__Bill__c'] = item.ERP7__Vendor_invoice_Bill__c;
            if(item.ERP7__Purchase_Orders__c != undefined) voucherPayment['ERP7__Purchase_Orders__c'] = item.ERP7__Purchase_Orders__c;
            voucherPayment['ERP7__Status__c'] = 'Paid';
            voucherPayment['ERP7__Posted__c'] = item.ERP7__Posted__c;
            voucherPayment['ERP7__Account__c'] = component.get("v.Organisation.Id");
            voucherPayment['ERP7__Payment_Type__c'] = 'Voucher';
            voucherPayment['ERP7__Transaction_Type__c']='BillPayment';
            component.set("v.billDate",item.ERP7__Vendor_invoice_Bill__r.ERP7__Bill_Date__c);
            /*var nowDate = new Date(); 
		var today = Date.parse(nowDate.getFullYear()+'-'+(nowDate.getMonth()+1)+'-'+nowDate.getDate());
        voucherPayment['ERP7__Payment_Date__c']=today;*/
            component.set("v.voucherPayment",voucherPayment);
            component.set("v.payAmount", component.get("v.voucherPayment.ERP7__Amount__c"));
            var action=component.get("c.fetchBankAccount");
            action.setParam("OrgId",component.get("v.Organisation.Id"));
            action.setCallback(this,function(r){
                if(r.getState() === 'SUCCESS'){
                    var filter = ''; var records=[]; records=r.getReturnValue();
                    for(var obj in records){
                        if(obj == 0) filter = ' And ( Id = \''+records[obj].Id+'\'';
                        else filter += ' Or Id = \''+records[obj].Id+'\'';
                    }
                    filter += ')'; 
                    component.set("v.AccountsFilter",filter);
                    console.log('AccountsFilter here~>'+filter);
                }
                else{
                }
            });
            $A.enqueueAction(action);
            helper.fetchCreditNotes(component,event,helper);
            
            component.set("v.showModal",true);
        }
    },
    pay_Voucher : function(component,event,helper){
        
        try{
            
            component.set("v.showMmainSpin",true);
            if(!component.get("v.NoPayment")){
                if(component.get("v.cnAmount")==0){
                   
                    var voucherPayment = component.get("v.voucherPayment");
                    var selectCmp = component.find("PayRecordTy");
                    voucherPayment['ERP7__Payment_Gateway__c'] = selectCmp.get("v.value");
                    //alert(selectCmp.get("v.value"));
                    var Continue=true;
                    if(voucherPayment.ERP7__Amount__c==null || voucherPayment.ERP7__Amount__c==0 || voucherPayment.ERP7__Amount__c<0 ||
                       voucherPayment.ERP7__Amount__c ==' ' || voucherPayment.ERP7__Amount__c==undefined)
                    {
                        Continue=false;
                        if(voucherPayment.ERP7__Amount__c<0 ) component.set('v.AmtErrMsg',$A.get('$Label.c.Please_enter_the_proper_amount'));
                        else component.set('v.AmtErrMsg',$A.get('$Label.c.Please_Enter_the_Amount'));
                        
                    }else{Continue=true;component.set('v.AmtErrMsg',null);}
                    if(voucherPayment.ERP7__Payment_Account__c==null || 
                       voucherPayment.ERP7__Payment_Account__c =='' || voucherPayment.ERP7__Payment_Account__c==undefined)
                    {
                        Continue=false;
                        component.set("v.AcctErrMsg",$A.get('$Label.c.Please_select_the_Payment_Account'));
                    }else{ if(Continue){Continue=true;}
                          component.set("v.AcctErrMsg",null);
                         }
                    
                    if(voucherPayment.ERP7__Payment_Date__c ==undefined){
                        Continue=false;
                        component.set("v.DateErrMsg",$A.get('$Label.c.Please_select_the_Payment_Date'));
                    }else{
                        Continue=true;
                        component.set("v.DateErrMsg",'');
                    }
                    
                    if(Continue){
                        voucherPayment['ERP7__Status__c ']='Paid';
                        voucherPayment['ERP7__Type__c']='Credit';
                        voucherPayment['ERP7__Posted__c'] = component.get('v.post');
                        console.log('JSON.stringify(voucherPayment):'+JSON.stringify(voucherPayment));
                        
                        var paymentAction  = component.get("c.save_Payment");
                        paymentAction.setParams({"record":JSON.stringify(voucherPayment),"singleVoucherToPay":component.get('v.singleVoucherToPay')});
                        paymentAction.setCallback(this,function(response){
                            if(response.getState() === 'SUCCESS'){
                                
                                component.set('v.AmtErrMsg',response.getReturnValue());
                                if(response.getReturnValue() == ''){
                                    console.log('Entered parveez');
                                    component.set("v.singleVoucherToPay","");
                                    component.set("v.AcctErrMsg",null);
                                    component.set('v.AmtErrMsg',null);
                                    component.set("v.showModal",false);                    
                                    helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.Payment_was_Successfull'));
                                    helper.getVouchers(component,event);
                                }
                                component.set("v.showMmainSpin",false);
                            } 
                            
                            
                        });
                        $A.enqueueAction(paymentAction);
                    }else{
                        component.set("v.showMmainSpin",false);
                    }
                }
                else if(component.get("v.cnAmount")>0 && (component.get("v.voucherPayment.ERP7__Amount__c")==null || component.get("v.voucherPayment.ERP7__Amount__c")==0)){
                    helper.applyCredit(component,event,helper);
                }else{
                    var paymentAction  = component.get("c.save_Payment_Credits");
                    var voucherPayment = component.get("v.voucherPayment");
                    var selectCmp = component.find("PayRecordTy");
                    voucherPayment['ERP7__Payment_Gateway__c'] = selectCmp.get("v.value");
                    //Moin added this on 04th Sep 2024 to pupulate the Debit Note applied Amount
                    if(component.get("v.cnAmount")>0){
                        voucherPayment['ERP7__Debit_Note_Applied_Amount__c'] = component.get("v.cnAmount");
                    }
                    //alert(selectCmp.get("v.value"));
                    var Continue=true;
                    if(voucherPayment.ERP7__Amount__c==null || voucherPayment.ERP7__Amount__c==0 || voucherPayment.ERP7__Amount__c<0 ||
                       voucherPayment.ERP7__Amount__c ==' ' || voucherPayment.ERP7__Amount__c==undefined)
                    {
                        Continue=false;
                        if(voucherPayment.ERP7__Amount__c<0 ) component.set('v.AmtErrMsg',$A.get('$Label.c.Please_enter_the_proper_amount'));
                        else component.set('v.AmtErrMsg','Please enter the amount');
                        
                    }else{Continue=true;component.set('v.AmtErrMsg',null);}
                    if(voucherPayment.ERP7__Payment_Account__c==null || 
                       voucherPayment.ERP7__Payment_Account__c =='' || voucherPayment.ERP7__Payment_Account__c==undefined)
                    {
                        Continue=false;
                        component.set("v.AcctErrMsg",$A.get('$Label.c.Please_select_the_Payment_Account'));
                    }else{ if(Continue){Continue=true;}
                          component.set("v.AcctErrMsg",null);
                         }
                    
                    if(voucherPayment.ERP7__Payment_Date__c ==undefined){
                        Continue=false;
                        component.set("v.DateErrMsg",$A.get('$Label.c.Please_select_the_Payment_Date'));
                    }else{
                        Continue=true;
                        component.set("v.DateErrMsg",'');
                    }
                    
                    if(Continue){
                        voucherPayment['ERP7__Status__c ']='Paid';
                        voucherPayment['ERP7__Type__c']='Credit';
                        voucherPayment['ERP7__Posted__c'] = component.get('v.post');
                        console.log('JSON.stringify(voucherPayment):'+JSON.stringify(voucherPayment));
                        
                        paymentAction.setParams({"record":JSON.stringify(voucherPayment),"singleVoucherToPay":component.get('v.singleVoucherToPay'), "cnAmount":component.get('v.cnAmount'), "dnList":component.get("v.debitNotes1")});
                        paymentAction.setCallback(this,function(response){
                            if(response.getState() === 'SUCCESS'){
                                component.set('v.AmtErrMsg',response.getReturnValue());
                                if(response.getReturnValue() == ''){
                                    component.set("v.singleVoucherToPay","");
                                    component.set("v.AcctErrMsg",null);
                                    component.set('v.AmtErrMsg',null);
                                    component.set("v.showModal",false);                    
                                    helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.Payment_was_Successfull'));
                                    helper.getVouchers(component,event);
                                    console.log("Creating and adding Accounts Payable component");
                                     var evt = $A.get("e.force:navigateToComponent");
                                    evt.setParams({
                                        componentDef : "c:Accounts_Payable",
                                        componentAttributes: {
                                            "selectedTab" : 'Payments'
                                            
                                        }
                                    });

        console.log("Firing event to navigate to Accounts Payable");
        evt.fire();
        console.log("Event fired successfully");
                                }
                                component.set("v.showMmainSpin",false);
                            }else{ 
                                 var errors = response.getError();
                                  console.log('Errors while saving:',errors);}
                        });
                        $A.enqueueAction(paymentAction);
                    }else{
                        component.set("v.showMmainSpin",false);
                    }
                }
            }
            else{
                helper.applyCredit(component,event,helper);  
            }
        }
        catch(e){console.log('Exception pay_Voucher:',e);}
        
    },
    approveVoucher : function(component, event, helper){
        var voucherAction =  component.get("c.update_VoucherApprove");
        let recId = event.target.dataset.record;
        var item = {};
        var vouchers = component.get("v.Vouchers");
        for(var x in vouchers){
            if(vouchers[x].Id === recId){ 
                vouchers[x].ERP7__Approved__c = !(vouchers[x].ERP7__Approved__c);
                item = vouchers[x];
                break;
            }
            
        }
        voucherAction.setParams({"recordId":recId,"fieldValue":item.ERP7__Approved__c}); 
        voucherAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.Vouchers",vouchers);
                let msg = 'Voucher #'+item.Name+' Approved Successfully'
                helper.showToast('Success!','success',msg);
            }
        });
        $A.enqueueAction(voucherAction);
    },
    
    approveUnVoucher : function(component, event, helper){
        var voucherAction =  component.get("c.update_VoucherApprove");
        let recId = event.target.dataset.record;
        var item = {};
        var vouchers = component.get("v.Vouchers");
        for(var x in vouchers){
            if(vouchers[x].Id === recId){ 
                vouchers[x].ERP7__Approved__c = false;
                item = vouchers[x];
                break;
            }
            
        }
        voucherAction.setParams({"recordId":recId,"fieldValue":item.ERP7__Approved__c}); 
        voucherAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.Vouchers",vouchers);
                let msg = 'Voucher #'+item.Name+' Un-Approved Successfully'
                helper.showToast('Error!','error',msg);
            }
        });
        $A.enqueueAction(voucherAction);
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            var currentTab = component.get("v.selectedTab"); 
            switch(currentTab) {
                case 'Vendor': helper.helper_getSupplierAccounts(component, event, helper);
                    break;
                case 'Purchase_Orders': helper.getpurchaseOrder(component,event);
                    break;
                case 'Bills': helper.getBills(component,event);
                    break;
                case 'Payments': helper.getPayments(component,event);
                    break;
                case 'Credit_debit_notes': helper.getDebitNotes(component,event);
                    break;
                case 'Vouchers': helper.getVouchers(component,event);
                    break;    
                default:
                    //('currentTab '+currentTab);
            }
        }
    },
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            var currentTab = component.get("v.selectedTab"); 
            switch(currentTab) {
                case 'Vendor': helper.helper_getSupplierAccounts(component, event, helper);
                    break;
                case 'Purchase_Orders': helper.getpurchaseOrder(component,event);
                    break;
                case 'Bills': helper.getBills(component,event);
                    break;
                case 'Payments': helper.getPayments(component,event);
                    break;
                case 'Credit_debit_notes': helper.getDebitNotes(component,event);
                    break;
                case 'Vouchers': helper.getVouchers(component,event);
                    break;    
                default:
                    //('currentTab '+currentTab);
            }
        }
    },
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            var currentTab = component.get("v.selectedTab"); 
            switch(currentTab) {
                case 'Vendor': helper.helper_getSupplierAccounts(component, event, helper);
                    break;
                case 'Purchase_Orders': helper.getpurchaseOrder(component,event);
                    break;
                case 'Bills': helper.getBills(component,event);
                    break;
                case 'Payments': helper.getPayments(component,event);
                    break;
                case 'Credit_debit_notes': helper.getDebitNotes(component,event);
                    break;
                case 'Vouchers': helper.getVouchers(component,event);
                    break;    
                default:
                    //('currentTab '+currentTab);
            }
        }
    },
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            var currentTab = component.get("v.selectedTab"); 
            switch(currentTab) {
                case 'Vendor': helper.helper_getSupplierAccounts(component, event, helper);
                    break;
                case 'Purchase_Orders': helper.getpurchaseOrder(component,event);
                    break;
                case 'Bills': helper.getBills(component,event);
                    break;
                case 'Payments': helper.getPayments(component,event);
                    break;
                case 'Credit_debit_notes': helper.getDebitNotes(component,event);
                    break;
                case 'Vouchers': helper.getVouchers(component,event);
                    break;    
                default:
                    //('currentTab '+currentTab);
            }
        }
    },
    Ofset : function(component,event,helper){
        var Offsetval = event.currentTarget.getAttribute('data-recordId');
        var curOffset = component.get("v.Offset");
        var show = parseInt(component.get("v.show"));
        if(((curOffset+show)/show) != Offsetval){
            var newOffset = (show*Offsetval)-show;
            component.set("v.Offset", newOffset);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((newOffset+show)/show));
        }
        var currentTab = component.get("v.selectedTab"); 
        switch(currentTab) {
            case 'Vendor': helper.helper_getSupplierAccounts(component, event, helper);
                break;
            case 'Purchase_Orders': helper.getpurchaseOrder(component,event);
                break;
            case 'Bills': helper.getBills(component,event);
                break;
            case 'Payments': helper.getPayments(component,event);
                break;
            case 'Credit_debit_notes': helper.getDebitNotes(component,event);
                break;
            case 'Vouchers': helper.getVouchers(component,event);
                break;    
            default:
                //('currentTab '+currentTab);
        }
        
    },
    OfsetChange : function(component,event,helper){
        var Offsetval ;
        if(component.get("v.selectedTab")=='Vendor')Offsetval= component.find("ik").get("v.value");
        if(component.get("v.selectedTab")=='Purchase_Orders')Offsetval= component.find("ikPO").get("v.value");
        if(component.get("v.selectedTab")=='Bills')Offsetval= component.find("ikBills").get("v.value");
        if(component.get("v.selectedTab")=='Payments')Offsetval= component.find("ikPay").get("v.value");
        if(component.get("v.selectedTab")=='Credit_debit_notes')Offsetval= component.find("ikCre").get("v.value");
        if(component.get("v.selectedTab")=='Vouchers')Offsetval= component.find("ikVou").get("v.value");
        var curOffset = component.get("v.Offset");
        var show = parseInt(component.get("v.show"));
        if(Offsetval > 0 && Offsetval <= component.get("v.PNS").length){
            if(((curOffset+show)/show) != Offsetval){
                var newOffset = (show*Offsetval)-show;
                component.set("v.Offset", newOffset);
                component.set("v.CheckOffset",true);
                var pageNum = (newOffset + show)/show;
                component.set("v.PageNum",pageNum);
            }
            var currentTab = component.get("v.selectedTab"); 
            switch(currentTab) {
                case 'Vendor': helper.helper_getSupplierAccounts(component, event, helper);
                    break;
                case 'Purchase_Orders': helper.getpurchaseOrder(component,event);
                    break;
                case 'Bills': helper.getBills(component,event);
                    break;
                case 'Payments': helper.getPayments(component,event);
                    break;
                case 'Credit_debit_notes': helper.getDebitNotes(component,event);
                    break;
                case 'Vouchers': helper.getVouchers(component,event);
                    break;    
                default:
                    //('currentTab '+currentTab);
            }
            
        } else component.set("v.PageNum",((curOffset+show)/show));
    },
    setShow : function(cmp,event,helper){
        cmp.set("v.startCount", 0);
        cmp.set("v.endCount", 0);
        cmp.set("v.Offset", 0);
        cmp.set("v.PageNum", 1);
        var currentTab = cmp.get("v.selectedTab"); 
        switch(currentTab) {
            case 'Vendor': helper.helper_getSupplierAccounts(cmp, event, helper);
                break;
            case 'Purchase_Orders': helper.getpurchaseOrder(cmp,event);
                break;
            case 'Bills': helper.getBills(cmp,event);
                break;
            case 'Payments': helper.getPayments(cmp,event);
                break;
            case 'Credit_debit_notes': helper.getDebitNotes(cmp,event);
                break;
            case 'Vouchers': helper.getVouchers(cmp,event);
                break;    
            default:
                //('currentTab '+currentTab);
        }
    },    
    
    /*   createPayment:function(component,event,helper){
         var createRecordEvent = $A.get("e.force:createRecord");
         if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": 'ERP7__Payment__c',
                "defaultFieldValues":{
                "Parent_id" : cmp.get("v.Parent_id"),
                "Name" : "Test anem",
                "AccountId" : cmp.get("v.accountId"),
                },
          });
          createRecordEvent.fire();
         }
       //component.set('v.schedular',true);
   },*/
    
    fetchDetails : function(component,event,helper){
        component.set("v.DisplayCard",false);
        var selected=event.getSource().get("v.value");
        if(selected=='Card Payments'){
            var action=component.get("c.fetchCardAccount");
            action.setParam("OrgId",component.get("v.Organisation.Id"));
            action.setCallback(this,function(r){
                if(r.getState() === 'SUCCESS'){
                    var filter = ''; var records=[]; records=r.getReturnValue();
                    for(var obj in records){
                        if(obj == 0) filter = ' And ( Id = \''+records[obj].Id+'\'';
                        else filter += ' Or Id = \''+records[obj].Id+'\'';
                    }
                    filter += ')'; 
                    component.set("v.AccountsFilter",filter);
                    if(records.length>0)  component.set("v.DisplayCard",true);
                }
                else{
                }
            });
            $A.enqueueAction(action);
        }else {
            var action=component.get("c.fetchBankAccount");
            action.setParam("OrgId",component.get("v.Organisation.Id"));
            action.setCallback(this,function(r){
                if(r.getState() === 'SUCCESS'){
                    var filter = ''; var records=[]; records=r.getReturnValue();
                    for(var obj in records){
                        if(obj == 0) filter = ' And ( Id = \''+records[obj].Id+'\'';
                        else filter += ' Or Id = \''+records[obj].Id+'\'';
                    }
                    filter += ')'; 
                    component.set("v.AccountsFilter",filter);
                    
                }
                else{
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    tabularView: function(component,event,helper)
    {
        component.set('v.tabular',true);
        component.set('v.grid',false);
    },
    
    gridView: function(component,event,helper)
    {
        component.set('v.tabular',false);
        component.set('v.grid',true);
    },
    
    /*fetchContactsById: function(component,event,helper)
    {
        //var params = event.getParam('arguments');
        //if(params) var id = params.Id;
        var id = '0011o00001ttkXCAAY';
        var apply = component.get('c.getContactsByAccId');
         apply.setParams({
            Id : id
        });   
         action1.setCallback(this, function(a1) 
        {
            component.set("v.Contacts", a1.getReturnValue());
        });
        $A.enqueueAction(apply);
    }*/
    
    getCOADetails1 : function(component,event,helper){
        /*component.set("v.PaymentAccountBalance",0.00);
        component.set("v.PaymentAccountBalanceConversion",0.00);
        component.set('v.currencyType','');
        component.set('v.currCode','');*/
        var coaAction =  component.get("c.getPaymentAccInfo");
        coaAction.setParams({"recordId":component.get("v.MultiVoucherPaymentInfo.ERP7__Payment_Account__c")});
        coaAction.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var paymentAcc = response.getReturnValue().coa;
                component.set("v.PaymentAccountBalance",response.getReturnValue().coa.ERP7__Calculated_Ending_Balance__c);
                component.set("v.PaymentAccountBalanceConversion",response.getReturnValue().coaConCurrency.ERP7__Calculated_Ending_Balance__c);
                component.set('v.currencyType',response.getReturnValue().currencyType);
                component.set('v.currCode',response.getReturnValue().isoCode);
                
            }
        });  
        $A.enqueueAction(coaAction);
    },
    
    hideMultiModal : function(component,event,helper){
        component.set("v.showMultiPayment",false);
        component.set("v.listOfVouchers",[]);
        component.set("v.AcctErrMsg",null);
        component.set("v.AmtErrMsg",null);
        
    },
    
    doneMultiPayment : function(cmp,event,helper){
        console.log('listOfVouchers:',cmp.get("v.listOfVouchers"));
        var listOfVouchers=[];
        var selectedVoucherLength = 0;
        var amount=0;
        var multiVoucher=[];
        var Vouchers=cmp.get('v.Vouchers');
        var voucherVenderId;
        for(var i=0;i<Vouchers.length;i++){
            if(Vouchers[i].checkSelected != undefined){
                if(Vouchers[i].checkSelected == true){
                    voucherVenderId=Vouchers[i].ERP7__Vendor__c;
                    break;
                }
            }
        }
        for(var i=0;i<Vouchers.length;i++){
            if(Vouchers[i].checkSelected != undefined){
                if(Vouchers[i].checkSelected == true){
                    selectedVoucherLength++;
                }
            }
        }
        for(var i=0;i<Vouchers.length;i++){
            if(Vouchers[i].checkSelected != undefined){
                if(Vouchers[i].checkSelected == true){
                    if(Vouchers[i].ERP7__Approved__c == false){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Acc_Pay_Voucher')+Vouchers[i].Name+$A.get('$Label.c.is_not_Approved'));
                        return;
                    }
                    /*if(Vouchers[i].ERP7__Amount_Paid_Rollup__c != 0){
                        helper.showToast('Error!','error','Voucher '+Vouchers[i].Name+' was partially paid. Not allowed to select partial paid Vouchers.');
                        return;
                    }*/
                    if(Vouchers[i].ERP7__Vendor__c == undefined){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Vendor_is_not_assigned_to_Vouchers')+Vouchers[i].Name);
                        return;
                    }
                    if(voucherVenderId != Vouchers[i].ERP7__Vendor__c){
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_select_Vouchers_from_same_Vendor'));
                        return;
                    }
                }
            }
        }
        for(var i=0;i<Vouchers.length;i++){
            if(Vouchers[i].checkSelected != undefined){
                if(Vouchers[i].checkSelected == true){
                    console.log('Vouchers:',Vouchers[i]);
                    //listOfVouchers.push(Vouchers[i].Id);
                    //listOfVouchers.push(Vouchers[i]);
                    listOfVouchers.push(Object.assign({}, Vouchers[i]));
                    //listOfVouchers.push(JSON.parse(JSON.stringify(Vouchers[i])));
                    amount += Vouchers[i].ERP7__Amount__c-Vouchers[i].ERP7__Amount_Paid_Rollup__c;
                    
                    multiVoucher[i]={};
                    multiVoucher[i].Name =Vouchers[i].Name;
                    multiVoucher[i].ERP7__Accounts__c = Vouchers[i].ERP7__Vendor__c;
                    cmp.set("v.multipleVoucherVendor",Vouchers[i].ERP7__Vendor__c);
                    //multiVoucher[i].ERP7__Amount__c = Vouchers[i].ERP7__Amount__c-Vouchers[i].ERP7__Amount_Paid_Rollup__c;
                    if(Vouchers[i].ERP7__Purchase_Orders__c != undefined && selectedVoucherLength==1) multiVoucher[i].ERP7__Purchase_Orders__c = Vouchers[i].ERP7__Purchase_Orders__c;
                    if(selectedVoucherLength==1) multiVoucher[i].ERP7__Voucher__c = Vouchers[i].Id;
                    if(Vouchers[i].ERP7__Vendor_invoice_Bill__c != undefined && selectedVoucherLength==1) multiVoucher[i].ERP7__Bill__c = Vouchers[i].ERP7__Vendor_invoice_Bill__c;
                    multiVoucher[i].ERP7__Status__c = 'Paid';
                    multiVoucher[i].ERP7__Posted__c = Vouchers[i].ERP7__Posted__c;
                    multiVoucher[i].ERP7__Account__c = cmp.get("v.Organisation.Id");
                    multiVoucher[i].ERP7__Payment_Type__c = 'Voucher';
                    multiVoucher[i].ERP7__Transaction_Type__c='BillPayment';
                    
                }
            }
        }
        if(listOfVouchers.length == 0){
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_select_Vouchers_for_payment'));
            return;
        }
        //if(listOfVouchers.length>1) cmp.set("v.disablemultiTotalAmount",true);
        //else cmp.set("v.disablemultiTotalAmount",false);
        console.log('amount:',amount);
        cmp.set('v.multiTotalAmount',amount);
        var multiVoucher1=[];
        for(var j=0;j<multiVoucher.length;j++){
            if(multiVoucher[j] != undefined) multiVoucher1.push(multiVoucher[j]);
        }
        cmp.set("v.MultiVoucherPayment",multiVoucher1);
        
        
        var MultiVoucherPaymentInfo =multiVoucher1[0];
        cmp.set('v.MultiVoucherPaymentInfo',MultiVoucherPaymentInfo);
        
        for(let i in listOfVouchers){
            listOfVouchers[i].ERP7__Amount__c-=listOfVouchers[i].ERP7__Amount_Paid_Rollup__c;
            listOfVouchers[i].ERP7__Amount_Due__c = listOfVouchers[i].ERP7__Amount__c;
            listOfVouchers[i].ActualAmount=listOfVouchers[i].ERP7__Amount__c;
        }            
        cmp.set("v.listOfVouchers",listOfVouchers);
        
        var action=cmp.get("c.fetchBankAccount");
        action.setParam("OrgId",cmp.get("v.Organisation.Id"));
        action.setCallback(this,function(r){
            if(r.getState() === 'SUCCESS'){
                var filter = ''; var records=[]; records=r.getReturnValue();
                for(var obj in records){
                    if(obj == 0) filter = ' And ( Id = \''+records[obj].Id+'\'';
                    else filter += ' Or Id = \''+records[obj].Id+'\'';
                }
                filter += ')'; 
                cmp.set("v.AccountsFilter",filter);
                
            }
            else{
            }
        });
        $A.enqueueAction(action);
        cmp.set('v.showMultiPayment',true);
        helper.getPayTerm(cmp,event,helper);
        var action=cmp.get("c.fetchDebitNote");
        action.setParam("CusAccId",multiVoucher1[0].ERP7__Accounts__c);
        action.setCallback(this,function(r){
            if(r.getState() === 'SUCCESS'){
                cmp.set("v.debitNotes1",r.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        //helper.fetchCreditNotes(component,event,helper);
    },
    
    pay_Voucher1 : function(component,event,helper){
        console.log('inside pay_Voucher1');
        var paymentAction  = component.get("c.save_Payment_Multi");
        var MultiVoucherPayment = component.get("v.MultiVoucherPaymentInfo");
        var selectCmp = component.find("PayRecord");
        MultiVoucherPayment['ERP7__Payment_Gateway__c'] = selectCmp.get("v.value");
        var totalAmount=component.get('v.multiTotalAmount');
        var Vouchers=component.get('v.Vouchers');
        var listOfVouchers=component.get('v.listOfVouchers');
        var advCount=0;
        var poCount=0;
        var expCount=0;
        //let totalAmountOfVoucher=0;
        /*for(var i in listOfVouchers){
            for(var j in Vouchers){ 
                console.log('Vouchers[j]:',Vouchers[j]);
                if(listOfVouchers[i].Id==Vouchers[j].Id){    
                    console.log('inside loop');
                    totalAmountOfVoucher+=Vouchers[j].ERP7__Amount__c-Vouchers[j].ERP7__Amount_Paid_Rollup__c;
                    console.log('totalAmountOfVoucher:',totalAmountOfVoucher);
                    console.log('Vouchers[j].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName:',Vouchers[j].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName);
                    if(Vouchers[j].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName =="Advance_to_vendor"){
                        advCount++;
                    }else if(Vouchers[j].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName =="PO_Bill" || Vouchers[j].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName =="Expense_Bill"){
                        poCount++;
                    }
                }                    
            }
        }*/
        let isCorrectAmount=true;
        for(var i in listOfVouchers){
            console.log('listOfVouchers:',listOfVouchers[i]);
            if(parseFloat(listOfVouchers[i].ERP7__Amount__c) <= 0 || parseFloat(listOfVouchers[i].ERP7__Amount__c) > listOfVouchers[i].ActualAmount){
                if(parseFloat(listOfVouchers[i].ERP7__Amount__c) <= 0) component.set('v.AmtErrMsg',"Voucher - "+ listOfVouchers[i].Name + ' : Please check vouches amount');
                if(parseFloat(listOfVouchers[i].ERP7__Amount__c) > listOfVouchers[i].ActualAmount) component.set('v.AmtErrMsg',"Voucher - "+ listOfVouchers[i].Name + ' : Amount can not be greater than due amount');
                isCorrectAmount=false;
                return;
            }else{
                component.set('v.AmtErrMsg',null);
                isCorrectAmount=true; 
            }
            /*if(listOfVouchers[i].ERP7__Amount__c > listOfVouchers[i].ActualAmount){
                component.set('v.AmtErrMsg',"Voucher - "+ listOfVouchers[i].Name + ' : Amount can not be greater than due amount');
                isCorrectAmount=false;
            }else{
                component.set('v.AmtErrMsg',null);
                isCorrectAmount=true;
            }*/
            //totalAmountOfVoucher+=listOfVouchers[j].ERP7__Amount__c-listOfVouchers[j].ERP7__Amount_Paid_Rollup__c;
            //console.log('totalAmountOfVoucher:',totalAmountOfVoucher);
            console.log('Vouchers[j].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName:',listOfVouchers[i].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName);
            if(listOfVouchers[i].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName =="Advance_to_vendor"){
                advCount++;
            }else if(listOfVouchers[i].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName =="PO_Bill" || listOfVouchers[i].ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName =="Expense_Bill"){
                poCount++;
            }            
        }
        
        var isSame=false;
        if(advCount == listOfVouchers.length){
            isSame=true;
        }else if(poCount == listOfVouchers.length){
            isSame=true;            
        }/*else if(expCount == listOfVouchers.length){
            isSame=true;
        }*/
        console.log('isSame:',isSame);
        if(!isSame){
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Can_not_paid_Advance_Bill_vouchers_with_PO_or_Expense_Bill_Vouchers'));
            return;
        }
        console.log('inside pay_Voucher1');
        var Continue=true;
        
        if(MultiVoucherPayment.ERP7__Payment_Account__c==null || MultiVoucherPayment.ERP7__Payment_Account__c =='' || MultiVoucherPayment.ERP7__Payment_Account__c==undefined){
            Continue=false;
            component.set("v.AcctErrMsg",$A.get('$Label.c.PH2_please_select_the_payment_account'));
        }else{
            if(Continue){Continue=true;}
            component.set("v.AcctErrMsg",null);
        }
        
        let isDate=true;
        if(MultiVoucherPayment.ERP7__Payment_Date__c == undefined){
            isDate=false;
            component.set('v.DateErrMsg1',$A.get('$Label.c.Please_select_payment_date'));
        }else{
            isDate=true;component.set('v.DateErrMsg1',null);
        }
        
        /*let isCorrectAmount=true;
        console.log('totalAmount:'+totalAmount);
        console.log('totalAmountOfVoucher:'+totalAmountOfVoucher);
        if(totalAmount > totalAmountOfVoucher){
            isCorrectAmount=false;
            component.set('v.AmtErrMsg','Please check vouches amount');
        }else if(totalAmount==null || totalAmount==0 || totalAmount<0 ||  totalAmount ==' ' || totalAmount==undefined){
            isCorrectAmount=false;
            if(totalAmount<0 ) component.set('v.AmtErrMsg','Voucher amount is in negative');
            else component.set('v.AmtErrMsg','Please check vouches amount');
        }else{
            isCorrectAmount=true;component.set('v.AmtErrMsg',null);
        }*/
        console.log('AmtErrMsg:',component.get('v.AmtErrMsg'));
        console.log('Continue:',Continue);
        console.log('isDate:',isDate);
        console.log('isCorrectAmount:',isCorrectAmount);
        if(Continue && isDate && isCorrectAmount){
            component.set("v.showMmainSpin",true);
            for(let i in listOfVouchers){
                delete listOfVouchers[i]['ActualAmount'];
                delete listOfVouchers[i]['checkSelected'];
            }
            
            console.log('listOfVouchers:',listOfVouchers);
            MultiVoucherPayment['ERP7__Status__c ']='Paid';
            MultiVoucherPayment['ERP7__Type__c']='Credit';
            MultiVoucherPayment['ERP7__Posted__c'] = component.get('v.postForMulti');
            console.log('MultiVoucherPayment:',JSON.stringify(MultiVoucherPayment));
            console.log('totalAmount:',totalAmount);
            console.log('voucherList:',component.get('v.listOfVouchers'));            
            paymentAction.setParams({"record":JSON.stringify(MultiVoucherPayment),totalAmount:totalAmount,voucherList:JSON.stringify(component.get('v.listOfVouchers')),dnList:component.get("v.debitNotes1")});
            paymentAction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    component.set("v.AcctErrMsg",null);
                    component.set('v.AmtErrMsg',null);
                    component.set("v.showMultiPayment",false);
                    helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.Payment_was_Successfull'));
                    helper.getVouchers(component,event);
                    component.set("v.showMmainSpin",false);
                }else{
                    console.log('Error:',response.getError());
                    component.set("v.AcctErrMsg",null);
                    component.set('v.AmtErrMsg',null);
                    component.set("v.showMultiPayment",false);
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Some_error_has_occured_Please_contact_your_administrator'));                    
                    helper.getVouchers(component,event);
                    component.set("v.showMmainSpin",false);                    
                }
            });
            $A.enqueueAction(paymentAction);
        }
    },
    
    apply_Voucher1 : function(component,event,helper){
        console.log('inside apply_Voucher1');
        var paymentAction  = component.get("c.save_Payment_Multi_Applied");
        component.set("v.showMmainSpin",true);
        var listOfVouchers=component.get('v.listOfVouchers');
        for(let i in listOfVouchers){
            delete listOfVouchers[i]['ActualAmount'];
            delete listOfVouchers[i]['checkSelected'];
        }            
        paymentAction.setParams({voucherList:JSON.stringify(component.get('v.listOfVouchers')),dnList:component.get("v.debitNotes1")});
        paymentAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.AcctErrMsg",null);
                component.set('v.AmtErrMsg',null);
                component.set("v.showMultiPayment",false);
                helper.showToast($A.get('$Label.c.Success'),'success','Credit Applied Successfully');
                helper.getVouchers(component,event);
                component.set("v.showMmainSpin",false);
            }else{
                console.log('Error:',response.getError());
                component.set("v.AcctErrMsg",null);
                component.set('v.AmtErrMsg',null);
                component.set("v.showMultiPayment",false);
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Some_error_has_occured_Please_contact_your_administrator'));                    
                helper.getVouchers(component,event);
                component.set("v.showMmainSpin",false);                    
            }
        });
        $A.enqueueAction(paymentAction);
    },
    
    handleTotalAmount:function(cmp,event){        
        let listOfVouchers=cmp.get("v.listOfVouchers");
        let amount=0;
        for(var i in listOfVouchers)
            if(listOfVouchers[i].ERP7__Amount__c != '') amount+=parseFloat(listOfVouchers[i].ERP7__Amount__c);
        cmp.set("v.multiTotalAmount",amount);
        
    },
    /*navigatetoPO : function(component, event, helper) {
        var POId = event.currentTarget.getAttribute('data-POId');  
         var evt = $A.get("e.force:navigateToComponent");
         evt.setParams({
             componentDef : "c:CreatePurchaseOrder",
             componentAttributes: {
                 recordId : POId,
                 fromCB : "true"
             }
         });
         evt.fire();        
    },*/
    navigatetoPO : function(component,event,helper){
        var POId = event.currentTarget.getAttribute('data-POId');  
        $A.createComponent("c:CreatePurchaseOrder",{
            "recordId" : POId,
            "fromAP" :true,
            "navigateToRecord":false,
            "cancelclick":component.getReference("c.backTO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    
    /*payvoucher11 : function(component,event,helper){
       var recId = event.target.dataset.record;
        
        var item = {};
        var vouchers = component.get("v.Vouchers");
        for(var x in vouchers){
            if(vouchers[x].Id === recId){ 
                item = vouchers[x];
                break;
            }   
        }
        var amount=0;
        amount=item.ERP7__Amount__c-item.ERP7__Amount_Paid_Rollup__c;
        if(amount<=0) helper.showToast('Warning!','warning','Payment Has Already Been Created');
        else{
        let voucherPayment = {};
        voucherPayment['Name'] =item.Name;
        voucherPayment['ERP7__Accounts__c'] = item.ERP7__Vendor__c;
        voucherPayment['ERP7__Amount__c'] = item.ERP7__Amount__c-item.ERP7__Amount_Paid_Rollup__c;
        voucherPayment['ERP7__Voucher__c'] = item.Id;
        if(item.ERP7__Vendor_invoice_Bill__c != undefined) voucherPayment['ERP7__Bill__c'] = item.ERP7__Vendor_invoice_Bill__c;
        voucherPayment['ERP7__Status__c'] = 'Paid';
        voucherPayment['ERP7__Posted__c'] = item.ERP7__Posted__c;
        voucherPayment['ERP7__Account__c'] = component.get("v.Organisation.Id");
        voucherPayment['ERP7__Payment_Type__c'] = 'Voucher';
        voucherPayment['ERP7__Transaction_Type__c']='BillPayment';
        component.set("v.voucherPayment",voucherPayment);
        var action=component.get("c.fetchBankAccount");
        action.setParam("OrgId",component.get("v.Organisation.Id"));
        action.setCallback(this,function(r){
             if(r.getState() === 'SUCCESS'){
                 var filter = ''; var records=[]; records=r.getReturnValue();
                  for(var obj in records){
                      if(obj == 0) filter = ' And ( Id = \''+records[obj].Id+'\'';
                       else filter += ' Or Id = \''+records[obj].Id+'\'';
                  }
                  filter += ')'; 
                  component.set("v.AccountsFilter",filter);
                  
             }
            else{
            }
        });
       $A.enqueueAction(action);
        component.set("v.showModal",true);
       }
    },*/
    
    closePopUP : function(component, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Accounts_Payable",
            componentAttributes: {
                "aura:id": "AccountsPayable",
                "selectedTab":"Purchase_Orders"
            }
        });
        evt.fire();
    },
    
    onCheck: function(component,event,helper){
        component.set("v.ShowPOType", false);
        var currBillTrye = event.currentTarget.getAttribute('data-billType');
        if(currBillTrye == 'PO'){
            $A.createComponent("c:CreatePurchaseOrder",{
                "aura:id": "poModal",
                "navigateToRecord":false,
                "fromAP":true,
                "cancelclick":component.getReference("c.backTO"),
                "saveclick":component.getReference("c.save_PO")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }else{
            $A.createComponent("c:CreatePurchaseOrder",{
                "aura:id": "poModal",
                "navigateToRecord":false,
                "cancelclick":component.getReference("c.backTO"),
                "saveclick":component.getReference("c.save_PO"),
                "returnToVendor" : true
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
    },
    
    
    
    createDebitPayment : function(component,event,helper){
        $A.createComponent("c:CreateDebitNotePayment",{
            "aura:id": "poModal"
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    navigateDebitPayment : function(component,event,helper){
        $A.createComponent("c:CreateDebitNotePayment",{
            "aura:id": "poModal",
            "DNId" : event.target.dataset.record
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    createMultiPO : function(cmp, event, helper) {
        $A.createComponent("c:MultiplePurchaseOrders",{
            "fromAP" : true
        },function(newCmp, status, errorMessage){
            console.log('status : ',status);
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
                
            }
        });
    },
    
    
    //__________________________________________________________   
    handlecustomermenu: function(component,event,helper){
        var operation = event.detail.menuItem.get("v.label");
        if(operation == "New Purchase Order"){
            console.log('new po');
            $A.createComponent("c:CreatePurchaseOrder",{
                
                "aura:id": "poModal",
                "navigateToRecord":false,
                "cancelclick":component.getReference("c.backTO"),
                "saveclick":component.getReference("c.save_PO")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    newCmp.set('v.PO.ERP7__Vendor__r',{'Id':event.detail.menuItem.get("v.value"),'Name':event.detail.menuItem.get("v.title")});
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }else if(operation == "New Bill"){
            console.log('CreateBill calling here2');
            var orgId=component.get('v.Organisation.Id');
            var obj = {'ERP7__Organisation__c':orgId,'ERP7__Amount__c':0.00,'ERP7__Discount_Amount__c':0.00,'ERP7__VAT_TAX_Amount__c':0.00};
            if(!$A.util.isUndefined(event.detail.menuItem.get("v.value")))
                obj['ERP7__Vendor__r'] = {'Id':event.detail.menuItem.get("v.value"),'Name':event.detail.menuItem.get("v.title")};
            $A.createComponent("c:CreateBill",{
                "aura:id": "mBill",
                "Bill": obj,
                "navigateToRecord":false,
                "fromAP":true,
                "cancelclick":component.getReference("c.backTO"),
                "saveclick":component.getReference("c.saveBill")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });   
        }else if(operation == "New Debit Note"){
            var defaults = {'ERP7__Organisation__c':component.get("v.Organisation.Id"),'ERP7__Account__c':event.detail.menuItem.get("v.value")}
            helper.createRecord(component,event,'ERP7__Debit_Note__c',defaults);
        }else if(operation == "Report"){
            var name=event.detail.menuItem.get("v.value");
            var reportUrl = $A.get("$Label.c.Vendor_Ledger");
            reportUrl = reportUrl + 'fv0=' + name;
            window.open(reportUrl,'_blank');
        }
        
    },
    
    
    createBill_PO_Lightning_button : function(component,event,helper){         
        var fetchpoliAction = component.get("c.fetch_Polis");
        fetchpoliAction.setParams({"Id":event.detail.menuItem.get("v.value")});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    var po = JSON.parse(resultList[0]);
                    var poliList = JSON.parse(resultList[1]);
                    //alert('1==>'+JSON.stringify(poliList));
                    if(!$A.util.isEmpty(poliList)){
                        console.log('CreateBill calling here');
                        var obj = {'ERP7__Amount__c':0.00,'ERP7__Discount_Amount__c':0.00,'ERP7__VAT_TAX_Amount__c':0.00};
                        if(!$A.util.isUndefined(event.detail.menuItem.get("v.value")))
                            //obj['ERP7__Purchase_Order__r'] = {'Id':event.target.dataset.record,'Name':event.target.dataset.name};
                            $A.createComponent("c:CreateBill",{
                                "showExpenseAccount":false,
                                "aura:id": "mBill",
                                "Bill": obj,
                                "navigateToRecord":false,
                                "fromAP":true,
                                "cancelclick":component.getReference("c.backTO"),
                                "saveclick":component.getReference("c.saveBill")
                            },function(newCmp, status, errorMessage){
                                if (status === "SUCCESS") {
                                    var body = component.find("body");
                                    newCmp.set('v.Bill.ERP7__Purchase_Order__c',event.detail.menuItem.get("v.value"));
                                    newCmp.set('v.Bill.ERP7__Organisation__c',component.get("v.Organisation.Id"));
                                    body.set("v.body", newCmp);
                                }
                            });
                        //
                    }else{
                        helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_Bill_Has_Already_Been_Created'));
                        
                        
                    }
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
    },
    
    onControllerFieldChange : function(component,event,helper){
        helper.getBills(component,event);
    },
    
    onDateFieldChange : function(component,event,helper){
        helper.paymentTerms(component,event,helper);
    },
    
    TermChange : function(component,event,helper){
        var disPlan = component.find("mySelect").get("v.value");
        if(disPlan!='--None--'){
            var myArray = disPlan.split("%");
            let word = myArray[0];
            var amount = parseFloat(word);
            component.set("v.MultiVoucherPaymentInfo.ERP7__Discount_Rate__c",amount);
            var disPer = amount/100;
            component.set("v.MultiVoucherPaymentInfo.ERP7__Discount_Amount__c",component.get("v.multiTotalAmount")*disPer);
        }else{
            component.set("v.MultiVoucherPaymentInfo.ERP7__Discount_Rate__c",null);
            component.set("v.MultiVoucherPaymentInfo.ERP7__Discount_Amount__c",null);
        }
    },
    
    calledMultiplePO : function(component, event, helper) {
        // Set attribute values for the LWC component
        var lwcAttributes = {
            showtab2: true,
            SelectedSalesOrderList: component.get("v.SelectedPOS"),
            fromAp : true
        };
        
        // Dynamically create LWC component and pass attribute values
        $A.createComponent(
            "c:mulitplePOtoBill",
            lwcAttributes,
            function(newComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    // Render the LWC component in the container
                    var container = component.find("body");
                    container.set("v.body", newComponent);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },
    
    calledMultipleExis : function(component, event, helper){
        var obj = {'ERP7__Amount__c':0.00,'ERP7__Discount_Amount__c':0.00,'ERP7__VAT_TAX_Amount__c':0.00};
        $A.createComponent("c:CreateBill",{
            "showExpenseAccount":false,
            "aura:id": "mBill",
            "Bill": obj,
            "navigateToRecord":false,
            "fromAP":true,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.saveBill"),
            "setRT":"PO Bill",
            "ShowBillType":false,
            "showPage":true,
            "isMultiPOBill":true,
            "POIdsList":component.get("v.SelectedPOS")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                //newCmp.set('v.Bill.ERP7__Purchase_Order__c',event.target.dataset.record);
                //newCmp.set('v.Bill.ERP7__Organisation__c',component.get("v.Organisation.Id"));
                body.set("v.body", newCmp);
            }
        });
    },
    
    navigateToClosingComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ManageClosingOfBooksCheckList",
            componentAttributes: {
                AP:component.get("v.AccoutingPeriod")
            }
        });
        evt.fire();
    },

    ManagePo :  function(component, event, helper) {
        //var url = '/apex/ERP7__CreatePurchaseOrderLC?PoId='+event.target.dataset.record+'&EditPO='+true;
        //window.open(url,"_self");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreatePurchaseOrder",
            componentAttributes: {
                recordId:event.target.dataset.record,
                fromAP : true
            }
        });
        evt.fire();
    },
    
    ClonePo :  function(component, event, helper) {
        //var url = '/apex/ERP7__CreatePurchaseOrderLC?PoId='+event.target.dataset.record+'&EditPO='+true;
        //window.open(url,"_self");
        var recId = event.currentTarget.dataset.record;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreatePurchaseOrder",
            componentAttributes: {
                clonePOId:recId,
                recordId:recId,
                fromAP : true
            }
        });
        evt.fire();
    },
    
    EdiVoucher: function(component, event, helper) {
        var recId = event.target.closest('a').dataset.record;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recId
        });

        // Register an event listener for record save success
        editRecordEvent.fire();
		
    },
    
    EdiPayment: function(component, event, helper) {
        var recId = event.target.closest('a').dataset.record;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recId
        });

        // Register an event listener for record save success
        editRecordEvent.fire();
		
    },

    ManageDebitNote :  function(component, event, helper) {
        var recId = event.target.closest('a').dataset.record;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreateDebitNote",
            componentAttributes: {
                DebitId:recId,
                fromAP : true,
                navigateToRecord : false,
                showPage : true,
                isUpdate : true
            }
        });
        evt.fire();
    },
    
    navigateToDashboard : function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ARAPDashboard",
            componentAttributes: {  
                fromAP : true
            }
        });
        evt.fire();
    }
    
})










({
	showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message 
            });
            toastEvent.fire();
        }
    },
    hideSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");    
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");   
    },
    helper_getSupplierAccounts : function(component,event){
        var vendorAction = component.get('c.getSupplierAccounts');
        //vendorAction.setStorable();
        vendorAction.setParams({"OrgID" : component.get("v.Organisation.Id"),  Offset: component.get("v.Offset"),
          RecordLimit: component.get('v.show'), searchString :component.get('v.setSearch')
        });
        vendorAction.setCallback(this,function(response){
            if(response.getState() ==='SUCCESS'){
            	component.set("v.vendorAccounts",response.getReturnValue().acc);
                component.set("v.vendorAccountsSL",response.getReturnValue().accSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().acc;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                if(Offsetval !=0 && records != null && records != undefined){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    } 
                }
                if(Offsetval == 0 && records != null && records != undefined){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
                
            /*else
                component.set("v.vendorAccounts",[]);*/
            }
        });
       // if(!$A.util.isEmpty(component.get("v.Organisation.Id")))
        	$A.enqueueAction(vendorAction);
        /*else
            helper.showToast('!Error','error','Please Select Organisation');
         */  
    },
    getpurchaseOrder : function(component,event){
        var accIds = [];
        var selectedAcc = component.get("v.SelectedAccounts");
        for(var x in selectedAcc)
            accIds.push(selectedAcc[x].Id); component.set("v.accIds",accIds);
        //alert(accIds);
        var fetchPoAction = component.get("c.fetchPO");
        //fetchPoAction.setStorable();
        fetchPoAction.setParams({"accId":(accIds.length>0)?accIds.toString() : '',"OrgID" : component.get("v.Organisation.Id"), Offset: component.get("v.Offset"),
          RecordLimit: component.get('v.show'),searchString :component.get('v.setSearch')});
        fetchPoAction.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.POList",response.getReturnValue().PO);
                component.set("v.POListSL",response.getReturnValue().POSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().PO;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
                
            }
        });
        $A.enqueueAction(fetchPoAction);
    },
    
    getBills : function(component,event){
        var accIds = [];
        var selectedPOS = component.get("v.SelectedPOS");//component.get("v.SelectedAccounts");
        if(!$A.util.isUndefined(selectedPOS.length)){
            accIds.push(selectedPOS);
        }else{
        for(var x in selectedPOS)
            accIds.push(selectedPOS[x]);} // accIds.push('a321o0000002ncEAAQ');  
        var venIds = [];
        var selectedvend = component.get("v.SelectedVen");
       
        if(!$A.util.isUndefined(selectedvend.length)){
            venIds.push(selectedvend);
        }else{
        for(var x in selectedvend)
            venIds.push(selectedvend[x]);}
        //alert(accIds);  
        var fetchBillAction = component.get("c.fetchBills");
        //fetchPoAction.setStorable();
        fetchBillAction.setParams({"accId":(accIds.length>0)?accIds.toString() : '',"OrgID" : component.get("v.Organisation.Id"),Offset: component.get("v.Offset"),
                                   RecordLimit: component.get('v.show'),searchString :component.get('v.setSearch'), 
                                   vids : (venIds.length>0)?venIds.toString() : '',
                                   Aging : component.get('v.DueFilter')});
        fetchBillAction.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Bills",response.getReturnValue().Bills);
                component.set("v.BillsSL",response.getReturnValue().BillsSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().Bills;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
               
            }
        });
        $A.enqueueAction(fetchBillAction);
    },
    
    
     getPayments : function(component,event){
         try{
        var selIds = [];
        var selectedVouchers = component.get("v.SelectedVouchers");
        for(var x in selectedVouchers)
            selIds.push(selectedVouchers[x].Id);                   
                           
        var accIds = [];
        var selectedAcc = component.get("v.SelectedAccounts");
        for(var x in selectedAcc)
            accIds.push(selectedAcc[x].Id);
        
        var fetchPayAction = component.get("c.fetchPayments");
        //fetchPayAction.setStorable();
        fetchPayAction.setParams({"accId":(accIds.length>0)?accIds.toString() : '',"OrgID" : component.get("v.Organisation.Id"),
                                  "OrderBy":component.get("v.OrderBy"),"Order":component.get("v.Order"),Offset: component.get("v.Offset"),
          RecordLimit: component.get('v.show'),searchString :component.get('v.setSearch'),
                                 "vouchIds":(selIds.length>0)?selIds.toString() : '',});
        fetchPayAction.setCallback(this,function(response){
            var state = response.getState();
            if(response.getState() === 'SUCCESS'){
                component.set("v.Payments",response.getReturnValue().pWrap);
                component.set("v.PaymentsSL",response.getReturnValue().PaymentsSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().Payments;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
            }
        });
        $A.enqueueAction(fetchPayAction);
         }catch(Err){
            console.log('getPayments Error'+Err);
        }
    },
    
   /* getPayments : function(component,event){
        try{
        var selIds = [];
        var selectedVouchers = component.get("v.SelectedVouchers");
        for(var x in selectedVouchers)
            selIds.push(selectedVouchers[x].Id);                   
                           
        var accIds = [];
        var selectedAcc = component.get("v.SelectedAccounts");
        for(var x in selectedAcc)
            accIds.push(selectedAcc[x].Id);
        
        var fetchPayAction = component.get("c.fetchPayments");
        fetchPayAction.setStorable();
        fetchPayAction.setParams({"accId":(accIds.length>0)?accIds.toString() : '',"OrgID" : component.get("v.Organisation.Id"),
                                  "OrderBy":component.get("v.OrderBy"),"Order":component.get("v.Order"),Offset: component.get("v.Offset"),
          RecordLimit: component.get('v.show'),searchString :component.get('v.setSearch'),
                                 "vouchIds":(selIds.length>0)?selIds.toString() : '',});
        fetchPayAction.setCallback(this,function(response){
            var state = response.getState();
            if(response.getState() === 'SUCCESS'){
                component.set("v.Payments",response.getReturnValue().Payments);
                component.set("v.PaymentsSL",response.getReturnValue().PaymentsSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().Payments;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
            }
        });
        $A.enqueueAction(fetchPayAction);
        }catch(Err){
            console.log('getPayments Error'+Err);
        }
    },*/
    createRecord :function(component,event,sObject,defaultvalues){
         var windowHash = window.location;
            var createRecordEvent = $A.get("e.force:createRecord");
        if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": sObject,
                "defaultFieldValues":defaultvalues/*,
                "panelOnDestroyCallback": function(event) {
                 windowHash.back(); // window.location.back();
            }*/
            });
           createRecordEvent.fire();
        }     
    },
    
    createAccount :function(component,event,sObject,defaultvalues, RecId){
        
        var windowHash = window.location;
            var createRecordEvent = $A.get("e.force:createRecord");
        if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": sObject,
                "recordTypeId": RecId,
                "defaultFieldValues":defaultvalues
                
            });
           createRecordEvent.fire();
        }     
    },
    getVouchers : function(component,event){
        var billids = [];
        var selBills = component.get("v.SelectedBillIds");
        for(var x in selBills)
            billids.push(selBills[x]);
        var accIds = [];
        var selectedAcc = component.get("v.SelectedAccounts");
        for(var x in selectedAcc)
            accIds.push(selectedAcc[x].Id);
        
        var fetchVoucherAction = component.get("c.fetchVouchers");
        fetchVoucherAction.setParams({"accId":(accIds.length>0)?accIds.toString() : '',"OrgID" : component.get("v.Organisation.Id"),
                                      "OrderBy":component.get("v.OrderBy"),"Order":component.get("v.Order"),Offset: component.get("v.Offset"),
                                      RecordLimit: component.get('v.show'),searchString :component.get('v.setSearch'),
                                      selbills:(billids.length>0)?billids.toString() : ''});
        fetchVoucherAction.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Vouchers",response.getReturnValue().vouchers);
                component.set("v.VouchersSL",response.getReturnValue().vouchersSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().vouchers;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                  if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
               
            }
        });
        $A.enqueueAction(fetchVoucherAction);
    },
    
    getDebitNotes : function(component,event){
        var accIds = [];
        var selectedAcc = component.get("v.SelectedAccounts");
        for(var x in selectedAcc)
            accIds.push(selectedAcc[x].Id);
        
        var fetchdebitAction = component.get("c.fetchdebitNotes");
        fetchdebitAction.setParams({"accId":(accIds.length>0)?accIds.toString() : '',"OrgID" : component.get("v.Organisation.Id"),
                                   "OrderBy":component.get("v.OrderBy"),"Order":component.get("v.Order"),Offset: component.get("v.Offset"),
          RecordLimit: component.get('v.show'),searchString :component.get('v.setSearch')});
        fetchdebitAction.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){  
                component.set("v.DebitNotes",response.getReturnValue().DebitNotes);
                component.set("v.DebitNotesSL",response.getReturnValue().DebitNotesSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().DebitNotes;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                  if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
               
            }
        });
        $A.enqueueAction(fetchdebitAction);
    },
    
    
    getCreditNotes : function(component,event){
        var accIds = [];
        var selectedAcc = component.get("v.SelectedAccounts");
        for(var x in selectedAcc)
            accIds.push(selectedAcc[x].Id);
        
        var fetchdebitAction = component.get("c.fetchcreditNotes");
        fetchdebitAction.setParams({"accId":(accIds.length>0)?accIds.toString() : '',"OrgID" : component.get("v.Organisation.Id"),
                                   "OrderBy":component.get("v.OrderBy"),"Order":component.get("v.Order"),Offset: component.get("v.Offset"),
          RecordLimit: component.get('v.show'),searchString :component.get('v.setSearch')});
        fetchdebitAction.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.creditNotes",response.getReturnValue().CreditNotes);
                component.set("v.CreditNotesSL",response.getReturnValue().CreditNotesSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().CreditNotes;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                  if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
               
            }
        });
        $A.enqueueAction(fetchdebitAction);
    },
    
    fetchCreditNotes : function(c, e, h) {
        var action=c.get("c.fetchDebitNote");
        action.setParam("CusAccId",c.get("v.voucherPayment.ERP7__Accounts__c"));
        action.setCallback(this,function(r){
             if(r.getState() === 'SUCCESS'){
                 c.set("v.debitNotes1",r.getReturnValue());
             }
        });
       $A.enqueueAction(action);
    },
    
    paymentTerms : function(c, e, h) {
        var action=c.get("c.getPaymentTerms");
        action.setParams({"CusAccId":c.get("v.voucherPayment.ERP7__Accounts__c"),
                          "billDate":c.get("v.billDate"),
                          "payDate":c.get("v.voucherPayment.ERP7__Payment_Date__c")});
        action.setCallback(this,function(r){
             if(r.getState() === 'SUCCESS'){
                 if(r.getReturnValue()!=null){
                     var amount = c.get("v.voucherPayment.ERP7__Amount__c");
                     var disAmount = r.getReturnValue().ERP7__Discount_Percent__c/100;
                     c.set("v.voucherPayment.ERP7__Discount_Amount__c", amount * disAmount);
                     c.set("v.voucherPayment.ERP7__Discount_Rate__c", r.getReturnValue().ERP7__Discount_Percent__c);
                     c.set("v.displayDiscount", true);
                 }else{
                     var amt = 0;
                     c.set("v.voucherPayment.ERP7__Discount_Amount__c", amt);
                     c.set("v.voucherPayment.ERP7__Discount_Rate__c", amt);
                     c.set("v.displayDiscount", false);
                 }
             }
        });
       $A.enqueueAction(action);
    },
    
    getPayTerm : function(c, e, h) {
        var action=c.get("c.fetchPaymentTerm");
        action.setParam("CusAccId",c.get("v.multipleVoucherVendor"));
        action.setCallback(this,function(r){
             if(r.getState() === 'SUCCESS'){
                 if(r.getReturnValue()!=null){
                     c.set("v.payTerms",r.getReturnValue());
                     c.set("v.displayDis", true);
                 }
             }
        });
       $A.enqueueAction(action);
    },
    
    applyCredit : function(c, e){
            var action=c.get("c.updateInvoiceCreditNotes");
            c.set("v.vouchered.ERP7__Credit_Applied__c",c.get("v.cnAmount"));
            action.setParams({
                "dnList":c.get("v.debitNotes1"),
                "vou":JSON.stringify(c.get("v.vouchered"))
            });
            action.setCallback(this,function(r){
                if(r.getState() === 'SUCCESS'){
                    this.showToast($A.get('$Label.c.Success'),'Success!',$A.get("$Label.c.Credit_Applied_successfully"));
                    var url = '/'+c.get("v.vouchered.Id");
                    window.location.replace(url);
                }else{
                    this.showToast('Error','error!','Error Applying Credit');
                    component.set("v.showMmainSpin",false);
                }
            });
            $A.enqueueAction(action);
    },
    
    
    displayCreditNotes : function(cmp, event, helper) {
        var action = cmp.get("c.getFunctionalityControl");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
               console.log('response.getReturnValue() : ',response.getReturnValue());
                cmp.set("v.displayCredNote",response.getReturnValue().Credit_Notes);
                 cmp.set("v.showMultiPO",response.getReturnValue().MultiPO);
                 cmp.set("v.displayCurrency", response.getReturnValue().displayCurrency);
                 cmp.set("v.undisplayVoucher", response.getReturnValue().undisplayVoucher);
                 cmp.set("v.undisplayEditVouPay", response.getReturnValue().undisplayEditVou_Pay);
                 cmp.set("v.approvalProcess", response.getReturnValue().approvalProcess);
            }  
        });
        $A.enqueueAction(action);       
    },

})