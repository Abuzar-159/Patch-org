({
    fetchSOsolisbyInv : function(component,event){
        console.log('fetchSOsolisbyInv inv called');
        component.set("v.exceptionError","");
        if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");
        var fetchaction = component.get("c.Build_RMALIByInvoice");
        fetchaction.setParams({"InvoiceId":component.get("v.RMA.ERP7__Invoice__c")}); 
        fetchaction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('response in fetchSOsolisbyInv~>'+JSON.stringify(response.getReturnValue()));
                var obj = response.getReturnValue();
                component.set("v.solis",[]);
                component.set("v.unfilteredsolis",[]);
                if(obj != null  && obj.sObj != null && obj.RAMLI_List.length>0){
                    //component.set("v.SelectRMALI",obj.RAMLI_List);
                    var newobj = [];
                    var RMALIlist = obj.RAMLI_List;
                    for(var i=0;i<RMALIlist.length;i++){
                        if(!$A.util.isEmpty(RMALIlist[i].RMALI) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI)){
                            if(!$A.util.isEmpty(RMALIlist[i].RMALI.ERP7__Quantity_Return__c) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI.ERP7__Quantity_Return__c)){
                                if(RMALIlist[i].RMALI.ERP7__Quantity_Return__c > 0){
                                    RMALIlist[i].returnQty = RMALIlist[i].RMALI.ERP7__Quantity_Return__c;
                                    RMALIlist[i].accepType = RMALIlist[i].RMALI.ERP7__Acceptance_Type__c;
                                    RMALIlist[i].reasonReason = RMALIlist[i].RMALI.ERP7__Return_Reason__c;
                                    newobj.push(RMALIlist[i]);
                                }
                            }
                        }
                    }
                    component.set("v.solis",newobj);
                    component.set("v.unfilteredsolis",newobj);
                    var obj =  []; obj =  component.get('v.solis');
                    if(obj.length>0){
                        var selectRMA = []; selectRMA = component.get("v.SelectRMALI");
                        var solis = [];
                        console.log('showModal selectRMA size~>'+selectRMA.length+' obj solis size~>'+ obj.length);
                        if(selectRMA.length>0){
                            for(var i=0;i<selectRMA.length;i++){
                                for(var j=0;j<obj.length;j++){
                                    if(selectRMA[i] == obj[j]){
                                        obj[j].isSelect = true;
                                        //solis.push(obj[j]);
                                    }
                                }
                            }
                        }
                        component.set("v.solis",obj); 
                        component.set("v.unfilteredsolis",obj);
                    }
                    console.log('solis set from inv~>'+JSON.stringify(component.get("v.solis")));
                }else{
                    console.log('fetchSOsolisbyInv no solis');
                }
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                ); 
            }else{
                console.log('errors in fetchSOsolisbyInv~>'+response.getError());
                var errors = response.getError();
                component.set("v.exceptionError",errors[0].message);
                setTimeout(function(){
                    component.set("v.exceptionError", "");
                }, 5000);
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                ); 
            }
        });
        $A.enqueueAction(fetchaction); 
    },
    
    fetchOrdsolisbyInv : function(component,event){
        console.log('fetchOrdsolisbyInv inv called');
        component.set("v.exceptionError","");
        if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");
        var fetchaction = component.get("c.Fetch_RMALIByInvoice");
        fetchaction.setParams({"InvoiceId":component.get("v.RMA.ERP7__Invoice__c")}); 
        fetchaction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('response in fetchOrdsolisbyInv~>'+JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                component.set("v.solis",[]);
                component.set("v.unfilteredsolis",[]);
                if(resp != null  && resp.sObj != null && resp.RAMLI_List.length>0){
                    //component.set("v.SelectRMALI",obj.RAMLI_List);
                    var newobj = [];
                    var RMALIlist = resp.RAMLI_List;
                    for(var i=0;i<RMALIlist.length;i++){
                        if(!$A.util.isEmpty(RMALIlist[i].RMALI) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI)){
                            if(!$A.util.isEmpty(RMALIlist[i].RMALI.ERP7__Quantity_Return__c) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI.ERP7__Quantity_Return__c)){
                                if(RMALIlist[i].RMALI.ERP7__Quantity_Return__c > 0){
                                    RMALIlist[i].returnQty = RMALIlist[i].RMALI.ERP7__Quantity_Return__c;
                                    RMALIlist[i].accepType = RMALIlist[i].RMALI.ERP7__Acceptance_Type__c;
                                    RMALIlist[i].reasonReason = RMALIlist[i].RMALI.ERP7__Return_Reason__c;
                                    newobj.push(RMALIlist[i]);
                                }
                            }
                        }
                    }
                    component.set("v.solis",newobj);
                    component.set("v.unfilteredsolis",newobj);
                    var obj =  []; obj =  component.get('v.solis');
                    if(obj.length>0){
                        var selectRMA = []; selectRMA = component.get("v.SelectRMALI");
                        var solis = [];
                        console.log('showModal selectRMA size~>'+selectRMA.length+' obj solis size~>'+ obj.length);
                        if(selectRMA.length>0){
                            for(var i=0;i<selectRMA.length;i++){
                                for(var j=0;j<obj.length;j++){
                                    if(selectRMA[i] == obj[j]){
                                        obj[j].isSelect = true;
                                        //solis.push(obj[j]);
                                    }
                                }
                            }
                        }
                        component.set("v.solis",obj); 
                        component.set("v.unfilteredsolis",obj);
                    }
                    console.log('solis set from inv~>'+JSON.stringify(component.get("v.solis")));
                }else{
                    console.log('fetchOrdsolisbyInv no solis');
                }
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                ); 
            }else{
                console.log('errors in fetchOrdsolisbyInv~>'+response.getError());
                var errors = response.getError();
                component.set("v.exceptionError",errors[0].message);
                setTimeout(function(){
                    component.set("v.exceptionError", "");
                }, 5000);
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                );  
            }
        });
        $A.enqueueAction(fetchaction); 
    },
    
    fetchSORMALI : function(component,event){
        console.log('fetchSORMALI inv called');
        component.set("v.exceptionError","");
        var fetchaction = component.get("c.Build_RMALIByInvoice");
        fetchaction.setParams({"InvoiceId":component.get("v.RMA.ERP7__Invoice__c")}); 
        fetchaction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var obj = response.getReturnValue();
                console.log('obj SORMALI in fetch by inv~>'+JSON.stringify(response.getReturnValue()));
                var customerdata = obj.sObj;
                if(obj != null  && obj.sObj != null){
                    try{
                        if(!$A.util.isEmpty(customerdata.ERP7__Account__c)){
                            component.set("v.RMA.ERP7__Account__c",customerdata.ERP7__Account__c);                                
                        }
                        if(!$A.util.isEmpty(customerdata.ERP7__Contact__c)){
                            component.set("v.RMA.ERP7__Return_Contact__c",customerdata.ERP7__Contact__c);                                
                        }
                        component.set("v.channelId",customerdata.ERP7__Order__r.ERP7__Channel__c);
                        var con = {};
                        if(!$A.util.isEmpty(customerdata.ERP7__Order__r.ERP7__Contact__c)){
                            con.Id =customerdata.ERP7__Order__r.ERP7__Contact__c;
                            con.Name=customerdata.ERP7__Order__r.ERP7__Contact__r.Name;
                        }
                        if(!$A.util.isEmpty(customerdata.ERP7__Order__c)){
                            component.set("v.RMA.ERP7__SO__c",customerdata.ERP7__Order__c);
                        }                            
                        component.set("v.CustContact",con);
                        var addr = {};
                        if(!$A.util.isEmpty(customerdata.ERP7__Order__r.ERP7__Ship_To_Address__c)){                                
                            component.set("v.RMA.ERP7__Address__c",customerdata.ERP7__Order__r.ERP7__Ship_To_Address__c);
                        }                                
                    }catch(err){
                        console.log('error '+err);
                    }
                }                   
                component.set("v.solis",[]);
                component.set("v.unfilteredsolis",[]);
                if(obj != null  && obj.sObj != null && obj.RAMLI_List.length>0){
                    //component.set("v.SelectRMALI",obj.RAMLI_List);
                    var newobj = [];
                    var RMALIlist = obj.RAMLI_List;
                    for(var i=0;i<RMALIlist.length;i++){
                        if(!$A.util.isEmpty(RMALIlist[i].RMALI) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI)){
                            if(!$A.util.isEmpty(RMALIlist[i].RMALI.ERP7__Quantity_Return__c) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI.ERP7__Quantity_Return__c)){
                                if(RMALIlist[i].RMALI.ERP7__Quantity_Return__c > 0){
                                    RMALIlist[i].returnQty = RMALIlist[i].RMALI.ERP7__Quantity_Return__c;
                                    RMALIlist[i].accepType = RMALIlist[i].RMALI.ERP7__Acceptance_Type__c;
                                    RMALIlist[i].reasonReason = RMALIlist[i].RMALI.ERP7__Return_Reason__c;
                                    newobj.push(RMALIlist[i]);
                                }
                            }
                        }
                    }
                    component.set("v.SelectRMALI",newobj);
                    component.set("v.solis",newobj);
                    component.set("v.unfilteredsolis",newobj);
                }else{
                    component.set("v.SelectRMALI",[]);
                    component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_No_Items_To_Return_For_Selected_Invoice'));
                }
                var selRMALI = [];
                selRMALI = component.get("v.SelectRMALI");
                var totalamt = 0.00;
                var totalamtWOtax = 0.00;
                if(selRMALI.length>0){
                    for(var i=0;i<selRMALI.length;i++){
                        if(!$A.util.isEmpty(selRMALI[i].RMALI) && !$A.util.isUndefinedOrNull(selRMALI[i].RMALI)){
                            if(!$A.util.isEmpty(selRMALI[i].RMALI.ERP7__Total_Deduction__c) && !$A.util.isUndefinedOrNull(selRMALI[i].RMALI.ERP7__Total_Deduction__c)){
                                totalamt += selRMALI[i].RMALI.ERP7__Total_Deduction__c;
                                if(!$A.util.isEmpty(selRMALI[i].RMALI.ERP7__Sale_Price__c) && !$A.util.isUndefinedOrNull(selRMALI[i].RMALI.ERP7__Sale_Price__c) && !$A.util.isEmpty(selRMALI[i].returnQty) && !$A.util.isUndefinedOrNull(selRMALI[i].returnQty)){
                                    totalamtWOtax = totalamtWOtax + (selRMALI[i].RMALI.ERP7__Sale_Price__c * selRMALI[i].returnQty);
                                }
                            }
                        }
                    }
                }
                component.set("v.totalamt",totalamt);
                component.set("v.totalamtli",totalamt);
                component.set("v.totalamtWOtax",totalamtWOtax);
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                );   
            }else{
                console.log('errors in fetchSORMALI~>'+response.getError());
                var errors = response.getError();
                component.set("v.exceptionError",errors[0].message);
                setTimeout(function(){
                    component.set("v.exceptionError", "");
                }, 5000);
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                );  
            }
        });
        if($A.util.isEmpty(component.get("v.RMA.Id")))
            $A.enqueueAction(fetchaction); 
        else{
            setTimeout(
                $A.getCallback(function() {
                    if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                }), 3000
            );   
            console.log('fetchSORMALI rma already exixts');
        }
    },
    
    fetchOrderRMLI : function(component,event){
        console.log('fetchOrderRMLI inv called');
        component.set("v.exceptionError","");
        var fetchaction = component.get("c.Fetch_RMALIByInvoice");
        fetchaction.setParams({"InvoiceId":component.get("v.RMA.ERP7__Invoice__c")}); 
        fetchaction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var obj = response.getReturnValue();
                console.log('obj Order RMALI in fetch by inv~>'+JSON.stringify(response.getReturnValue()));
                var customerdata = obj.sObj;
                if(obj != null  && obj.sObj != null){
                    try{
                        if(!$A.util.isEmpty(customerdata.ERP7__Account__c)){
                            component.set("v.RMA.ERP7__Account__c",customerdata.ERP7__Account__c);                                
                        }
                        if(!$A.util.isEmpty(customerdata.ERP7__Contact__c)){
                            component.set("v.RMA.ERP7__Return_Contact__c",customerdata.ERP7__Contact__c);                                
                        }
                        component.set("v.channelId",customerdata.ERP7__Order_S__r.ERP7__Channel__c);
                        var con = {};
                        if(!$A.util.isEmpty(customerdata.ERP7__Order_S__r.ERP7__Contact__c)){
                            con.Id =customerdata.ERP7__Order_S__r.ERP7__Contact__c;
                            con.Name=customerdata.ERP7__Order_S__r.ERP7__Contact__r.Name;
                        }
                        if(!$A.util.isEmpty(customerdata.ERP7__Order_S__c)){
                            component.set("v.RMA.ERP7__Order__c",customerdata.ERP7__Order_S__c);
                        }                            
                        component.set("v.CustContact",con);
                        var addr = {};
                        if(!$A.util.isEmpty(customerdata.ERP7__Order_S__r.ERP7__Ship_To_Address__c)){                                
                            component.set("v.RMA.ERP7__Address__c",customerdata.ERP7__Order_S__r.ERP7__Ship_To_Address__c);
                        }                                
                    }catch(err){
                        console.log('error '+err);
                    }
                }                   
                component.set("v.solis",[]);
                component.set("v.unfilteredsolis",[]);
                if(obj != null  && obj.sObj != null && obj.RAMLI_List.length>0){
                    //component.set("v.SelectRMALI",obj.RAMLI_List);
                    var newobj = [];
                    var RMALIlist = obj.RAMLI_List;
                    for(var i=0;i<RMALIlist.length;i++){
                        if(!$A.util.isEmpty(RMALIlist[i].RMALI) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI)){
                            if(!$A.util.isEmpty(RMALIlist[i].RMALI.ERP7__Quantity_Return__c) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI.ERP7__Quantity_Return__c)){
                                if(RMALIlist[i].RMALI.ERP7__Quantity_Return__c > 0){
                                    RMALIlist[i].returnQty = RMALIlist[i].RMALI.ERP7__Quantity_Return__c;
                                    RMALIlist[i].accepType = RMALIlist[i].RMALI.ERP7__Acceptance_Type__c;
                                    RMALIlist[i].reasonReason = RMALIlist[i].RMALI.ERP7__Return_Reason__c;
                                    newobj.push(RMALIlist[i]);
                                }
                            }
                        }
                    }
                    component.set("v.SelectRMALI",newobj);
                    component.set("v.solis",newobj);
                    component.set("v.unfilteredsolis",newobj);
                }else{
                    component.set("v.SelectRMALI",[]);
                    component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_No_Items_To_Return_For_Selected_Invoice'));                   
                }
                var selRMALI = [];
                selRMALI = component.get("v.SelectRMALI");
                var totalamt = 0.00;
                var totalamtWOtax = 0.00;
                if(selRMALI.length>0){
                    for(var i=0;i<selRMALI.length;i++){
                        if(!$A.util.isEmpty(selRMALI[i].RMALI) && !$A.util.isUndefinedOrNull(selRMALI[i].RMALI)){
                            if(!$A.util.isEmpty(selRMALI[i].RMALI.ERP7__Total_Deduction__c) && !$A.util.isUndefinedOrNull(selRMALI[i].RMALI.ERP7__Total_Deduction__c)){
                                totalamt += selRMALI[i].RMALI.ERP7__Total_Deduction__c;
                                if(!$A.util.isEmpty(selRMALI[i].RMALI.ERP7__Sale_Price__c) && !$A.util.isUndefinedOrNull(selRMALI[i].RMALI.ERP7__Sale_Price__c) && !$A.util.isEmpty(selRMALI[i].returnQty) && !$A.util.isUndefinedOrNull(selRMALI[i].returnQty)){
                                    totalamtWOtax = totalamtWOtax + (selRMALI[i].RMALI.ERP7__Sale_Price__c * selRMALI[i].returnQty);
                                }
                            }
                        }
                    }
                }
                component.set("v.totalamt",totalamt);
                component.set("v.totalamtli",totalamt);
                component.set("v.totalamtWOtax",totalamtWOtax);
                
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                ); 
            }else{
                console.log('errors in fetchOrderRMLI~>'+response.getError());
                var errors = response.getError();
                component.set("v.exceptionError",errors[0].message);
                setTimeout(function(){
                    component.set("v.exceptionError", "");
                }, 5000);
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                );
            }
        });
        if($A.util.isEmpty(component.get("v.RMA.Id")))
            $A.enqueueAction(fetchaction);
        else{
            setTimeout(
                $A.getCallback(function() {
                    if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                }), 3000
            );  
            console.log('fetchOrderRMLI rma already exixts');
        }
    },
    
    fetchRMADetails : function(component, event, helper, onLoadRmaId){
        console.log('fetchRMADetails called onLoadRmaId~>'+onLoadRmaId);
        var fetchaction = component.get("c.fetch_RMALI");
        fetchaction.setParams({"RMA_Id":onLoadRmaId});
        fetchaction.setParams({
            "RMA_Id":onLoadRmaId,
            "isSalesOrder":component.get("v.isSOAccess"),
            "isOrder":component.get("v.isOrderAcc")
        }); 
        fetchaction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.preventChanges",false);
                var obj = response.getReturnValue();
                console.log('fetchRMADetails success~>'+JSON.stringify(obj));
                var customerdata = obj.sObj;
                component.set("v.RMA_lookup.Id",onLoadRmaId);
                component.set("v.RMA_lookup.Name",customerdata.Name);                
            }else {
                console.log('Error:',response.getError());
                var errors = response.getError();
                component.set("v.exceptionError",errors[0].message);
                setTimeout(function(){
                    component.set("v.exceptionError", "");
                }, 5000);
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                );
            }
        });
        $A.enqueueAction(fetchaction); 
    },
    
    showToast : function(modeType,title, type, message) {	
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":modeType,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }
    },
    
    hideModal: function(component, event) {
        component.set("v.savehide",false);
        var cmpTarget = component.find('showModal');
        $A.util.removeClass(cmpTarget, 'slds-show');
        $A.util.addClass (cmpTarget, 'slds-hide');
        
    },
    
    focusTOscan:function(component, event){
        $(document).ready(function() {
            component.set("v.scanValue",'');
            var pressed = false;
            var chars = [];
            $(window).keypress(function(e) {          
                chars.push(String.fromCharCode(e.which));                      
                if (pressed == false) {
                    setTimeout(
                        $A.getCallback(function() {
                            if (chars.length >= 4) {                         
                                var barcode = chars.join("");
                                barcode = barcode.trim();
                                component.set("v.scanValue",barcode);
                            }
                            chars = [];
                            pressed = false;
                        }), 500
                    );                               
                }              
                pressed = true;
            });        
            
            $(window).keypress(function(e){
                if ( e.which === 13 ) {        
                    e.preventDefault();
                }
            }); 
        });
        $(window).trigger('keypress');
    },
    
    resetAttribute : function(component,event){
        if(!component.reset){
            component.reset = true;           
            component.set("v.RMA",{});           
            component.set("v.SelectRMALI",[]);  
            var totalamt = 0.00;
            component.set("v.totalamt",totalamt);
            component.set("v.totalamtli",totalamt);
            component.set("v.totalamtWOtax",totalamt);
            component.set("v.RMA.ERP7__Account__c",'');
            component.set("v.CustContact.Id",'');           
            component.set("v.RMA.ERP7__Address__c",'');
            component.set("v.RMA.ERP7__Return_Contact__c",'');
            component.set("v.CustContact.Name",'');            
            component.set("v.solis",[]); 
            component.set("v.unfilteredsolis",[]);
        }    
    },
    
    fetchCRUD: function(component, event, helper) {
        var action = component.get("c.getCRUD");
        action.setCallback(this, function(a) {
            component.set("v.crudValues", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    fetchStatus: function(component, event,helper){
        var action = component.get("c.getStatus");
        var inputsel = component.find("InputSelectDynamic");
        var opts=[];
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            // inputsel.set("v.options", opts);
            component.set("v.InputSelectDynamicOptions",opts);
            
        });
        $A.enqueueAction(action); 
    },
    
    CreatePO : function(component, event, helper,recordId){  
        //var rmaId = event.currentTarget.getAttribute('data-recordId');
        console.log('RMAid~>'+component.get("v.RMA.Id"));
        $A.createComponent("c:CreatePurchaseOrder",{
            "rmaId":component.get("v.RMA.Id"),
            "rmaliID":recordId,
            
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);
            }
        });     
        //"cancelclick":component.getReference("c.backTO")
    },
    
    CreateWO : function(component, event, helper,recordId){
        //var rmaId = event.currentTarget.getAttribute('data-rmarecordId');
        var URL_RMA = '/apex/ERP7__WorkOrderLC?rmarecordId='+recordId;
        window.open(URL_RMA,'_blank');
    },
    
})