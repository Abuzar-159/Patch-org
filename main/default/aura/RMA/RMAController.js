({
    fetchRMALI : function(component, event, helper){
        if(component.get("v.preventChanges") == false){
            console.log('fetchRMALi called');
            if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");                                                      
            component.set("v.RMAId",component.get("v.RMA_lookup")['Id']);
            if(!$A.util.isEmpty(component.get("v.RMA_lookup.Id")) && !$A.util.isUndefined(component.get("v.RMA_lookup.Id"))){
                var fetchaction = component.get("c.fetch_RMALI");
                fetchaction.setParams({
                    "RMA_Id":component.get("v.RMA_lookup")['Id'],
                    "isSalesOrder":component.get("v.isSOAccess"),
                    "isOrder":component.get("v.isOrderAcc")
                }); 
                fetchaction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        console.log('fetchRMALI in success');
                        var obj = response.getReturnValue();
                        component.set("v.RMA",obj.sObj);  
                        
                        // component.set("v.RMA_lookup.Id",obj.sObj.Id);                    
                        var customerdata = obj.sObj;
                        component.set("v.solis",[]); 
                        component.set("v.unfilteredsolis",[]);
                        if(customerdata){
                            if(component.get("v.RMA.ERP7__Authorize__c") || component.get("v.RMA.ERP7__Is_Closed__c")){
                                component.set("v.disaAddbutton",true);
                                component.set("v.disaeditdelete",true);
                            }else { component.set("v.disaAddbutton",false); component.set("v.disaeditdelete",false); }
                            
                            component.set("v.priorCloseValue",customerdata.ERP7__Is_Closed__c);
                            if(!$A.util.isEmpty(customerdata.ERP7__SO__c) && !$A.util.isUndefinedOrNull(customerdata.ERP7__SO__c)){
                                if($A.util.isEmpty(component.get("v.RMA.ERP7__SO__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__SO__c"))) component.set("v.RMA.ERP7__SO__c",customerdata.ERP7__SO__c);                        
                            }
                            if(!$A.util.isEmpty(customerdata.ERP7__Order__c)  && !$A.util.isUndefinedOrNull(customerdata.ERP7__Order__c)){
                                if($A.util.isEmpty(component.get("v.RMA.ERP7__Order__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Order__c"))) component.set("v.RMA.ERP7__Order__c",customerdata.ERP7__Order__c);                        
                            }
                            if(!$A.util.isEmpty(customerdata.ERP7__Account__c)  && !$A.util.isUndefinedOrNull(customerdata.ERP7__Account__c)){                        	
                                if($A.util.isEmpty(component.get("v.RMA.ERP7__Account__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Account__c")))  component.set("v.RMA.ERP7__Account__c",customerdata.ERP7__Account__c);
                            }
                            if(!$A.util.isEmpty(customerdata.ERP7__Invoice__c)  && !$A.util.isUndefinedOrNull(customerdata.ERP7__Invoice__c)){
                                if($A.util.isEmpty(component.get("v.RMA.ERP7__Invoice__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Invoice__c")))  component.set("v.RMA.ERP7__Invoice__c",customerdata.ERP7__Invoice__c);
                            }
                            
                            component.set("v.RMA.ERP7__Address__c",customerdata.ERP7__Address__c);
                            
                            component.set("v.RMA.ERP7__Return_Contact__c",customerdata.ERP7__Return_Contact__c);
                            
                            if(!$A.util.isEmpty(customerdata.ERP7__Address__c)  && !$A.util.isUndefinedOrNull(customerdata.ERP7__Address__c)){                           
                                if($A.util.isEmpty(component.get("v.RMA.ERP7__Address__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Address__c"))) component.set("v.RMA.ERP7__Address__c",customerdata.ERP7__Address__c);
                            }
                            component.set("v.freightType",customerdata.ERP7__Frieght_Type__c);
                        }
                        if(obj.RAMLI_List.length>0){ 
                            var newobj = [];
                            var RMALIlist = obj.RAMLI_List;
                            for(var i=0;i<RMALIlist.length;i++){
                                if(!$A.util.isEmpty(RMALIlist[i].RMALI) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI)){
                                    RMALIlist[i].returnQty = RMALIlist[i].RMALI.ERP7__Quantity_Return__c;
                                    RMALIlist[i].accepType = RMALIlist[i].RMALI.ERP7__Acceptance_Type__c;
                                    RMALIlist[i].reasonReason = RMALIlist[i].RMALI.ERP7__Return_Reason__c;
                                    newobj.push(RMALIlist[i]);
                                }
                            }
                            component.set("v.SelectRMALI",newobj);
                            //component.set("v.SelectRMALI",obj.RAMLI_List);
                        }else component.set("v.SelectRMALI",[]);     
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
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        );  
                        var errors = response.getError();
                        console.log('fetchRMALI Error:',errors);
                        component.set("v.exceptionError", errors[0].message);
                        setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
                    }
                });         
                $A.enqueueAction(fetchaction);
                
            }
            else{
                console.log('fetchRMALI rmalookupId is empty');
                var action = component.get("c.getRMAInstance");    
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") { 
                        component.set("v.RMA",response.getReturnValue());
                        component.set("v.SelectRMALI",[]);  
                        var totalamt = 0.00;
                        component.set("v.totalamt",totalamt);
                        component.set("v.totalamtli",totalamt);
                        component.set("v.totalamtWOtax",totalamt);
                        component.set("v.RMA.ERP7__Account__c",'');
                        component.set("v.RMA.ERP7__Order__c",'');
                        component.set("v.CustContact.Id",'');           
                        component.set("v.RMA.ERP7__Address__c",'');
                        component.set("v.RMA.ERP7__Return_Contact__c",'');
                        component.set("v.CustContact.Name",'');            
                        component.set("v.solis",[]); 
                        component.set("v.unfilteredsolis",[]);
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        );                                                                                                                               
                    }else{
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        ); 
                        console.log('Error getRMAInstance:',response.getError());
                    }       
                });
                $A.enqueueAction(action);
            } 
            $A.enqueueAction(component.get("c.calculateShippingTaxPercentage"));
            $A.enqueueAction(component.get("c.calculateRestockTaxPercentage"));
        }
    },
    
    fetchRMALIByInvId : function(component, event, helper){
        console.log('fetchRMALIByInvId called');
        if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");           
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Invoice__c")) && !$A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Invoice__c"))){
            if(component.get('v.isSOAccess')){
                helper.fetchSORMALI(component,event);
            }
            if(component.get('v.isOrderAcc')){
                helper.fetchOrderRMLI(component,event);
            }
        }
        else{
            console.log('fetchRMALIByInvId rma invId empty');
            if($A.util.isEmpty(component.get("v.RMA.Id")) || $A.util.isUndefinedOrNull(component.get("v.RMA.Id"))){
                component.set("v.solis",[]);
                component.set("v.SelectRMALI",[]);
                var totalamt = 0.00;
                component.set("v.totalamt",totalamt);
                component.set("v.totalamtli",totalamt);
                component.set("v.totalamtWOtax",totalamt);
                component.set("v.unfilteredsolis",[]);
                component.set("v.RMA.ERP7__SO__c",'');
                component.set("v.RMA.ERP7__Order__c",'');
            }
            if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
        }
    },
    
    fetchCustomerInfo : function(component, event, helper) {
        console.log('fetchCustomerInfo called');
        if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");
        var customerinfo = component.get("c.FetchcustomerInfo");
        var invId = '';
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Invoice__c")) && !$A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Invoice__c"))){
            invId = component.get("v.RMA.ERP7__Invoice__c");
        }
        var ordId = '';
        if(component.get('v.isOrderAcc')){
            if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Order__c")) && !$A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Order__c"))){
                ordId = component.get("v.RMA.ERP7__Order__c");
            }
        }
        customerinfo.setParams({
            "custId":component.get("v.RMA.ERP7__Account__c"),
            "invId":invId,
            "ordId":ordId,
            "isSalesOrder":component.get("v.isSOAccess"),
            "isOrder":component.get("v.isOrderAcc")
        });
        customerinfo.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var obj = response.getReturnValue();
                if(!component.get("v.RMA.ERP7__Address__c") && obj.Address.Id != null && ($A.util.isEmpty(component.get("v.RMA.ERP7__Address__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Address__c")))){                   
                    component.set("v.RMA.ERP7__Address__c",obj.Address.Id);
                }
                if(!component.get("v.CustContact.Id") && obj.contact.Id != null && ($A.util.isEmpty(component.get("v.RMA.ERP7__Return_Contact__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Return_Contact__c")))){    
                    component.set("v.RMA.ERP7__Return_Contact__c",obj.contact.Id);
                    component.set("v.CustContact.Id",obj.contact.Id); 
                    component.set("v.CustContact.Name",obj.contact.Name);  
                } 
                
                component.set("v.offSet",'0');
                 console.log('fetchCustomerInfo obj.RAMLI_List length~>'+obj.RAMLI_List.length);
                //console.log('fetchCustomerInfo obj.RAMLI_List~>'+JSON.stringify(obj.RAMLI_List));
                if(($A.util.isEmpty(component.get("v.RMA.ERP7__Invoice__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Invoice__c"))) && ($A.util.isEmpty(component.get("v.RMA.Id")) || $A.util.isUndefinedOrNull(component.get("v.RMA.Id")) || (component.get("v.RMA.ERP7__Is_Closed__c") == false && component.get("v.RMA.ERP7__Authorize__c") == false))) {
                    if(obj.RAMLI_List.length >0){
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
                                    }else console.log('RMALI.ERP7__Quantity_Return__c not > 0');
                                }else console.log('RMALI.ERP7__Quantity_Return__c empty');
                            }else console.log('RMALI empty');
                        }
                        console.log('fetchCustomerInfo newobj ~>'+newobj.length);
                        component.set("v.solis",newobj);
                        component.set("v.unfilteredsolis",newobj);
                        console.log('solis length after~>'+component.get("v.solis").length);
                         console.log('unfilteredsolis length after~>'+component.get("v.unfilteredsolis").length);
                        var solis =  []; solis = component.get("v.solis");
                        if(solis.length>0){
                            var selectRMA = []; selectRMA = component.get("v.SelectRMALI");   
                            //console.log('selectRMA~>'+JSON.stringify(selectRMA));
                            if(selectRMA.length>0){
                                for(var i=0;i<selectRMA.length;i++){
                                    for(var j=0;j<solis.length;j++){
                                        if(selectRMA[i] == solis[j]){
                                            solis[j].isSelect = true;
                                        }
                                    }
                                }
                            }
                            component.set("v.solis",solis); 
                            component.set("v.unfilteredsolis",solis);
                        }
                        //console.log('solis set from assets acc~>'+JSON.stringify(component.get("v.solis")));
                    }else console.log('obj.RAMLI_List empty');
                }else console.log('Invoice not empty');
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                );                    
            }else{
                setTimeout(
                    $A.getCallback(function() {
                        if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    }), 3000
                ); 
                var errors = response.getError();
                component.set("v.exceptionError",errors[0].message);
                setTimeout(function(){
                    component.set("v.exceptionError", "");
                }, 5000);
            }
        });        
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Account__c")) && !$A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Account__c"))){
            $A.enqueueAction(customerinfo);
        }else{
            console.log('fetchCustomerInfo rma custinfo account empty');
            setTimeout(
                $A.getCallback(function() {
                    if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                }), 3000
            );                                
            helper.resetAttribute(component,event);
            component.set("v.CustContact.Id",'');            	
            component.set("v.RMA.ERP7__Address__c",'');
        }
        
    },
    
    dummy : function(component, event, helper){
        console.log('ERP7__Return_Contact__c handler~>'+component.get("v.RMA.ERP7__Return_Contact__c"));
    },
    
    fetchAddress : function(component, event, helper){
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Address__c")) && !$A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Address__c")) && !$A.util.isEmpty(component.get("v.RMA.ERP7__Account__c")) && !$A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Account__c"))){
            console.log('fetchAddress called rma address~>'+component.get("v.RMA.ERP7__Address__c"));
            if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");
            var customerinfo = component.get("c.FetchAddressById");
            customerinfo.setParams({"custId":component.get("v.RMA.ERP7__Account__c"),"recordId":component.get("v.RMA.ERP7__Address__c")});
            customerinfo.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    console.log('success fetchADdress ');
                    var obj = response.getReturnValue();
                    if(obj != null && obj != undefined && obj != ''){
                        component.set("v.CustomerAddress",obj);
                    }else component.set("v.CustomerAddress",{});
                    setTimeout(
                        $A.getCallback(function() {
                            if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                        }), 3000
                    );                    
                }else{
                    setTimeout(
                        $A.getCallback(function() {
                            if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                        }), 3000
                    ); 
                    var errors = response.getError();
                    console.log('fetchAddress error~>'+errors);
                    component.set("v.exceptionError",errors[0].message);
                    setTimeout(function(){
                        component.set("v.exceptionError", "");
                    }, 5000);
                }            
            });
            $A.enqueueAction(customerinfo);
        }else{
            console.log('fetchAddress not executed');
            component.set("v.CustomerAddress",{});
        }
    },
    
    doinit : function(component, event, helper){
        console.log('doinit called');
        component.reset = false;
        var initaction = component.get("c.doInit");
        initaction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.preventChanges",true);
                var obj = response.getReturnValue();
                component.set("v.RMAObjectLabel",obj.ObjectLabel);
                 if(obj.ObjectLabel != undefined && obj.ObjectLabel != null && obj.ObjectLabel != ''){
                    if(obj.ObjectLabel == 'Return goods Authorization (RGA)'){
                        component.set("v.RMAObjectLabel",'Return Goods Authorization (RGA)');
                    }
                }
                if(!$A.util.isEmpty(obj) && !$A.util.isUndefinedOrNull(obj)){ 
                    if(obj.isSOAccess && obj.isOrderAccess){
                        component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_disable_one_of_the_Field_level_access_Order_or_Sales_Order_in'));
                        return;
                    }
                    if(obj.isSOAccess == false && obj.isOrderAccess == false){
                        component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_EnableFieldLevelAccess'));
                        return;
                    }
                    component.set("v.isOrderAcc",obj.isOrderAccess);
                    component.set("v.isSOAccess",obj.isSOAccess);
                    console.log('Standard order Acess => '+obj.isOrderAccess+' AND Sales order Acess => '+obj.isSOAccess);
                    var FrieghtTypeList=[]; FrieghtTypeList=obj.FrieghtTypeList;
                    var FrieghtTypeListA=[];  
                    for(var i=0;i<FrieghtTypeList.length;i++){
                        FrieghtTypeListA.push({"class": "optionClass", label: FrieghtTypeList[i], value: FrieghtTypeList[i]});
                    }
                    component.set("v.FrieghtTypeList",FrieghtTypeListA);
                   
                    var StatusList=[]; StatusList=obj.StatusList;
                    var StatusListA=[];  
                    for(var i=0;i<StatusList.length;i++){
                        StatusListA.push({"class": "optionClass", label: StatusList[i], value: StatusList[i]});
                    }
                    component.set("v.StatusList",StatusListA);
                    try{   
                        if(!$A.util.isEmpty(obj.distributionchannel) && !$A.util.isUndefinedOrNull(obj.distributionchannel)){
                            if(!$A.util.isEmpty(obj.distributionchannel.Id) && !$A.util.isUndefinedOrNull(obj.distributionchannel.Id)){
                                component.set("v.DistributeChannel.Id",obj.distributionchannel.Id);
                                component.set("v.DistributeChannel.Name",obj.distributionchannel.Name);
                                if(!$A.util.isEmpty(obj.distributionchannel.ERP7__Channel__c) && !$A.util.isUndefinedOrNull(obj.distributionchannel.ERP7__Channel__c)) component.set("v.channelId",obj.distributionchannel.ERP7__Channel__c);
                            }else{
                                component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_verify_distribution_channel_and_receiving_site'));
                            }
                            if(!$A.util.isEmpty(obj.distributionchannel.ERP7__Site__c) && !$A.util.isUndefinedOrNull(obj.distributionchannel.ERP7__Site__c)){ 
                                component.set("v.site.Id",obj.distributionchannel.ERP7__Site__c);
                                component.set("v.site.Name",obj.distributionchannel.ERP7__Site__r.Name);  
                                if(!$A.util.isEmpty(obj.distributionchannel.ERP7__Site__r.ERP7__Address__c) && !$A.util.isUndefinedOrNull(obj.distributionchannel.ERP7__Site__r.ERP7__Address__c)){
                                    component.set("v.SiteAddressId",obj.distributionchannel.ERP7__Site__r.ERP7__Address__c);
                                    component.set("v.SiteAddress",obj.distributionchannel.ERP7__Site__r.ERP7__Address__r);
                                } 
                            }
                            component.set("v.qry",'WHERE ERP7__Channel__c =\''+obj.ChannelId+'\' AND ERP7__Active__c = true AND ERP7__Returns_Handling__c= true order by ERP7__Primary__c');
                        }else{
                            component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_verify_distribution_channel_and_receiving_site'));
                        }
                    }catch(ex){ 
                        console.log('RMA ex ERROR=>'+ex);
                        //helper.showToast("dismissible","Error!","error",'Please verify distribution channel and receiving site !');
                        component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_verify_distribution_channel_and_receiving_site'));
                    }     
                } 
                helper.fetchCRUD(component, event, helper); 
                if(!$A.util.isEmpty(component.get("v.RMAId")) && !$A.util.isUndefinedOrNull(component.get("v.RMAId"))){
                    helper.fetchRMADetails(component, event, helper, component.get("v.RMAId"));
                }
                setTimeout(function(){
                    component.set("v.preventChanges",false);
                }, 3000);
            }else{
                console.log('Error in donint:',response.getError());
                var errors = response.getError();
                component.set("v.exceptionError",errors[0].message);
                setTimeout(function(){
                    component.set("v.exceptionError", "");
                }, 5000);
            }
        });
        $A.enqueueAction(initaction);
        
    },
    
    showModal: function(component, event, helper){
        //console.log('showmodal solis here~>'+JSON.stringify(component.get("v.solis")));
        component.set("v.savehide",true);
        // if(component.get("v.RMA.ERP7__Invoice__c")!=undefined && component.get("v.RMA.ERP7__Invoice__c")!='' ){ 
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
        }else{
            if(component.get("v.RMA.ERP7__Invoice__c")!=undefined && component.get("v.RMA.ERP7__Invoice__c")!='' ){ 
                if(component.get("v.isSOAccess"))
                    helper.fetchSOsolisbyInv(component, event);     
                if(component.get("v.isOrderAcc"))
                    helper.fetchOrdsolisbyInv(component, event);
            }else if(component.get("v.RMA.ERP7__Account__c")!=undefined && component.get("v.RMA.ERP7__Account__c")!='' ){
                component.fetchCustomerInfo();
            }else{
                component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_select_a_Customer_or_an_Invoice'));
                setTimeout(function(){
                   component.set("v.exceptionError", "");
                }, 5000);
            }
        }
        
        component.set("v.RerenderPanel",false); 
        component.set("v.RerenderPanel",true); 
        
        var cmpTarget = component.find('showModal');
        $A.util.addClass(cmpTarget, 'slds-show');
        $A.util.removeClass (cmpTarget, 'slds-hide');
        
        /* }else{
            component.set("v.exceptionError",'Please select an Invoice');
            setTimeout(function(){
                component.set("v.exceptionError", "");
            }, 5000);
        }  */
    },
    
    hideModal: function(component, event, helper){
        component.set("v.RMALIsearchtext","");
        helper.hideModal(component, event);
    },
    
    doSearch: function(component, event, helper){
        var data = component.get("v.solis");  
        var allData = component.get("v.unfilteredsolis");  
        var searchKey = component.get("v.RMALIsearchtext");  
        if(data!=undefined || data.length>0){ 
            if(component.get('v.isSOAccess')){
                var filtereddata = allData.filter(word => (!searchKey) || word.SOLI.ERP7__Product__r.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.SOLI.ERP7__Sales_Order__r.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 );   
            }
            if(component.get('v.isOrderAcc')){
                var filtereddata = allData.filter(word => (!searchKey) || word.OrdItem.Product2.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.OrdItem.Order.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 );    
            }
        }  
        component.set("v.solis", filtereddata);  
        if(searchKey==''){  
            //component.set("v.solis",component.get("v.unfilteredsolis"));
            /*if(component.get('v.isSOAccess')){
                helper.SoliByCustomer(component, event);
            }
            if(component.get('v.isOrderAcc')){
                console.log('here called');
                helper.OrdItemByCustomer(component, event);
            } */
        }  
        /* var searchString = component.get("v.RMALIsearchtext");
        if(searchString.length>0){
            var solis = component.get("v.solis");
            if(component.get('v.isSOAccess')){
                solis = solis.filter(word => (!searchString) || word.SOLI.ERP7__Product__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) > -1 || word.SOLI.ERP7__Sales_Order__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) > -1 );  
               
            }
            if(component.get('v.isOrderAcc')){
                solis = solis.filter(word => (!searchString) || word.OrdItem.Product2.Name.toLowerCase().indexOf(searchString.toLowerCase()) > -1 || word.OrdItem.Order.Name.toLowerCase().indexOf(searchString.toLowerCase()) > -1 );  
                
            }
            
            component.set("v.solis",solis);          
        }else{
            if(component.get('v.isSOAccess')){
                helper.SoliByCustomer(component, event);
            }
            if(component.get('v.isOrderAcc')){
                helper.OrdItemByCustomer(component, event);
            }
            
        } */
    },
     
    AddRMALI: function(component, event, helper) {
        try{
            component.set("v.EditRMA",true);
            
            var obj =  []; obj =  component.get('v.solis');
            //var selectRMA = []; selectRMA = component.get("v.SelectRMALI");
            var newSelectedRMA = [];
            //var nonselectRMA = [];
            var bool = true;
            if(obj.length >0){ 
                for(var i=0;i<obj.length;i++){
                    if(obj[i].isSelect){
                        if(!$A.util.isEmpty(obj[i].returnQty) && !$A.util.isUndefinedOrNull(obj[i].returnQty)) {
                            if(obj[i].returnQty > 0 &&  obj[i].returnQty <= obj[i].RMALI.ERP7__Quantity_Return__c) {
                                bool = true;
                                //obj[i].RMALI.ERP7__Quantity_Return__c =  obj[i].returnQty; 
                            } else { bool = false; break; }
                        }else { bool = false; break; }
                        obj[i].isSelect = false;
                        //obj[i].RMALI.ERP7__Acceptance_Type__c = obj[i].accepType;
                        //obj[i].RMALI.ERP7__Return_Reason__c = obj[i].reasonReason;
                        //selectRMA.push(obj[i]);
                        newSelectedRMA.push(obj[i]);
                    }else{
                        console.log('isSelect is false');
                        //nonselectRMA.push(obj[i]);
                    }
                }
                console.log('bool is~>'+bool+' and newSelectedRMA size~>'+newSelectedRMA.length);
                if(newSelectedRMA.length>0 && bool){
                    //component.set('v.solis',nonselectRMA);
                    //component.set("v.unfilteredsolis",nonselectRMA);
                    component.set("v.SelectRMALI",newSelectedRMA);
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
                    helper.hideModal(component, event);
                }else if(bool == false){
                    helper.showToast("dismissible",$A.get('$Label.c.Error_UsersShiftMatch'),"error",$A.get('$Label.c.PH_RMA_Invalid_Return_Quantity')); 
                }else{
                    helper.showToast("dismissible",$A.get('$Label.c.Error_UsersShiftMatch'),"error",$A.get('$Label.c.PH_RMA_Please_select_a_Line_Item'));                 
                }
            }else{
                helper.showToast("dismissible",$A.get('$Label.c.Error_UsersShiftMatch'),"error",$A.get('$Label.c.PH_RMA_Please_select_a_Line_Item')); 
            }
        }catch(err){
            console.log('error '+err);
        }
    },
    
    focusTOscan : function (component, event,helper) {
        helper.focusTOscan(component, event);
    },
     
    showEditModal : function (component, event, helper) {
        var target = event.target;
        var rowIndex = target.getAttribute("data-row-index");
        console.log("Row No : " + rowIndex);
        component.set('v.EditIndex',rowIndex);
        component.set('v.errMsg','');
        var SoLIID = event.currentTarget.getAttribute('data-SoLIID');
        var recordId = event.currentTarget.getAttribute('data-recordId');
        
        
        
        component.set("v.savehide",true);
        var objArray = component.get("v.SelectRMALI");
        
        console.log('Current RMA Line to Edit accepType :',objArray[rowIndex].accepType);
        
   
        var obj ={};
        if(component.get('v.isSOAccess')){
            for(var j=0;j<objArray.length;j++){
                if(objArray[j].RMALI.ERP7__SOLI__c === SoLIID){
                    obj = objArray[j]; //.RMALI;
                    break;
                }       
            }
        }
        if(component.get('v.isOrderAcc')){
            for(var j=0;j<objArray.length;j++){
                if(objArray[j].RMALI.ERP7__Ord_Item__c === SoLIID){
                    obj = objArray[j]; //.RMALI;
                    break;
                }       
            }
        }
        
        console.log("Current Edit Object: " + JSON.stringify(obj));
        component.set("v.RMALI",obj);
        var taxPercentage = 0;
        if(!$A.util.isEmpty(component.get("v.RMALI.RMALI.ERP7__Tax__c")) && !$A.util.isUndefined(component.get("v.RMALI.RMALI.ERP7__Tax__c"))){
            if(component.get("v.RMALI.RMALI.ERP7__Tax__c")>0){
                if(!$A.util.isEmpty(component.get("v.RMALI.RMALI.ERP7__Sale_Price__c")) && !$A.util.isUndefined(component.get("v.RMALI.RMALI.ERP7__Sale_Price__c")) && !$A.util.isEmpty(component.get("v.RMALI.returnQty")) && !$A.util.isUndefined(component.get("v.RMALI.returnQty"))){
                    var totalAmount = component.get("v.RMALI.RMALI.ERP7__Sale_Price__c") * component.get("v.RMALI.returnQty");
                    var totalTax = component.get("v.RMALI.RMALI.ERP7__Tax__c") * component.get("v.RMALI.returnQty");
                    taxPercentage = (totalTax/totalAmount)*100;
                }
            }
        }
        component.set("v.EditTaxPer",taxPercentage);
        var cmpTarget = component.find('editModal');
        $A.util.addClass(cmpTarget, 'slds-show');
        $A.util.removeClass (cmpTarget, 'slds-hide');
        helper.fetchStatus(component, event, helper);
    },
    
    hideEditModal : function (component, event, helper) {
        var cmpTarget = component.find('editModal');
        $A.util.removeClass(cmpTarget, 'slds-show');
        $A.util.addClass (cmpTarget, 'slds-hide');
        component.set('v.errMsg','No Items Select');
    },
    
    handleSelectChange: function(component, event, helper) {
        
        var selectedValue = event.getSource().get("v.value");
        console.log('Selected Acceptance Type: ' + selectedValue);
        var RMALI = component.get("v.RMALI");
        RMALI.accepType = selectedValue;
        component.set("v.RMALI", RMALI);
        
    },
    
    saveRMALI : function (component, event, helper) {
        component.set("v.exceptionError","");
        var obj = component.get("v.RMALI");
        console.log('var obj = component.get("v.RMALI");',JSON.stringify(obj));
        var objArray = component.get("v.SelectRMALI");
        var flag = 0;
        var orgQty =0.00;
        for(var j=0;j<objArray.length;j++){
            if(component.get('v.isSOAccess')){
                if(objArray[j].RMALI.ERP7__SOLI__c === obj.RMALI.ERP7__SOLI__c){
                    //console.log('ars~>'+JSON.stringify(objArray[j]));
                    orgQty = objArray[j].SOLI.ERP7__Quantity__c - objArray[j].SOLI.ERP7__ReturnedQuantity__c;
                    if(orgQty === 0 || obj.returnQty <= orgQty && obj.returnQty  !='' && obj.returnQty != undefined){
                        var totalPrice = parseFloat((obj.returnQty * obj.RMALI.ERP7__Sale_Price__c)+ (obj.returnQty * obj.RMALI.ERP7__Tax__c));
                        obj.RMALI.ERP7__Total_Deduction__c = totalPrice;
                        flag = 1;
                    }
                    if(obj.returnQty == 0) flag = 0;
                    objArray[j].RMALI = obj.RMALI;
                    break;
                }   
            }
            if(component.get('v.isOrderAcc')){
                if(objArray[j].RMALI.ERP7__Ord_Item__c === obj.RMALI.ERP7__Ord_Item__c){
                    //console.log('ars~>'+JSON.stringify(objArray[j]));
                    if(objArray[j].OrdItem.Product2.ERP7__Serialise__c){
                        orgQty = objArray[j].RMALI.ERP7__Quantity_Return__c;
                    }else{
                        orgQty = objArray[j].OrdItem.Quantity - objArray[j].OrdItem.ERP7__ReturnedQuantity__c;
                    }
                    if(orgQty === 0 || obj.returnQty <= orgQty && obj.returnQty  !='' && obj.returnQty != undefined){
                        var totalPrice = parseFloat((obj.returnQty * obj.RMALI.ERP7__Sale_Price__c)+ (obj.returnQty * obj.RMALI.ERP7__Tax__c));
                        obj.RMALI.ERP7__Total_Deduction__c = totalPrice;
                        flag = 1;
                    }
                    if(obj.returnQty == 0) flag = 0;
                    console.log('obj.RMALI:',JSON.stringify(obj.RMALI));
                    objArray[j].RMALI = obj.RMALI;
                    break;
                }  
            }
            
        } 
        var currentIndex = component.get('v.EditIndex');
        objArray[currentIndex].accepType = obj.accepType;
        
        if(flag){
            console.log('flag is 1');
            component.set("v.SelectRMALI",objArray); 
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
            component.set("v.savehide",false);
            var cmpTarget = component.find('editModal');
            $A.util.removeClass(cmpTarget, 'slds-show');
            $A.util.addClass (cmpTarget, 'slds-hide');
        }else{
            console.log('flag is 0');
            if(obj.returnQty  !='' && obj.returnQty != undefined && obj.returnQty != null){
                console.log('invalid returnqty');
                component.set('v.exceptionError','Return Quantity > 0 and <='+orgQty);
            }
            else{
                console.log('null returnqty');
                component.set('v.exceptionError','Return Quantity > 0');
            }
            
        }            
    },
    
    deleteRMALI : function(component, event, helper){
        var recordId = event.currentTarget.getAttribute('data-recordId');
        var SoLIID =  event.currentTarget.getAttribute('data-SoLIID');
        var objArray = component.get("v.SelectRMALI");
        if(component.get('v.isSOAccess')){
            for(var j=0;j<objArray.length;j++){
                if(objArray[j].RMALI.ERP7__SOLI__c === SoLIID){
                    component.set("v.DelObj",objArray[j]);
                    $A.util.toggleClass(component.find("deleteModal"),"slds-hide");
                    break;
                }       
            }
        }
        if(component.get('v.isOrderAcc')){
            for(var j=0;j<objArray.length;j++){
                if(objArray[j].RMALI.ERP7__Ord_Item__c === SoLIID){
                    component.set("v.DelObj",objArray[j]);
                    $A.util.toggleClass(component.find("deleteModal"),"slds-hide");
                    break;
                }       
            }
        }
    },
    
    DeleteRecordById :  function(component, event, helper){
        var del_obj  = component.get("v.DelObj");
        var objArray = component.get("v.SelectRMALI");
        //console.log('del_obj~>'+JSON.stringify(del_obj));
        for(var j=0;j<objArray.length;j++){
            if(component.get('v.isSOAccess')){
                if(objArray[j].RMALI.ERP7__SOLI__c === del_obj.RMALI.ERP7__SOLI__c){
                    objArray.splice(j,1)
                    $A.util.toggleClass(component.find("deleteModal"),"slds-hide");
                    break;
                } 
            }
            if(component.get('v.isOrderAcc')){
                if(objArray[j].RMALI.ERP7__Ord_Item__c === del_obj.RMALI.ERP7__Ord_Item__c){
                    objArray.splice(j,1)
                    $A.util.toggleClass(component.find("deleteModal"),"slds-hide");
                    break;
                }  
            }
        }
        component.set("v.SelectRMALI",objArray);
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
        if(del_obj.RMALI.Id != null){
            var delAction = component.get("c.DeleteByRMALIId");
            delAction.setParams({"recordData":JSON.stringify(del_obj.RMALI)});
            delAction.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                }else{
                    var errors = response.getError();
                    component.set("v.exceptionError",errors[0].message);
                    setTimeout(function(){
                        component.set("v.exceptionError", "");
                    }, 5000);
                }
            });
            $A.enqueueAction(delAction); 
        }
    },
    
    hideDeletePopup :function(component, event, helper){ 
        $A.util.toggleClass(component.find("deleteModal"),"slds-hide");
    },
    
    closeError : function(component, event, helper) {
        component.set("v.exceptionError","");
    },
    
    commitRMA : function(component, event, helper){ 
        console.log('commitRMA called');
        if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");  
        let button = event.getSource();
        button.set('v.disabled',true);
        
        var obj=[]; 
        obj=component.get("v.SelectRMALI");
        console.log('selectRMALI JSON in commitRMA~>'+JSON.stringify(obj));
        var selectedcount = 0 ;
        var bool = true;
        console.log('RMA JSON in commitRMA~>'+JSON.stringify(component.get("v.RMA")));
        console.log('Distrubutionchannel in commitRMA~>'+JSON.stringify(component.get("v.DistributeChannel")));
        console.log('site in commitRMA~>'+JSON.stringify(component.get("v.site")));
        if($A.util.isEmpty(component.get("v.DistributeChannel.Id")) || $A.util.isUndefinedOrNull(component.get("v.DistributeChannel.Id"))){
            bool = false;
            component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_Select_Distrubution_Channel'));
            setTimeout(function(){
                component.set("v.exceptionError", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.site.Id")) || $A.util.isUndefinedOrNull(component.get("v.site.Id"))){
            bool = false;
            component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_Select_Recieving_Site'));
            setTimeout(function(){
                component.set("v.exceptionError", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.RMA.ERP7__Account__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Account__c"))){
            bool = false;
            component.set("v.exceptionError",$A.get('$Label.c.PH_CredNotes_Please_select_the_Customer'));
            //setTimeout(function(){
                //component.set("v.exceptionError", "");
            //}, 5000);
        }else if($A.util.isEmpty(component.get("v.RMA.ERP7__Return_Contact__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Return_Contact__c"))){
            bool = false;
            component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_Select_a_Contact'));
            setTimeout(function(){
                component.set("v.exceptionError", "");
            }, 5000);
        }/*else if($A.util.isEmpty(component.get("v.RMA.ERP7__Invoice__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Invoice__c"))){
            bool = false;
            component.set("v.exceptionError",'Please Select an Invoice');
            setTimeout(function(){
                component.set("v.exceptionError", "");
            }, 5000);
        }*/
        
        /*if(bool){
            if(component.get('v.isSOAccess')){
                if($A.util.isEmpty(component.get("v.RMA.ERP7__SO__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__SO__c"))){
                    bool = false;
                    component.set("v.exceptionError",'Please Select an Order');
                    setTimeout(function(){
                        component.set("v.exceptionError", "");
                    }, 5000);
                }
            }
            if(component.get('v.isOrderAcc')){
                if($A.util.isEmpty(component.get("v.RMA.ERP7__Order__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Order__c"))){
                    bool = false;
                    component.set("v.exceptionError",'Please Select an Order');
                    setTimeout(function(){
                        component.set("v.exceptionError", "");
                    }, 5000);
                }
            }
        }*/
        
        if(bool){
            if(obj.length >0){ 
                var QTYbool = true;
                console.log('in bool true');
                for(var i=0;i<obj.length;i++){
                    if(obj[i].RMALI.Id !=null) obj[i].isfinalSelect = true;
                    if(obj[i].isfinalSelect){
                        if($A.util.isEmpty(obj[i].returnQty) || $A.util.isUndefinedOrNull(obj[i].returnQty)){
                            QTYbool = false;
                            break;
                        }else if(obj[i].returnQty <= 0){
                            QTYbool = false;
                            break;
                        }
                        selectedcount+=1; 
                        obj[i].RMALI.ERP7__Quantity_Return__c =  obj[i].returnQty; 
                        obj[i].RMALI.ERP7__Acceptance_Type__c = obj[i].accepType;
                        obj[i].RMALI.ERP7__Return_Reason__c = obj[i].reasonReason;
                        delete obj[i].returnQty;
                        delete obj[i].accepType;
                        delete obj[i].reasonReason;
                    } 
                }
                console.log('commitRMA selectedcount~>'+selectedcount);
                if(selectedcount>0 && QTYbool){
                    var saveaction = component.get("c.createRMA");                
                    var objRMA = component.get("v.RMA");
                    var objRMAs = JSON.stringify(objRMA);
                    
                    if(component.get("v.RMA_lookup.Id") != ''){
                        objRMA['Name'] = component.get("v.RMA_lookup")['Name'];
                    }else{
                        objRMA['Id'] = null;      
                    }                  
                    objRMA["ERP7__Distribution_Channel__c"] = component.get("v.DistributeChannel.Id");
                    objRMA["ERP7__Site__c"] = component.get("v.site.Id");                                   
                    objRMA["ERP7__Channel__c"] = component.get("v.channelId"); 
                    objRMA["ERP7__Return_Contact__c"] = component.get("v.RMA.ERP7__Return_Contact__c");
                    console.log('Exp Date~>'+objRMA["ERP7__Expected_Date__c"]);
                     console.log('type of Exp Date~>'+ typeof objRMA["ERP7__Expected_Date__c"]);
                    if($A.util.isEmpty(objRMA["ERP7__Expected_Date__c"]) || $A.util.isUndefinedOrNull(objRMA["ERP7__Expected_Date__c"])){
                        objRMA["ERP7__Expected_Date__c"]=null; 
                    }
                    //objRMA["ERP7__Return_Contact__c"] = component.get("v.CustContact.Id"); //CustomerContact  {!v.RMA.ERP7__Return_Contact__c} 
                    saveaction.setParams({
                        "RMAobj":JSON.stringify(objRMA),
                        "RMALIs":JSON.stringify(obj),
                        "isSalesOrder":component.get("v.isSOAccess"),
                        "isOrder":component.get("v.isOrderAcc")
                    }); 
                    console.log('commitRMA b4 callback');
                    saveaction.setCallback(this,function(response){
                        if(response.getState() === 'SUCCESS'){
                            var res = response.getReturnValue();
                            console.log('commitRMA success ~>');
                            var newobj = [];
                            var RMALIlist = res.RAMLI_List;
                            for(var i=0;i<RMALIlist.length;i++){
                                if(!$A.util.isEmpty(RMALIlist[i].RMALI) && !$A.util.isUndefinedOrNull(RMALIlist[i].RMALI)){
                                    //console.log('json RMALIlist[i]~>'+JSON.stringify(RMALIlist[i]));
                                    RMALIlist[i].returnQty = RMALIlist[i].RMALI.ERP7__Quantity_Return__c;
                                    RMALIlist[i].accepType = RMALIlist[i].RMALI.ERP7__Acceptance_Type__c;
                                    RMALIlist[i].reasonReason = RMALIlist[i].RMALI.ERP7__Return_Reason__c;
                                    newobj.push(RMALIlist[i]);
                                }
                            }
                            console.log('commitRMA here1');
                            component.set("v.SelectRMALI",newobj);
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
                            //component.set("v.SelectRMALI",response.getReturnValue().RAMLI_List); 
                            var rma = response.getReturnValue().sObj;
                            component.set("v.RMA",response.getReturnValue().sObj);
                            if(component.get("v.RMA.ERP7__Authorize__c") || component.get("v.RMA.ERP7__Is_Closed__c")){
                                component.set("v.disaAddbutton",true);
                                component.set("v.disaeditdelete",true);
                            }else { component.set("v.disaAddbutton",false); component.set("v.disaeditdelete",false); }
                            component.set("v.RMAId",response.getReturnValue().sObj.Id);
                            
                            console.log('commitRMA here2');
                            
                            var toastEvent = $A.get("e.force:showToast");
                            if(toastEvent != undefined){
                                toastEvent.setParams({
                                    "mode":"dismissible",
                                    "type": "success",
                                    "message": (objRMA['Id'] != null)? rma["Name"]+' was updated.':rma["Name"]+' was created.'
                                });
                                toastEvent.fire();
                            }
                            console.log('commitRMA here3');
                            if(component.get("v.navigateToRecord")){
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "isredirect": true,
                                    "recordId": rma.Id,
                                    "slideDevName": "detail"
                                }); 
                                if(navEvt != undefined) navEvt.fire();
                            }else{ 
                                component.set("v.RMA_lookup.Name",rma.Name);  
                                component.set("v.RMA_lookup.Id",rma.Id);   
                            }
                            setTimeout(
                                $A.getCallback(function() {
                                    if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                                }), 3000
                            ); 
                            button.set('v.disabled',false);
                        }else{
                            if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            button.set('v.disabled',false);
                            var errors = response.getError();
                            component.set("v.exceptionError",errors[0].message);
                            setTimeout(function(){
                                component.set("v.exceptionError", "");
                            }, 5000);
                        }
                        
                    });
                    $A.enqueueAction(saveaction); 
                }else{
                    if(selectedcount<=0){
                        component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_select_a_Line_Item'));
                    }else if(QTYbool == false){
                        component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Return_Quantity_of_Line_Item_should_be_greater_than_0'));
                    }
                    setTimeout(function(){
                        component.set("v.exceptionError", "");
                    }, 5000);
                    if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                    button.set('v.disabled',false);
                }
            }else{
                component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_select_a_Line_Item'));
                setTimeout(function(){
                   component.set("v.exceptionError", "");
                }, 5000);
                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                button.set('v.disabled',false);
            }
        }else{
            console.log('bool is false');
            if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
            button.set('v.disabled',false);
        }        
        
    },
    
    cancelRMA : function(component, event, helper){
        var  objArray = [];
        //component.set("v.SelectRMALI",objArray);
        if(Boolean(component.get("v.showbackBtn"))){
            var so = component.get("v.RMA.ERP7__SO__c");
            var navEvt = $A.get("e.force:navigateToSObject");
            if(navEvt!=undefined && so!=undefined){
                navEvt.setParams({
                    "isredirect": true,
                    "recordId": so,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }else if(so!=undefined){
                window.open('/'+so,'_blank');
            } 
        }else{           
            location.reload();
        }        
    },
    
    /* fetchContact : function(component, event, helper){
        console.log('fetchContact called');
        if(component.get("v.RMA.ERP7__Account__c") != null || component.get("v.RMA.ERP7__Account__c") != undefined || component.get("v.CustContact.Id") != null || component.get("v.CustContact.Id") != undefined){
            if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");
            var customerinfo = component.get("c.FetchContactById");      
            customerinfo.setParams({"custId":component.get("v.RMA.ERP7__Account__c"),"recordId":component.get("v.CustContact.Id")});
            customerinfo.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    var obj = response.getReturnValue();
                    if(obj != null || obj != undefined){
                        component.set("v.CustomerContact",obj);
                    }else component.set("v.CustomerContact",{});
                    setTimeout(
                        $A.getCallback(function() {
                            if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                        }), 3000
                    );  
                }else{
                    setTimeout(
                        $A.getCallback(function() {
                            if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                        }), 3000
                    );  
                    var errors = response.getError();
                    component.set("v.exceptionError",errors[0].message);
                    setTimeout(function(){
                        component.set("v.exceptionError", "");
                    }, 5000);
                }            
            });
            $A.enqueueAction(customerinfo);
        }else{
            console.log('fetchContact not executed');
            component.set("v.CustomerContact",{});
        }
    }, */
    
    fetchSiteAddress : function(component, event, helper){
        if(component.get("v.preventChanges") == false){
            console.log('fetchSiteAddress called');
            if(!$A.util.isEmpty(component.get("v.SiteAddressId")) && !$A.util.isUndefinedOrNull(component.get("v.SiteAddressId"))){
                if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");
                var siteAddressAction = component.get("c.FetchAddressById");
                siteAddressAction.setParams({"custId":'',"recordId":component.get("v.SiteAddressId")});
                siteAddressAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        var obj = response.getReturnValue();
                        if(obj != null || obj != undefined) component.set("v.SiteAddress",obj);
                        else component.set("v.SiteAddress",{});
                        component.set("v.RerenderPanel",false); 
                        component.set("v.RerenderPanel",true);     
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        );
                    }else{
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        );
                        var errors = response.getError();
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(function(){
                            component.set("v.exceptionError", "");
                        }, 5000);
                        component.set("v.RerenderPanel",false); component.set("v.RerenderPanel",true); 
                    }
                    
                });
                $A.enqueueAction(siteAddressAction);
            }else{ 
                console.log('fetchSiteAddress siteaddressId empty');
                component.set("v.SiteAddress",{}); 
                component.set("v.RerenderPanel",false); 
                component.set("v.RerenderPanel",true); 
            }
        }
    },
    
    QtyCheck : function(component, event, helper){
        component.set("v.exceptionError","");
        var obj = component.get("v.RMALI");
        if(obj.returnQty >0){
            var totalPrice = 0;
            if(obj.RMALI.ERP7__Sale_Price__c > 0) totalPrice = parseFloat((obj.returnQty * obj.RMALI.ERP7__Sale_Price__c)+ (obj.returnQty * obj.RMALI.ERP7__Tax__c));
            obj.RMALI.ERP7__Total_Deduction__c = totalPrice;
            component.set("v.RMALI",obj);
        }else{
            obj.RMALI.ERP7__Total_Deduction__c = 0;
            component.set("v.RMALI",obj);
        }
        
        var taxPercentage = 0;
        if(!$A.util.isEmpty(component.get("v.RMALI.RMALI.ERP7__Tax__c")) && !$A.util.isUndefined(component.get("v.RMALI.RMALI.ERP7__Tax__c"))){
            if(component.get("v.RMALI.RMALI.ERP7__Tax__c")>0){
                if(!$A.util.isEmpty(component.get("v.RMALI.RMALI.ERP7__Sale_Price__c")) && !$A.util.isUndefined(component.get("v.RMALI.RMALI.ERP7__Sale_Price__c")) && !$A.util.isEmpty(component.get("v.RMALI.returnQty")) && !$A.util.isUndefined(component.get("v.RMALI.returnQty"))){
                    var totalAmount = component.get("v.RMALI.RMALI.ERP7__Sale_Price__c") * component.get("v.RMALI.returnQty");
                    var totalTax = component.get("v.RMALI.RMALI.ERP7__Tax__c") * component.get("v.RMALI.returnQty");
                    taxPercentage = (totalTax/totalAmount)*100;
                }
            }
        }
        component.set("v.EditTaxPer",taxPercentage);
    },
    
    EditRMA:function(component, event, helper){
        component.set("v.EditRMA",true);
    },
    
    fetchSiteDetails : function (component, event, helper) {
        if(component.get("v.preventChanges") == false){
            console.log('fetchSiteDetails called');
            if(!$A.util.isEmpty(component.get("v.site.Id")) && !$A.util.isUndefinedOrNull(component.get("v.site.Id"))){
                if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");
                var siteDetailsAction = component.get("c.getSiteDetails");
                siteDetailsAction.setParams({"recordId":component.get("v.site.Id")});
                siteDetailsAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        console.log('fetchSiteDetails success');
                        if(response.getReturnValue()) component.set("v.SiteAddressId",response.getReturnValue());
                        else{ component.set("v.SiteAddressId",'');  }
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        );
                    }else{
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        );
                        component.set("v.SiteAddress",{});
                        var errors = response.getError();
                        console.log('fetchSiteDetails error~>'+errors);
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(function(){
                            component.set("v.exceptionError", "");
                        }, 5000);
                    }
                });        
                $A.enqueueAction(siteDetailsAction);
            }else{
                console.log('fetchSiteDetails site.id empty');
                component.set("v.SiteAddressId",'');  
                component.set("v.SiteAddress",{});
            }
        }
    },
    
    fetchSiteDetailsByDC : function (component, event, helper) {
        if(component.get("v.preventChanges") == false){
            console.log('fetchSiteDetailsByDC called');
            if(!$A.util.isEmpty(component.get("v.DistributeChannel.Id")) && !$A.util.isUndefinedOrNull(component.get("v.DistributeChannel.Id"))){
                if(component.find('spinner')!=undefined) $A.util.removeClass(component.find('spinner'), "slds-hide");
                var siteDetailsActionDC = component.get("c.getSiteDetailsbyDC");
                siteDetailsActionDC.setParams({"recordId":component.get("v.DistributeChannel.Id")});
                siteDetailsActionDC.setCallback(this,function(response){
                    if(response.getState() ==='SUCCESS'){
                        console.log('fetchSiteDetailsByDC success');
                        if(response.getReturnValue()){
                            if(!$A.util.isEmpty(response.getReturnValue()) && !$A.util.isEmpty(response.getReturnValue().ERP7__Site__c) ){
                                component.set("v.site.Id",response.getReturnValue().ERP7__Site__c);
                                component.set("v.site.Name",response.getReturnValue().ERP7__Site__r.Name);
                            }
                        }else{
                            component.set("v.site.Id",null);
                            component.set("v.site.Name",null); 
                        }
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        );
                    }else{
                        setTimeout(
                            $A.getCallback(function() {
                                if(component.find('spinner')!=undefined) $A.util.addClass(component.find('spinner'), "slds-hide"); 
                            }), 3000
                        );
                        var errors = response.getError();
                        console.log('fetchSiteDetailsByDC error~>'+errors);
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(function(){
                            component.set("v.exceptionError", "");
                        }, 5000);
                    }
                });        
                $A.enqueueAction(siteDetailsActionDC);
            }else{
                console.log('fetchSiteDetailsByDC distributionchannel.Id empty');
                component.set("v.site.Id",null);
                component.set("v.site.Name",null); 
            }
        }
    },
    
    CreatePO : function(component, event, helper){  
        var rmaId = event.currentTarget.getAttribute('data-recordId');
        $A.createComponent("c:CreatePurchaseOrder",{
            "rmaliID":rmaId,
            "cancelclick":component.getReference("c.backTO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);
            }
        });       
    },
    
    backTO : function(component,event,helper){
        console.log('RMALOOKup Id~>'+component.get("v.RMA_lookup.Id"));
        $A.createComponent("c:RMA",{
            "RMA_lookup.Id" :component.get("v.RMA_lookup.Id")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                let rmaID  = component.get("v.RMA_lookup.Id");
                let name = component.get("v.RMA_lookup.Name");
                //newCmp.set("v.RMA_lookup.Id",rmaID);
                //newCmp.set("v.RMA_lookup.Name",name);
                var body = component.find("sldshide");
                body.set("v.body", newCmp);
            }
        }); 
    },
    
    CreateWO : function(component, event, helper){
        var rmaId = event.currentTarget.getAttribute('data-rmarecordId');
        var URL_RMA = '/apex/ERP7__WorkOrderLC?rmarecordId='+rmaId;
        window.open(URL_RMA,'_blank');
    },
    
    createPackageRMA : function(component, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:RMAPackage",
            componentAttributes: {
                ReturnMAID: component.get("v.RMA.Id"),
                //frieghtType : component.get("v.RMA.ERP7__Frieght_Type__c"),
                refundAmt : component.get("v.RMA.ERP7__Refund_Amount__c"),
                isSOAccess : component.get("v.isSOAccess"),
                isOrderAcc : component.get("v.isOrderAcc"),
                isFromRMADetail : false,
            }
        });
        evt.fire();
        /*$A.createComponent(
            "c:RMAPackage", {
                "ReturnMAID": component.get("v.RMA.Id"),
                "frieghtType" : component.get("v.RMA.ERP7__Frieght_Type__c"),
                "refundAmt" : component.get("v.RMA.ERP7__Refund_Amount__c"),
                "isSOAccess": component.get("v.isSOAccess"),
                "isOrderAcc": component.get("v.isOrderAcc"),
            },
            function(newCmp) {
                if (component.isValid()) {
                    var body = component.find("sldshide");
                    body.set("v.body", newCmp);
                    
                }
            }
        );*/
    },
    
    handlemenu : function(component, event, helper){
        var operation = event.detail.menuItem.get("v.title");
        if(operation == "PO"){
            helper.CreatePO(component,event,helper,event.detail.menuItem.get("v.value"));   
        } else if(operation == "WO"){
            helper.CreateWO(component,event,helper,event.detail.menuItem.get("v.value"));
        }else{
        }
    },
    
    showDocval: function(component, event, helper){
        console.log('showDocval called and contact~>'+component.get("v.RMA.ERP7__Return_Contact__c"));
        if($A.util.isEmpty(component.get("v.RMA.ERP7__Return_Contact__c")) || $A.util.isUndefinedOrNull(component.get("v.RMA.ERP7__Return_Contact__c"))){
            component.set("v.exceptionError",$A.get('$Label.c.PH_RMA_Please_select_a_Contact_and_save'));
            setTimeout(function(){
                component.set("v.exceptionError", "");
            }, 5000);
        }
    },
    
    calculateRestockfee : function(component, event, helper){
        var restockfee = 0;
        if(!$A.util.isEmpty(component.get("v.totalamtWOtax")) && !$A.util.isUndefined(component.get("v.totalamtWOtax"))){
            if(component.get("v.totalamtWOtax") > 0){
                var totalamt = component.get("v.totalamtWOtax");
                if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_percentage__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_percentage__c"))){
                    var restockper = component.get("v.RMA.ERP7__Restock_percentage__c");
                    console.log('totalamt~>'+totalamt);
                    console.log('restockper~>'+restockper);
                    restockfee = (totalamt/100) * restockper;
                    console.log('calculated restockfee~>'+restockfee);
                }
            }
        }
        component.set("v.RMA.ERP7__Restock_Fee__c",restockfee);
        
        var totalamountli;
        if(!$A.util.isEmpty(component.get("v.totalamtli")) && !$A.util.isUndefined(component.get("v.totalamtli"))){
            totalamountli = component.get("v.totalamtli");
        }else totalamountli = 0;
        
        var Restockfees;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            Restockfees = component.get("v.RMA.ERP7__Restock_Fee__c");
        }else Restockfees = 0;
        
        var RestockTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            RestockTaxamount = component.get("v.RMA.ERP7__ReStock_Tax__c");
        }else RestockTaxamount = 0;
        
        var Shippingamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            Shippingamount = component.get("v.RMA.ERP7__Shipping_Amount__c");
        }else Shippingamount = 0;
        
        var ShippingTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
            ShippingTaxamount = component.get("v.RMA.ERP7__Shipping_Tax__c");
        }else ShippingTaxamount = 0;
        
        var MainTotalAmount = 0;
        if(component.get("v.totalamtli") > 0){
            MainTotalAmount = parseFloat(totalamountli)+parseFloat(Restockfees)+parseFloat(RestockTaxamount)+parseFloat(Shippingamount)+parseFloat(ShippingTaxamount);
        }
        
        component.set("v.totalamt",parseFloat(MainTotalAmount));
        
    },
    
    calculateRestockper : function(component, event, helper){
        var totalamountli;
        if(!$A.util.isEmpty(component.get("v.totalamtli")) && !$A.util.isUndefined(component.get("v.totalamtli"))){
            totalamountli = component.get("v.totalamtli");
        }else totalamountli = 0;
        
        var Restockfees;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            Restockfees = component.get("v.RMA.ERP7__Restock_Fee__c");
        }else Restockfees = 0;
        
        var RestockTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            RestockTaxamount = component.get("v.RMA.ERP7__ReStock_Tax__c");
        }else RestockTaxamount = 0;
        
        var Shippingamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            Shippingamount = component.get("v.RMA.ERP7__Shipping_Amount__c");
        }else Shippingamount = 0;
        
        var ShippingTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
            ShippingTaxamount = component.get("v.RMA.ERP7__Shipping_Tax__c");
        }else ShippingTaxamount = 0;
        
        var MainTotalAmount = 0;
        if(component.get("v.totalamtli") > 0){
            MainTotalAmount = parseFloat(totalamountli)+parseFloat(Restockfees)+parseFloat(RestockTaxamount)+parseFloat(Shippingamount)+parseFloat(ShippingTaxamount);
        }
        
        component.set("v.totalamt",parseFloat(MainTotalAmount));
        
        var restockper = 0;
        if(!$A.util.isEmpty(component.get("v.totalamtWOtax")) && !$A.util.isUndefined(component.get("v.totalamtWOtax"))){
            if(component.get("v.totalamtWOtax") > 0){
                var totalamt = component.get("v.totalamtWOtax");
                if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
                    var restockfee = component.get("v.RMA.ERP7__Restock_Fee__c");
                    restockper = (restockfee/totalamt) * 100;
                }
            }
        }
        component.set("v.RMA.ERP7__Restock_percentage__c",restockper);
    },
    
    restockhandler : function(component, event, helper){
        var fee = 0;
        var per = 0;
        if($A.util.isEmpty(component.get("v.RMA.ERP7__Restock_percentage__c")) || $A.util.isUndefined(component.get("v.RMA.ERP7__Restock_percentage__c"))){
            component.set("v.RMA.ERP7__Restock_percentage__c",per);
        }
        if($A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) || $A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            component.set("v.RMA.ERP7__Restock_Fee__c",fee);
        }
        if(!$A.util.isEmpty(component.get("v.totalamtWOtax")) && !$A.util.isUndefined(component.get("v.totalamtWOtax"))){
            if(component.get("v.totalamtWOtax") > 0){
                var totalamt = component.get("v.totalamtWOtax");
                if(component.get("v.RMA.ERP7__Restock_percentage__c") > 0){
                    var restockper = component.get("v.RMA.ERP7__Restock_percentage__c");
                    fee = (totalamt/100) * restockper;
                    component.set("v.RMA.ERP7__Restock_Fee__c",fee);
                }else if(component.get("v.RMA.ERP7__Restock_Fee__c") > 0){
                    var restockfee = component.get("v.RMA.ERP7__Restock_Fee__c");
                    per = (restockfee/totalamt) * 100;
                    component.set("v.RMA.ERP7__Restock_percentage__c",per);
                }else{
                    component.set("v.RMA.ERP7__Restock_Fee__c",fee);
                    component.set("v.RMA.ERP7__Restock_percentage__c",per);
                }
            }else{
                component.set("v.RMA.ERP7__Restock_Fee__c",fee);
                component.set("v.RMA.ERP7__Restock_percentage__c",per);
            }
        }else{
            component.set("v.RMA.ERP7__Restock_Fee__c",fee);
            component.set("v.RMA.ERP7__Restock_percentage__c",per);
        }
        
        var totalamountli;
        if(!$A.util.isEmpty(component.get("v.totalamtli")) && !$A.util.isUndefined(component.get("v.totalamtli"))){
            totalamountli = component.get("v.totalamtli");
        }else totalamountli = 0;
        
        var Restockfees;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            Restockfees = component.get("v.RMA.ERP7__Restock_Fee__c");
        }else Restockfees = 0;
        
        var RestockTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            RestockTaxamount = component.get("v.RMA.ERP7__ReStock_Tax__c");
        }else RestockTaxamount = 0;
        
        var Shippingamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            Shippingamount = component.get("v.RMA.ERP7__Shipping_Amount__c");
        }else Shippingamount = 0;
        
        var ShippingTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
            ShippingTaxamount = component.get("v.RMA.ERP7__Shipping_Tax__c");
        }else ShippingTaxamount = 0;
        
        var MainTotalAmount = 0;
        if(component.get("v.totalamtli") > 0){
            MainTotalAmount = parseFloat(totalamountli)+parseFloat(Restockfees)+parseFloat(RestockTaxamount)+parseFloat(Shippingamount)+parseFloat(ShippingTaxamount);
        }
        
        component.set("v.totalamt",parseFloat(MainTotalAmount));
        
    },
    
    calculateRestockTax : function(component, event, helper){
        var restockfee = 0;
        if(!$A.util.isEmpty(component.get("v.refundTaxPer")) && !$A.util.isUndefined(component.get("v.refundTaxPer"))){
            if(component.get("v.refundTaxPer") > 0){
                var totalamt = component.get("v.refundTaxPer");
                if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
                    var restockper = component.get("v.RMA.ERP7__Restock_Fee__c");
                    restockfee = (restockper/100) * totalamt;
                }
            }
        }
        component.set("v.RMA.ERP7__ReStock_Tax__c",restockfee);
        
        var totalamountli;
        if(!$A.util.isEmpty(component.get("v.totalamtli")) && !$A.util.isUndefined(component.get("v.totalamtli"))){
            totalamountli = component.get("v.totalamtli");
        }else totalamountli = 0;
        
        var Restockfees;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            Restockfees = component.get("v.RMA.ERP7__Restock_Fee__c");
        }else Restockfees = 0;
        
        var RestockTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            RestockTaxamount = component.get("v.RMA.ERP7__ReStock_Tax__c");
        }else RestockTaxamount = 0;
        
        var Shippingamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            Shippingamount = component.get("v.RMA.ERP7__Shipping_Amount__c");
        }else Shippingamount = 0;
        
        var ShippingTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
            ShippingTaxamount = component.get("v.RMA.ERP7__Shipping_Tax__c");
        }else ShippingTaxamount = 0;
        
        var MainTotalAmount = 0;
        if(component.get("v.totalamtli") > 0){
            MainTotalAmount = parseFloat(totalamountli)+parseFloat(Restockfees)+parseFloat(RestockTaxamount)+parseFloat(Shippingamount)+parseFloat(ShippingTaxamount);
        }
        
        component.set("v.totalamt",parseFloat(MainTotalAmount));
    },
    
    calculateRestockTaxPercentage : function(component, event, helper){
        var totalamountli;
        if(!$A.util.isEmpty(component.get("v.totalamtli")) && !$A.util.isUndefined(component.get("v.totalamtli"))){
            totalamountli = component.get("v.totalamtli");
        }else totalamountli = 0;
        
        var Restockfees;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            Restockfees = component.get("v.RMA.ERP7__Restock_Fee__c");
        }else Restockfees = 0;
        
        var RestockTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            RestockTaxamount = component.get("v.RMA.ERP7__ReStock_Tax__c");
        }else RestockTaxamount = 0;
        
        var Shippingamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            Shippingamount = component.get("v.RMA.ERP7__Shipping_Amount__c");
        }else Shippingamount = 0;
        
        var ShippingTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
            ShippingTaxamount = component.get("v.RMA.ERP7__Shipping_Tax__c");
        }else ShippingTaxamount = 0;
        
        var MainTotalAmount = 0;
        if(component.get("v.totalamtli") > 0){
            MainTotalAmount = parseFloat(totalamountli)+parseFloat(Restockfees)+parseFloat(RestockTaxamount)+parseFloat(Shippingamount)+parseFloat(ShippingTaxamount);
        }
        
        component.set("v.totalamt",parseFloat(MainTotalAmount));
        
        var restockfee = 0;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            if(component.get("v.RMA.ERP7__ReStock_Tax__c") > 0){
                var totalamt = component.get("v.RMA.ERP7__ReStock_Tax__c");
                if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
                    var restockper = component.get("v.RMA.ERP7__Restock_Fee__c");
                    if(restockper > 0){
                        restockfee = (totalamt/restockper)*100;
                    }
                }
            }
        }
        component.set("v.refundTaxPer",restockfee);
    },
    
    calculateShippingTax : function(component, event, helper){
        var restockfee = 0;
        if(!$A.util.isEmpty(component.get("v.shippingTaxPer")) && !$A.util.isUndefined(component.get("v.shippingTaxPer"))){
            if(component.get("v.shippingTaxPer") > 0){
                var totalamt = component.get("v.shippingTaxPer");
                if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
                    var restockper = component.get("v.RMA.ERP7__Shipping_Amount__c");
                    restockfee = (restockper/100) * totalamt;
                }
            }
        }
        component.set("v.RMA.ERP7__Shipping_Tax__c",restockfee);
        
        var totalamountli;
        if(!$A.util.isEmpty(component.get("v.totalamtli")) && !$A.util.isUndefined(component.get("v.totalamtli"))){
            totalamountli = component.get("v.totalamtli");
        }else totalamountli = 0;
        
        var Restockfees;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            Restockfees = component.get("v.RMA.ERP7__Restock_Fee__c");
        }else Restockfees = 0;
        
        var RestockTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            RestockTaxamount = component.get("v.RMA.ERP7__ReStock_Tax__c");
        }else RestockTaxamount = 0;
        
        var Shippingamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            Shippingamount = component.get("v.RMA.ERP7__Shipping_Amount__c");
        }else Shippingamount = 0;
        
        var ShippingTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
            ShippingTaxamount = component.get("v.RMA.ERP7__Shipping_Tax__c");
        }else ShippingTaxamount = 0;
        
        var MainTotalAmount = 0;
        if(component.get("v.totalamtli") > 0){
            MainTotalAmount = parseFloat(totalamountli)+parseFloat(Restockfees)+parseFloat(RestockTaxamount)+parseFloat(Shippingamount)+parseFloat(ShippingTaxamount);
        }
        
        component.set("v.totalamt",parseFloat(MainTotalAmount));
        
    },
    
    calculateShippingTaxPercentage : function(component, event, helper){
        var totalamountli;
        if(!$A.util.isEmpty(component.get("v.totalamtli")) && !$A.util.isUndefined(component.get("v.totalamtli"))){
            totalamountli = component.get("v.totalamtli");
        }else totalamountli = 0;
        
        var Restockfees;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            Restockfees = component.get("v.RMA.ERP7__Restock_Fee__c");
        }else Restockfees = 0;
        
        var RestockTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            RestockTaxamount = component.get("v.RMA.ERP7__ReStock_Tax__c");
        }else RestockTaxamount = 0;
        
        var Shippingamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            Shippingamount = component.get("v.RMA.ERP7__Shipping_Amount__c");
        }else Shippingamount = 0;
        
        var ShippingTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
            ShippingTaxamount = component.get("v.RMA.ERP7__Shipping_Tax__c");
        }else ShippingTaxamount = 0;
        
        var MainTotalAmount = 0;
        if(component.get("v.totalamtli") > 0){
            MainTotalAmount = parseFloat(totalamountli)+parseFloat(Restockfees)+parseFloat(RestockTaxamount)+parseFloat(Shippingamount)+parseFloat(ShippingTaxamount);
        }
        
        component.set("v.totalamt",parseFloat(MainTotalAmount));
        
        var restockfee = 0;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            if(component.get("v.RMA.ERP7__Shipping_Amount__c") > 0){
                var totalamt = component.get("v.RMA.ERP7__Shipping_Amount__c");
                if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
                    var restockper = component.get("v.RMA.ERP7__Shipping_Tax__c");
                    restockfee = (restockper/totalamt)*100;
                }
            }
        }
        component.set("v.shippingTaxPer",restockfee);
    },
    
    updateEditTax : function(component, event, helper){
        var taxAmount = 0;
        if(!$A.util.isEmpty(component.get("v.EditTaxPer")) && !$A.util.isUndefined(component.get("v.EditTaxPer"))){
            if(component.get("v.EditTaxPer")>0){
                if(!$A.util.isEmpty(component.get("v.RMALI.RMALI.ERP7__Sale_Price__c")) && !$A.util.isUndefined(component.get("v.RMALI.RMALI.ERP7__Sale_Price__c")) && !$A.util.isEmpty(component.get("v.RMALI.returnQty")) && !$A.util.isUndefined(component.get("v.RMALI.returnQty"))){
                    var totalAmount = component.get("v.RMALI.RMALI.ERP7__Sale_Price__c") * component.get("v.RMALI.returnQty");
                    var totalTax = (totalAmount * component.get("v.EditTaxPer"))/100;
                    taxAmount = (totalTax/component.get("v.RMALI.returnQty"));
                }
            }
        }
        component.set("v.RMALI.RMALI.ERP7__Tax__c",taxAmount);
        $A.enqueueAction(component.get("c.QtyCheck"));
    },
    
    totalamthandler : function(component, event, helper){
        var totalamountli;
        if(!$A.util.isEmpty(component.get("v.totalamtli")) && !$A.util.isUndefined(component.get("v.totalamtli"))){
            totalamountli = component.get("v.totalamtli");
        }else totalamountli = 0;
        
        var Restockfees;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Restock_Fee__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Restock_Fee__c"))){
            Restockfees = component.get("v.RMA.ERP7__Restock_Fee__c");
        }else Restockfees = 0;
        
        var RestockTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__ReStock_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__ReStock_Tax__c"))){
            RestockTaxamount = component.get("v.RMA.ERP7__ReStock_Tax__c");
        }else RestockTaxamount = 0;
        
        var Shippingamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Amount__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Amount__c"))){
            Shippingamount = component.get("v.RMA.ERP7__Shipping_Amount__c");
        }else Shippingamount = 0;
        
        var ShippingTaxamount;
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Shipping_Tax__c")) && !$A.util.isUndefined(component.get("v.RMA.ERP7__Shipping_Tax__c"))){
            ShippingTaxamount = component.get("v.RMA.ERP7__Shipping_Tax__c");
        }else ShippingTaxamount = 0;
        
        var MainTotalAmount = 0;
        if(component.get("v.totalamtli") > 0){
            MainTotalAmount = parseFloat(totalamountli)+parseFloat(Restockfees)+parseFloat(RestockTaxamount)+parseFloat(Shippingamount)+parseFloat(ShippingTaxamount);
        }
        
        component.set("v.totalamt",parseFloat(MainTotalAmount));
        
    },
})