({
    doInit : function(cmp, event, helper) {

        var action = cmp.get("c.getDefaultOrganisation");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(cmp.get("v.fetchRecordsBool")==true){
                    cmp.set("v.Organisation.Id",response.getReturnValue().Id);
                 	helper.displayDebitNotes(cmp, event, helper); 
                    helper.displayApproval(cmp, event, helper); 
                }else{
                    cmp.set("v.Organisation.Id",response.getReturnValue().Id);
                 	helper.displayDebitNotes(cmp, event, helper);
                    $A.enqueueAction(cmp.get("c.getOrganisedRecords"));
                    helper.displayApproval(cmp, event, helper); 
                }
                helper.functionalityControl(cmp, event, helper); 
            }  
        });
        $A.enqueueAction(action);  
              
    },
    
    openReport : function(component,event,helper){
        var name=event.currentTarget.dataset.service;
        var reportUrl = $A.get("$Label.c.Customer_Ledger");
        reportUrl = reportUrl + 'fv0=' + name;
        window.open(reportUrl,'_blank');
    },
     tabularView: function(component,event,helper){
        component.set('v.tabular',true);
        component.set('v.grid',false);
    },
    
     gridView: function(component,event,helper){
        component.set('v.tabular',false);
        component.set('v.grid',true);
    },
    
    
     selectedPO : function(component, event, helper) {
         component.set("v.SelectedPOS",'');
        var SelectedId = event.getSource().get("v.name");
        
         
        var selectedPOSList =[];
        selectedPOSList =  component.get("v.SelectedPOS");
         if(selectedPOSList=='')selectedPOSList.pop();
         if(event.getSource().get("v.checked")){
            selectedPOSList.push(SelectedId);
         }else{
            for(var x =0;x < selectedPOSList.length;x++){
                if(selectedPOSList[x] === SelectedId){
                    selectedPOSList.splice(x,1);
                    break;
                } 
                
            }
        }
        component.set("v.SelectedPOS",selectedPOSList);
     },
    
    getOrganisedRecords: function(cmp,event,helper){
         cmp.set("v.startCount", 0);
         cmp.set("v.endCount", 0);
         cmp.set("v.Offset", 0);
         //var searchString;
         //if(event.getParam("searchString")!=null)searchString = event.getParam("searchString").toString();
         helper.fetchRecords(cmp, event, helper);         
    },
    
    accountStatementMouseover:function(cmp, event, helper){      
        var Index=event.currentTarget.dataset.service;
        var CustomerList=[]; CustomerList=cmp.get("v.CustomerList");
        var AccountId=CustomerList[Index].Id;
        var AccountStatementURL='/apex/ERP7__AccountsStatement?AccountId='+AccountId;
        cmp.set('v.AccountStatementURL',AccountStatementURL);
    }, 
    
    getInoiceRecord:function(cmp, event, helper){ 
        var InvoiceList=[]; InvoiceList=cmp.get("v.InvoiceList");
        var Index=event.getSource().get("v.text");
        var action=cmp.find("invCBId")[Index].get("v.value");
        var Id=InvoiceList[Index].Id;       
        var InvoicesId=[]; InvoicesId=cmp.get("v.InvoicesId");
        var ind; if(action!=false && InvoicesId!=undefined && InvoicesId!="") ind=InvoicesId.indexOf(Id);
        if(action) InvoicesId.push(Id);
        else InvoicesId.splice(ind,1);
        cmp.set("v.InvoicesId",InvoicesId);
    }, 
    
    getCustomerRecord:function(cmp, event, helper){ 
        cmp.set("v.selectedCustomersId",'');
        cmp.set("v.selectedCustomers",'')
        var CustomerList=[]; CustomerList=cmp.get("v.CustomerList"); var selectedCustomers=[]; selectedCustomers=cmp.get("v.selectedCustomers");
        var Index=event.getSource().get("v.name");
        var actionElements=[]; actionElements=cmp.find("cusCBId");
        var action=false;
        if(actionElements[parseInt(Index)]!=undefined && actionElements.length!=undefined){  
          action=actionElements[parseInt(Index)].get("v.checked");  
        }else  action=actionElements.get("v.checked");
        var Id=CustomerList[Index].Id;
        var record=CustomerList[Index];
        var selectedCustomersId=[]; selectedCustomersId=cmp.get("v.selectedCustomersId");
        var ind; if(action!=false) ind=selectedCustomersId.indexOf(Id);
        if(action) {
            selectedCustomersId.push(Id); 
            selectedCustomers.push(record);
        }
        else{
            selectedCustomersId.splice(ind,1);
            selectedCustomers.splice(ind,1);
        } 
        cmp.set("v.selectedCustomersId",selectedCustomersId);
        cmp.set("v.selectedCustomers",selectedCustomers);
    },
    
    removeCustomer:function(cmp, event, helper){
        var selectedCustomers=[]; selectedCustomers=cmp.get("v.selectedCustomers");
        var selectedCustomersId=[]; selectedCustomersId=cmp.get("v.selectedCustomersId");
        var Index=event.getSource().get("v.title");
        
        selectedCustomersId.splice(Index,1);
        selectedCustomers.splice(Index,1);
        
        cmp.set("v.selectedCustomersId",selectedCustomersId);
        cmp.set("v.selectedCustomers",selectedCustomers);
    }, 
    
    getTab:function(cmp, event, helper){
        cmp.set('v.setSearch','');   
        cmp.set("v.startCount", 0);
        cmp.set("v.endCount", 0);
        cmp.set("v.Offset", 0);
        cmp.set("v.OrderBy",'Name'); cmp.set("v.Order",'ASC');
        cmp.set("v.LoaderControll",true);  
        //cmp.set("v.SelectedPOS",'');
        helper.getTab(cmp, event, helper, event.target.dataset.record);
    },
    
    SortRecodEventHandler : function(cmp,event,helper){
        cmp.set("v.showMainSpin",true); 
        var showTabs=cmp.get("v.showTabs");
        console.log('showTabs:',showTabs);
        var RecordList = event.getParam("RecordList"); 
        
        if(showTabs=='cus') cmp.set("v.CustomerList",RecordList);      
        else if(showTabs=='cre') cmp.set("v.CreditList",RecordList);
            else if(showTabs=='dun') cmp.set("v.DunningList",RecordList); 
        cmp.set("v.showMainSpin",false);
    },  
    
    getSortedRecords : function(cmp,event,helper){
        cmp.set("v.LoaderControll",false);  
        cmp.set("v.OrderBy",event.currentTarget.id);
        if(cmp.get("v.Order")=='DESC') cmp.set("v.Order",'ASC'); 
        else if(cmp.get("v.Order")=='ASC') cmp.set("v.Order",'DESC');   
        helper.fetchRecords(cmp, event, helper);    
    }, 
    
    getRecordTypePopupClose : function(component,event,helper){
        component.set("v.showCP",false);  component.set("v.showPP",false);
        component.set("v.showCouP",false);   
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
        componentDef : "c:AccountsReceivable",
        componentAttributes: {
            "showTabs" : 'cus'
        }
       });
       evt.fire();
    }, 
    
    getCustomerPopup : function(component,event,helper){
        component.set("v.RecordTypeId",'');
        component.set("v.showCP",true); 
        component.set("v.criteriaMsgCus",'');
        component.set("v.RecordTypeId",component.get("v.CustomerRTList")[0].value);
        if(component.find("CRadioId")[0]!=undefined) component.find("CRadioId")[0].set("v.value",true);
        else component.find("CRadioId").set("v.value",true);
    }, 
    
    onCustomerRadio : function(component,event,helper){
        var elem=component.find("CRadioId");
        if(component.find("CRadioId")[0]!=undefined) for(var i in elem) component.find("CRadioId")[i].set("v.value",false); 
        else component.find("CRadioId").set("v.value",false); 
        
        if(component.find("CRadioId")[0]!=undefined) component.find("CRadioId")[event.getSource().get("v.labelClass")].set("v.value",true); 
        else component.find("CRadioId").set("v.value",true); 
        component.set("v.RecordTypeId",event.getSource().get("v.text")); 
    },
    
    createCustomer : function(component,event,helper){
        component.set("v.showCP",false);
        var orgId;
        if(component.get("v.Organisation.Id")!=undefined && component.get("v.Organisation.Id")!='') orgId=component.get("v.Organisation.Id"); 
        var defaults = {'ERP7__Organisation__c':orgId, 'RecordTypeId':component.get("v.RecordTypeId"),'ERP7__Account_Type__c': 'Customer'}
        helper.createRecord(component,event,'Account',defaults);
    }, 
    
    createInvoice : function(component,event,helper){
        if(event.target.dataset.service!=undefined) component.set("v.Account.Id",event.currentTarget.dataset.service);                                            
        $A.createComponent(
            "c:CreateInvoice", { 
                "showTabs":component.get("v.showTabs"),
                "Organisation":component.get("v.Organisation"),
                "AccountId":event.currentTarget.dataset.service,
                "FromAR":true
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );	                                               
        
    },
   
    getPaymentPopup : function(component,event,helper){
        /*var getInvId = event.currentTarget.dataset.service;
        var ShowPaymentType,showPage;
        if(getInvId==null || getInvId=='' || getInvId==undefined){
            ShowPaymentType=true;showPage=false;
        }
        else{
            ShowPaymentType=false;showPage=true;}
        $A.createComponent("c:RecordPayment",{
            "aura:id": "recordPayment",
            "navigateToRecord":false,
            "recordId":event.currentTarget.dataset.service,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.savePayment"),
            "ShowPaymentType":ShowPaymentType,
            "showPage":showPage,
            "OrgId" : component.get("v.Organisation.Id"),
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });  */
        
        var getInvId = event.currentTarget.dataset.service;
        if(getInvId!=undefined){
        var action=component.get("c.checkPayment");
        action.setParams({
            InvId:getInvId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") { 
                if(response.getReturnValue()){
                    var ShowPaymentType,showPage;
                    if(getInvId==null || getInvId=='' || getInvId==undefined){
                        ShowPaymentType=true;showPage=false;
                    }
                    else{
                        ShowPaymentType=false;showPage=true;}
                    $A.createComponent("c:RecordPayment",{
                        "aura:id": "recordPayment",
                        "navigateToRecord":false,
                        "recordId":getInvId,
                        /*"cancelclick":component.getReference("c.backTO"),
                        "saveclick":component.getReference("c.savePayment"),*/
                        "ShowPaymentType":ShowPaymentType,
                        "showPage":showPage,
                        "OrgId" : component.get("v.Organisation.Id"),
                    },function(newCmp, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = component.find("body");
                            body.set("v.body", newCmp);
                        }
                    });
                }else{
                   helper.showToast($A.get("$Label.c.warning_UserAvailabilities"),'warning',$A.get("$Label.c.Payment_Has_Already_Been_Created"));
                }
            }
        });
         $A.enqueueAction(action);
        }else{
            $A.createComponent("c:RecordPayment",{
                        "aura:id": "recordPayment",
                        "navigateToRecord":false,
                        "ShowPaymentType":true,
                        "showPage":true,
                        "OrgId" : component.get("v.Organisation.Id"),
                    },function(newCmp, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = component.find("body");
                            body.set("v.body", newCmp);
                        }
                    });
        }
    },   
    onPaymetRadio : function(component,event,helper){
        var elem=component.find("PRadioId");
        if(component.find("PRadioId")[0]!=undefined){  
            for(var i in elem) component.find("PRadioId")[i].set("v.value",false);       
            component.find("PRadioId")[event.getSource().get("v.labelClass")].set("v.value",true);  
        }
        component.set("v.RecordTypeId",event.getSource().get("v.text")); 
    },
    
    createPayment : function(component,event,helper){
        var orgId;
        if(component.get("v.Organisation.Id") !='' && component.get("v.Organisation.Id") !=undefined) orgId=component.get("v.Organisation.Id");
        component.set("v.showPP",false); 
        var defaults = {'ERP7__Account__c':orgId,'ERP7__Invoice__c':component.get("v.InvId"),'RecordTypeId':component.get("v.RecordTypeId")} 
        helper.createRecord(component,event,'ERP7__Payment__c',defaults);
    },
    
    getCouponPopup : function(component,event,helper){
        component.set("v.RecordTypeId",'');
        component.set("v.showCouP",true); 
        component.set("v.RecordTypeId",component.get("v.CouponRTList")[0].value);
        if(component.find("CouRadioId")[0]!=undefined) component.find("CouRadioId")[0].set("v.value",true);
        else component.find("CouRadioId").set("v.value",true);      
    }, 
    
    onCouponRadio : function(component,event,helper){
        var elem=component.find("CouRadioId");
        if(component.find("CouRadioId")[0]!=undefined){   
            for(var i in elem) component.find("CouRadioId")[i].set("v.value",false);       
            component.find("CouRadioId")[event.getSource().get("v.labelClass")].set("v.value",true); 
        }    
        component.set("v.RecordTypeId",event.getSource().get("v.text")); 
    },
    
    createCoupon : function(component,event,helper){
        component.set("v.showCouP",false); 
        var defaults = {'ERP7__Organisation__c':component.get("v.Organisation.Id"), 'RecordTypeId':component.get("v.RecordTypeId")}
        helper.createRecord(component,event,'ERP7__Coupon__c',defaults);
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
    
    createOrder: function (component, event, helper) {
        var standardOrder = component.get("v.standardOrder");
        console.log('standardOrder' + standardOrder);
        if (standardOrder == true) {
            // var RecUrl = "/lightning/n/ERP7__e_Pos";
            // window.open(RecUrl, "_self");
            var evt = $A.get("e.force:navigateToComponent");
           evt.setParams({
               componentDef : "c:epos",
               componentAttributes: {
                    "FromAR": true
                }
           });
           evt.fire();
        } else {
            var evt = $A.get("e.force:navigateToComponent");
           evt.setParams({
               componentDef : "c:OrderConsole",
               componentAttributes: {
                // "aura:id": "mOrd",
                "FromAR": true,
                "cancelclick": component.getReference("c.backTO"),
                "showTabs": component.get("v.showTabs"),
                "Organisation": component.get("v.Organisation")
                }
           });
           evt.fire();
            // $A.createComponent("c:OrderConsole", {
            //     "aura:id": "mOrd",
            //     "FromAR": true,
            //     "cancelclick": component.getReference("c.backTO"),
            //     "showTabs": component.get("v.showTabs"),
            //     "Organisation": component.get("v.Organisation")
            // }, function (newcomponent, status, errorMessage) {
            //     if (status === "SUCCESS") {
            //         var body = component.find("body");
            //         body.set("v.body", newcomponent);
            //     }
            // });
        }
    },
    
    createDebit : function(component,event,helper){
        var orgId;
        if(component.get("v.Organisation.Id")!='' && component.get("v.Organisation.Id")!=undefined) orgId=component.get("v.Organisation.Id");
        var defaults = {'ERP7__Organisation__c':orgId,'ERP7__Account__c':event.currentTarget.dataset.service} 
        helper.createRecord(component,event,'ERP7__Debit_Note__c',defaults);
    },
    createDunning : function(component,event,helper){
        var orgId;
        if(component.get("v.Organisation.Id")!='' && component.get("v.Organisation.Id")!=undefined) orgId=component.get("v.Organisation.Id");
        var defaults = {'ERP7__Organisations__c':orgId} 
        helper.createRecord(component,event,'ERP7__Dunning__c',defaults);
    },
    
    fetchInvoiceUpdate: function(cmp,event,helper){
        helper.fetchInvoiceUpdate(cmp,event,helper,event.target.id,event.currentTarget.dataset.service);   
    },
    
    fetchPaymentUpdate: function(cmp,event,helper){
        helper.fetchPaymentUpdate(cmp,event,helper,event.target.id,event.currentTarget.dataset.service);      
    },
    fetchDebitUpdate: function(cmp,event,helper){
        helper.fetchDebitUpdate(cmp,event,helper,event.target.id,event.currentTarget.dataset.service);   
    },
    selectedSalOrd: function (cmp, event, helper) {
        try {
            var SelectedId = event.getSource().get("v.name");
            console.log('SelectedId' + SelectedId);
            var selectedORDList = [];
            selectedORDList = cmp.get("v.SelectedSalOrd");
            if (selectedORDList == '') selectedORDList.pop();
            console.log('event.getSource().get("v.checked")' + event.getSource().get("v.checked"));
            if (event.getSource().get("v.checked")) {
                selectedORDList.push(SelectedId);
            } else {
                for (var x = 0; x < selectedORDList.length; x++) {
                    if (selectedORDList[x] === SelectedId) {
                        selectedORDList.splice(x, 1);
                        break;
                    }

                }
            }

            var checkboxes = cmp.find("SalOrdId");
            var currentCheckbox = event.getSource();
            var currentAccountId = currentCheckbox.get("v.value");

            checkboxes.forEach(function (checkbox) {
                if (checkbox !== currentCheckbox) {
                    var otherAccountId = checkbox.get("v.value");
                    checkbox.set("v.disabled", currentAccountId !== otherAccountId);
                }
            });

            var checkedCount = checkboxes.reduce(function (count, checkbox) {
                return count + (checkbox.get("v.checked") ? 1 : 0);
            }, 0);
            console.log('checkedCount '+checkedCount);
            if (checkedCount >= 2) {
                cmp.set("v.displayMultipleSalOrd", true);
            } else if (checkedCount == 0) {
                cmp.set("v.displayMultipleSalOrd", false);
                helper.enableAllCheckboxes(checkboxes);
            } else if (checkedCount == 1) {
                cmp.set("v.displayMultipleSalOrd", false);
            }
            cmp.set("v.SelectedSalOrd", selectedORDList);
            console.log('cmp.set("v.SelectedSalOrd")' + JSON.stringify(cmp.get("v.SelectedSalOrd")));
        } catch (error) {
            console.error(error);
            console.log('error' + JSON.stringify(error));
        }
    },
    selectedOrd: function (cmp, event, helper) {
        try {
            var SelectedId = event.getSource().get("v.name");
            console.log('SelectedId' + SelectedId);
            var selectedORDList = [];
            selectedORDList = cmp.get("v.SelectedOrd");
            if (selectedORDList == '') selectedORDList.pop();
            console.log('event.getSource().get("v.checked")' + event.getSource().get("v.checked"));
            if (event.getSource().get("v.checked")) {
                selectedORDList.push(SelectedId);
            } else {
                for (var x = 0; x < selectedORDList.length; x++) {
                    if (selectedORDList[x] === SelectedId) {
                        selectedORDList.splice(x, 1);
                        break;
                    }
                }
            }

            var checkboxes = cmp.find("OrdId");
            var currentCheckbox = event.getSource();
            var currentAccountId = currentCheckbox.get("v.value");

            checkboxes.forEach(function (checkbox) {
                if (checkbox !== currentCheckbox) {
                    var otherAccountId = checkbox.get("v.value");
                    checkbox.set("v.disabled", currentAccountId !== otherAccountId);
                }
            });

            var checkedCount = checkboxes.reduce(function (count, checkbox) {
                return count + (checkbox.get("v.checked") ? 1 : 0);
            }, 0);

            if (checkedCount >= 2) {
                cmp.set("v.displayMultipleOrd", true);
            } else if (checkedCount == 0) {
                cmp.set("v.displayMultipleOrd", false);
                helper.enableAllCheckboxes(checkboxes);
            } else if (checkedCount == 1) {
                cmp.set("v.displayMultipleOrd", false);
            }

            cmp.set("v.SelectedOrd", selectedORDList);
            console.log('cmp.set("v.SelectedSalOrd")' + JSON.stringify(cmp.get("v.SelectedOrd")));
        } catch (error) {
            console.error(error);
            console.log('error' + JSON.stringify(error));
        }
    },
    searchEventHandler : function(cmp,event,helper){ 
        cmp.set('v.criteriaMsgCus',''); 
        var searchString = event.getParam("searchString").toString();
       // if(searchString.length>1){
            if(cmp.get("v.showTabs")=='cus'){ 
               /* var CustomerList = cmp.get('v.CustomerListForSearch');// cmp.get("v.CustomerList"); CustomerListForSearch
                if(CustomerList!=undefined && CustomerList!=''){ 
                    CustomerList = CustomerList.filter(function (el) { 
                        var cond1=false;      
                        if(el.AccountNumber!=undefined){ 
                            el.AccountNumber=(el.AccountNumber).toString(); 
                            cond1=el.AccountNumber.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                        } 
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1);
                    }); 
                    var currList=[];var count=0;var limit=parseInt(cmp.get("v.show"));
                    for(var inv in CustomerList){
                        if(count<limit){
                            currList.push(CustomerList[count]);
                            count=count+1;
                        }else break;
                     }
                    cmp.set("v.CustomerList",currList);               
                } else cmp.set('v.criteriaMsgCus','No Customer Found');
               */ 
                if(searchString.length>1) helper.fetchRecords(cmp, event, helper);
                if(searchString.length==0) helper.fetchRecords(cmp, event, helper);
            } else if (cmp.get("v.showTabs") == 'ord') {
                if (searchString.length > 1) helper.fetchRecords(cmp, event, helper);
                if (searchString.length == 0) helper.fetchRecords(cmp, event, helper);
            }else if(cmp.get("v.showTabs")=='inv'){ 
               /*
                var InvoiceList = cmp.get('v.InvoiceListForSearch');//cmp.get("v.InvoiceList"); InvoiceListForSearch 
                if(InvoiceList!=undefined && InvoiceList!=''){ 
                    InvoiceList = InvoiceList.filter(function (el) {
                        if(el.ERP7__Invoice_Amount__c!=undefined){
                            el.ERP7__Invoice_Amount__c=(el.ERP7__Invoice_Amount__c).toString(); 
                            var cond1=false;
                            cond1=el.ERP7__Invoice_Amount__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                        } 
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1);
                      });
                    var invList=[];var count=0;var limit=parseInt(cmp.get("v.show"));
                    for(var inv in InvoiceList){
                        if(count<limit){
                            invList.push(InvoiceList[count]);
                            count=count+1;
                        }else break;
                     }
                     cmp.set("v.InvoiceList",invList);
                }else cmp.set('v.criteriaMsgCus','No Invoice Found');
                */
                if(searchString.length>1) helper.fetchRecords(cmp, event, helper);
                if(searchString.length==0) helper.fetchRecords(cmp, event, helper);

            }else if(cmp.get("v.showTabs")=='pay'){ 
               /* var PaymentList = cmp.get("v.PaymentListForSearch"); // cmp.get("v.PaymentList"); PaymentListForSearch
                if(PaymentList!=undefined && PaymentList!=''){
                    PaymentList = PaymentList.filter(function (el) {
                        var cond1=false;
                        if(el.ERP7__Invoice__c!=undefined){
                            if(el.ERP7__Invoice__r.Name !=undefined){                 
                                cond1=el.ERP7__Invoice__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                            } 
                        }     
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1);
                    });
                    var currList=[];var count=0;var limit=parseInt(cmp.get("v.show"));
                    for(var inv in PaymentList){
                        if(count<limit){
                            currList.push(PaymentList[count]);
                            count=count+1;
                        }else break;
                     }
                    cmp.set("v.PaymentList",currList);
                }else cmp.set('v.criteriaMsgCus','No Payment Found'); 
                */
                if(searchString.length>1) helper.fetchRecords(cmp, event, helper);
                if(searchString.length==0) helper.fetchRecords(cmp, event, helper);

            }
                else if(cmp.get("v.showTabs")=='cou'){
                    /*
                    var CouponList = cmp.get("v.CouponListForSearch"); // cmp.get("v.CouponList"); CouponListForSearch
                    if(CouponList!=undefined && CouponList!=''){  
                        CouponList = CouponList.filter(function (el) { 
                            var cond1=false;    
                            if(el.ERP7__Product__c!=undefined){    
                                if(el.ERP7__Product__r.Name !=undefined){                               
                                    cond1=el.ERP7__Product__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                                }
                            }     
                            return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1);
                        });
                    var currList=[];var count=0;var limit=parseInt(cmp.get("v.show"));
                    for(var inv in CouponList){
                        if(count<limit){
                            currList.push(CouponList[count]);
                            count=count+1;
                        }else break;
                     }
                     cmp.set("v.CouponList",currList);
                    } else cmp.set('v.criteriaMsgCus','No Coupon Found'); 
                    */
                if(searchString.length>1) helper.fetchRecords(cmp, event, helper);
                if(searchString.length==0) helper.fetchRecords(cmp, event, helper);

                }
                    else if(cmp.get("v.showTabs")=='cre'){
                        /*
                        var CreditList = cmp.get("v.CreditListForSearch");// cmp.get("v.CreditList"); CreditListForSearch
                        if(CreditList!=undefined && CreditList!=''){ 
                            CreditList = CreditList.filter(function (el) { 
                                var cond1=false;    
                                if(el.ERP7__Account__c!=undefined){    
                                    if(el.ERP7__Account__r.Name !=undefined){             
                                        cond1=el.ERP7__Account__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                                    }
                                }     
                                return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1);
                            });
                    var currList=[];var count=0;var limit=parseInt(cmp.get("v.show"));
                    for(var inv in CreditList){
                        if(count<limit){
                            currList.push(CreditList[count]);
                            count=count+1;
                        }else break;
                     }
                     cmp.set("v.CreditList",currList);
                        }else cmp.set('v.criteriaMsgCus','No Credit Note Found');    
                        */
                          if(searchString.length>1) helper.fetchRecords(cmp, event, helper);
                          if(searchString.length==0) helper.fetchRecords(cmp, event, helper);

                    }else if(cmp.get("v.showTabs")=='deb'){
                             if(searchString.length>1) helper.fetchRecords(cmp, event, helper);
                             if(searchString.length==0) helper.fetchRecords(cmp, event, helper);
                        }
            
                        else if(cmp.get("v.showTabs")=='dun'){
                            /*
                            var DunningList = cmp.get("v.DunningList");
                            if(DunningList!=undefined && DunningList!=''){ 
                                DunningList = DunningList.filter(function (el) {
                                    var cond1=false;    
                                    if(el.ERP7__Customer__r.Name!=undefined){             
                                        cond1=el.ERP7__Customer__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                                    } 
                                    return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1);
                                });
                    var currList=[];var count=0;var limit=parseInt(cmp.get("v.show"));
                    for(var inv in DunningList){
                        if(count<limit){
                            currList.push(DunningList[count]);
                            count=count+1;
                        }else break;
                     }
                     cmp.set("v.DunningList",currList);            
                            }cmp.set('v.criteriaMsgCus','No Dunning Found');  
                            */
                        }      
        /*}else{
            cmp.set("v.CustomerList",cmp.get("v.CustomerListD"));
            cmp.set("v.InvoiceList",cmp.get("v.InvoiceListD"));
            cmp.set("v.PaymentList",cmp.get("v.PaymentListD"));
            cmp.set("v.CouponList",cmp.get("v.CouponListD"));
            cmp.set("v.CreditList",cmp.get("v.CreditListD"));
            cmp.set("v.AEList",cmp.get("v.AEListD"));
            cmp.set("v.DunningList",cmp.get("v.DunningListD"));           
        } */            
    },
    savePayment : function(c,e,h){
        try{
            c.find("recordPayment").savePayment(function(response){
                $A.createComponent("c:AccountsReceivable",{
                    "aura:id": "AccountsReceivable",
                    "showTabs":c.get("v.showTabs")
                },function(newCmp, status, errorMessage){
                    if(status === "SUCCESS") {  
                        var body = c.find("body");
                        body.set("v.body", newCmp);
                    }
                }); 
            }); 
        }catch(ex){ }   
    },
    backTO : function(component,event,helper){ 
        $A.createComponent("c:AccountsReceivable",{
            "aura:id": "AccountsReceivable",
            "showTabs":component.get("v.showTabs")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {  
                
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        }); 
    },
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
                var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            	//alert(Offsetval);    
            	component.set("v.Offset", Offsetval);
                component.set("v.CheckOffset",true);
                component.set("v.PageNum",(component.get("v.PageNum")+1));
                helper.fetchRecords(component, event, helper);
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
                helper.fetchRecords(component, event, helper);
            }
     },
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
               var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            	//alert(Offsetval);    
            	component.set("v.Offset", Offsetval);
                component.set("v.CheckOffset",true);
            	component.set("v.PageNum",(component.get("v.PageNum")-1));
                helper.fetchRecords(component, event, helper);
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
                helper.fetchRecords(component, event, helper);
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
        helper.fetchRecords(component, event, helper);
    },
    OfsetChange : function(component,event,helper){
        var Offsetval ;
        if(component.get("v.showTabs")=='inv')Offsetval= component.find("ikINV").get("v.value");
        if(component.get("v.showTabs")=='cus')Offsetval= component.find("ik").get("v.value");
        if (component.get("v.showTabs") == 'ord' && component.get("v.grid")==true) Offsetval = component.find("ikgOrd").get("v.value");
        else if (component.get("v.showTabs") == 'ord' && component.get("v.grid")==false) Offsetval = component.find("ikOrd").get("v.value");
        if(component.get("v.showTabs")=='pay')Offsetval= component.find("ikPay").get("v.value");
        if(component.get("v.showTabs")=='cre')Offsetval= component.find("ikCre").get("v.value");
        if(component.get("v.showTabs")=='deb')Offsetval= component.find("ikdb").get("v.value");
               
        var curOffset = component.get("v.Offset");
        var show = parseInt(component.get("v.show"));
        if(Offsetval > 0 && Offsetval <= component.get("v.PNS").length){
            if(((curOffset+show)/show) != Offsetval){
                var newOffset = (show*Offsetval)-show;
                component.set("v.Offset", newOffset);
                component.set("v.CheckOffset",true);
                //alert(newOffset);
                //alert(show);
                //alert((newOffset + show))
                var pageNum = (newOffset + show)/show;
                //alert(pageNum);
                component.set("v.PageNum",pageNum);
            }
            helper.fetchRecords(component, event, helper);
        } else component.set("v.PageNum",((curOffset+show)/show));
    },
    setShow : function(cmp,event,helper){
          cmp.set("v.startCount", 0);
          cmp.set("v.endCount", 0);
          cmp.set("v.Offset", 0);
          cmp.set("v.PageNum", 1);
         helper.fetchRecords(cmp, event, helper);
    },    
    
    handledebitmenu: function(cmp,event,helper){
        var operation = event.detail.menuItem.get("v.label");
        if(operation == "Post" || operation == "Unpost" ){
            helper.fetchDebitUpdate(cmp,event,helper,event.detail.menuItem.get("v.value"),event.detail.menuItem.get("v.title"));   
        } else if(operation == "Record Payment"){
            helper.getPaymentPopupForDebit(cmp,event,helper,event.detail.menuItem.get("v.value"));
        }else{
        }
    },
    handleinvoicemenu: function(cmp,event,helper){
        var invoiceList = [];
        invoiceList = cmp.get("v.InvoiceList");
        var invId = event.detail.menuItem.get("v.value");
        for(var i=0;i<invoiceList.length;i++){
            if((invoiceList[i].Id == invId) && invoiceList[i].ERP7__Status__c!= undefined && invoiceList[i].ERP7__Status__c == $A.get("$Label.c.On_Hold")){
                var msg = $A.get("$Label.c.DoPayment_Status") + ' ' +$A.get("$Label.c.On_Hold_AddTimeCardEntry");
                helper.showToast($A.get("$Label.c.warning_UserAvailabilities"),'warning',msg);
                return;
            }
        }
        var operation = event.detail.menuItem.get("v.label");
        if(operation == $A.get("$Label.c.Acc_Recev_Post") || operation == $A.get("$Label.c.Acc_Recev_Unpost") ){
            helper.fetchInvoiceUpdate(cmp,event,helper,event.detail.menuItem.get("v.value"),event.detail.menuItem.get("v.title"));   
        } else if(operation == $A.get("$Label.c.Acc_Recev_Record_Payment")){
            helper.getPaymentPopup(cmp,event,helper,event.detail.menuItem.get("v.value"));
        }else{
        }
    },
    handlepaymentmenu: function(cmp,event,helper){
        var operation = event.detail.menuItem.get("v.label");
        if(operation ==  $A.get("$Label.c.Acc_Recev_Post") || operation == $A.get("$Label.c.Acc_Recev_Unpost") ){
            helper.fetchPaymentUpdate(cmp,event,helper,event.detail.menuItem.get("v.value"),event.detail.menuItem.get("v.title"));   
        } else{
        }
    },
    handleordmenu: function (component, event, helper) {
        var operation = event.detail.menuItem.get("v.label");
        var standardOrder = component.get("v.standardOrder");
        if (operation == "New Invoice") {
            if (event.detail.menuItem.get("v.value") != undefined) {
                component.set("v.Account.Id", event.detail.menuItem.get("v.value"));
                $A.createComponent(
                    "c:CreateInvoice", {
                    "showTabs": component.get("v.showTabs"),
                    "Organisation": component.get("v.Organisation"),
                    "SOId": standardOrder == false ? event.detail.menuItem.get("v.value") : '',
                    "StdId": standardOrder == true ? event.detail.menuItem.get("v.value") : '',
                    "FromAR": true
                },
                    function (newComp) {
                        var content = component.find("body");
                        content.set("v.body", newComp);
                    }
                );
            }
        }
    },
    calledMultipleOrdExis: function (component, event, helper) {
        console.log('calledMultipleOrdExis');
        var standardOrder = component.get("v.standardOrder");
        $A.createComponent(
            "c:CreateInvoice", {
            "showTabs": component.get("v.showTabs"),
            "Organisation": component.get("v.Organisation"),
            "AccountId": component.get("v.AccountId"),
            "MultiOrder": true,
            "SalOrdIdsList": standardOrder == false ? component.get("v.SelectedSalOrd") : '',
            "OrdIdsList": standardOrder == true ? component.get("v.SelectedOrd") : '',
            "FromAR": true
        },
            function (newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );
    },
    handlecustomermenu: function(component,event,helper){
        var operation = event.detail.menuItem.get("v.label");
        if(operation == $A.get("$Label.c.Acc_Recev_New_Credit_Note")){
            var orgId;
            if(component.get("v.Organisation.Id")!='' && component.get("v.Organisation.Id")!=undefined) orgId=component.get("v.Organisation.Id");
            var defaults = {'ERP7__Organisation__c':orgId,'ERP7__Account__c':event.detail.menuItem.get("v.value")} 
            helper.createRecord(component,event,'ERP7__Credit_Note__c',defaults);
        }else if(operation == $A.get("$Label.c.Acc_Recev_New_Debit_Note")){
            var orgId;
            if(component.get("v.Organisation.Id")!='' && component.get("v.Organisation.Id")!=undefined) orgId=component.get("v.Organisation.Id");
            var defaults = {'ERP7__Organisation__c':orgId,'ERP7__Account__c':event.detail.menuItem.get("v.value")} 
            helper.createRecord(component,event,'ERP7__Debit_Note__c',defaults);
        }else if(operation == $A.get("$Label.c.Acc_Recev_New_Invoice")){
            if(event.detail.menuItem.get("v.value")!=undefined){
                component.set("v.Account.Id",event.detail.menuItem.get("v.value"));
                $A.createComponent(
                    "c:CreateInvoice", { 
                        "showTabs":component.get("v.showTabs"),
                        "Organisation":component.get("v.Organisation"),
                        "AccountId":event.detail.menuItem.get("v.value"),
                        "FromAR":true
                    },
                    function(newComp) {
                        var content = component.find("body");
                        content.set("v.body", newComp);
                    }
                );	     
            }                                             
        }else if(operation == $A.get("$Label.c.Account_Statement")){
            var Index=event.detail.menuItem.get("v.title");
            var CustomerList=[]; CustomerList=component.get("v.CustomerList");
            var AccountId=CustomerList[Index].Id;
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CustomerVendorDetails",
                componentAttributes: {    
                    'customerVendorId':AccountId,
                    'fromAR':true
                }
            });
            evt.fire();
            /*var AccountStatementURL='/apex/ERP7__AccountsStatement?AccountId='+AccountId;
            component.set('v.AccountStatementURL',AccountStatementURL);
            window.open(AccountStatementURL,'_blank');*/
        }else if(operation == $A.get("$Label.c.Acc_Recev_Report")){
            var name=event.detail.menuItem.get("v.value");
            var reportUrl = $A.get("$Label.c.Customer_Ledger");
            reportUrl = reportUrl + 'fv0=' + name;
            window.open(reportUrl,'_blank');
        }
    },
    
   // ______________________________________
     calledCustomer : function(component,event,helper){
        component.set("v.showTabs", 'cus');
         component.set("v.setSearch",'');    
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.OrderBy",'Name'); component.set("v.Order",'ASC');
        component.set("v.LoaderControll",true); 
        helper.fetchOrg(component,event,helper);
        helper.fetchRecords(component,event,helper);
    },
    
     calledInvoices : function(component,event,helper){
        component.set("v.showTabs", 'inv');
        component.set("v.setSearch",'');   
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.OrderBy",'Name'); component.set("v.Order",'ASC');
        component.set("v.LoaderControll",true); 
        helper.fetchOrg(component,event,helper);
        helper.fetchRecords(component,event,helper);
    },
    
    calledOrders: function (component, event, helper) {
        console.log('calledOrders');
        component.set("v.showTabs", 'ord');
        component.set("v.setSearch", '');
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.OrderBy", 'Name'); component.set("v.Order", 'ASC');
        component.set("v.LoaderControll", true);
        helper.fetchOrg(component, event, helper);
        helper.fetchRecords(component, event, helper);
    },
    
     calledPayments : function(component,event,helper){
        component.set("v.showTabs", 'pay');
         component.set("v.setSearch",''); 
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.OrderBy",'Name'); component.set("v.Order",'ASC');
        component.set("v.LoaderControll",true);
        helper.fetchOrg(component,event,helper);
        helper.fetchRecords(component,event,helper);
    },
    
    calledCreditNotes : function(component,event,helper){
        component.set("v.showTabs", 'cre');
         component.set("v.setSearch",'');    
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.OrderBy",'Name'); component.set("v.Order",'ASC');
        component.set("v.LoaderControll",true); 
        helper.fetchOrg(component,event,helper);
        helper.fetchRecords(component,event,helper);
    },
    
    onControllerFieldChange : function(component,event,helper){
        helper.fetchRecords(component,event,helper);
    },
    
    navigateToDashboard : function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ARAPDashboard",
            componentAttributes: {  
            }
        });
        evt.fire();
    }
})