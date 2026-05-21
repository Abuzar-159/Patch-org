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
                console.log('Bills AP response:',response.getReturnValue());
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