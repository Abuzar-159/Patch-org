({
    deletePOLI1 : function(component,helper,itemToDel){
        var action = component.get("c.deletePOLI");
        action.setParams({
            "itemToDel":itemToDel
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
            }else{
                //button.set('v.disabled',false);
                console.log('Error deletePOLI1:',response.getError());
                component.set("v.exceptionError",response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    /*getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },*/
    
    fetchDetails : function(component, event, helper) {
        console.log('fetchDetails called');
        var initaction = component.get("c.fetchChannelandDC");
        initaction.setParams({
            OId: component.get("v.orderId"),
            SOLIId : component.get("v.soliID")
        });
        initaction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                try{ 
                    var obj = response.getReturnValue();
                    console.log('resp : '+JSON.stringify(response.getReturnValue()));
                    if(!$A.util.isEmpty(obj.distributionChannel.Id)){
                        
                        console.log('component.get("v.recordId") here4~>', component.get("v.recordId"));
                        
                        if(($A.util.isEmpty(component.get("v.recordId")) || $A.util.isUndefinedOrNull(component.get("v.recordId"))) && ($A.util.isEmpty(component.get("v.clonePOId")) || $A.util.isUndefinedOrNull(component.get("v.clonePOId")))){
                            if(component.get("v.dChannelId") == null || component.get("v.dChannelId") == ''){
                                component.set("v.distributionChannel.Id",obj.distributionChannel.Id);
                                component.set("v.distributionChannel.Name",obj.distributionChannel.Name);
                                //component.set("v.Channel.Name",obj.distributionChannel.ERP7__Channel__r.Name);
                                console.log('going to set dChannelId if not (~>'+obj.dontDefault);
                                component.set("v.channelId",obj.distributionChannel.ERP7__Channel__c);
                                if(!obj.dontDefault) component.set("v.dChannelId", obj.distributionChannel.Id);
                            }
                        }
                        if(component.get("v.clonePOId") != null && component.get("v.clonePOId") != '' && component.get("v.clonePOId") != undefined) component.set("v.PO.Name",'');
                        if(($A.util.isEmpty(component.get("v.recordId")) || $A.util.isUndefinedOrNull(component.get("v.recordId"))) && ($A.util.isEmpty(component.get("v.clonePOId")) || $A.util.isUndefinedOrNull(component.get("v.clonePOId")))){
                            component.set("v.PO.ERP7__Organisation__c",obj.OrgAcc.Id);
                            component.set("v.PO.ERP7__Organisation__r.Id",obj.OrgAcc.Id);
                            component.set("v.PO.ERP7__Organisation__r.Name",obj.OrgAcc.Name);
                            console.log('PO org : ',component.get("v.PO.ERP7__Organisation__c")); 
                            console.log('PO org .Id : ',component.get("v.PO.ERP7__Organisation__r.Id")); 
                        }
                        
                        component.set("v.PO.ERP7__Invoice_Address__c",obj.BillAdd.Id);
                        
                        console.log("before ERP7__Delivery_Address__c here 4"+component.get("v.PO.ERP7__Delivery_Address__c"));
                        if(obj.showReceive && component.get("v.FieldToAssign") !='POD'){
                            if($A.util.isEmpty(component.get("v.recordId")) || $A.util.isUndefinedOrNull(component.get("v.recordId"))){
                                component.set("v.PO.ERP7__Delivery_Address__c",obj.deliveryAdd);
                                console.log('ERP7__Delivery_Address__c set here4~>',obj.deliveryAdd);
                            }
                        }
                        
                        component.set("v.isSalesOrder",obj.salesAccess);
                        if(component.get("v.interCompanyPO")){
                            component.set("v.isSalesOrder",true);
                            component.set("v.PO.ERP7__Inter_Company_PO__c", true);
                        }
                        component.set("v.ispaymnetAccess",obj.paymnetAccess);
                        component.set("v.showVenName",obj.VenAccess);
                        component.set("v.POLINameAcc",obj.POLINameAcc);
                        component.set("v.showTaxName",obj.TaxAccess);
                        component.set("v.showTaxRate", obj.TaxRate);
                        //component.set("v.versionAccess", obj.versionAccess);
                        component.set("v.QuoteAccess", obj.QuoteAccess);
                        component.set("v.hidechannelRemove",obj.hideRemove);
                        component.set("v.showOrgName",obj.showOrg);
                        component.set("v.showDchannelBelow",obj.showDCbelow);
                        component.set("v.venAddressRequired", obj.VendorAddRequired);
                        component.set("v.DcRequired", obj.DCRequired);
                        let defaultven = {'ERP7__Organisation__c':component.get("v.PO.ERP7__Organisation__c"),'ERP7__Account_Type__c': 'Vendor','RecordTypeId':obj.AccountRectype};
                        
                        component.set("v.defaultVenAcc",defaultven);
                        console.log('defaultVenAcc',component.get("v.defaultVenAcc"));
                        component.set("v.ACCRecId",obj.AccountRectype);
                        //component.set("v.ConRecId",obj.ContactRectype);
                        console.log('obj.showReceive-'+obj.showReceive);
                        component.set("v.showReceive",obj.showReceive);
                        var vBillDate = new Date();
                        vBillDate.setDate(vBillDate.getDate());
                        component.set("v.PO.ERP7__Expected_Date__c", vBillDate.getFullYear() + "-" + (vBillDate.getMonth() + 1) + "-" + vBillDate.getDate());
                        component.set("v.PO.ERP7__Status__c",'Draft');
                        if(component.get("v.orderId") != null || component.get("v.orderId") != undefined || component.get("v.orderId") != ''){ component.set("v.PO.ERP7__Order__c",component.get("v.orderId"));}
                        //Moin added this below line and commented the next line as the order was not populcating while trying the create an purchase order from order record page
                        if(component.get("v.SOId") != null || component.get("v.SOId") != undefined || component.get("v.SOId") != ''){ component.set("v.PO.ERP7__Sales_Order__c",component.get("SOId"));}
                        //if(component.get("v.soliID") != null || component.get("v.soliID") != undefined || component.get("v.soliID") != ''){ component.set("v.PO.ERP7__Sales_Order__c",obj.SOID1);}
                        console.log("after ERP7__Delivery_Address__c here 4"+component.get("v.PO.ERP7__Delivery_Address__c"));
                    }
                }catch(ex){
                    console.log('err~>'+ex);
                } 
            }else{
                var errors = response.getError();
                console.log("fetchDetails server error :", errors);
            }
        });
        $A.enqueueAction(initaction);
    },
    
    setPOandPOLIs : function(component, event, helper){
        try{
            console.log('setPOandPOLIs called');
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//1
            component.set("v.showSpinner",true);
            var recordId = (component.get("v.recordId") != null && component.get("v.recordId") != undefined && component.get("v.recordId") != "") ? component.get("v.recordId") : component.get("v.clonePOId");
            console.log('recordId : ',recordId);
            var action = component.get("c.fetchPOandPOLIs");
            action.setParams({
                purchaseId : recordId,
                returnToVendor : component.get("v.returnToVendor")
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    component.set("v.proceedDeliveryAddChange",false);
                    console.log('res of fetchPOandPOLIs:',JSON.stringify(response.getReturnValue()));
                    
                    var pli = response.getReturnValue().wPOLIs;
                    var stocklst = response.getReturnValue().productStocks;
                    var dimeList = response.getReturnValue().demLIs;
                    var poliAcc = [];
                    if(pli != null && pli != undefined){
                        if(dimeList != undefined && dimeList != null){
                            //for(var x in pli){
                            for(var x = 0; x < pli.length; x++){
                                poliAcc = [];
                                //for(var y in dimeList){
                                for(var y = 0; y < dimeList.length; y++){
                                    if(pli[x].Id == dimeList[y].ERP7__Purchase_Line_Items__c){
                                        if(component.get("v.returnToVendor") || (component.get("v.clonePOId") != null && component.get("v.clonePOId") != undefined && component.get("v.clonePOId") != "")){
                                            dimeList[y].Id = null;
                                        }
                                        poliAcc.push(dimeList[y]);
                                    }
                                }
                                pli[x].Accounts = poliAcc;
                            }
                        }
                        //for(var x in pli){
                        for(var x = 0; x < pli.length; x++){
                            if(component.get("v.clonePOId") != null && component.get("v.clonePOId") != undefined && component.get("v.clonePOId") != "") pli[x].Id = null; // added by shaguftha on 09/11/23
                            //for(var y in stocklst){
                            for(var y = 0; y < stocklst.length; y++){
                                if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                    pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                    pli[x].demand = stocklst[y].Demand;
                                    pli[x].ItemsinStock = stocklst[y].Stock;
                                }
                            }
                        }
                    }
                    //New code added by Arshad 02/02/23
                    try{
                        var newpli = [];
                        if(component.get("v.returnToVendor")){
                            var dumpli = []; var dumrpli = [];
                            dumpli = pli; 
                            dumrpli = response.getReturnValue().existingReturnPOLIs;
                            console.log('dumrpli~>',dumrpli);
                            //for(var i in dumpli){
                            for(var i = 0; i < dumpli.length; i++){
                                if(!$A.util.isEmpty(dumpli[i].ERP7__Quantity__c) && !$A.util.isUndefinedOrNull(dumpli[i].ERP7__Quantity__c)){
                                    dumpli[i].returnedQTY = 0;
                                    dumpli[i].allowedReturnQTY = 0;
                                    //for(var j in dumrpli){
                                    for(var j = 0; j < dumrpli.length; j++){
                                        if(dumpli[i].ERP7__Product__c == dumrpli[j].ERP7__Product__c && !$A.util.isEmpty(dumrpli[j].ERP7__Quantity__c) && !$A.util.isUndefinedOrNull(dumrpli[j].ERP7__Quantity__c)){
                                            dumpli[i].returnedQTY += dumrpli[j].ERP7__Quantity__c;
                                        }
                                    }
                                    if(dumpli[i].returnedQTY > 0){
                                        dumpli[i].allowedReturnQTY = parseInt(dumpli[i].ERP7__Quantity__c) - parseInt(dumpli[i].returnedQTY);
                                        dumpli[i].ERP7__Quantity__c = dumpli[i].allowedReturnQTY;
                                    }else dumpli[i].allowedReturnQTY = parseInt(dumpli[i].ERP7__Quantity__c);
                                    if(dumpli[i].allowedReturnQTY >= 1){
                                        newpli.push(dumpli[i]);
                                    }
                                }
                            }
                            if(newpli.length <= 0){
                                component.set("v.exceptionError",'No items available to be returned');
                            }
                        }else newpli = pli;
                    }catch(e){ console.log('arshad err~>'+e); newpli = pli; }
                    //
                    console.log('arshad newpli here~>'+JSON.stringify(newpli));
                    
                    component.set("v.poli", newpli); //component.set("v.poli", pli);
                    
                    console.log('setting v.PO here1');
                    
                    if(response.getReturnValue().wPO != undefined && response.getReturnValue().wPO != null){
                        if(response.getReturnValue().wPO.Id != undefined && response.getReturnValue().wPO.Id != null && response.getReturnValue().wPO.Id != ''){
                            console.log('proceedDefaultTaxRateChange set to false');
                            component.set("v.proceedDefaultTaxRateChange",false);
                        }
                    }
                    
                    component.set("v.PO", response.getReturnValue().wPO);
                    var PO = component.get("v.PO");
                    
                    try{
                        component.set("v.showTaxRate",response.getReturnValue().displayTaxRate);
                        component.set("v.showTaxName",response.getReturnValue().displayTax);
                       // component.set("v.versionAccess",response.getReturnValue().displayVersion);
                        component.set("v.showVenName",response.getReturnValue().displayVPO);
                        component.set("v.QuoteAccess", response.getReturnValue().displayQuote);
                        component.set("v.showAllocations", response.getReturnValue().displayAllocations);
                        component.set("v.showDchannelBelow", response.getReturnValue().displayDCBelow);
                        //component.set("v.showOrgName", response.getReturnValue().displayDCBelow);
                        component.set("v.SubTotal",PO.ERP7__Amount__c);
                        component.set("v.TotalTax",PO.ERP7__Tax_Amount__c);
                        component.set("v.TotalAmount",PO.ERP7__Total_Amount__c);
                        component.set("v.POLINameAcc", response.getReturnValue().displayName);
                        component.set("v.channelId", PO.ERP7__Channel__c);
                        component.set("v.Channel.Id",PO.ERP7__Channel__c);
                        
                        if(PO.ERP7__Channel__c != undefined && PO.ERP7__Channel__c != null && PO.ERP7__Channel__c != ''){
                            component.set("v.Channel.Name",PO.ERP7__Channel__r.Name);
                        }
                        
                        console.log('setting dChannelId here~>');
                        
                        component.set("v.dChannelId", PO.ERP7__Distribution_Channel__c);
                        component.set("v.distributionChannel.Id",PO.ERP7__Distribution_Channel__c);
                        
                        if(PO.ERP7__Distribution_Channel__c != undefined && PO.ERP7__Distribution_Channel__c != null && PO.ERP7__Distribution_Channel__c != ''){
                            component.set("v.distributionChannel.Name",PO.ERP7__Distribution_Channel__r.Name);
                        }
                        
                        try{ console.log('PO.ERP7__Ready_To_Receive__c~>'+PO.ERP7__Ready_To_Receive__c); }catch(e){ }
                        /*if(response.getReturnValue().isBilled!==undefined && response.getReturnValue().isBilled!==null){
                            component.set("v.isRecieved", response.getReturnValue().isBilled);
                        }*/
                        if(PO.ERP7__Ready_To_Receive__c){
                            component.set("v.isRecieved", PO.ERP7__Ready_To_Receive__c);
                        }
                        if(component.get("v.returnToVendor") || (component.get("v.clonePOId") != null && component.get("v.clonePOId") != undefined && component.get("v.clonePOId") != "")){
                            console.log('arshad isReceived set to false here');
                            component.set("v.isRecieved", false);
                            component.set("v.PO.ERP7__Ready_To_Receive__c", false);
                            component.set("v.PO.Id", null);
                        }
                        
                        var DescriptionVal = PO.ERP7__Description__c;
                        if(DescriptionVal){
                            var strippedValue = DescriptionVal.replace(/(<([^>]+)>)/ig,"");
                            component.set("v.PO.ERP7__Description__c", strippedValue);
                        }
                        
                        component.set("v.PO.ERP7__Sales_Order__c", PO.ERP7__Sales_Order__c);
                        component.set("v.PO.ERP7__Order__c", PO.ERP7__Order__c);
                        component.set("v.PO.ERP7__Status__c", 'Draft');
                        
                        var poLIst = component.get("v.poli");
                        console.log('poLIst : ',poLIst);
                        
                        //for(var x in poLIst){
                        for(var x = 0; x < poLIst.length; x++){
                            //try{ console.log('before x : ',x,' poLIst[x].ERP7__Total_Price__c : ',poLIst[x].ERP7__Total_Price__c,' poLIst[x].ERP7__Tax__c : ',poLIst[x].ERP7__Tax__c,' poLIst[x].ERP7__Tax_Rate__c : ',poLIst[x].ERP7__Tax_Rate__c); }catch(e){}
                            if(poLIst[x].ERP7__Tax__c != null && poLIst[x].ERP7__Tax__c != undefined) poLIst[x].ERP7__Total_Price__c = poLIst[x].ERP7__Total_Price__c + poLIst[x].ERP7__Tax__c;
                            else poLIst[x].ERP7__Total_Price__c = poLIst[x].ERP7__Quantity__c * poLIst[x].ERP7__Unit_Price__c;
                            var amount = poLIst[x].ERP7__Quantity__c * poLIst[x].ERP7__Unit_Price__c;
                            console.log('amount~>'+amount);
                            console.log('poLIst[x].ERP7__Tax__c~>'+poLIst[x].ERP7__Tax__c);
                            console.log('before poLIst[x].ERP7__Tax_Rate__c~>'+poLIst[x].ERP7__Tax_Rate__c);
                            if(poLIst[x].ERP7__Tax__c != null && poLIst[x].ERP7__Tax__c > 0){
                                if(poLIst[x].ERP7__Tax_Rate__c == null || poLIst[x].ERP7__Tax_Rate__c <= 0) poLIst[x].ERP7__Tax_Rate__c = (poLIst[x].ERP7__Tax__c/amount) * 100;
                            }
                            console.log('after poLIst[x].ERP7__Tax_Rate__c~>'+poLIst[x].ERP7__Tax_Rate__c);
                        }
                        
                        console.log('before component.get("v.selectedRecType")~>'+component.get("v.selectedRecType"));
                        if(!$A.util.isEmpty(response.getReturnValue().wPO) && !$A.util.isUndefinedOrNull(response.getReturnValue().wPO)){
                            if(!$A.util.isEmpty(response.getReturnValue().wPO.Id) && !$A.util.isUndefinedOrNull(response.getReturnValue().wPO.Id)){
                                if(!$A.util.isEmpty(response.getReturnValue().wPO.RecordTypeId) && !$A.util.isUndefinedOrNull(response.getReturnValue().wPO.RecordTypeId)){
                                    if(!$A.util.isEmpty(response.getReturnValue().wPO.RecordType) && !$A.util.isUndefinedOrNull(response.getReturnValue().wPO.RecordType)){
                                        if(!$A.util.isEmpty(response.getReturnValue().wPO.RecordType.Name) && !$A.util.isUndefinedOrNull(response.getReturnValue().wPO.RecordType.Name)){
                                            console.log('response.getReturnValue().wPO.RecordType.Name~>'+response.getReturnValue().wPO.RecordType.Name);
                                            component.set("v.selectedRecType",response.getReturnValue().wPO.RecordType.Name);
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(component.get("v.returnToVendor")){
                            component.set("v.selectedRecType",'Return to Vendor');
                        }
                        
                        console.log('after component.get("v.selectedRecType")~>'+component.get("v.selectedRecType"));
                        
                        console.log('proceedDefaultTaxRateChange setting true back');
                        component.set("v.proceedDeliveryAddChange",true);
                        component.set("v.proceedDefaultTaxRateChange",true);
                        
                        let poStatus = component.get("c.getStatus");
                        poStatus.setCallback(this,function(response){
                            let resList = response.getReturnValue();
                            component.set("v.POStatusoptions",resList);
                            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//2
                            component.set("v.showSpinner",false);
                        });
                        $A.enqueueAction(poStatus);
                        let poPackageType = component.get("c.getPackageType");
                        poPackageType.setCallback(this,function(response){
                            let resList = response.getReturnValue();
                            component.set("v.POTypeoptions",resList);                
                            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//2   
                            component.set("v.showSpinner",false);//uncomment         
                        });
                        $A.enqueueAction(poPackageType);
                        
                    }catch(e){
                        //$A.util.addClass(component.find('mainSpin'), "slds-hide");//3
                        component.set("v.showSpinner",false);
                        component.set("v.proceedDeliveryAddChange",true);
                        component.set("v.proceedDefaultTaxRateChange",true);
                    }
                }
                else{
                    console.log('error fetchPOandPOLIs: ',response.getError());
                }
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//4
                component.set("v.showSpinner",false);
            });
            $A.enqueueAction(action);
            console.log('end of Error fetchPOandPOLIs:');
        }
        catch(e){console.log('Error in fetchPOandPOLIs:',e);}
        
    },
    
    showToast : function(title, type, message) {
       var toastEvent = $A.get("e.force:showToast");
console.log('toastEvent:', toastEvent);
if (toastEvent != undefined) {
    toastEvent.setParams({
        "mode": "dismissible",
        "title": title,
        "type": type,
        "message": message
    });
    toastEvent.fire();
} else {
    console.log('Error: force:showToast event is undefined');
}
    },
    /*
    hideSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");    
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");   
    },*/
    validationCheck : function (component, event) {
        var NOerrorsval = true;
        var NOerrorsPoli = true;
        var vendorAcc = component.get("v.PO.ERP7__Vendor__c");
        console.log('vendorAcc : '+vendorAcc);
        if(!$A.util.isUndefined(vendorAcc))  NOerrorsval =  true; 
        else NOerrorsval =  false;
        //this.checkvalidationLookup(vendorAcc);
        var poliList = component.find("poli");
        if(!$A.util.isUndefined(poliList))
            if(poliList.length>0){
                let flag = true;
                //for(let x  in poliList)
                for(let x = 0; x < poliList.length; x++)
                    flag = poliList[x].callValidate(); 
                if(!flag) return false;
                // else return flag;
            }else{
                NOerrorsPoli = poliList.callValidate(); 
            }
        var NOerrors = NOerrorsPoli && NOerrorsval;
        return NOerrors;
    },
    
    validationVendorCon : function (component, event) {
        var NOerrorsval = true;
        var NOerrorsPoli = true;
        var vendorCon = component.find("vendorContact");
        if(!$A.util.isUndefined(vendorCon))
            NOerrorsval =  this.checkvalidationLookup(vendorCon);
        
        var poliList = component.find("poli");
        if(!$A.util.isUndefined(poliList))
            if(poliList.length>0){
                let flag = true;
                //for(let x  in poliList)
                for(let x = 0; x < poliList.length; x++)
                    flag = poliList[x].callValidate(); 
                if(!flag) return false;
                // else return flag;
            }else{
                NOerrorsPoli = poliList.callValidate(); 
            }
        var NOerrors = NOerrorsPoli && NOerrorsval;
        return NOerrors;
    },
    
    validationVendorAdd : function (component, event) {
        var NOerrorsval = false;
        if(component.get("v.PO.ERP7__Vendor_Address__c") !=null && component.get("v.PO.ERP7__Vendor_Address__c") !='' && component.get("v.PO.ERP7__Vendor_Address__c") != undefined){
            NOerrorsval = true;
        }
        return NOerrorsval;
    },
    
    validationCheckOrg : function (component, event) {
        var NOerrorsval = true;
        var NOerrorsPoli = true;
        var orgAcc = component.find("organisationAccount");
        if(!$A.util.isUndefined(orgAcc))
            NOerrorsval =  this.checkvalidationLookup(orgAcc);
        
        var poliList = component.find("poli");
        if(!$A.util.isUndefined(poliList))
            if(poliList.length>0){
                let flag = true;
                //for(let x  in poliList)
                for(let x = 0; x < poliList.length; x++)
                    flag = poliList[x].callValidate(); 
                if(!flag) return false;
                // else return flag;
            }else{
                NOerrorsPoli = poliList.callValidate(); 
            }
        var NOerrors = NOerrorsPoli && NOerrorsval;
        return NOerrors;
    },
    
    validationCheckName : function (component, event) {
        var NOerrors = true;       
        var poName = component.find("poName");
        
        if(!$A.util.isUndefined(poName))
            NOerrors =  this.checkValidationField(poName);
        else
        {
            var poliList = component.find("poli");
            if(!$A.util.isUndefined(poliList))
                if(poliList.length>0){
                    let flag = true;
                    //for(let x  in poliList)
                    for(let x = 0; x < poliList.length; x++)
                        flag = poliList[x].callValidate(); 
                    if(!flag) return false;
                    // else return flag;
                }else{
                    NOerrors = poliList.callValidate(); 
                }
        }
        return NOerrors;
    },
    
    validationCheckDC : function (component, event) {
        var NOerrors = true;       
        var dcId = component.find("dcId");
        if(!$A.util.isUndefined(dcId)){
            //  NOerrors =  this.checkValidationField(dcId);
            component.set("v.class","");
        }else{  dcId.set("v.class","hasError");
              // NOerrors = poliList.callValidate(); 
             }
        // return NOerrors;
    },
    
    validationCheckQuantity : function (component, event, helper) {
        var isErrors = false;       
        var qtyElem=[]; 
        qtyElem=component.get("v.poli");  
        var qtyElem1=[]; 
        qtyElem1=component.find("qty");
        try{  
            //for(var i in qtyElem){   
            for(var i = 0; i < qtyElem.length; i++){
                if(qtyElem[i].ERP7__Quantity__c<=0 || qtyElem[i].ERP7__Quantity__c==undefined || qtyElem[i].ERP7__Quantity__c==null) {
                    //  qtyElem1[i].set("v.class","hasError");
                    component.set("v.qmsg",'not valid');
                    // return true;
                    isErrors=true; return isErrors;//break;
                }
                else{ 
                    // qtyElem[i].set("v.class","hasError");
                    // return false;  
                    isErrors=false;
                }                  
            }   
        }catch(ex){}
        //alert('validationCheckQuantity isErrors==>'+isErrors);
        return isErrors;
    }, 
    
    //New code added by Arshad 02/02/23
    validationRTVPOqtyCheck : function (component, event, helper) {
        var isErrors = false;       
        var qtyElem=[]; 
        qtyElem = component.get("v.poli");  
        try{  
            //for(var i in qtyElem){  
            for(var i = 0; i < qtyElem.length; i++){
                if(!$A.util.isEmpty(qtyElem[i].ERP7__Quantity__c) && !$A.util.isUndefinedOrNull(qtyElem[i].ERP7__Quantity__c)){
                    if(qtyElem[i].allowedReturnQTY > 0 && qtyElem[i].ERP7__Quantity__c > 0 && qtyElem[i].ERP7__Quantity__c > qtyElem[i].allowedReturnQTY) {
                        component.set("v.qmsg",'not valid');
                        isErrors=true; 
                        return isErrors;
                    }             
                }   
            }
        }catch(ex){ console.log('validationRTVPOqtyCheck err ~>'+ex); }
        return isErrors;
    }, 
    //
    
    validationCheckUnitPrice : function (component, event, helper) {
        var isErrors = false;       
        var qtyElem = []; 
        qtyElem = component.get("v.poli");
        try{  
            //for(var i in qtyElem){
            for(var i = 0; i < qtyElem.length; i++){
                if(qtyElem[i].ERP7__Unit_Price__c < 0 || qtyElem[i].ERP7__Unit_Price__c == null || qtyElem[i].ERP7__Unit_Price__c == undefined) {
                    isErrors = true; 
                    return isErrors;
                }
                else{ 
                    isErrors = false;
                }
            }   
        }catch(ex){}
        return isErrors;
    },
    
    validationCheckQuantityDum : function (component, event, helper) {
        var isErrors = false;       
        var qtyElem=[]; qtyElem=component.find("qty");
        
        //for(var i in qtyElem){ 
        for(var i = 0; i < qtyElem.length; i++){
            if(qtyElem[i].getElement().get("v.value")<=0 || qtyElem[i].getElement().get("v.value")==undefined || qtyElem[i].getElement().get("v.value")=='') {
                qtyElem[i].set("v.class","hasError");
                component.set("v.qmsg",'not valid');
                // return true;
                isErrors=true; return isErrors;//break;
            }
            else{ 
                // qtyElem[i].set("v.class","hasError");
                // return false;  
                isErrors=false; 
                
            }  
            /* if(!$A.util.isUndefined(dcId)){
        
          component.set("v.class","");
        }else{  dcId.set("v.class","hasError");
          // NOerrors = poliList.callValidate(); 
        }*/
        }   
        
        return isErrors;
    }, 
    
    checkvalidationLookup : function(poli_List){
        if(poli_List != null && poli_List != undefined && poli_List != '' && $A.util.isEmpty(poli_List) && $A.util.isEmpty(poli_List.get("v.selectedRecord.Id"))){
            poli_List.set("v.inputStyleclass","hasError");
            return false;
        }else{
            poli_List.set("v.inputStyleclass",""); 
            return true;
        }
    },
    
    checkValidationField : function(component){
        if($A.util.isEmpty(component.get("v.value"))){
            component.set("v.class","hasError");
            return false;
        }else{
            component.set("v.class","");
            return true;
        }
        
    },
    
    RMADOInit: function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//5
        component.set("v.showSpinner",true);
        var action = component.get("c.populateRMAPO");
        action.setParams({
            rmaliID:component.get("v.rmaliID")
        });
        action.setCallback(this, function(a) {
            // component.set("v.RMALI", a.getReturnValue());
            var poliList = [];
            poliList.push(a.getReturnValue());
            component.set("v.poli",poliList);
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//6
            component.set("v.showSpinner",false);
            //}    
        });
        $A.enqueueAction(action);
    },
    
    SOLIDOInit: function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//7
        component.set("v.showSpinner",true);
        var action = component.get("c.populateSOLI");
        if(component.get("v.soliID") != null){
            action.setParams({
                soliID:component.get("v.soliID")
            });
            action.setCallback(this, function(a) {
                var poliList = [];//component.get("v.poli");
                console.log('a.getReturnValue() : ',a.getReturnValue());
                poliList.push(a.getReturnValue().Prs);
                poliList[0].ItemsinStock = a.getReturnValue().Stock;
                poliList[0].demand = a.getReturnValue().Demand;
                poliList[0].AwaitingStock = a.getReturnValue().AwaitingStocks;
                console.log('poliList : ',poliList);
                component.set("v.poli",poliList);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//8
                component.set("v.showSpinner",false);
            });
        }    
        $A.enqueueAction(action);
    },
    
    mpslineInit: function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//9
        component.set("v.showSpinner",true);
        var action = component.get("c.populateMpsline");
        if(component.get("v.mpslineId") != null){
            action.setParams({
                mpslineId:component.get("v.mpslineId")
            });
            action.setCallback(this, function(a) {
                var poliList = component.get("v.poli");
                //if(poliList.length>0){
                //poliList.unshift(a.getReturnValue());
                poliList.push(a.getReturnValue());
                component.set("v.poli",poliList);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//10
                component.set("v.showSpinner",false);
                //}    
            });
        }    
        $A.enqueueAction(action);
    },
    
    mrplineInit: function(component, event, helper) {
        console.log('mrplineInit called');
        
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//11
        component.set("v.showSpinner",true);
        var action = component.get("c.populateMrpline");
        if(component.get("v.mrplineId") != null){
            action.setParams({
                mrplineId:component.get("v.mrplineId")
            });
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS"){
                    console.log('resp populateMrpline : ', JSON.stringify(response.getReturnValue()));
                    var poliList = [];//component.get("v.poli");
                    
                    //if(poliList.length>0){
                    /*poliList.unshift(a.getReturnValue());
            		component.set("v.poli",poliList);*/
                    
                    console.log('populateMrpline quantityMultiplier~>'+component.get("v.quantityMultiplier"));
                    
                    //imran added for quantityMultiplier
                    var poli = response.getReturnValue().poli;
                    poli.ERP7__Unit_Price__c = 0.00;
                    poli.ERP7__Total_Price__c = 0.00;
                    console.log('populateMrpline poli.ERP7__Quantity__c before~>'+poli.ERP7__Quantity__c);
                    poli.ERP7__Quantity__c = poli.ERP7__Quantity__c/component.get("v.quantityMultiplier");
                    poli.AwaitingStock = response.getReturnValue().Awstock;
                    poli.demand = response.getReturnValue().ReqStock;
                    poli.ItemsinStock = response.getReturnValue().stock;
                    
                    console.log('populateMrpline poli.ERP7__Quantity__c after~>'+poli.ERP7__Quantity__c);
                    poliList.push(poli);
                    component.set("v.poli",poliList);
                    component.set("v.PO.ERP7__Vendor__c",response.getReturnValue().vendId);
                    component.set("v.MPsMOId",response.getReturnValue().MOId);
                    console.log('MPsMOId : ',component.get("v.MPsMOId"));
                }else{
                    var errors = response.getError();
                    console.log("server error in populateMrpline : ", JSON.stringify(errors));
                }
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//12
                component.set("v.showSpinner",false);
                //}     
            });
        }    
        $A.enqueueAction(action);
    },
    
    addNew : function(component, event, helper) {
        var poliList = component.get("v.poli");
        poliList.push({sObjectType :'ERP7__Purchase_Line_Items__c'});
        component.set("v.poli",poliList);
    },
    
    fetchVendorDetails : function(component, event, helper) {  
        console.log('fetchVendorDetails called and v.PO~>',JSON.stringify(component.get("v.PO")));
        
        var polis = component.get("v.poli");
        console.log('fetchVendorDetails polis~>',JSON.stringify(polis));
        
        if(component.get("v.PO.ERP7__Vendor_Contact__c") == null && component.get("v.PO.ERP7__Vendor_Contact__c") == undefined && component.get("v.PO.ERP7__Vendor_Contact__c") == ''){
            console.log('fetchVendorDetails inhere contact empty');
            component.set("v.PO.ERP7__Vendor_Contact__r.Id",undefined);
            if(component.get("v.PO.ERP7__Vendor__r.Id") == undefined || component.get("v.PO.ERP7__Vendor__r.Id") == null || component.get("v.PO.ERP7__Vendor__r.Id") == ''){
                component.set("v.PO.ERP7__Payment_Terms__c",0);
                if(polis != undefined && polis != null){
                    //for(var x in polis){
                    for(var x = 0; x < polis.length; x++){
                        if(polis[x] != undefined && polis[x].ERP7__Cost_Card__c != undefined) {
                            console.log('fetchVendorDetails setting ERP7__Cost_Card__c here to null');
                            polis[x].ERP7__Cost_Card__c = null;
                        }
                    }
                    console.log('fetchVendorDetails inhere setting poli again');
                    component.set("v.poli",polis); 
                }
            }
            else{      
                console.log('fetchVendorDetails inhere2');
                if(component.get("v.PO.ERP7__Vendor__r.Id") != undefined){
                    component.set("v.vendorId",component.get("v.PO.ERP7__Vendor__r.Id"));  
                }
                var productIds = "";	
                var count = 0;
                if(polis != undefined && polis != null){
                    //for(var x in polis){
                    for(var x = 0; x < polis.length; x++){
                        if(polis[x] != undefined && polis[x].ERP7__Product__c != undefined) {
                            if(count == 0) productIds += polis[x].ERP7__Product__c;
                            else productIds = productIds + ',' + polis[x].ERP7__Product__c;
                            count++;
                        }
                    }
                }
                console.log('fetchVendorDetails calling getVendorDetailsNew');
                
                var action = component.get("c.getVendorDetailsNew");    
                action.setParams({
                    "AccId":component.get("v.PO.ERP7__Vendor__r.Id"),
                    "proIds":productIds
                });  
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        console.log('getVendorDetailsNew resp~>',response.getReturnValue());
                        
                        if(response.getReturnValue().Acc.ERP7__Payment_Terms__c != undefined) component.set("v.PO.ERP7__Payment_Terms__c",response.getReturnValue().Acc.ERP7__Payment_Terms__c); 
                        if(response.getReturnValue().Con.Id != undefined) component.set("v.PO.ERP7__Vendor_Contact__r.Id",response.getReturnValue().Con.Id);
                        
                        if(polis != undefined && polis != null){
                            //for(var x in polis){
                            for(var x = 0; x < polis.length; x++){
                                if(polis[x] != undefined && polis[x].ERP7__Product__c != undefined) {
                                    for(var y in response.getReturnValue().ApprovedVendorPrice){
                                        if(response.getReturnValue().ApprovedVendorPrice[y].ERP7__Product__c  == polis[x].ERP7__Product__c && response.getReturnValue().ApprovedVendorPrice[y].ERP7__Cost_Card__c != undefined && polis[x].ERP7__Quantity__c >= response.getReturnValue().ApprovedVendorPrice[y].ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c && polis[x].ERP7__Quantity__c <= response.getReturnValue().ApprovedVendorPrice[y].ERP7__Cost_Card__r.ERP7__Quantity__c) {
                                            var quan = polis[x].ERP7__Quantity__c;
                                            console.log('getVendorDetailsNew setting ERP7__Cost_Card__c here1');
                                            polis[x].ERP7__Cost_Card__c = response.getReturnValue().ApprovedVendorPrice[y].ERP7__Cost_Card__c; 
                                            //polis[x].ERP7__Quantity__c = quan;
                                            //polis[x].ERP7__Unit_Price__c = response.getReturnValue().ApprovedVendorPrice[y].ERP7__Cost_Card__r.ERP7__Cost__c;
                                            //polis[x].ERP7__Total_Price__c = polis[x].ERP7__Unit_Price__c * polis[x].ERP7__Quantity__c;
                                            break;
                                        }
                                    }
                                }
                            } 
                            console.log('fetchVendorDetails inhere2 setting poli again');
                            component.set("v.poli",polis); 
                        }
                        
                    }        
                });
                $A.enqueueAction(action);  
            }
        }
        
    },
    
    fetchAddressDetails : function(component, event, helper) {
        console.log('fetchAddressDetails called');
        console.log("beforef ERP7__Delivery_Address__c here1~>"+component.get("v.PO.ERP7__Delivery_Address__c"));
        if($A.util.isEmpty(component.get("v.PO.ERP7__Invoice_Address__c"))  && $A.util.isEmpty(component.get("v.PO.ERP7__Delivery_Address__c"))){
            component.set("v.PO.ERP7__Invoice_Address__r.Id",undefined);
            component.set("v.PO.ERP7__Delivery_Address__r.Id",undefined);
            if(component.get("v.PO.ERP7__Organisation__r.Id") != '' && component.get("v.PO.ERP7__Organisation__r.Id") != undefined &&( component.get("v.PO.PO.ERP7__Invoice_Address__r.Id") == null || component.get("v.PO.PO.ERP7__Invoice_Address__r.Id") == undefined)){
                var action = component.get("c.getOrgAddressDetails");    
                action.setParams({
                    "AccId":component.get("v.PO.ERP7__Organisation__r.Id")
                });  
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        console.log('getOrgAddressDetails success~>',response.getReturnValue());
                        if(response.getReturnValue().InvAdd.Id != undefined){
                            component.set("v.PO.ERP7__Invoice_Address__r",response.getReturnValue().InvAdd);
                            component.set("v.PO.ERP7__Invoice_Address__c",response.getReturnValue().InvAdd.Id);
                        }
                        if(response.getReturnValue().DelAdd.Id != undefined) {
                            component.set("v.PO.ERP7__Delivery_Address__r",response.getReturnValue().DelAdd);
                            component.set("v.PO.ERP7__Delivery_Address__c",response.getReturnValue().DelAdd.Id);
                            console.log('ERP7__Delivery_Address__c set here1~>',response.getReturnValue().DelAdd.Id);
                        }
                    }       
                });
                $A.enqueueAction(action);  
                console.log("afterf ERP7__Delivery_Address__c here1~>"+component.get("v.PO.ERP7__Delivery_Address__c"));
            }
        }
        else{
            //  $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
    },
    
    MOInit: function(component, event, helper) {
        console.log('MOInit calledd');
        component.set('v.addProductsMsg','');
        if(component.get("v.MOId") != null){
            var dcId = '';
            if(component.get("v.distributionChannel.Id") != '' && component.get("v.distributionChannel.Id") != undefined && component.get("v.distributionChannel.Id") != null) dcId = component.get("v.distributionChannel.Id");
            var action = component.get("c.populateMOlines");
            action.setParams({
                MOId:component.get("v.MOId")
            });
            action.setCallback(this, function(response) {
                console.log('MOInit state : ',response.getState());
                if(response.getState() === "SUCCESS"){
                    console.log('MOInit response : ',response.getReturnValue());
                    if(response.getReturnValue() != null){
                        var pli = response.getReturnValue().wPOLIs;
                        var stocklst = response.getReturnValue().productStocks;
                        //for(var x in pli){
                        for(var x = 0; x < pli.length; x++){
                            //for(var y in stocklst){
                            for(var y = 0; y < stocklst.length; y++){
                                //Moin added this on 11th october 2024 to set the values as 0 for unit price and total price from coming from workbench
                                pli[x].ERP7__Unit_Price__c = 0.00;
                            	pli[x].ERP7__Total_Price__c = 0.00;
                                if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                    pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                    pli[x].demand = stocklst[y].Demand;
                                    pli[x].ItemsinStock = stocklst[y].Stock;
                                }
                            }
                        }
                        component.set("v.poli",pli);
                        let msg = response.getReturnValue().CommonVendorMessage;
                        if(msg != null && msg != '' && msg != undefined){ helper.showToast('Warning', 'warning', msg); console.log('*************'); }
                        // component.set('v.addProductsMsg',msg); }
                        else component.set("v.PO.ERP7__Vendor__c",response.getReturnValue().CommonVendor);
                        console.log('addProductsMsg : ',component.get("v.addProductsMsg"));  
                    }
                    else{
                        helper.showToast('Warning', 'warning', 'No Products available');  
                    }
                }
                else{
                    console.log('MOInit error : ',response.getError());
                }
                
            });
            $A.enqueueAction(action);
        }  
    },
    
    SOInit: function(component, event, helper) {
        if(component.get("v.SOId") != null){
            var action = component.get("c.populateSOlines");
            action.setParams({
                SOId:component.get("v.SOId")
            });
            action.setCallback(this, function(response) {
                if(response.getState() == "SUCCESS"){
                    console.log('res of SOInit:',response.getReturnValue());
                    var pli = response.getReturnValue().wPOLIs;
                    var stocklst = response.getReturnValue().productStocks;
                    //for(var x in pli){
                    for(var x = 0; x < pli.length; x++){
                        //for(var y in stocklst){
                        for(var y = 0; y < stocklst.length; y++){
                            if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                pli[x].demand = stocklst[y].Demand;
                                pli[x].ItemsinStock = stocklst[y].Stock;
                            }
                        }
                    }
                    component.set("v.poli",pli);
                    component.set("v.PO.ERP7__Sales_Order__c",component.get("v.SOId"));
                }
                else{
                    var error1=response.getError();
                    console.log('error1 : ',error1);
                    component.set('v.exceptionError',error1[0].message);
                }
                this.getExistingPR(component, event); 
            });
            $A.enqueueAction(action);
        }  
    },
    
    WOInit: function(component, event, helper) {
        if(component.get("v.WOId") != null){
            var action = component.get("c.populateWOlines");
            action.setParams({
                WOId:component.get("v.WOId")
            });
            action.setCallback(this, function(a) {
                var pli = a.getReturnValue();
                //Moin added this on 11th october 2024 to set the values as 0 for unit price and total price from coming from workbench
                for(var x = 0; x < pli.length; x++){
                    pli[x].ERP7__Unit_Price__c = 0.00;
                    pli[x].ERP7__Total_Price__c = 0.00;
                }
                component.set("v.poli",a.getReturnValue());
            });
            $A.enqueueAction(action);
        }  
    },
    
    displayRecords: function(component, event, helper) {
        var initaction = component.get("c.fetchChannelandDC");
        initaction.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                try{ 
                    var obj = response.getReturnValue();
                    
                    if(!$A.util.isEmpty(obj.distributionChannel.Id)){
                        component.set("v.distributionChannel.Id",obj.distributionChannel.Id);
                        component.set("v.distributionChannel.Name",obj.distributionChannel.Name);
                        //component.set("v.Channel.Name",obj.distributionChannel.ERP7__Channel__r.Name);
                        component.set("v.channelId",obj.distributionChannel.ERP7__Channel__c);
                    }
                }catch(ex){
                } 
            }
        });
        $A.enqueueAction(initaction);
    },
    
    savePOS : function(component, event, helper){
        component.set("v.qmsg",'');
        var poLIst = component.get("v.poli");
        
        component.set("v.PO.ERP7__Channel__c",component.get("v.channelId"));
        component.set("v.PO.ERP7__Distribution_Channel__c",component.get("v.distributionChannel.Id"));
        
        var flag = helper.validationCheck(component,event);
        var isErrors=helper.validationCheckQuantity(component, event, helper);
        var errorDisplay = helper.validationCheckName(component, event);
        // || component.get("v.distributionChannel.Id")!=undefined || component.get("v.distributionChannel.Id")!=''
        //|| component.get("v.distributionChannel.Id")!=' ' || isErrors!=true){
        if(errorDisplay && isErrors!=true && flag){//if(flag && isErrors!=true && errorDisplay){
            if(poLIst.length>0){
                
                var saveAction = component.get("c.save_PurchaseOrder");
                saveAction.setParams({"purchaseOrder":JSON.stringify(component.get("v.PO")),"POLI_List":JSON.stringify(poLIst)});
                saveAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.PH_Purchase_Order_Created_Successfully'));
                        if(component.get("v.navigateToRecord")){
                            var navEvt = $A.get("e.force:navigateToSObject");
                            if(navEvt != undefined){
                                navEvt.setParams({
                                    "isredirect": true,
                                    "recordId": response.getReturnValue().Id,
                                    "slideDevName": "detail",
                                    "orderId":component.get("v.orderId")
                                }); 
                                navEvt.fire();
                            }else {
                                location.reload();  
                            }
                        }else{
                            var params = event.getParam('arguments');
                            var callback;
                            if (params) {
                                callback = params.callback;
                            }
                            if (callback) callback(response.getReturnValue());
                        }
                    }
                    else{
                        var errors = response.getError();
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            //helper.showToast('Error!','error',errors[0].message);
                            component.set("v.exceptionError","Error! "+errors[0].message);
                        }
                    }
                });
                $A.enqueueAction(saveAction);
            }else{
                //helper.showToast('Error!','error','Please add a Line Item');
                component.set("v.exceptionError",$A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item'));
            }
        }
        else{
            //helper.showToast('Error!','error','Review All Errors');
            component.set("v.exceptionError",$A.get('$Label.c.PH_DebNote_Review_All_Errors'));
        }
    },
    
    goBackTask : function(component, event, helper) {
        
        $A.createComponent("c:AddMilestoneTask",{
            "aura:id" : "taskcomponent",
            "projectId" : component.get("v.projectId"),
            "taskId" : component.get("v.Mtask.Id"),
            "newTask" : component.get("v.Mtask"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
    },
    
    OrdItmDOInit : function(component,event){
        console.log('inside OrdItmDOInit');
        var orderId=component.get('v.orderId');
        var selectedordList = [];
        selectedordList.push(orderId);
        var action=component.get('c.populateOrdItems');
        action.setParams({
            "orderId1":selectedordList
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var msg = response.getReturnValue().ErrMessage;
                if(msg != null && msg != '' && msg != undefined){
                    component.set("v.exceptionError",msg);
                }
                else{
                    var pli = response.getReturnValue().wPOLIs;
                    var stocklst = response.getReturnValue().productStocks;
                    //for(var x in pli){
                    for(var x = 0; x < pli.length; x++){
                        //for(var y in stocklst){
                        for(var y = 0; y < stocklst.length; y++){
                            if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                pli[x].demand = stocklst[y].Demand;
                                pli[x].ItemsinStock = stocklst[y].Stock;
                            }
                        }
                    }
                    console.log('res of OrdItmDOInit:',response.getReturnValue());
                    component.set("v.poli",pli);
                }
                
            }else{
                var error1=response.getError();
                component.set('v.exceptionError',error1[0].message);
            }
            this.getExistingPR(component, event); 
        });
        $A.enqueueAction(action);
    },
    
    OrdItmsDOInit : function(component,event){
        console.log('inside OrdItmsDOInit');
        var selectedordList=component.get('v.SelectedcustomerOrders');
        
        var action=component.get('c.populateOrdItems');
        action.setParams({
            "orderId1":selectedordList
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var msg = response.getReturnValue().ErrMessage;
                if(msg != null && msg != '' && msg != undefined){
                    component.set("v.exceptionError",msg);
                }
                else{
                    var pli = response.getReturnValue().wPOLIs;
                    var stocklst = response.getReturnValue().productStocks;
                    //for(var x in pli){
                    for(var x = 0; x < pli.length; x++){
                        //for(var y in stocklst){
                        for(var y = 0; y < stocklst.length; y++){
                            if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                pli[x].demand = stocklst[y].Demand;
                                pli[x].ItemsinStock = stocklst[y].Stock;
                            }
                        }
                    }
                    console.log('res of OrdItmDOInit:',response.getReturnValue());
                    component.set("v.poli",pli);
                }
                
            }else{
                var error1=response.getError();
                component.set('v.exceptionError',error1[0].message);
            }
            this.getExistingPR(component, event); 
        });
        $A.enqueueAction(action);
    },
    
    getExistingPR : function(comp, event){ //$A.util.removeClass(comp.find("cnvrtLogBtnId"),'a_disabled');  
        var action=comp.get("c.getExistingPO"); 
        action.setParams({"SOId":comp.get("v.SOId"),
                          "OrderId":comp.get("v.orderId")});   
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (comp.isValid() && state === "SUCCESS") {
                comp.set("v.POExisting",response.getReturnValue());
                // this.getLLIDeleteSingle(comp, event, helper);
            }       
        });
        $A.enqueueAction(action);
        
    },
    
    getPLIfromshipment : function(component, event){ 
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//13
        component.set("v.showSpinner",true);
        
        var action=component.get("c.getpacklistdetails"); 
        action.setParams({"shipId":component.get("v.ShipmentId"),
                          "Packid":component.get("v.PackIds")});
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                console.log('response getpacklistdetails : ',response.getReturnValue());
                component.set("v.PO",response.getReturnValue().shipPO);
                component.set("v.channelId",response.getReturnValue().channelid);
                component.set("v.dChannelId",response.getReturnValue().DCid);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    gobackshipment : function(component,event,helper){
        
        $A.createComponent("c:InternalShipment",{
            "shipmentID":component.get("v.ShipmentId"),
            "packageIDS" : component.get("v.PackIds"),
            "showHeader":  false
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
        
        
    },
    
    queryRecentRecord : function(component, event){ 
        if(component.get("v.FieldToAssign")=='POV'){
            var action=component.get("c.getRecentRecord"); 
            action.setParams({"ObjectAPIName":component.get("v.ObjectAPIName")});
            action.setCallback(this,function(response){
                if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                    if(component.get("v.FieldToAssign")=='POV'){
                        component.set("v.PO.ERP7__Vendor__c",response.getReturnValue());
                        
                    }else if(component.get("v.FieldToAssign")=='POC'){
                        component.set("v.PO.ERP7__Vendor_Contact__c",response.getReturnValue()); 
                    }else if(component.get("v.FieldToAssign")=='POD'){
                        component.set("v.PO.ERP7__Delivery_Address__c",response.getReturnValue());
                        console.log('ERP7__Delivery_Address__c set here2~>',response.getReturnValue());
                    }
                }
            });
            $A.enqueueAction(action);
        }else if(component.get("v.FieldToAssign")=='POC'){
            var action=component.get("c.getRecentContact"); 
            action.setParams({"ObjectAPIName":component.get("v.ObjectAPIName")});
            action.setCallback(this,function(response){
                if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                    component.set("v.PO.ERP7__Vendor_Contact__c",response.getReturnValue().Id);
                    //component.set("v.PO.ERP7__Vendor__c", response.getReturnValue().AccountId);
                }
            });
            $A.enqueueAction(action);
        }else if(component.get("v.FieldToAssign")=='POD'){
            var action=component.get("c.getRecentDA"); 
            action.setParams({"ObjectAPIName":component.get("v.ObjectAPIName")});
            action.setCallback(this,function(response){
                if(response.getState() == "SUCCESS" && response.getReturnValue() != null){
                    component.set("v.PO.ERP7__Delivery_Address__c",response.getReturnValue().Id);
                    console.log('ERP7__Delivery_Address__c set here3~>',response.getReturnValue().Id);
                    component.set("v.isNewAddress",true);
                    //component.set("v.PO.ERP7__Vendor__c", response.getReturnValue().ERP7__Customer__c);
                    //component.set("v.PO.ERP7__Vendor_Contact__c",response.getReturnValue().ERP7__Contact__c);
                }
            });
            $A.enqueueAction(action);
        }
        component.set("v.QueryRecentRecord", false);
    },
    
    contactRT : function(component, event){ 
        var action=component.get("c.ContactRecordTypess"); 
        action.setParams({});
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                component.set("v.ConRecId",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    setVendorAddress : function(component, event, helper){
        console.log('setVendorAddress called');
        var action = component.get('c.getVendorAddress');
        action.setParams({ vendor : component.get("v.PO.ERP7__Vendor__c")});
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var res = response.getReturnValue();
                if(res != null){
                    component.set("v.PO.ERP7__Vendor_Address__c",res.Id);
                }
                else{
                    component.set("v.PO.ERP7__Vendor_Address__c",null); 
                }
                console.log('setVendorAddress ERP7__Vendor_Address__c sethere 1 : ',component.get("v.PO.ERP7__Vendor_Address__c"));
            }else{
                //button.set('v.disabled',false);
                console.log('Error setVendorAddress:',response.getError());
                component.set("v.exceptionError",response.getError());
            }
        });
        $A.enqueueAction(action); 
    },
    
    fetchEmployeeRequester : function(component, event, helper){
        var action = component.get('c.fetchEmployeeRequester');
        action.setParams({});
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var res = response.getReturnValue();
                if(res != null){
                    component.set("v.PO.ERP7__EmployeeRequester__c",res.Id);
                }
                
                
            }else{
                //button.set('v.disabled',false);
                console.log('Error fetchEmployeeRequester:',response.getError());
                component.set("v.exceptionError",response.getError());
            }
        });
        $A.enqueueAction(action); 
    },
    
    fetchShipmentType : function(component, event, helper){
        let poShipment = component.get("c.getShipmentType");
        poShipment.setCallback(this,function(response){
            let resList = response.getReturnValue();
            component.set("v.POShipmentoptions",resList);                
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//14 
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(poShipment);
    },
    getDependentPicklistsFamily : function(component, event, helper) {
        console.log('getDependentPicklistsFamily called');
        var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : component.get("v.Poructobj"),
            parentField : component.get("v.FamilycontrollingFieldAPI"),
            childField : component.get("v.SubFamilydependingFieldAPI")
        });
        
        action.setCallback(this, function(response){
            var status = response.getState();
            console.log('getDependentPicklistsFamily status : ',status);
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                console.log('getDependentPicklistsFamily pickListResponse : ',response.getReturnValue());
                //save response 
                component.set("v.FamilydepnedentFieldMap",pickListResponse.pickListMap);
                
                // create a empty array for store parent picklist values 
                var parentkeys = []; // for store all map keys 
                var parentField = []; // for store parent picklist value to set on lightning:select. 
                
                // Iterate over map and store the key
                for (var pickKey in pickListResponse.pickListMap) {
                    console.log('getDependentPicklistsFamily pickKey~>'+JSON.stringify(pickKey));
                    parentkeys.push(pickKey);
                }
                
                //set the parent field value for lightning:select
                /*if (parentkeys != undefined && parentkeys.length > 0) {
                    parentField.push('');
                }*/
                
                for (var i = 0; i < parentkeys.length; i++) {
                    parentField.push(parentkeys[i]);
                }  
                // set the parent picklist
                console.log('getDependentPicklist parentField~>'+JSON.stringify(parentField));
                console.log('getDependentPicklist pickListResponse.controllingValues~>'+JSON.stringify(pickListResponse.controllingValues));
                //component.set("v.listControllingValues", parentField);
                component.set("v.familylst", pickListResponse.controllingValues);
                console.log('familylst  : ',component.get("v.familylst"));       
                component.set("v.seachItemFmily", '');
                component.set("v.subItemFmily", '');
            }
            else{
                console.log('getDependentPicklist err : '+JSON.stringify(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
    },
    familyFieldChange : function(component, event, helper){
        try{
            console.log('familyFieldChange called');
            var controllerValue = component.get("v.seachItemFmily");//component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
            var pickListMap = component.get("v.FamilydepnedentFieldMap");
            console.log('controllerValue : '+controllerValue);
            console.log('pickListMap : '+JSON.stringify(pickListMap));
            if (controllerValue != '' && controllerValue != null && controllerValue != undefined) {
                //get child picklist value
                var childValues = pickListMap[controllerValue];
                var childValueList = [];
                if(childValues != undefined && childValues != null){
                    if(childValues.length > 0){
                        //childValueList.push('');
                        for (var i = 0; i < childValues.length; i++) {
                            childValueList.push(childValues[i]);
                        }
                    }
                }
                // set the child list
                console.log('childValueList~>'+JSON.stringify(childValueList));
                component.set("v.subfamilylst", childValueList);
                
                if(childValueList.length > 0){
                    component.set("v.bDisabledSubFamilyFld" , false);  
                }else{
                    component.set("v.bDisabledSubFamilyFld" , true); 
                }
            } else {
                var list = [];
                component.set("v.subfamilylst", list);
                component.set("v.bDisabledSubFamilyFld" , true);
            }
            
            /*  if(component.get("v.subfamilylst").length > 0){
                var listdependingValues = component.get("v.subfamilylst");
                component.set("v.subItemFmily",listdependingValues[0].value);
            }*/
            
            console.log('v.subItemFmily~>'+component.get("v.subItemFmily"));
        }catch(e){
            console.log('err parentFieldChange~>',e);
        }
    },
    
    getDependentPicklists : function(component, event, helper) {
        console.log('getDependentPicklists called');
        var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : component.get("v.objDetail"),
            parentField : component.get("v.controllingFieldAPI"),
            childField : component.get("v.dependingFieldAPI")
        });
        
        action.setCallback(this, function(response){
            var status = response.getState();
            console.log('getDependentPicklist status : ',status);
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                console.log('getDependentPicklist pickListResponse : ',response.getReturnValue());
                //save response 
                component.set("v.depnedentFieldMap",pickListResponse.pickListMap);
                
                // create a empty array for store parent picklist values 
                var parentkeys = []; // for store all map keys 
                var parentField = []; // for store parent picklist value to set on lightning:select. 
                
                // Iterate over map and store the key
                for (var pickKey in pickListResponse.pickListMap) {
                    console.log('getDependentPicklist pickKey~>'+JSON.stringify(pickKey));
                    parentkeys.push(pickKey);
                }
                
                //set the parent field value for lightning:select
                /*if (parentkeys != undefined && parentkeys.length > 0) {
                    parentField.push('');
                }*/
                
                for (var i = 0; i < parentkeys.length; i++) {
                    parentField.push(parentkeys[i]);
                }  
                // set the parent picklist
                console.log('getDependentPicklist parentField~>'+JSON.stringify(parentField));
                console.log('getDependentPicklist pickListResponse.controllingValues~>'+JSON.stringify(pickListResponse.controllingValues));
                //component.set("v.listControllingValues", parentField);
                component.set("v.listControllingValues", pickListResponse.controllingValues);
                console.log('getDependentPicklist listControllingValues : ',component.get("v.listControllingValues"));
                component.set("v.PO.ERP7__Shipment_Type__c", '');
                component.set("v.PO.ERP7__Shipment_Preference_Speed__c", '');
                
            }
            else{
                console.log('getDependentPicklist err : '+JSON.stringify(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
    },
    
    fetchcurrency : function(component, event, helper) {
        console.log('fetchcurrency called');
        try{
            var recordId = component.get("v.recordId");
            var purchaseOrderId = component.get("v.purchaseOrderId");
            var clonePOId = component.get("v.clonePOId");
            console.log('recordId~>'+recordId);
            console.log('purchaseOrderId~>'+purchaseOrderId);
            console.log('clonePOId~>'+clonePOId);
            var poId = '';
            if(!$A.util.isEmpty(recordId) && !$A.util.isUndefinedOrNull(recordId)){
                poId = recordId;
            }
            else if(!$A.util.isEmpty(purchaseOrderId) && !$A.util.isUndefinedOrNull(purchaseOrderId)){
                poId = purchaseOrderId;
            }
            // 26-Nov-23:Added by Parveez to retrieve the same currency from the source PO on the Clone PO page
            else if(!$A.util.isEmpty(clonePOId) && !$A.util.isUndefinedOrNull(clonePOId)){
                poId = clonePOId;
            }
            
            console.log('poId~>'+poId);
            
            var action=component.get("c.getCurrencies");
            action.setParams({'PoId' : poId,});
            action.setCallback(this,function(response){
                var status = response.getState();
                console.log('fetchcurrency status : ',status);
                if(status === "SUCCESS"){
                    console.log('fetchcurrency getCurrencies response ~>',JSON.stringify(response.getReturnValue()));
                    if(response.getReturnValue() != null){
                        component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                        component.set("v.currencyList",response.getReturnValue().currencyList);
                        if(response.getReturnValue().POIsocode != ''){
                            console.log('inhere set POIsocode');
                            component.set("v.POCurrencyIsoCode",response.getReturnValue().POIsocode);
                            component.set("v.PO.CurrencyIsoCode",response.getReturnValue().POIsocode);
                            console.log('v.PO.CurrencyIsoCode after setting~>'+component.get("v.PO.CurrencyIsoCode"));
                            console.log('v.POCurrencyIsoCode after setting~>'+component.get("v.POCurrencyIsoCode"));
                            
                            window.setTimeout( $A.getCallback(function() {
                                console.log('inhere timeout');
                                component.set("v.POCurrencyIsoCode",response.getReturnValue().POIsocode);
                                component.set("v.PO.CurrencyIsoCode",response.getReturnValue().POIsocode);
                                console.log('v.PO.CurrencyIsoCode after setting in timeout~>'+component.get("v.PO.CurrencyIsoCode"));
                                console.log('v.POCurrencyIsoCode after setting in timeout~>'+component.get("v.POCurrencyIsoCode"));
                            }),3000);
                        }
                    }
                }else{
                    var errors = response.getError();
                    console.log("server error in getCurrencies : ", JSON.stringify(errors));
                } 
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('err~>',e);
        }
    },
    
    fetchOrgCurrncy : function(component, event, helper) {
        console.log('fetchOrgCurrncy CurrencyIsoCode called');
        var action=component.get("c.getOrgCurrencies");
        action.setParams({'OrgId' : component.get("v.PO.ERP7__Organisation__c")});
        action.setCallback(this,function(response){
            console.log('getOrgCurrencies CurrencyIsoCode ~>'+response.getReturnValue());
            if(response.getReturnValue() != null){
                component.set("v.PO.CurrencyIsoCode",response.getReturnValue());
                component.set("v.POCurrencyIsoCode",response.getReturnValue());
            }
            
        });
        $A.enqueueAction(action);
    },
    
    AnalyticalAccountCheck : function(component, event, helper) {
        var poli = component.get("v.poli");
        var bool = false;
        //for(var x in poli){
        for(var x = 0; x < poli.length; x++){
            var TotalAmount = 0.00;
            if(poli[x].ERP7__Tax__c != null && poli[x].ERP7__Tax__c != undefined && poli[x].ERP7__Tax__c != '') TotalAmount = parseFloat(parseFloat(poli[x].ERP7__Total_Price__c) - parseFloat(poli[x].ERP7__Tax__c)).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            else TotalAmount = parseFloat(poli[x].ERP7__Total_Price__c).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            console.log('final 1 TotalAmount~>'+TotalAmount+' typeof ~>'+typeof TotalAmount);
            
            TotalAmount = parseFloat(TotalAmount).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            console.log('final 2 TotalAmount~>'+TotalAmount+' typeof ~>'+typeof TotalAmount);
            TotalAmount = parseFloat(TotalAmount).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            console.log('final 3 TotalAmount~>'+TotalAmount+' typeof ~>'+typeof TotalAmount);
            
            var acc = [];
            console.log('AnalyticalAccountCheck : ',JSON.stringify(poli[x]));
            acc = poli[x].Accounts;
            var accTotal = 0.00;
            if(acc != undefined && acc != null){
                if(acc.length > 0){
                    //for(var y in acc){
                    for(var y = 0; y < acc.length; y++){
                        if(acc[y].ERP7__Allocation_Amount__c != undefined && acc[y].ERP7__Allocation_Amount__c != null && acc[y].ERP7__Allocation_Amount__c != ''){
                            if(acc[y].ERP7__Allocation_Amount__c > 0) accTotal += ((parseFloat(parseFloat(poli[x].ERP7__Quantity__c) * parseFloat(poli[x].ERP7__Unit_Price__c) * acc[y].ERP7__Allocation_Percentage__c)/100)); 
                            //parseFloat(acc[y].ERP7__Allocation_Amount__c).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            console.log('accTotal~>'+accTotal+' typeof ~>'+typeof accTotal);
                        }
                    }
                    console.log('final 1 accTotal~>'+accTotal+' typeof ~>'+typeof accTotal);
                    accTotal = parseFloat(accTotal).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    console.log('final 2 accTotal~>'+accTotal+' typeof ~>'+typeof accTotal);
                    accTotal = parseFloat(accTotal).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    console.log('final 3 accTotal~>'+accTotal+' typeof ~>'+typeof accTotal);
                    
                    console.log(' item '+x+' and its TotalAmount~>'+TotalAmount+' and its accTotal~>'+accTotal);
                    if(accTotal > TotalAmount){
                        //this.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Alanytical Account amount is greater then line item amount for line item '+x);
                        return true;
                    }else if(TotalAmount > accTotal){
                        return true; 
                    }
                }
            }
        }
        return bool;
    },
    
    AnalyticalAccountCoaCheck : function(component, event, helper) {
        var poli = component.get("v.poli");
        var bool = false;
        //for(var x in poli){
        for(var x = 0; x < poli.length; x++){
            var acc = [];
            acc = poli[x].Accounts;
            if(acc != undefined && acc != null){
                if(acc.length > 0){
                    if(poli[x].ERP7__Chart_of_Account__c ==null || poli[x].ERP7__Chart_of_Account__c == undefined || poli[x].ERP7__Chart_of_Account__c == '') {
                        return true;
                    }
                    //for(var y in acc){
                    for(var y = 0; y < acc.length; y++){
                        if(acc[y].ERP7__Project__c == null || acc[y].ERP7__Project__c == undefined || acc[y].ERP7__Project__c == ''){
                            return true;
                        }
                    }
                }
            }
        }
        return bool;
    },
    
    AnalyticalAccountingAccountCheck : function(component, event, helper) {
        var poli = component.get("v.poli");
        var bool = true;
        //for(var x in poli){
        for(var x = 0; x < poli.length; x++){
            if(poli[x].ERP7__Total_Price__c!=null && poli[x].ERP7__Total_Price__c!=undefined && poli[x].ERP7__Total_Price__c>0){
                var acc = [];
                acc = poli[x].Accounts;
                console.log('acc',acc);
                if(acc != undefined && acc != null && acc.length > 0 && acc[0].ERP7__Project__c != null && acc[0].ERP7__Project__c != undefined && acc[0].ERP7__Project__c != ''){
                    continue;
                }else{
                    bool = false;
                    break;
                }
            }
        }
        return bool;
    },
    
    saveAA : function(component, event, helper) {
        var poli = component.get("v.poli");
        var acc = [];
        //for(var x in poli){
        for(var x = 0; x < poli.length; x++){
            var TotalAmount = 0.00;
            TotalAmount = poli[x].ERP7__Total_Price__c;
            console.log('poLIst : ',JSON.stringify(poli[x]));
            acc.push(poli[x].Accounts);
        }
        var action=component.get("c.saveAnalyticalAccounts");
        action.setParams({'AA':acc});
        action.setCallback(this,function(response){
            //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
            //component.set("v.currencyList",response.getReturnValue().currencyList);
        });
        $A.enqueueAction(action);
    },
    
    saveAtt : function(component,event,file,parentId){
        console.log('saveAtt called ');
        var reader = new FileReader();
        reader.onloadend = function() {
            var contents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
            var fileContents = contents.substring(dataStart);
            
            var action = component.get("c.uploadFile");
            
            action.setParams({
                parent: parentId,
                fileName: file.name,
                base64Data: encodeURIComponent(fileContents),
                contentType: file.type
            });
            action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS'){
                    console.log('response : ',response.getReturnValue());
                }else{
                    console.log('Error :',response.getError());
                }
            });
            $A.enqueueAction(action); 
        }
        reader.readAsDataURL(file);
        //}
    },
    
    
    creatAttachment : function(component,event,parentId){
        //alert('createAttachment called ');
        var filesDataToUpload = component.get("v.filesData2Upload");
        var action = component.get("c.createAttachment");
        
        action.setParams({
            filesData: JSON.stringify(filesDataToUpload),
            orderId : parentId
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                console.log('response : ',response.getReturnValue());
            }else{
                console.log('Error :',response.getError());
            }
        });
        $A.enqueueAction(action); 
    },
    
    getSearchProducts :function(component){
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//15
        component.set("v.showSpinner",true);
        component.set('v.listOfProducts',[]);
        //component.set('v.selectedListOfProducts', []);
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch helper: ',globalsearch);
        component.set('v.addProductsMsg','');
        var selectedProds = component.get('v.selectedListOfProducts');
        var action = component.get("c.getProducts");
        action.setParams({
            "venId":component.get('v.PO.ERP7__Vendor__c'),
            "searchString": component.get('v.searchItem'),
            "searchFamily": component.get('v.seachItemFmily'),
            "DCId": component.get('v.dChannelId'),
            "search" : globalsearch,
            "subFamily": component.get('v.subItemFmily'),
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('response getSearchProducts: ',JSON.stringify(response.getReturnValue()));
                console.log('setting listOfProducts here5');
                component.set('v.listOfProducts', response.getReturnValue().wrapList);
                
                
                //Added by Arshad 03 Aug 2023
                try{
                    var standProds = component.get('v.listOfProducts');
                    if(standProds != undefined){
                      //added the below code if condition on 18_01_24 shaguftha
                      var indexfound = false;
                        var bfrStandProdslength = standProds.length;
                        if(selectedProds != undefined && selectedProds.length > 0){
                            for(var i = 0; i < selectedProds.length; i++){
                                var index = standProds.findIndex(function(products) {
                                    console.log('products : ',JSON.stringify(products));
                                    return products.prod.Id === selectedProds[i].prod.Id;
                                });
                                console.log('index : ',index);
                                if (index !== -1) {
                                    indexfound = true;
                                    standProds.splice(index, 1);
                                }
                            }
                            
                        }
                        
                        for(var x = 0; x < standProds.length; x++){
                            if(standProds[x].selCostCardId != undefined && standProds[x].selCostCardId != null && standProds[x].selCostCardId != ''){
                                console.log('in here1 standProds[x].selCostCardId~>'+standProds[x].selCostCardId);
                                var res = standProds[x].selectedCostCard;
                                console.log('standProds[x].selectedCostCard res~>',res);
                                
                                standProds[x].unitPrice  = parseFloat(res.ERP7__Cost__c);
                                
                                if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                                
                                console.log('defaultTaxRate~>'+component.get("v.defaultTaxRate"));
                                if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(component.get("v.defaultTaxRate"));
                                
                                let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                                console.log('tax  bfr:  ',tax);
                                
                                tax = tax * standProds[x].quantity;
                                
                                standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                
                                if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                                console.log('unitPrice : ',standProds[x].unitPrice);
                                console.log('quantity : ',standProds[x].quantity);
                                console.log('taxAmount : ',standProds[x].taxAmount);
                                console.log('taxPercent : ',standProds[x].taxPercent);
                                
                                standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                                console.log('TotalPrice : ',standProds[x].TotalPrice);
                            }
                        }
                        console.log('setting listOfProducts here11');
                        component.set('v.listOfProducts',standProds);
                        
                        //new code Added by parveez on 24/05/24 for retaining selected products whilw searching for new product line 1696 to line 1706
                        var stdprods = component.get('v.listOfProducts');
                        
                        
                        if (selectedProds !== undefined && selectedProds.length > 0) {
                            for (var i = 0; i < selectedProds.length; i++) {
                                stdprods.push(selectedProds[i]);
                            }
                        } 
                        
                        component.set('v.listOfProducts', stdprods);
                        
                        if(indexfound == true && standProds.length == 0 && bfrStandProdslength == 1) component.set('v.addProductsMsg',$A.get("$Label.c.Product_is_selected"));
                        else if(standProds.length == 0) component.set('v.addProductsMsg',$A.get("$Label.c.No_products_available_to_view"));
                        else component.set('v.addProductsMsg',response.getReturnValue().Msg);
                    }
                    //for(var x in standProds){
                    
                }catch(e){
                    console.log('err~>',e);
                }
                
                
                component.set('v.globalProdSearch',response.getReturnValue().globalSearch);
                console.log('globalsearch helpers set: ',component.get('v.globalProdSearch'));
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//16
                component.set("v.showSpinner",false);
            }else{
                console.log('Error getSearchProducts:',response.getError());
                component.set("v.exceptionError",response.getError());
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//17
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getAttchedFiles : function(component,event,helper){
        try{
            var parentId;
            
            parentId = (!$A.util.isUndefined(component.get("v.recordId")) && !$A.util.isEmpty(component.get("v.recordId"))) ? component.get("v.recordId") : '';
            parentId = (!$A.util.isUndefined(component.get("v.clonePOId")) && !$A.util.isEmpty(component.get("v.clonePOId"))) ? component.get("v.clonePOId") : parentId;
            console.log('parentId:',parentId);
            console.log('recId:',component.get('v.recordId'));
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//18
            component.set("v.showSpinner",true);
            var action = component.get("c.getFiles");
            action.setParams({
                "recId":parentId
            });
            action.setCallback(this,function(response){
                console.log('Inside getAttchedFiles: ',response.getState());
                if(response.getState() === 'SUCCESS'){
                    if(response.getReturnValue() != null){
                        console.log('response getFiles: ',response.getReturnValue());
                        component.set('v.uploadedFile',JSON.parse(response.getReturnValue()));
                        console.log('uploadedFile getFiles: ',component.get('v.uploadedFile'));  
                    }
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide"); //19
                    component.set("v.showSpinner",false);
                }else{
                    console.log('Error getAttchedFiles:',response.getError());
                    component.set("v.exceptionError",response.getError());
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");//20
                    component.set("v.showSpinner",false);
                }
            });
            $A.enqueueAction(action);
        }
        catch(e){console.log('getAttchedFiles error:',e);}
    },
    
    /*
    fetchPOCurrncy : function(component, event, helper) {
        console.log('fetchPOCurrncy CurrencyIsoCode called');
        
        var recordId = component.get("v.recordId");
        var purchaseOrderId = component.get("v.purchaseOrderId");
        console.log('recordId~>'+recordId);
        console.log('purchaseOrderId~>'+purchaseOrderId);
        var poId = '';
        if(!$A.util.isEmpty(recordId) && !$A.util.isUndefinedOrNull(recordId)){
            poId = recordId;
        }else if(!$A.util.isEmpty(purchaseOrderId) && !$A.util.isUndefinedOrNull(purchaseOrderId)){
            poId = purchaseOrderId;
        }
        
        console.log('poId~>'+poId);
        
        if(poId != ''){
            var action=component.get("c.getPOCurrencies");
            action.setParams({
                "PoId" : poId,
            });
            action.setCallback(this,function(response){
                console.log('response.getState() state: ',response.getState());
                if(response.getState() === 'SUCCESS'){
                    console.log('response.getReturnValue() fetchPOCurrncy: CurrencyIsoCode~>',response.getReturnValue());
                    component.set("v.PO.CurrencyIsoCode",response.getReturnValue());
                }else{
                    var errors = response.getError();
                    console.log("server error in getPOCurrencies : ", JSON.stringify(errors));
                } 
            });
            
            $A.enqueueAction(action);
        }
    },
    */
    
    getRecTypePO : function(component){
        var action=component.get("c.getPORecordTypes");
        action.setCallback(this,function(response){
            console.log('response.getState() getPORecordTypes: ',response.getState());
            console.log('response.getReturnValue() getPORecordTypes: ',response.getReturnValue());
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue() != null){
                    console.log('response.getReturnValue() : ',JSON.stringify(response.getReturnValue()));
                    let data = response.getReturnValue();
                    function customSort(a, b) {
                        var order = {
                            "Standard Purchase Order": 1,
                            "Return to Vendor (RTV)": 2,
                            "Drop Ship purchase order": 3
                        };
                        
                        return order[a.label] - order[b.label];
                    }
                    
                    // Sort the array using the custom sorting function
                    data.sort(customSort);
                    
                    // Output the sorted array
                    console.log(data);
                    component.set("v.POType",data);
                    if((component.get("v.recordId") == null || component.get("v.recordId")  == undefined || component.get("v.recordId")  == '') && (component.get("v.clonePOId") == null || component.get("v.clonePOId")  == undefined || component.get("v.clonePOId")  == '')) {
                        component.set("v.showPOType",true);
                    }else component.set("v.showPOType",false);
                }
                else{
                    component.set("v.exceptionError",'No access to PO record Type');
                }
                
            }
            
        });
        $A.enqueueAction(action);
    },
    getProductDetails : function(component,helper){
    	var action = component.get("c.getProdDetails");
        action.setParams({"prodId" : component.get('v.prodRecordId'),DCId : component.get("v.distributionChannel.Id")});
        action.setCallback(this,function(response){
            console.log('response.getState() getProductDetails: ',response.getState());
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue() != null){
                    console.log('response : ',response.getReturnValue());
                    var standProds = response.getReturnValue();
                   let productsToAdd = [];
                    let poliadd = {};
                    poliadd.AwaitingStock = standProds.AwaitStock;
                    poliadd.demand = standProds.demand; 
                    poliadd.ItemsinStock = standProds.stock;
                    poliadd.ERP7__Product__c = standProds.prodId;
                    poliadd.ERP7__Product__r = { ProductCode : standProds.ProductCode };
                    poliadd.Name = standProds.prodName;
                    poliadd.ERP7__Cost_Card__c =  standProds.selCostCardId; 
                    poliadd.ERP7__Quantity__c = component.get('v.PoQty');
                    poliadd.ERP7__Vendor_product_Name__c = standProds.VendorPartNumber;
                    poliadd.ERP7__Unit_Price__c = standProds.cost;
                    poliadd.ERP7__Tax_Rate__c = 0;
                    poliadd.ERP7__Tax__c = 0;
                    poliadd.ERP7__Total_Price__c = 0;
                    poliadd.ERP7__Description__c = standProds.description;
                    poliadd.ERP7__Lead_Time_Days__c = standProds.LeadTime; 
                    productsToAdd.push(poliadd);
                    component.set('v.poli',productsToAdd);
                    component.set('v.PO.ERP7__Vendor__c',standProds.venId);
                    if(standProds.errMsg != null && standProds.errMsg != '' && standProds.errMsg != undefined){
                       helper.showToast('warning','warning',standProds.errMsg);
                   }	 
                }
            }
        });
        $A.enqueueAction(action);
    },
    saveAttachments: function (component, filesDataToUpload, parentId) {
        console.log('filesDataToUpload helper called: ',filesDataToUpload);
        var action = component.get("c.saveAttachmentsApex");
        var attachments = [];

        // Prepare the attachment data to be sent to Apex
        for (var i = 0; i < filesDataToUpload.length; i++) {
            attachments.push({
                "fileName": filesDataToUpload[i].fileName,
                "base64Data": filesDataToUpload[i].base64Data,
                "contentType": filesDataToUpload[i].type,
                "parentId": parentId
            });
        }

        action.setParams({
            "attachments": JSON.stringify(attachments)
        });

        // Callback after Apex execution
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('Success', 'success', 'Attachments uploaded successfully.');
            } else {
                var errors = response.getError();
                this.showToast('Error', 'error', errors[0].message);
            }
        });

        $A.enqueueAction(action);
    },
    
    
    
    // This pard is added  by Saqlain khan here to handle PO creation for the products from OCR funtionality 
    
      handleBillPayload : function(component, billPayload) {
            console.log("✅ Vendor Info => ", JSON.stringify(billPayload.vendorInfo));
            console.log("✅ Products => ", JSON.stringify(billPayload.products));
        
            var vendorInfo = billPayload.vendorInfo || {};
        
            component.set("v.PO.ERP7__Vendor__c", vendorInfo.vendor || '');
            component.set("v.PO.ERP7__Vendor_Contact__c", vendorInfo.vendorContact || '');
            component.set("v.PO.ERP7__Vendor_Address__c", vendorInfo.vendorAddress || '');
            component.set("v.PO.ERP7__Description__c", vendorInfo.description || ''); 
        
            console.log("✅ Vendor details set from billPayload:", vendorInfo);
        
            var poliList = [];
            var products = billPayload.products || [];
          
        products.forEach(function(prod) {
            poliList.push({
                sObjectType: 'ERP7__Purchase_Line_Items__c',
                Name: prod.productId ? '' : prod.productName,  
                ERP7__Product__c: prod.productId || null,       
                ERP7__Quantity__c: prod.quantity || 0,
                ERP7__Unit_Price__c: prod.unitPrice || 0,
                ItemsinStock: 0.0,
                demand: 0.0,
                AwaitingStock: 0.0,
                Accounts: [],
                Category: '',
                AccAccount: '',
                CustomProd: !prod.productId  
            });
        });
        
            component.set("v.poli", poliList);
            console.log(" Final PO Line Items (poli):", JSON.stringify(poliList));
        },
    
})