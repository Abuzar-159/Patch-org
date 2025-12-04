({
    doInit: function(c, e, h) { 
        
        /*
        
        
        c.fetch();
        */
        console.log('recordId Payment Component:',c.get("v.recordId"));
        $A.enqueueAction(c.get("c.fetchCredential"));
        console.log('OrgId:',c.get("v.OrgId"));
        c.fetch();
        if(c.get('v.setRT') == 'Debit_Note_Payments'){
            var a = c.get("c.getDebitDetails");
            a.setParam("debitId",c.get("v.recordId"));
            a.setCallback(this,function(r){
                
                if(r.getState() === 'SUCCESS'){
                    
                    var today = new Date();
                    var monthDigit = today.getMonth() + 1;
                    if (monthDigit <= 9) {
                        monthDigit = '0' + monthDigit;
                    }
                    var todayDate = today.getFullYear()+'-'+monthDigit+'-'+today.getDate();
                    c.set('v.today',todayDate);
                    
                    var result = r.getReturnValue(); 
                    c.set("v.payment.ERP7__Accounts__c",result.ERP7__Account__c);
                    if(result.ERP7__Amount__c != null || result.ERP7__Amount__c!= undefined || result.ERP7__Amount__c!= ''){
                        c.set("v.payment.ERP7__Total_Amount__c",result.ERP7__Amount__c);  
                        c.set("v.CustomerBalance", result.ERP7__Debit__c);  
                    }else{
                        c.set("v.payment.ERP7__Total_Amount__c",result.ERP7__Debit__c);
                        c.set("v.CustomerBalance", result.ERP7__Debit__c);
                    } 
                    var today = new Date();
                    var monthDigit = today.getMonth() + 1;
                    if (monthDigit <= 9) {
                        monthDigit = '0' + monthDigit;
                    }
                    var todayDate = today.getFullYear()+'-'+monthDigit+'-'+today.getDate();
                    c.set("v.payment.ERP7__Payment_Date__c",todayDate);
                    c.set("v.payment.ERP7__Debit_Note__c", c.get("v.recordId"));                           
                }else{
                    //('Error occured in doInit');
                }
                
            });
            $A.enqueueAction(a); 
        }else{                       
            var today = new Date();
            var monthDigit = today.getMonth() + 1;
            if (monthDigit <= 9) {
                monthDigit = '0' + monthDigit;
            }
            var todayDate = today.getFullYear()+'-'+monthDigit+'-'+today.getDate();
            c.set('v.today',todayDate);
            
            if(c.get("v.Refund")){
                var a = c.get("c.getRefundInvoiceDetails");
                a.setParams({"recordId":c.get("v.recordId"),"paymentId":c.get("v.paymentId")});
                a.setCallback(this,function(r){
                    if(r.getState()==='SUCCESS'){
                        
                        var result = r.getReturnValue().inv;
                        c.set('v.Invoice',r.getReturnValue().inv);
                        c.set("v.OrgId",r.getReturnValue().inv.ERP7__Account__r.ERP7__Organisation__c);
                        
                        c.set('v.RT',result.RecordType.DeveloperName);
                        c.set("v.payment.ERP7__Accounts__c",result.ERP7__Account__c);
                        // c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today')); 
                        c.set("v.payment.ERP7__Payment_Date__c", c.get('v.today'));
                        var list = [];
                        list.push(result);
                        var total =0.00,dueAmt=0.00;
                        if(result.RecordType.DeveloperName === 'Advance'){
                            for(let x in list){
                                total =parseFloat(total+ list[x].ERP7__Total_Down_Payment_Amount__c);
                                dueAmt = parseFloat(dueAmt+ list[x].ERP7__Total_Down_Payment_Amount__c);
                                list[x].paymentApplied = {'ERP7__Amount__c':0.00,'ERP7__Invoice__c':list[x].Id,ERP7__Type__c:'Debit'};
                                list[x].checked=false;
                            }
                            c.set("v.invoiceList",list);
                        }else{
                            for(let x in list){
                                total =parseFloat(total+ list[x].ERP7__Invoice_Amount__c);
                                dueAmt = parseFloat(dueAmt+ list[x].ERP7__Total_Due__c);
                                list[x].paymentApplied = {'ERP7__Amount__c':0.00,'ERP7__Invoice__c':list[x].Id,ERP7__Type__c:'Debit'};
                                list[x].checked=false;
                            }
                            c.set("v.invoiceList",list);
                        }
                        c.set("v.totalAmount",r.getReturnValue().totalAmount);
                        c.set("v.dueAmount",dueAmt);
                        c.set("v.CustomerBalance",-1*r.getReturnValue().totalAmount);
                        c.fetch();
                        
                    }
                    
                });
                $A.enqueueAction(a);
                
            }
            else if(!$A.util.isEmpty(c.get("v.recordId"))){
                var a = c.get("c.getInvoiceDetails");
                a.setParam("recordId",c.get("v.recordId"));
                a.setCallback(this,function(r){
                    if(r.getState()==='SUCCESS'){
                        console.log('Inside RocordId Method:',r.getReturnValue());
                        var result = r.getReturnValue();
                        c.set('v.Invoice',r.getReturnValue());
                        c.set("v.OrgId",r.getReturnValue().ERP7__Account__r.ERP7__Organisation__c);
                        
                        c.set('v.RT',result.RecordType.DeveloperName);
                        c.set("v.payment.ERP7__Accounts__c",result.ERP7__Account__c);
                        // c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today')); 
                        c.set("v.payment.ERP7__Payment_Date__c", c.get('v.today'));
                        var list = [];
                        list.push(result);
                        var total =0.00,dueAmt=0.00;
                        if(result.RecordType.DeveloperName === 'Advance'){
                            for(let x in list){
                                total =parseFloat(total+ list[x].ERP7__Total_Down_Payment_Amount__c);
                                dueAmt = parseFloat(dueAmt+ list[x].ERP7__Total_Down_Payment_Amount__c);
                                list[x].paymentApplied = {'ERP7__Amount__c':0.00,'ERP7__Invoice__c':list[x].Id,ERP7__Type__c:'Debit'};
                                list[x].checked=false;
                            }
                            c.set("v.invoiceList",list);
                            c.set("v.totalAmount",total);
                            c.set("v.dueAmount",dueAmt);
                            c.set("v.CustomerBalance",dueAmt);
                            c.fetch();
                            $A.enqueueAction(c.get("c.fetchCreditNotes"));
                            
                        }else{
                            for(let x in list){
                                total =parseFloat(total+ list[x].ERP7__Invoice_Amount__c);
                                dueAmt = parseFloat(dueAmt+ list[x].ERP7__Total_Due__c);
                                list[x].paymentApplied = {'ERP7__Amount__c':0.00,'ERP7__Invoice__c':list[x].Id,ERP7__Type__c:'Debit'};
                                list[x].checked=false;
                            }
                            c.set("v.invoiceList",list);
                            c.set("v.totalAmount",total);
                            c.set("v.dueAmount",dueAmt);
                            c.set("v.CustomerBalance",dueAmt);
                            c.fetch();
                            $A.enqueueAction(c.get("c.fetchCreditNotes"));
                        }
                    }
                    
                });
                $A.enqueueAction(a);
                
            }
        }
      
    },
    
    fetch : function(c, e, h) {
       var action=c.get("c.fetchBankAccount");
        action.setParam("OrgId",c.get("v.OrgId"));
        action.setCallback(this,function(r){
             if(r.getState() === 'SUCCESS'){
                 var filter = ''; var records=[]; records=r.getReturnValue();
                  for(var obj in records){
                      if(obj == 0) filter = ' And ( Id = \''+records[obj].Id+'\'';
                       else filter += ' Or Id = \''+records[obj].Id+'\'';
                  }
                  filter += ')'; 
                  c.set("v.AccountsFilter",filter);
             }
            else{
                //('Error occured in doInit'); 
            }
        });
       $A.enqueueAction(action);
    },
    
    fetchCredential : function(c, e, h) {
       var action=c.get("c.credList");
        action.setParam();
        action.setCallback(this,function(r){
             if(r.getState() === 'SUCCESS'){
                 if(r.getReturnValue() != null) c.find("payType").set("v.options", r.getReturnValue());
             }
            else{
                //('Error occured in doInit'); 
            }
        });
       $A.enqueueAction(action);
    },
    
    
    
    accountBalance : function(c, e, h) {
      //  c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today'));
        c.set("v.creditNotes",null);
        if(c.get("v.showPage")){
            var a = c.get("c.getAccountBalance");
            a.setParams({accountId:c.get("v.payment.ERP7__Accounts__c")});
            a.setCallback(this,function(r){
                if(r.getState()==='SUCCESS'){ 
                    var res =r.getReturnValue();
                    if(!$A.util.isUndefined(res['error'])){
                        //show Toast
                        return;
                    }else{
                        if($A.util.isEmpty(c.get("v.recordId"))){
                        var list = res['invoiceList'];
                        var total =0.00,dueAmt=0.00;
                        for(let x in list){
                            total =parseFloat(total+ list[x].ERP7__Invoice_Amount__c);
                            dueAmt = parseFloat(dueAmt+ list[x].ERP7__Total_Due__c);
                            list[x].paymentApplied = {'ERP7__Amount__c':0.00,'ERP7__Invoice__c':list[x].Id,ERP7__Type__c:'Debit'};
                            list[x].checked=false;
                        }
                        if(c.get('v.setRT')!='Customer payment')c.set("v.invoiceList",list);
                        c.set("v.totalAmount",total);
                        c.set("v.dueAmount",dueAmt);
                        c.set("v.CustomerBalance",dueAmt);
                      }
                        var crdt=res['availableCredits'];
                        //  c.set("v.creditBalance",res['availableCredits']);
                        if(crdt!=undefined){
                            c.set("v.creditBalance",crdt[0].ERP7__Available_Credit_Balance__c);
                            c.set("v.OrgId", crdt[0].ERP7__Organisation__c);
                        }
                    }
                }
            });
            $A.enqueueAction(a);
        }else{
            $A.enqueueAction(c.get("c.fetchCreditNotes"));
        }
    },
    resetInvoices : function(c, e, h) {
        var cbox = c.find('cbox');
        if(!$A.util.isUndefined(cbox) && $A.util.isUndefined(cbox.length)){
            cbox.set("v.checked",false);
        }else{
            for(var x in cbox){
                cbox[x].set("v.checked",false);
            }
        }
        var list = c.get("v.invoiceList");
        for(let x in list)
            list[x].paymentApplied.ERP7__Amount__c = 0.00;
        
        c.set("v.invoiceList",list);
        c.set("v.paymentAmount",0.00);
        //Moin Commented this //$A.enqueueAction(c.get("c.checkDiscount"));
    },
    
    updatePaymentAmount : function(c,e,h){
        var list = c.get("v.creditNotes");
        var ccAmount = 0*1;
        for(var x in list){
            if(list[x].debitAmount!=null){
                ccAmount = ccAmount + list[x].debitAmount*1;
            }
        }
        c.set("v.cnAmount",ccAmount);
        if(c.get("v.cnAmount")!=0){
            if(c.get("v.cnAmount")==c.get("v.CustomerBalance")){
                c.set("v.payment.ERP7__Total_Amount__c",0);
            }else{
                c.set("v.payment.ERP7__Total_Amount__c",0);
            }
            if(c.get("v.cnAmount")==c.get("v.paymentAmount")){
                c.set("v.NoPayment",true);
            }else{
                c.set("v.NoPayment",false);
            }
        }else{
            c.set("v.NoPayment",false);
            c.set("v.payment.ERP7__Total_Amount__c",0);
        }
        $A.enqueueAction(c.get("c.updatedToInvoices"));
    },
    
    checkSettings:function(c,e,h){
        /*if(e.getSource().get("v.value")==='Credit'){
            c.set("v.displayCN",true);
        }else{
            c.set("v.displayCN",false);
            c.set("v.cnAmount",0);
        }*/
        /*if(e.getSource().get("v.value")==='Card')
            h.showToast('info','info!','Please Contact Administrator for Card Settings');*/
    },
    
    displayCreditNote : function(c,e,h){
        if(c.get("v.displayCN")){
            c.set("v.displayCN",false);
        }else{
            c.set("v.displayCN",true);
        }
    },
    updatedToInvoices: function(c, e, h) {
        var invoiceId = e.getSource().get("v.name");
        var list = c.get("v.invoiceList");
        var paymentAmt = c.get("v.payment.ERP7__Total_Amount__c");
        if($A.util.isUndefined(paymentAmt)){c.find("paymentAmount").showHelpMessageIfInvalid();e.getSource().set("v.checked",false);return;}
        var appliedAmt =c.get("v.paymentAmount");
        var remainingAmt = parseFloat(paymentAmt-appliedAmt+c.get("v.cnAmount"));
        for(let x in list){
            if(list[x].Id === invoiceId){
                if(e.getSource().get("v.checked") &&  remainingAmt > 0.00){
                    if(remainingAmt > list[x].ERP7__Total_Due__c){
                        list[x].paymentApplied.ERP7__Amount__c = list[x].ERP7__Total_Due__c;
                        appliedAmt += list[x].ERP7__Total_Due__c;
                    }else{
                        list[x].paymentApplied.ERP7__Amount__c = remainingAmt;
                        appliedAmt +=remainingAmt;
                    }
                }
                else{
                    
                    appliedAmt -= list[x].paymentApplied.ERP7__Amount__c;
                    list[x].paymentApplied.ERP7__Amount__c = 0.00;
                    e.getSource().set("v.checked",false);
                }
            }
        }
        c.set("v.invoiceList",list);
        c.set("v.paymentAmount",appliedAmt);
        if(c.get("v.cnAmount")>0){
            if(c.get("v.cnAmount")==c.get("v.CustomerBalance")){
                c.set("v.NoPayment",true);
            }else{
                c.set("v.NoPayment",false);
            }
        }else{
            c.set("v.NoPayment",false);
        }
    },
    saveAppliedPayments : function(c,e,h){
        console.log('Inside saveAppliedPayments');
        if(!c.get("v.NoPayment")){
            if(c.get("v.Refund")){
                var msg = 'Fields marked as * are required';
                if(c.get('v.post')){
                    c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today'));
                }else{
                    c.set("v.payment.ERP7__Posted_Date__c",null);
                }
                if(c.get('v.CustomerBalance')<0){
                    c.set("v.payment.ERP7__Refund_Amount__c",c.get("v.payment.ERP7__Total_Amount__c"));
                    c.set("v.payment.ERP7__Refund__c",true);
                    c.set("v.payment.ERP7__Invoice__c",c.get("v.Invoice.Id"));
                    c.set("v.payment.ERP7__Sales_Order__c",c.get("v.Invoice.ERP7__Order__c"));
                }
                h.showSpinner(c,e);
                var validation = true;
                if(c.get('v.paymentMode')=='Cash' || c.get('v.paymentMode')=='Cheque/Wire'){
                    if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c')))
                    {
                        validation = false;
                    }
                }   
                //if($A.util.isUndefinedOrNull(c.find("vendorAccount").get("v.selectedRecordId")) || $A.util.isEmpty(c.find("vendorAccount").get("v.selectedRecordId")))
                   // validation = false;
                if($A.util.isUndefinedOrNull(c.find("paymentAmount").get("v.value")) || $A.util.isEmpty(c.find("paymentAmount").get("v.value"))){
                    c.find("paymentAmount").showHelpMessageIfInvalid();
                    validation = false;
                }
                if(!$A.util.isUndefinedOrNull(c.find("checkReference")) && ($A.util.isUndefinedOrNull(c.find("checkReference").get("v.value")) || $A.util.isEmpty(c.find("checkReference").get("v.value")))){
                    c.find("checkReference").showHelpMessageIfInvalid();
                    validation = false;
                }
                
                if(c.get('v.payment.ERP7__Bank_Charges__c') > 0 && c.get('v.payment.ERP7__Bank_Charges__c') !='' && c.get('v.payment.ERP7__Bank_Charges__c') != undefined ){
                    var total = parseInt(c.get('v.payment.ERP7__Bank_Charges__c')) + parseInt(c.get('v.payment.ERP7__Total_Amount__c'));
                    if( total > c.get('v.CustomerBalance')){
                        msg = 'Please Enter the proper amount';
                        validation = false;
                    }
                    if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Bank_Fee_COA__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Bank_Fee_COA__c')))
                    {
                        validation = false;
                    }
                }
                if(!validation){
                    h.hideSpinner(c,e);
                    h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'), msg); 
                    return;
                }
                
                var a = c.get("c.saveRefundPayment");
                a.setParams({payment:JSON.stringify(c.get("v.payment")),PM:c.get('v.paymentMode'),post:c.get('v.post'),
                             RType:c.get('v.setRT'),accId : c.get("v.payment.ERP7__Accounts__c")
                            });
                a.setCallback(this,function(res){
                    if(res.getState()==='SUCCESS'){
                        h.hideSpinner(c,e);
                        var result = res.getReturnValue();
                        var paymentName = res.getReturnValue().pay;
                        c.set('v.PayName', paymentName.Name);
                        h.showToast('Success',$A.get('$Label.c.Success') ,c.get('v.PayName')+$A.get('$Label.c.Is_Created'));
                        if(!$A.util.isUndefined(result['error'])){h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),result['error']);return;}
                        if(c.get("v.navigateToRecord")){
                            var navEvt = $A.get("e.force:navigateToSObject");
                            if(!$A.util.isUndefined(navEvt)){
                                navEvt.setParams({
                                    "recordId": ['payments'].Id
                                });
                                navEvt.fire();
                            }else {
                                var url = '/'+c.get("v.recordId");
                                window.open(url, "_self");
                            }
                        }else if(c.get("v.FromClosing")=== true){
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:ManageClosingOfBooksCheckList",
                                componentAttributes: {
                                    AP:c.get("v.AccoutingPeriod")
                                }
                            });
                            evt.fire();
                        }else{
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:AccountsReceivable",
                                componentAttributes: {
                                    "showTabs" : 'pay',
                                    "setSearch" : c.get('v.PayName')
                                }
                            });
                            evt.fire(); 
                        }
                    }
                });
                $A.enqueueAction(a);
            }else if(c.get("v.cnAmount")==0){
                var msg = 'Fields marked as * are required';
                if(c.get('v.post')){
                    c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today'));
                }else{
                    c.set("v.payment.ERP7__Posted_Date__c",null);
                }
                if(c.get('v.CustomerBalance')<0){
                    c.set("v.payment.ERP7__Refund_Amount__c",c.get("v.payment.ERP7__Total_Amount__c"));
                    c.set("v.payment.ERP7__Refund__c",true);
                    c.set("v.payment.ERP7__Invoice__c",c.get("v.Invoice.Id"));
                    c.set("v.payment.ERP7__Sales_Order__c",c.get("v.Invoice.ERP7__Order__c"));
                }
                c.find("invErrMsg").getElement().className="slds-hide";
                h.showSpinner(c,e);
                var validation = true;
                if(c.get('v.paymentMode')=='Cash' || c.get('v.paymentMode')=='Cheque/Wire'){
                    if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c')))
                    {
                        validation = false;
                    }
                }   
                //if($A.util.isUndefinedOrNull(c.find("vendorAccount").get("v.selectedRecordId")) || $A.util.isEmpty(c.find("vendorAccount").get("v.selectedRecordId")))
                   // validation = false;
                if($A.util.isUndefinedOrNull(c.find("paymentAmount").get("v.value")) || $A.util.isEmpty(c.find("paymentAmount").get("v.value"))){
                    c.find("paymentAmount").showHelpMessageIfInvalid();
                    validation = false;
                }
                if(!$A.util.isUndefinedOrNull(c.find("checkReference")) && ($A.util.isUndefinedOrNull(c.find("checkReference").get("v.value")) || $A.util.isEmpty(c.find("checkReference").get("v.value")))){
                    c.find("checkReference").showHelpMessageIfInvalid();
                    validation = false;
                }
                
                if(c.get('v.payment.ERP7__Bank_Charges__c') > 0 && c.get('v.payment.ERP7__Bank_Charges__c') !='' && c.get('v.payment.ERP7__Bank_Charges__c') != undefined ){
                    var total = parseInt(c.get('v.payment.ERP7__Bank_Charges__c')) + parseInt(c.get('v.payment.ERP7__Total_Amount__c'));
                    if( total > c.get('v.CustomerBalance')){
                        msg = 'Please Enter the proper amount';
                        validation = false;
                    }
                    if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Bank_Fee_COA__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Bank_Fee_COA__c')))
                    {
                        validation = false;
                    }
                }
                var cbox = c.find('cbox');
                if(!$A.util.isUndefined(cbox) && $A.util.isUndefined(cbox.length)){
                    if(!cbox.get("v.checked"))validation = false;
                }else if(c.get('v.setRT')!='Customer payment' && c.get('v.setRT')!='Debit_Note_Payments'){
                    var flag = 0;
                    for(var x in cbox){
                        if(cbox[x].get("v.checked"))flag++;
                    }
                    if(!flag){
                        validation = false;
                        c.find("invErrMsg").getElement().className="slds-show";
                    }
                }
                if(!validation){
                    h.hideSpinner(c,e);
                    h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'), msg); 
                    return;
                }
                //alert('called');
                //Please Review All Errors
                if(c.get("v.RT")=='Advance'){
                    c.set("v.advancePayment",true);
                }
                var a = c.get("c.saveAppliedPayment");
                var appliedList = [];
                var list = c.get("v.invoiceList");
                for(var x in list){
                    if(c.get("v.CustomerBalance")<0){
                        if(list[x].checked) {
                            list[x].paymentApplied.ERP7__Amount__c = -1 * list[x].paymentApplied.ERP7__Amount__c;
                        	appliedList.push(list[x].paymentApplied);
                    	}
                    }else if(list[x].checked && list[x].paymentApplied.ERP7__Amount__c > 0.00) {
                        appliedList.push(list[x].paymentApplied);
                    }
                }
                a.setParams({payment:JSON.stringify(c.get("v.payment")),appliedPaymentList:JSON.stringify(appliedList),PM:c.get('v.paymentMode'),post:c.get('v.post'),
                             RType:c.get('v.setRT'),accId : c.get("v.payment.ERP7__Accounts__c"),isAdvance : c.get("v.advancePayment")
                            });
                a.setCallback(this,function(res){
                    if(res.getState()==='SUCCESS'){
                        h.hideSpinner(c,e);
                        var result = res.getReturnValue();
                        var paymentName = res.getReturnValue().pay;
                        c.set('v.PayName', paymentName.Name);
                        h.showToast('Success',$A.get('$Label.c.Success'),c.get('v.PayName')+$A.get('$Label.c.Is_Created'));
                        if(!$A.util.isUndefined(result['error'])){h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'),result['error']);return;}
                        if(!$A.util.isEmpty(c.get("v.recordId")) && c.get("v.fromAccRec")=== false){//added the && part to navigate back to Accounts Rec page after creating payment-14/5/24
                            /* console.log('Inside recId');//this code was not working so added the below code to navigate-14/5/24
                            var url = '/'+c.get("v.recordId");
                            sforce.one.navigateToURL(url);
                        }*/
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId":c.get("v.recordId")
                            });
                            navEvt.fire();
                        }
                        if(c.get("v.navigateToRecord")){
                            console.log('Inside navtoRec');
                            var navEvt = $A.get("e.force:navigateToSObject");
                            if(!$A.util.isUndefined(navEvt)){
                                navEvt.setParams({
                                    "recordId": ['payments'].Id
                                });
                                navEvt.fire();
                            }else {
                                location.reload();  
                            }
                        }else if(c.get("v.FromClosing")=== true){
                            console.log('Inside fromclosing');
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:ManageClosingOfBooksCheckList",
                                componentAttributes: {
                                    AP:c.get("v.AccoutingPeriod")
                                }
                            });
                            evt.fire();
                        }else{
                            console.log('Inside AccRec');
                            /*$A.createComponent("c:AccountsReceivable",{
                                "showTabs" : 'pay',
                                "setSearch" : c.get('v.PayName')
                            },function(newCmp, status, errorMessage){
                                if (status === "SUCCESS") {
                                    console.log('Inside AccRec success');
                                    //var body = c.find("body");
                                    //body.set("v.body", newCmp);
                                }
                            });  */
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:AccountsReceivable",
                                componentAttributes: {
                                    "showTabs" : 'pay',
                                    "setSearch" : c.get('v.PayName')
                                }
                            });
                            evt.fire(); 
                        }
                    }
                });
                $A.enqueueAction(a);
            }else if(c.get("v.cnAmount")!=0 && (c.get("v.payment.ERP7__Total_Amount__c")==null || c.get("v.payment.ERP7__Total_Amount__c") == 0)){
                h.applyCredit(c, e);
            }else{
                var msg = 'Fields marked as * are required';
                if(c.get('v.post')){
                    c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today'));
                }else{
                    c.set("v.payment.ERP7__Posted_Date__c",null);
                }
                
                c.find("invErrMsg").getElement().className="slds-hide";
                h.showSpinner(c,e);
                var validation = true;
                if(c.get('v.paymentMode')=='Cash' || c.get('v.paymentMode')=='Cheque/Wire'){
                    if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c')))
                    {
                        validation = false;
                    }
                }   
                //if($A.util.isUndefinedOrNull(c.find("vendorAccount").get("v.selectedRecordId")) || $A.util.isEmpty(c.find("vendorAccount").get("v.selectedRecordId")))
                   // validation = false;
                if($A.util.isUndefinedOrNull(c.find("paymentAmount").get("v.value")) || $A.util.isEmpty(c.find("paymentAmount").get("v.value"))){
                    c.find("paymentAmount").showHelpMessageIfInvalid();
                    validation = false;
                }
                if(!$A.util.isUndefinedOrNull(c.find("checkReference")) && ($A.util.isUndefinedOrNull(c.find("checkReference").get("v.value")) || $A.util.isEmpty(c.find("checkReference").get("v.value")))){
                    c.find("checkReference").showHelpMessageIfInvalid();
                    validation = false;
                }
                
                if(c.get('v.payment.ERP7__Bank_Charges__c') > 0 && c.get('v.payment.ERP7__Bank_Charges__c') !='' && c.get('v.payment.ERP7__Bank_Charges__c') != undefined ){
                    var total = parseInt(c.get('v.payment.ERP7__Bank_Charges__c')) + parseInt(c.get('v.payment.ERP7__Total_Amount__c'));
                    if( total > c.get('v.CustomerBalance')){
                        msg = 'Please Enter the proper amount';
                        validation = false;
                    }
                    if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Bank_Fee_COA__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Bank_Fee_COA__c')))
                    {
                        validation = false;
                    }
                }
                var cbox = c.find('cbox');
                if(!$A.util.isUndefined(cbox) && $A.util.isUndefined(cbox.length)){
                    if(!cbox.get("v.checked"))validation = false;
                }else if(c.get('v.setRT')!='Customer payment' && c.get('v.setRT')!='Debit_Note_Payments'){
                    var flag = 0;
                    for(var x in cbox){
                        if(cbox[x].get("v.checked"))flag++;
                    }
                    if(!flag){
                        validation = false;
                        c.find("invErrMsg").getElement().className="slds-show";
                    }
                }
                if(!validation){
                    h.hideSpinner(c,e);
                    h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'), msg); 
                    return;
                } 
                if(c.get("v.RT")=='Advance'){
                    c.set("v.advancePayment",true);
                }
                //Please Review All Errors
                var a = c.get("c.saveAppliedPaymentAgainstCreditNote");
                var appliedList = [];
                var list = c.get("v.invoiceList");
                for(var x in list){
                    if(list[x].checked && list[x].paymentApplied.ERP7__Amount__c > 0.00){
                        appliedList.push(list[x].paymentApplied);
                    }
                }
                
                a.setParams({payment:JSON.stringify(c.get("v.payment")),appliedPaymentList:JSON.stringify(appliedList),PM:c.get('v.paymentMode'),post:c.get('v.post'),
                             RType:c.get('v.setRT'),accId : c.get("v.payment.ERP7__Accounts__c"),credNoteAmount : c.get("v.cnAmount"),isAdvance : c.get("v.advancePayment")
                            });
                a.setCallback(this,function(res){
                    if(res.getState()==='SUCCESS'){
                        h.hideSpinner(c,e);
                        var result = res.getReturnValue();
                        var paymentName = res.getReturnValue().pay;
                        c.set('v.PayName', paymentName.Name);
                        h.showToast('Success',$A.get('$Label.c.Success'),c.get('v.PayName')+$A.get('$Label.c.Is_Created'));
                        h.applyCredit(c, e);
                        /*if(!$A.util.isUndefined(result['error'])){h.showToast('error','Error!',result['error']);return;}
                        if(c.get("v.navigateToRecord")){
                            var navEvt = $A.get("e.force:navigateToSObject");
                            if(!$A.util.isUndefined(navEvt)){
                                navEvt.setParams({
                                    "recordId": ['payments'].Id
                                });
                                navEvt.fire();
                            }else {
                                location.reload();  
                            }
                        }else{
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:AccountsReceivable",
                                componentAttributes: {
                                    "showTabs" : 'pay',
                                    "setSearch" : c.get('v.PayName')
                                }
                            });
                            evt.fire(); 
                        }*/
                    }
                });
                $A.enqueueAction(a);
            }
        }else{
            h.applyCredit(c, e);
        }
    },
    
    fetchCreditNotes : function(c, e, h) {
        var action=c.get("c.fetchCreditNote");
        action.setParam("CusAccId",c.get("v.payment.ERP7__Accounts__c"));
        action.setCallback(this,function(r){
             if(r.getState() === 'SUCCESS'){
                 c.set("v.creditNotes",r.getReturnValue());
             }
        });
       $A.enqueueAction(action);
    },
    
    goBack : function(component, event, helper) {
        try{
            if (component.get("v.FromClosing") === true) {
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:ManageClosingOfBooksCheckList",
                    componentAttributes: {
                        AP:component.get("v.AccoutingPeriod")
                    }
                });
                evt.fire();
            }
            if(!$A.util.isEmpty(component.get("v.recordId")) && component.get("v.fromAccRec")===false){//added the && part to navigate back to the Accounts Rec page after creating payment-14/5/24
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId":component.get("v.recordId")
                });
                navEvt.fire();
                //var url = '/'+component.get("v.recordId");//this code was not working so added the above code to navigate-14/5/24
                //sforce.one.navigateToURL(url);
            }
            else{
                
                location.reload();
            }
            
        }
        catch(e){console.log('Error in Back:',e);}
    },
   
    setPostToTrue:function(component, event, helper) {
      component.set('v.post',true);  
    },
    setPostToFalse:function(component, event, helper) {
     component.set('v.post',false);   
    },
    onCheck: function(component,event,helper){
         //var poCheck=component.find('invoiceCheckbox').get("v.value");
         //var billCheck=component.find('customerCheckbox').get("v.value");
         var billCheck=component.find('customerCheckbox').get("v.checked");
         //if(poCheck)component.set('v.setRT','PO Bill');
        if(billCheck){
            component.set('v.setRT','Customer payment');
            component.set('v.ShowPaymentType',false);
            component.set('v.showRefundPage',true);
            component.set('v.showPage',false);
            
        }else{
         component.set('v.ShowPaymentType',false);
         component.set('v.showPage',true);
         component.set('v.showRefundPage',false);
        }
         
    },
    
    cancelclick : function(cmp,event,helper){
        if(cmp.get("v.FromClosing")=== true){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:ManageClosingOfBooksCheckList",
                componentAttributes: {
                    AP:cmp.get("v.AccoutingPeriod")
                }
            });
            evt.fire();
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:AccountsReceivable",
                componentAttributes: {
                    "showTabs" : 'pay'
                }
            });
            evt.fire();
        }
    },
    
    cardPaymentModal: function(cmp, event, helper){
        helper.showSpinner(cmp,event);
        
        var payAmt=cmp.get('v.payment.ERP7__Total_Amount__c');
        
        var validation=helper.validation(cmp,event);
        if(!validation) return;
        
        var action=cmp.get("c.cardDetails");
        action.setParams({
            accId:cmp.get("v.payment.ERP7__Accounts__c"),
            OrgId:cmp.get('v.OrgId')
        });
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
               
                var res=response.getReturnValue();
                if(res.errorMsg != '') helper.showToast('Error',$A.get('$Label.c.Error_UsersShiftMatch'),res.errorMsg);
                var currCountry=res.shipAdd.ERP7__Country__c;
                var currState=res.shipAdd.ERP7__State__c;
                for(var i in res.CountryList){
                    if(res.CountryList[i].value == currCountry)
                        res.CountryList[i].selected=true;
                }
                for(var j in res.CountyList){
                    if(res.CountyList[j].value == currState)
                        res.CountyList[j].selected=true;
                }
                res.ExpiryMonth[0].selected=true;
                res.ExpiryYear[0].selected=true;
                res.CardTypes[0].selected=true;
                cmp.set('v.cardOptions',res.CardTypes);
                cmp.set('v.countryOptions',res.CountryList);
                cmp.set('v.stateOptions',res.CountyList);
                cmp.set('v.monthsOptions',res.ExpiryMonth);
                cmp.set('v.yearsOptions',res.ExpiryYear);
                cmp.set("v.billingAdd",res.shipAdd);
                
                if(res.isMultiCurrency){
                    cmp.set("v.isMultiCurrency",res.isMultiCurrency);
                    cmp.set("v.orderCurrency",res.orderCurrency);
                }
                
                $A.util.addClass(cmp.find("myModalCard"),"slds-fade-in-open");
                $A.util.addClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
                helper.hideSpinner(cmp,event);
            }else{
                console.log('Error:',response.getError());
                $A.util.addClass(cmp.find("myModalCard"),"slds-fade-in-open");
                $A.util.addClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
                helper.hideSpinner(cmp,event);
            }
        });
        $A.enqueueAction(action);        
    },
    
    closeCardModal : function(component, event, helper) {
        $A.util.removeClass(component.find("myModalCard"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalCardBackdrop"),"slds-backdrop_open");        
    },
    
    CardPayment : function(cmp,event,helper){
        helper.showSpinner(cmp,event);
        cmp.set("v.CardError", ''); 
        cmp.set('v.post',true);
        cmp.set("v.payment.ERP7__Posted_Date__c", cmp.get('v.today'));
        var customer=cmp.get("v.payment.ERP7__Accounts__c");
        var billingAdd=cmp.get('v.billingAdd');
        var payment=cmp.get("v.payment");
        var paymentMode=cmp.get('v.paymentMode');
        var post=cmp.get('v.post');
        var RType=cmp.get('v.setRT');
        var PaymentMethod=cmp.get("v.PaymentMethod");
        
                
        var appliedList = [];
        var list = cmp.get("v.invoiceList");
        for(var x in list)
            if(list[x].checked && list[x].paymentApplied.ERP7__Amount__c > 0.00) 
                appliedList.push(list[x].paymentApplied);
        
        
        if(PaymentMethod.ERP7__CardType__c =='') PaymentMethod.ERP7__CardType__c=cmp.get("v.cardOptions")[0].value;
        if(PaymentMethod.ERP7__Card_Expiration_Month__c == '') PaymentMethod.ERP7__Card_Expiration_Month__c=cmp.get('v.monthsOptions')[0].value;
        if(PaymentMethod.ERP7__Card_Expiration_Year__c == '') PaymentMethod.ERP7__Card_Expiration_Year__c=cmp.get("v.yearsOptions")[0].value;
        
        //if(cmp.get("v.payType") != 'Stripe'){
            var validate=helper.validatePayment(cmp,event);
            if(!validate){helper.hideSpinner(cmp,event);return;}
            var action=cmp.get("c.cardPaymentUpdate");
            action.setParams({
                customer:customer,
                billingAdd1:JSON.stringify(billingAdd),
                payment:JSON.stringify(payment),
                paymentMode:JSON.stringify(paymentMode),
                post:post,
                RType:RType,
                appliedList:JSON.stringify(appliedList),
                PaymentMethod1:JSON.stringify(PaymentMethod),
                cvvs:cmp.get("v.CVV"),
                orgId:cmp.get("v.OrgId"),
                payGate : cmp.get("v.payType")
            });
            action.setCallback(this,function(response){
                if(response.getState()==="SUCCESS"){
                    if(response.getReturnValue().payment.Id != '' && response.getReturnValue().payment.Id != undefined){
                        cmp.set('v.PayName', response.getReturnValue().payment.Name);                    
                        helper.showToast('Success',$A.get('$Label.c.Success'),cmp.get('v.PayName')+$A.get('$Label.c.Is_Created'));
                        helper.hideSpinner(cmp,event);
                        if(cmp.get("v.FromClosing")=== true){
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:ManageClosingOfBooksCheckList",
                                componentAttributes: {
                                    AP:cmp.get("v.AccoutingPeriod")
                                }
                            });
                            evt.fire();
                        }else{
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:AccountsReceivable",
                                componentAttributes: {
                                    "showTabs" : 'pay',
                                    "setSearch" : cmp.get('v.PayName')
                                }
                            });
                            evt.fire(); 
                        }
                    }else{
                        cmp.set("v.CardError", "Invalid Details");
                    }
                    
                    if(response.getReturnValue().errorMsg != '') cmp.set("v.CardError", response.getReturnValue().errorMsg);
                    
                    
                    helper.hideSpinner(cmp,event);
                }else{
                    cmp.set("v.CardError", response.getReturnValue()); 
                    console.log('Error:',response.getError());
                    helper.hideSpinner(cmp,event);
                }
            });
            $A.enqueueAction(action);
        /*}else{
            var action=cmp.get("c.cardPaymentUpdateStripe");
            action.setParams({
                customer:customer,
                billingAdd1:JSON.stringify(billingAdd),
                payment:JSON.stringify(payment),
                paymentMode:JSON.stringify(paymentMode),
                post:post,
                RType:RType,
                appliedList:JSON.stringify(appliedList),
                PaymentMethod1:JSON.stringify(PaymentMethod),
                cvvs:cmp.get("v.CVV"),
                orgId:cmp.get("v.OrgId"),
                invId : cmp.get("v.recordId")
            });
            action.setCallback(this,function(response){
                if(response.getState()==="SUCCESS"){
                    window.location.replace(response.getReturnValue().navigateURL);
                    if(response.getReturnValue().errorMsg != '') cmp.set("v.CardError", response.getReturnValue().errorMsg);
                    
                    
                    helper.hideSpinner(cmp,event);
                }else{
                    cmp.set("v.CardError", response.getReturnValue()); 
                    console.log('Error:',response.getError());
                    helper.hideSpinner(cmp,event);
                }
            });
            $A.enqueueAction(action);
        }*/
        
        
    },
    
    
    
     updateRefundPaymentAmount : function(c,e,h){
        var list = c.get("v.creditNotes");
        var ccAmount = 0*1;
        for(var x in list){
            if(list[x].debitAmount!=null){
                ccAmount = ccAmount + list[x].debitAmount*1;
            }
        }
        c.set("v.cnAmount",ccAmount);
        if(c.get("v.cnAmount")!=0){
            c.set("v.payment.ERP7__Total_Amount__c",ccAmount);
        }
    },
    
    
    saveRefund : function(c,e,h){
        
        var msg = 'Fields marked as * are required';
        if(c.get('v.post')){
            c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today'));
        }else{
            c.set("v.payment.ERP7__Posted_Date__c",null);
        }
        
        h.showSpinner(c,e);
        var validation = true;
        if(c.get('v.paymentMode')=='Cash' || c.get('v.paymentMode')=='Cheque/Wire'){
            if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c')))
            {
                validation = false;
            }
        }   
        //if($A.util.isUndefinedOrNull(c.find("vendorAccount").get("v.selectedRecordId")) || $A.util.isEmpty(c.find("vendorAccount").get("v.selectedRecordId")))
        // validation = false;
        if($A.util.isUndefinedOrNull(c.find("RpaymentAmount").get("v.value")) || $A.util.isEmpty(c.find("RpaymentAmount").get("v.value"))){
            c.find("RpaymentAmount").showHelpMessageIfInvalid();
            validation = false;
        }
        if(!$A.util.isUndefinedOrNull(c.find("RcheckReference")) && ($A.util.isUndefinedOrNull(c.find("RcheckReference").get("v.value")) || $A.util.isEmpty(c.find("RcheckReference").get("v.value")))){
            c.find("RcheckReference").showHelpMessageIfInvalid();
            validation = false;
        }
        
        if(c.get('v.payment.ERP7__Bank_Charges__c') > 0 && c.get('v.payment.ERP7__Bank_Charges__c') !='' && c.get('v.payment.ERP7__Bank_Charges__c') != undefined ){
            if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Bank_Fee_COA__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Bank_Fee_COA__c')))
            {
                validation = false;
            }
        }
        
        if(!validation){
            h.hideSpinner(c,e);
            h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'), msg); 
            return;
        } 
        //Please Review All Errors
        var a = c.get("c.saveRefundPay");
        a.setParams({payment:JSON.stringify(c.get("v.payment")),accId : c.get("v.payment.ERP7__Accounts__c"),RType:c.get('v.setRT'), PM:c.get('v.paymentMode'), post:c.get('v.post')});
        a.setCallback(this,function(res){
            if(res.getState()==='SUCCESS'){
                h.hideSpinner(c,e);
                var result = res.getReturnValue();
                var paymentName = res.getReturnValue().pay;
                c.set('v.PayName', paymentName.Name);
                c.set('v.RefundPaymentId', paymentName.Id);
                h.showToast('Success',$A.get('$Label.c.Success'),c.get('v.PayName')+$A.get('$Label.c.Is_Created'));
                if(c.get("v.cnAmount")>0) h.applyRefundCredit(c, e);
                else{
                    var url = '/'+c.get("v.RefundPaymentId");
                    window.location.replace(url);
                }
            }
        });
        $A.enqueueAction(a);
    },
    
    saveRefundPost : function(c,e,h){
        
        var msg = 'Fields marked as * are required';
        c.set("v.post", true);
        if(c.get('v.post')){
            c.set("v.payment.ERP7__Posted_Date__c", c.get('v.today'));
        }else{
            c.set("v.payment.ERP7__Posted_Date__c",null);
        }
        
        h.showSpinner(c,e);
        var validation = true;
        if(c.get('v.paymentMode')=='Cash' || c.get('v.paymentMode')=='Cheque/Wire'){
            if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Payment_Account__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Payment_Account__c')))
            {
                validation = false;
            }
        }   
        //if($A.util.isUndefinedOrNull(c.find("vendorAccount").get("v.selectedRecordId")) || $A.util.isEmpty(c.find("vendorAccount").get("v.selectedRecordId")))
        // validation = false;
        if($A.util.isUndefinedOrNull(c.find("RpaymentAmount").get("v.value")) || $A.util.isEmpty(c.find("RpaymentAmount").get("v.value"))){
            c.find("RpaymentAmount").showHelpMessageIfInvalid();
            validation = false;
        }
        if(!$A.util.isUndefinedOrNull(c.find("RcheckReference")) && ($A.util.isUndefinedOrNull(c.find("RcheckReference").get("v.value")) || $A.util.isEmpty(c.find("RcheckReference").get("v.value")))){
            c.find("RcheckReference").showHelpMessageIfInvalid();
            validation = false;
        }
        
        if(c.get('v.payment.ERP7__Bank_Charges__c') > 0 && c.get('v.payment.ERP7__Bank_Charges__c') !='' && c.get('v.payment.ERP7__Bank_Charges__c') != undefined ){
            if($A.util.isUndefinedOrNull(c.get('v.payment.ERP7__Bank_Fee_COA__c')) || $A.util.isEmpty(c.get('v.payment.ERP7__Bank_Fee_COA__c')))
            {
                validation = false;
            }
        }
        
        if(!validation){
            h.hideSpinner(c,e);
            h.showToast('error',$A.get('$Label.c.Error_UsersShiftMatch'), msg); 
            return;
        } 
        //Please Review All Errors
        var a = c.get("c.saveRefundPay");
        a.setParams({payment:JSON.stringify(c.get("v.payment")),accId : c.get("v.payment.ERP7__Accounts__c"),RType:c.get('v.setRT'), PM:c.get('v.paymentMode'), post:c.get('v.post')});
        a.setCallback(this,function(res){
            if(res.getState()==='SUCCESS'){
                h.hideSpinner(c,e);
                var result = res.getReturnValue();
                var paymentName = res.getReturnValue().pay;
                c.set('v.PayName', paymentName.Name);
                c.set('v.RefundPaymentId', paymentName.Id);
                h.showToast('Success',$A.get('$Label.c.Success'),c.get('v.PayName')+$A.get('$Label.c.Is_Created'));
                if(c.get("v.cnAmount")>0) h.applyRefundCredit(c, e);
                else{
                    var url = '/'+c.get("v.RefundPaymentId");
                    window.location.replace(url);
                }
            }
        });
        $A.enqueueAction(a);
    },
    
    checkDiscount : function(c,e,h){
        //alert(c.get("v.Invoice.ERP7__Payment_Terms__c"));
        var a = c.get("c.getDaysBetween");
        a.setParams({invDate:c.get("v.Invoice.ERP7__Invoice_Date__c"),payDate : c.get("v.payment.ERP7__Payment_Date__c")});
        a.setCallback(this,function(res){
            //alert(res.getState());
            if(res.getState()==='SUCCESS'){
                var days = res.getReturnValue();
                let text = c.get("v.Invoice.ERP7__Payment_Terms__c");
                var myArray = text.split("Days");
                let word = myArray[0];
                //var myArray1 = word.split(" ");
                var amount = parseFloat(word);
                if(parseInt(amount)>parseInt(days)){
                    let word2 = myArray[1];
                    var myArray2 = word2.split(" ");
                    var amount2 = myArray2[1];
                    var amount3 = amount2.split("%");
                    amount3 = parseFloat(amount3);
                    var amountUpdated = amount3.toFixed(2);
                    c.set("v.defaultDiscount", amountUpdated);
                    c.set("v.payment.ERP7__Discount_Rate__c",amountUpdated);
                    var message = 'Discount Applied since customer is making payment before '+amount+ ' days';
                    c.set("v.Message", message);
                    c.set("v.DisMessage",'');
                    var disTaxRate = amountUpdated/100;
                    c.set("v.payment.ERP7__Discount_Amount__c", c.get("v.payment.ERP7__Total_Amount__c")*disTaxRate);
                }else{
                    c.set("v.payment.ERP7__Discount_Rate__c",0);
                    c.set("v.payment.ERP7__Discount_Amount__c", 0);
                    c.set("v.Message", '');
                    
                }
                //alert()
                /*let word = myArray[0];
                var myArray1 = word.split("/");
                var amount = parseFloat(myArray1);
                var amountUpdated = amount.toFixed(2);
                c.set("v.payment.ERP7__Discount_Rate__c",amount);*/
                
            }
        });
        $A.enqueueAction(a);
        /*
        let text = c.get("v.Invoice.ERP7__Payment_Terms__c");
		var myArray = text.split("Net");
		let word = myArray[0];
        var myArray1 = word.split("/");
        var amount = parseFloat(myArray1);
        var amountUpdated = amount.toFixed(2);
        c.set("v.payment.ERP7__Discount_Rate__c",amount);*/
    },
    
    UpdateDiscountAmount : function(c,e,h){
        var payDis = c.get("v.payment.ERP7__Discount_Rate__c");
        if(parseFloat(payDis)>c.get("v.defaultDiscount")){
            c.set("v.DisMessage",'You are providing the discount more then the specified');
        }else{
            c.set("v.DisMessage",'');
        }
        var disTaxRate = c.get("v.payment.ERP7__Discount_Rate__c")/100;
        c.set("v.payment.ERP7__Discount_Amount__c", c.get("v.payment.ERP7__Total_Amount__c")*disTaxRate);
    }
})