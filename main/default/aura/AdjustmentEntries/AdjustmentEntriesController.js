({
    doinit : function(component, event, helper) {
        console.log('doinit AdjustmentEntries called');
        component.set('v.showSpinner', true);
        helper.fetchcurrency(component, event, helper);
        var action = component.get('c.fetchDetails');
        action.setParams({Offset: component.get("v.Offset"),
                          RecordLimit: component.get('v.show'),searchString :component.get('v.setSearch')
                         });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('success in doInit~>'+JSON.stringify(response.getReturnValue()));
                component.set('v.Instance', response.getReturnValue());
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().adjustmentList;   
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
                component.set('v.showSpinner', false);
                
                helper.addDebits(component, event, helper);
            }else{
                console.log('doInit error occured');
                var errors = response.getError();
                console.log("server error in doInit : ", JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
        
    },
    
    changeTab : function(component, event, helper){
        component.set('v.Tab', event.currentTarget.getAttribute("id"));
    },
    
    addDebit : function(component, event, helper){
        helper.addDebits(component, event, helper);
    },
    
    addCredit : function(component, event, helper){
        helper.addCredits(component, event, helper);
    },
    
    deleteEntires : function(component, event, helper){
        component.set('v.showSpinner', true);
        var i = event.currentTarget.getAttribute("id");
        var wrapper = component.get('v.newInstanceFGLEs');
        wrapper.splice(i, 1); 
        component.set('v.newInstanceFGLEs', wrapper);
        component.set('v.showSpinner', false);
    },
    
    deleteCloneEntires : function(component, event, helper){
        component.set('v.showSpinner', true);
        var i = event.currentTarget.getAttribute("id");
        var wrapper = component.get('v.Instance.editAdjustments');
        wrapper.splice(i, 1); 
        component.set('v.Instance.editAdjustments', wrapper);
        $A.enqueueAction(component.get("c.updateEditDebitCredit"));
        component.set('v.showSpinner', false);
    },
    
    addNew : function(component, event, helper) {
        try{
            var fgleList = component.get("v.Instance.editAdjustments");
            if(component.get("v.editTotalDebit")>component.get("v.editTotalCredit")){
                fgleList.push({sObjectType :'Finance_General_Ledger_Entry__c', ERP7__General_Ledger_Entry_Type__c:'Credit'});
            }else{
                fgleList.push({sObjectType :'Finance_General_Ledger_Entry__c', ERP7__General_Ledger_Entry_Type__c:'Debit'});
            }
            console.log('fgleList'+JSON.stringify(fgleList));
            component.set("v.Instance.editAdjustments",fgleList);
        }catch(e){
            console.log('addNew err',e);
        }
    },
    
    save : function(component, event, helper){
        console.log('newInstanceFGLEs log--> ', component.get('v.newInstanceFGLEs'));
        console.log('Instance log--> ', component.get('v.Instance'));
        console.log('is_Adjustment__c log--> ', component.get('v.Instance.adjEntries.Trans.ERP7__is_Adjustment__c'));
        component.set('v.Instance.adjEntries.Trans.ERP7__is_Adjustment__c', component.get('v.Instance.dummyadjEntries.Trans.ERP7__is_Adjustment__c'));
        component.set('v.Instance.adjEntries.Trans.ERP7__Transaction_Status__c', component.get('v.Instance.dummyadjEntries.Trans.ERP7__Transaction_Status__c'));
        console.log('is_Adjustment__c log--> ', component.get('v.Instance.dummyadjEntries.Trans.ERP7__is_Adjustment__c'));
        component.set('v.mesgType', 'slds-notify slds-notify_toast slds-theme--error');
        if( component.get('v.TotalDebit') != component.get('v.TotalCredit') ){
            component.set('v.message', $A.get('$Label.c.Entries_not_matched'));
            component.set("v.showMessage",true);
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showMessage",false);
                }), 3000
            );
        }else if(component.get('v.TotalDebit') < 0 || component.get('v.TotalCredit') < 0 || component.get('v.TotalCredit') == 0 || component.get('v.TotalDebit') == 0){
            component.set('v.message', $A.get('$Label.c.Please_enter_debit_and_credit'));
            component.set("v.showMessage",true);
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showMessage",false);
                }), 3000
            );
        }else{
            component.set('v.showSpinner', true);
            var btn = event.getSource();
            var label= btn.get('v.label');
            var action;
            console.log('Currency before save: ', component.get('v.Instance.adjEntries.Trans.CurrencyIsoCode'));
            if(label == 'Save and Close' ){
                action = component.get('c.saveandClose');
            }else{
                action = component.get('c.saveandNew');
            }

			console.log('before save newInstanceFGLEs~>'+JSON.stringify(component.get('v.newInstanceFGLEs')));
            component.set('v.Instance.adjEntries.FGLEs',component.get('v.newInstanceFGLEs'));
            action.setParams({Offset: component.get("v.Offset"),
                              RecordLimit: component.get('v.show'),
                              searchString :component.get('v.setSearch'),
                              ins:JSON.stringify(component.get('v.Instance')),
                             });
            
            action.setCallback(this, function(response){
                if( response.getState() == 'SUCCESS'){
                    component.set("v.refreshList", false);
                    component.set("v.refreshList", true);
                    
                    console.log('resp save~>',response.getReturnValue());
                    console.log('after apex save adjEntries.FGLEs~>',response.getReturnValue().adjEntries.FGLEs);
                    component.set('v.Instance', response.getReturnValue());
                    
                    component.set('v.Instance.adjEntries.Trans', response.getReturnValue().dummyadjEntries.Trans);
                    
                    console.log('Bfr entries v.newInstanceFGLEs', component.get('v.newInstanceFGLEs'));
                    
                    component.set("v.newInstanceFGLEs",null);  
                    
                    console.log('after entries v.newInstanceFGLEs', component.get('v.newInstanceFGLEs'));
                    
                    component.set('v.mesgType', 'slds-notify slds-notify_toast slds-theme--success');
                    component.set('v.message', 'Transaction : '+response.getReturnValue().transName+' is created.');
                    component.set("v.showMessage",true);
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.showMessage",false);
                        }), 5000
                    );
                    component.set('v.showSpinner', false);
                    component.set('v.TotalDebit', 0);  component.set('v.TotalCredit', 0);
                    
                    
                    var Offsetval=parseInt(component.get("v.Offset"));
                    var records;   
                    records = response.getReturnValue().adjustmentList;   
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
                    
                    if(label == 'Save and Close') component.set('v.Tab', 'Tab1');
                    else helper.addDebits(component, event, helper);
                    
                    component.set("v.refreshList", false);
                    
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.refreshList", true);
                        }), 2000);
                    
                }else{
                    component.set('v.message', 'There is no valid accounting period for the selected transaction date ');
                    component.set("v.showMessage",true);
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.showMessage",false);
                        }), 4000
                    );
                    console.log('save Error occured', response.getError());
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    clear :  function(component, event, helper){
          component.set("v.newInstanceFGLEs",null);
        component.set('v.TotalDebit', 0);  component.set('v.TotalCredit', 0);
        helper.addDebits(component, event, helper);
    },
    
    fecthCOA : function(component, event, helper){
        console.log('fecthCOA called');
        var wrapper = component.get('v.newInstanceFGLEs');
        var index = event.currentTarget.getAttribute('id');
        if(wrapper != undefined && wrapper != null){
            if(wrapper.length > 0){
                var AccountId = wrapper[index].GEntries.ERP7__CustomerVendor__c;
                if(AccountId != null && AccountId != '' && AccountId !=undefined ){
                    component.set('v.showSpinner', true);
                    var action = component.get("c.setCOANew");
                    action.setParams({count:event.currentTarget.getAttribute('id'),
                                      selID:AccountId,
                                      ins:JSON.stringify(component.get('v.Instance'))});
                    action.setCallback(this, function(response){
                        if(response.getState() === "SUCCESS"){
                            console.log('setCOANew resp~>',response.getReturnValue());
                            if(response.getReturnValue() != null){
                                if(wrapper[index].GEntries.Chart_of_Account__c != undefined && wrapper[index].GEntries.Chart_of_Account__c != null){
                                    wrapper[index].GEntries.Chart_of_Account__c = response.getReturnValue();
                                    component.set("v.newInstanceFGLEs",wrapper);
                                }
                            }
                            component.set('v.showSpinner', false);
                        }else{
                            console.log('setCOANew Error occured');
                            component.set('v.showSpinner', false);
                        }
                    });
                    $A.enqueueAction(action);
                }  
            }
        }
    },
    
    fecthEditCOA : function(component, event, helper){
        var wrapper = component.get('v.Instance.editAdjustments');
        var AccountId = wrapper[event.currentTarget.getAttribute('id')].ERP7__CustomerVendor__c;
        
        if(AccountId != null && AccountId != '' && AccountId !=undefined ){
            component.set('v.showSpinner', true);
            var action = component.get('c.setEditCOA');
            action.setParams({count:event.currentTarget.getAttribute('id'),
                              selID:AccountId,
                              ins:JSON.stringify(component.get('v.Instance'))});
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                    component.set('v.Instance.editAdjustments', response.getReturnValue().editAdjustments);
                    component.set('v.showSpinner', false);
                }else{
                    //('Error occured');
                }
            });
            $A.enqueueAction(action);
        }    
    },
    
    updateDebitCredit : function(component, event, helper){
        component.set('v.showSpinner', true);
        var wrapper = component.get('v.newInstanceFGLEs');
        var debitCount = 0; var creditCount = 0;
        for(var i in wrapper){ 
            if(wrapper[i].GEntries.ERP7__General_Ledger_Entry_Type__c == 'Debit'){
                if(wrapper[i].GEntries.ERP7__Debit_Entry__c < 0 || wrapper[i].GEntries.ERP7__Debit_Entry__c !=0 ) debitCount = parseFloat(debitCount) + parseFloat(0);
                if(wrapper[i].GEntries.ERP7__Debit_Entry__c > 0)debitCount = parseFloat(debitCount) + parseFloat(wrapper[i].GEntries.ERP7__Debit_Entry__c);  
            }
            else{
                if(wrapper[i].GEntries.ERP7__Credit_Entry__c < 0 || wrapper[i].GEntries.ERP7__Credit_Entry__c !=0 ) creditCount = parseFloat(creditCount) + parseFloat(0);
                if(wrapper[i].GEntries.ERP7__Credit_Entry__c > 0)creditCount = parseFloat(creditCount) + parseFloat(wrapper[i].GEntries.ERP7__Credit_Entry__c);
            }
        }
        if(debitCount > 0 || debitCount == 0)component.set('v.TotalDebit', debitCount.toFixed(2) );
        if(creditCount > 0 || creditCount == 0)component.set('v.TotalCredit', creditCount.toFixed(2) );
        component.set('v.showSpinner', false);
    },
    
    hideNotification : function(component, event, helper){
        component.set("v.showMessage",false);
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.getTransactions(component, event, helper);
        }
    },
    
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.getTransactions(component, event, helper);
        }
    },
    
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.getTransactions(component, event, helper);
        }
    },
    
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.getTransactions(component, event, helper);
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
        helper.getTransactions(component, event, helper);
    },
    
    OfsetChange : function(component,event,helper){
        var Offsetval ;
        Offsetval= component.find("ik").get("v.value");
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
            helper.getTransactions(component, event, helper);
        } else component.set("v.PageNum",((curOffset+show)/show));
    },
    
    setShow : function(component,event,helper){
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.PageNum", 1);
        helper.getTransactions(component,event);
    },
    
    handleComponentEvent : function(component,event,helper){
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        var searchString =component.get('v.setSearch');
        if(searchString.length>1){
            helper.getTransactions(component,event);
        }else{
            if(searchString.length==0) helper.getTransactions(component,event);
        }
    },
    
    deleteTrans : function(component, event, helper){
        var btn = event.getSource();
        var selID= btn.get('v.name');
        component.set('v.selTransaction', selID);
        component.set('v.showPOPUp', true);
    },
    
    DeleteTransaction : function(component, event, helper){
        var selID = component.get('v.selTransaction');
        var action = component.get('c.deleteAdjsTransaction');
        action.setParams({Offset: component.get("v.Offset"),
                          RecordLimit: component.get('v.show'),
                          searchString :component.get('v.setSearch'),
                          selId:selID,
                          ins:JSON.stringify(component.get('v.Instance')), });
        action.setCallback(this, function(response){
            var state = response.getState();
            if( state === "SUCCESS" ){
                component.set('v.Instance.adjustmentList', response.getReturnValue().adjustmentList);    
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().adjustmentList;   
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
                component.set('v.showPOPUp', false);
            }else{
                //('Error in getTransactions');
            }
        });
        $A.enqueueAction(action);
    },
    
    CancelDelete : function(component, event, helper){
        component.set('v.showPOPUp', false);
    },
    
    changeDate :function(component, event, helper){
        console.log('adjdate-------------->' , component.get('v.Instance.adjDate'));
        console.log('value-------------->' , component.get('v.Instance.AdjwrapperList.Trans.ERP7__Transaction_Date__c'));
        const date = component.get('v.Instance.AdjwrapperList.Trans.ERP7__Transaction_Date__c');
        const parts = date.split("-");
        const formattedDate = `${parts[2]}/${parts[1]}/${parts[0]}`
        component.set('v.Instance.adjDate',formattedDate);
        console.log('adjdate after-------------->' , formattedDate);
        const today = new Date();
		console.log(today);
    } ,
    
    EditTransaction : function(component, event, helper){
        var btn = event.getSource();
        var selID= btn.get('v.name');
        var action  = component.get('c.getFGLES');
        action.setParams({selId :selID,
                          ins : JSON.stringify(component.get('v.Instance')),
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                component.set('v.Instance.editAdjustments', response.getReturnValue().editAdjustments);
                component.set('v.Instance.editTrans', response.getReturnValue().editTrans);
                component.set('v.editTotalDebit', component.get('v.Instance.editTrans.ERP7__Amount__c') );
                component.set('v.editTotalCredit', component.get('v.Instance.editTrans.ERP7__Amount__c') );
                component.set('v.showEditPopup', true); 
                component.set("v.cloneProcess", false);
            }else{
                //('Error occured in EditTransaction');
            }
        });
        $A.enqueueAction(action);
    }, 
    
    CloneAdjustment : function(component, event, helper){
        var selID= event.target.closest('a').dataset.record;
        var action  = component.get('c.getFGLES');
        action.setParams({selId :selID,
                          ins : JSON.stringify(component.get('v.Instance')),
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                component.set('v.Instance.editAdjustments', response.getReturnValue().editAdjustments);
                component.set('v.Instance.editTrans', response.getReturnValue().editTrans);
                component.set('v.editTotalDebit', component.get('v.Instance.editTrans.ERP7__Amount__c') );
                component.set('v.editTotalCredit', component.get('v.Instance.editTrans.ERP7__Amount__c') );
                component.set('v.showEditPopup', true); 
                component.set("v.cloneProcess", true);
            }else{
                //('Error occured in EditTransaction');
            }
        });
        $A.enqueueAction(action);
    }, 
    
    cancelEdit : function(component, event, helper){
        component.set('v.showEditPopup', false);
    },
    
    saveEditTrans : function(component, event, helper){
        component.set('v.mesgType', 'slds-notify slds-notify_toast slds-theme--error');
        if( component.get('v.editTotalDebit') != component.get('v.editTotalCredit') ){
            component.set('v.message', $A.get('$Label.c.Entries_not_matched'));
            component.set("v.showMessage",true);
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showMessage",false);
                }), 3000
            );
        }else if(component.get('v.editTotalDebit') < 0 || component.get('v.editTotalCredit') < 0 || component.get('v.editTotalCredit') == 0 || component.get('v.editTotalDebit') == 0){
            component.set('v.message', $A.get('$Label.c.Please_enter_debit_and_credit'));
            component.set("v.showMessage",true);
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showMessage",false);
                }), 3000
            );
        }else{
            component.set('v.Instance.editTrans.ERP7__Amount__c', component.get('v.editTotalDebit'));    
            component.set('v.showEditPopup', false);    
            component.set('v.showSpinner', true);
            var action =  component.get('c.saveEditEntries');
            action.setParams({ins : JSON.stringify(component.get('v.Instance'))});
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set('v.showSpinner', false);
                    component.set('v.mesgType', 'slds-notify slds-notify_toast slds-theme--success');
                    component.set('v.message', $A.get('$Label.c.Transaction_saved_successfully'));
                    component.set("v.showMessage",true);
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.showMessage",false);
                        }), 3000
                    );
                    helper.getTransactions(component, event, helper);
                }else{
                    //('Error in saveEditTrans');
                }
            });
            $A.enqueueAction(action);
        }
        
    }, 
    
    updateEditDebitCredit : function(component, event, helper){
        component.set('v.showSpinner', true);
        var wrapper = component.get('v.Instance.editAdjustments');
        var debitCount = 0; var creditCount = 0;
        for(var i in wrapper){ 
            if(wrapper[i].ERP7__General_Ledger_Entry_Type__c == 'Debit'){
                if(wrapper[i].ERP7__Debit_Entry__c < 0 || wrapper[i].ERP7__Debit_Entry__c !=0 ) debitCount = parseFloat(debitCount) + parseFloat(0);
                if(wrapper[i].ERP7__Debit_Entry__c > 0)debitCount = parseFloat(debitCount) + parseFloat(wrapper[i].ERP7__Debit_Entry__c);  
            }
            else{
                if(wrapper[i].ERP7__Credit_Entry__c < 0 || wrapper[i].ERP7__Credit_Entry__c !=0 ) creditCount = parseFloat(creditCount) + parseFloat(0);
                if(wrapper[i].ERP7__Credit_Entry__c > 0)creditCount = parseFloat(creditCount) + parseFloat(wrapper[i].ERP7__Credit_Entry__c);
            }
        }

        if(debitCount > 0 || debitCount == 0)component.set('v.editTotalDebit',  debitCount.toFixed(2) );
        if(creditCount > 0 || creditCount == 0)component.set('v.editTotalCredit', creditCount.toFixed(2) );
        component.set('v.showSpinner', false);
    },
    
    updateTransaction : function(component, event, helper){
        console.log('updateTransaction called');
        helper.getTransactions(component, event, helper);
    },
    
    showGFLES : function(component, event, helper){
        component.set('v.Tab', 'Tab2');
        console.log('Set value' ,component.get('v.Instance.AdjwrapperList.Trans.ERP7__Transaction_Date__c'));
        const date = new Date();
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        const formattedDate = `${year}-${month}-${day}`;
        console.log('Today\'s value' ,formattedDate);
        component.set('v.Instance.AdjwrapperList.Trans.ERP7__Transaction_Date__c',formattedDate);
        console.log('Transaction date' ,component.get('v.Instance.AdjwrapperList.Trans.ERP7__Transaction_Date__c'));
        
        var addNew = true;
        if(component.get('v.newInstanceFGLEs') != undefined && component.get('v.newInstanceFGLEs') != null){
            if(component.get('v.newInstanceFGLEs').length > 0) addNew = false;
        }
        if(addNew) helper.addDebits(component, event, helper);
    },
    
    showEntreis : function(component, event, helper){
        component.set('v.Tab', 'Tab1');
    },
    
    navigateToBRComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BankReconciliation",
            componentAttributes: {
                Bank_Reconciliation_Id : component.get("v.BRId"),
                showTabs : 'inv',
                FromSP : true,
                OrganisationId:component.get("v.orgFromBrec")
            }
        });
        evt.fire();
    },
    
    navigateToClosingComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ManageClosingOfBooksCheckList",
            componentAttributes: {
                AP:component.get("v.AccoutingPeriod"),
                OrgId:component.get("v.COBOrgId")
            }
        });
        evt.fire();
    },
    
    SortRecodEventHandler : function(cmp, event, helper) {
        var RecordList = event.getParam("RecordList"); 
        cmp.set("v.Instance.adjustmentList",RecordList);
    },
    
    
    saveCloneTrans : function(component, event, helper){
        component.set('v.mesgType', 'slds-notify slds-notify_toast slds-theme--error');
        if( component.get('v.editTotalDebit') != component.get('v.editTotalCredit') ){
            component.set('v.message', $A.get('$Label.c.Entries_not_matched'));
            component.set("v.showMessage",true);
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showMessage",false);
                }), 3000
            );
        }else if(component.get('v.editTotalDebit') < 0 || component.get('v.editTotalCredit') < 0 || component.get('v.editTotalCredit') == 0 || component.get('v.editTotalDebit') == 0){
            component.set('v.message', $A.get('$Label.c.Please_enter_debit_and_credit'));
            component.set("v.showMessage",true);
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showMessage",false);
                }), 3000
            );
        }else{
            component.set('v.Instance.editTrans.ERP7__Amount__c', component.get('v.editTotalDebit'));
            component.set('v.Instance.editTrans.Id', null);
            component.set('v.showEditPopup', false);    
            component.set('v.showSpinner', true);
            var action =  component.get('c.saveCloneEntries');
            action.setParams({ins : JSON.stringify(component.get('v.Instance'))});
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set('v.showSpinner', false);
                    component.set('v.mesgType', 'slds-notify slds-notify_toast slds-theme--success');
                    component.set('v.message', $A.get('$Label.c.Transaction_saved_successfully'));
                    component.set("v.showMessage",true);
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.showMessage",false);
                        }), 3000
                    );
                    helper.getTransactions(component, event, helper);
                }else{
                    //('Error in saveEditTrans');
                }
            });
            $A.enqueueAction(action);
        }
        
    }, 
    
    
})