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
        }else{
            sforce.one.showToast({
                "title": title,
                "message": message,
                "type": type
            });
        }
        
    },


    // Newly added on 14-11-2025 for the doc deletion by saqlain khan
     SaveButtonForManageBillDoc: function(component, event) {
        var parentId = component.get('v.recordId');  
        var queue = (component.get('v.deletedFiles') || []).slice();  

        if (!queue.length) {
            console.log('[SaveButtonForManageBillDoc] nothing to delete');
            return;
        }

        console.log('[SaveButtonForManageBillDoc] deleting:', JSON.stringify(queue));

        var processNext = function() {
            if (!queue.length) {
                component.set('v.deletedFiles', []); 
                console.log('[SaveButtonForManageBillDoc] delete complete');
                return;
            }

            var idToDelete = queue.shift();
            var action = component.get('c.DeleteAttachment'); 
            action.setParams({
                attachId: idToDelete,
                parentId: parentId || ''
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    console.log('[SaveButtonForManageBillDoc] deleted on server:', idToDelete);
                } else {
                    console.error('[SaveButtonForManageBillDoc] failed for', idToDelete, response.getError && response.getError());
                }
                processNext();
            });

            $A.enqueueAction(action);
        };

        processNext();
    },


    resetFileStateSafe: function(component) {
    console.log('🧹 resetFileStateSafe called');
    try {
        component.set("v.showDelete", false);
        var isReadBillChecked = component.get("v.isActive");//added by asra 14/10
        if (isReadBillChecked) {//added by asra 14/10
            var billItems = component.get("v.billItems") || [];
            billItems.splice(0, billItems.length);
            component.set("v.billItems", billItems);
            console.log('✔ Bill items cleared');
        }//added by asra 14/10
        else{//added by asra 14/10
            console.log('⚠ Bill items not cleared because isReadBillChecked is false');//added by asra 14/10
        }//added by asra 14/10

        component.set("v.FileList", []);
        component.set("v.fillList", []);
        console.log('✔ FileList & fillList cleared');

        // let fileInput = component.find("fileId");
        // if (fileInput) {
        //     fileInput.getElement().value = "";
        //     console.log('✔ File input reset');
        // } else {
        //     console.warn('⚠ fileInput not found in DOM');
        // }
    } catch (err) {
        console.error('❌ Error in resetFileStateSafe:', err);
    }
},

    
    /*getAttachment : function (component, event) {
        var action=component.get("c.uploadFile");
        action.setParams({
            "pid" : component.get("v.Bill.ERP7__Purchase_Order__c")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            alert('state'+state);
            if( state === "SUCCESS" ){
                 component.set("v.Attach",response.getReturnValue());
               
            }
        });
        $A.enqueueAction(action);
    },*/
    
    /*FieldAccess:function (component, event) {
       var action=component.get("c.FieldAccessibility");
       action.setCallback(this,function(response){
        component.set('v.FieldAccess',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },*/
    
    FieldAccess:function (component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action=component.get("c.CreateBillCheckFLS");
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                console.log('CreateBillFLSCheck~>'+response.getReturnValue());
                component.set('v.CreateBillFLSCheck',response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("errors -> ", errors);
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    getPOLIDimeListhelper : function (component, event, helper) {
        try{
            component.set("v.showMmainSpin",true);
            console.log('getPOLIDimeListhelper called');
            var action = component.get("c.getPOLIDimeList");
            action.setParams({
                "POId": component.get("v.Bill.ERP7__Purchase_Order__c"),
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    component.set("v.showMmainSpin",false);
                    console.log("getPOLIDimeListhelper resp: ", JSON.stringify(response.getReturnValue()));
                    var dimeList = response.getReturnValue();
                    var pli = component.get("v.billItems");
                    console.log('getPOLIDimeListhelper pli~>'+JSON.stringify(pli));
                    
                    var poliAcc = []; var poliAccCat = ''; var poliAccCOA = '';
                    try{
                        for(var x = 0; x < pli.length; x++){//var x in pli){
                            console.log('pli[x]'+JSON.stringify(pli[x]));
                            if (typeof pli[x] !== 'object' || pli[x] === null) {
                                console.warn('Skipping non-object item in pli at index', x, pli[x]);
                                continue;
                            }
                            poliAcc = []; poliAccCat = ''; poliAccCOA = '';
                            if(dimeList != undefined && dimeList != null && dimeList.length > 0){
                                for(var y in dimeList){
                                    console.log('inhere dimeList loop');
                                    if(pli[x].ERP7__Purchase_Order_Line_Items__c != undefined && pli[x].ERP7__Purchase_Order_Line_Items__c != null && pli[x].ERP7__Purchase_Order_Line_Items__c != ''){
                                        if(pli[x].ERP7__Purchase_Order_Line_Items__c == dimeList[y].ERP7__Purchase_Line_Items__c){
                                            console.log('value matched');
                                            poliAcc.push(dimeList[y]);
                                            //Changed Shaguftha 24/10/23 from dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c && dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c to dimeList[y].ERP7__Account_Category__c and dimeList[y].ERP7__Chart_of_Account__c respectively
                                            if(dimeList[y].ERP7__Account_Category__c != undefined && dimeList[y].ERP7__Account_Category__c != null && dimeList[y].ERP7__Account_Category__c != ''){
                                                poliAccCat =dimeList[y].ERP7__Account_Category__c; //dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c;
                                            }
                                            if(dimeList[y].ERP7__Chart_of_Account__c != undefined && dimeList[y].ERP7__Chart_of_Account__c != null && dimeList[y].ERP7__Chart_of_Account__c != ''){
                                                poliAccCOA = dimeList[y].ERP7__Chart_of_Account__c; //dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c;
                                            }
                                        }
                                    }
                                }
                            }
                            if(poliAccCat != '') pli[x].ERP7__Account_Category__c = poliAccCat;
                            console.log('getPOLIDimeListhelper pli[x].ERP7__Account_Category__c set : ',poliAccCat);
                            if(poliAccCOA != '') pli[x].ERP7__Chart_Of_Account__c = poliAccCOA;
                            console.log('getPOLIDimeListhelper pli[x].ERP7__Chart_Of_Account__c set : ',poliAccCOA);
                            if (typeof pli[x] === 'object' && pli[x] !== null && Array.isArray(poliAcc) && poliAcc.length > 0)pli[x].Accounts = poliAcc;
                            console.log('getPOLIDimeListhelper pli[x].Accounts set');
                        }
                    }catch(e){
                        console.log('getPOLIDimeListhelper err heree1~>',e);
                        try {
                            console.log('Error message:', e.message);
                            console.log('Error stack:', e.stack);
                        } catch(innerErr) {
                            console.log('Could not read error details due to Locker:', innerErr);
                        }
                        component.set("v.showMmainSpin",false);
                    }
                    console.log('getPOLIDimeListhelper setting here billItems pli~>',JSON.stringify(pli));
                    //component.set("v.billItems",[]);
                    component.set("v.billItems",pli);
                    component.set("v.showMmainSpin",false);
                }else{
                    var errors = response.getError();
                    console.log("server error in getPOLIDimeListhelper : ", JSON.stringify(errors));
                    component.set("v.showMmainSpin",false);
                } 
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('getPOLIDimeListhelper err heree~>',e);
            component.set("v.showMmainSpin",false);
        }
    },
    
    getPOLIDimeListMultihelper : function (component, event, helper) {
        try{
            component.set("v.showMmainSpin",true);
            console.log('getPOLIDimeListhelper called');
            var action = component.get("c.getPOLIDimeMultiList");
            action.setParams({
                "POIds": component.get("v.POIdsList"),
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    component.set("v.showMmainSpin",false);
                    console.log("getPOLIDimeListhelper resp: ", JSON.stringify(response.getReturnValue()));
                    var dimeList = response.getReturnValue();
                    var pli = component.get("v.billItems");
                    var poliAcc = []; var poliAccCat = ''; var poliAccCOA = '';
                    for(var x in pli){
                        poliAcc = []; poliAccCat = ''; poliAccCOA = '';
                        for(var y in dimeList){
                            if(pli[x].ERP7__Purchase_Order_Line_Items__c != undefined && pli[x].ERP7__Purchase_Order_Line_Items__c != null && pli[x].ERP7__Purchase_Order_Line_Items__c != ''){
                                if(pli[x].ERP7__Purchase_Order_Line_Items__c == dimeList[y].ERP7__Purchase_Line_Items__c){
                                    poliAcc.push(dimeList[y]);
                                    if(dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c != undefined && dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c != null && dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c != ''){
                                        poliAccCat = dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c;
                                    }
                                    if(dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c != undefined && dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c != null && dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c != ''){
                                        poliAccCOA = dimeList[y].ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c;
                                    }
                                }
                            }
                        }
                        if(poliAccCat != '') pli[x].ERP7__Account_Category__c = poliAccCat;
                        if(poliAccCOA != '') pli[x].ERP7__Chart_Of_Account__c = poliAccCOA;
                        pli[x].Accounts = poliAcc;
                    }
                    console.log('setting here billItems');
                    console.log(pli);
                    //component.set("v.billItems",[]);
                    component.set("v.billItems",pli);
                    component.set("v.showMmainSpin",false);
                }else{
                    var errors = response.getError();
                    console.log("server error in doInit : ", JSON.stringify(errors));
                    component.set("v.showMmainSpin",false);
                } 
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('err heree~>',e);
            component.set("v.showMmainSpin",false);
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
    
    validation_Check : function (component, event) {
        // component.NOerrors = true;
        var billName = component.find("billName");
        if(!$A.util.isUndefined(billName)) 
            this.checkValidationField(component,billName);
        var vendorAcc = component.find("vendorAccount");
        if(!$A.util.isUndefined(vendorAcc))
            this.checkvalidationLookup(component,vendorAcc);
        var billList = component.find("bill_Items");
        if(!$A.util.isUndefined(billList))
            if(billList.length>0){
                var flag = true;
                for(var x  in billList)
                    flag = billList[x].callValidate(); 
                if(!flag && component.NOerrors) component.NOerrors = false;
            }else{
                component.NOerrors = billList.callValidate(); 
            }       
    },
    
    checkValidationField : function(component,cmp){
        if($A.util.isEmpty(cmp.get("v.value"))){
            cmp.set("v.class","slds-input hasError");
            component.NOerrors = false;
        }else
            cmp.set("v.class","slds-input");   
    },
   
    checkvalidationLookup : function(component,lkpField){
        if($A.util.isEmpty(lkpField.get("v.selectedRecordId"))){
            lkpField.set("v.inputStyleclass","hasError");
            component.NOerrors = false;
        }else
            lkpField.set("v.inputStyleclass","");    
    },
    
    calculateAdvBill: function(cmp,event){
        
        cmp.set('v.advPayment',0.00);
        var action=cmp.get("c.fetchAdvBill");
        action.setParams({
            POId:cmp.get("v.Bill.ERP7__Purchase_Order__c"),
            venId:cmp.get('v.Bill.ERP7__Vendor__c')
        });
        action.setCallback(this, function(response){
            if(response.getState() =='SUCCESS'){
                var res=response.getReturnValue();
                cmp.set('v.advBillList',res);
                if(res.length > 0){
                    const resCont=JSON.parse(JSON.stringify(res));
                    var advPay=0;
                    for(var i in resCont){
                        if(resCont[i].ERP7__Status__c='Paid' && resCont[i].ERP7__Amount_Paid__c > 0){
                            advPay+=resCont[i].ERP7__Amount_Paid__c;
                        }
                    }
                    cmp.set('v.advPayment',advPay);
                }
            }else{
                console.log('ERROR:',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    /*saveAtt : function(component,event,file,parentId){
        try{
            
            var getchunk,filename,fileType, fileContents ;
            var objFileReader = new FileReader();
            // set onload function of FileReader object   
            objFileReader.onload = $A.getCallback(function() {
                fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
                fileContents = fileContents.substring(dataStart);
                var startPosition = 0;
                var endPosition = Math.min(fileContents.length, startPosition + 750000);
                getchunk = fileContents.substring(startPosition, endPosition);
                
                var saveAction = component.get("c.save_attachment");
                
                saveAction.setParams({
                    "parentId": parentId,
                    "FileName": file.name, 
                    "FileType" :file.type,
                    "Base64":fileContents.substring(startPosition, endPosition)
                });
                saveAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                    }else{
                    }
                });
                $A.enqueueAction(saveAction);
            });
            objFileReader.readAsDataURL(file);
        }catch(err){
        }        
    },*/
    
    /*AnalyticalAccountCheck : function(component, event, helper) {
        var poli = component.get("v.billItems");
        var arshbool = false;
        for(var x in poli){
            var TotalAmount = 0.00;
            TotalAmount = parseFloat(poli[x].ERP7__Total_Amount__c); //.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            console.log('TotalAmount~>'+TotalAmount+' typeof ~>'+typeof TotalAmount);
            //if(poli[x].ERP7__Tax_Amount__c != null && poli[x].ERP7__Tax_Amount__c != undefined && poli[x].ERP7__Tax_Amount__c != '') TotalAmount = parseFloat(poli[x].ERP7__Total_Amount__c - poli[x].ERP7__Tax_Amount__c);
            //else TotalAmount = poli[x].ERP7__Total_Amount__c;
            var acc = [];
            console.log('AnalyticalAccountCheck : ',JSON.stringify(poli[x]));
            acc = poli[x].Accounts;
            var accTotal = 0.00;
            if(acc != undefined && acc != null){
                if(acc.length > 0){
                    for(var y in acc){
                        if(acc[y].ERP7__Allocation_Amount__c != undefined && acc[y].ERP7__Allocation_Amount__c != null && acc[y].ERP7__Allocation_Amount__c != ''){
                            if(acc[y].ERP7__Allocation_Amount__c > 0) accTotal += parseFloat(acc[y].ERP7__Allocation_Amount__c);
                            console.log('accTotal~>'+accTotal+' typeof ~>'+typeof accTotal);
                        }
                    }
                    console.log('final 1 accTotal~>'+accTotal+' typeof ~>'+typeof accTotal);
                    accTotal = parseFloat(accTotal).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    console.log('final 2 accTotal~>'+accTotal+' typeof ~>'+typeof accTotal);
                    accTotal = parseFloat(accTotal);
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
        return arshbool;
    },*/
    
    AnalyticalAccountCheck : function(component, event, helper) {
        var poli = component.get("v.billItems");
        var bool = false;
        //for(var x in poli){
        for(var x = 0; x < poli.length; x++){//Moin added this on 09th september
            var TotalAmount = 0.00;
            TotalAmount = parseFloat(poli[x].ERP7__Total_Amount__c).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
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
                    for(var y in acc){
                        if(acc[y].ERP7__Allocation_Amount__c != undefined && acc[y].ERP7__Allocation_Amount__c != null && acc[y].ERP7__Allocation_Amount__c != ''){
                            if(acc[y].ERP7__Allocation_Amount__c > 0) accTotal += ((parseFloat(parseFloat(poli[x].ERP7__Quantity__c) * parseFloat(poli[x].ERP7__Amount__c) * acc[y].ERP7__Allocation_Percentage__c)/100)); 
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
        var poli = component.get("v.billItems");
        var arshbool = false;
        for(var x in poli){
            var acc = [];
            acc = poli[x].Accounts;
            if(acc != undefined && acc != null){
                if(acc.length > 0){
                    if(poli[x].ERP7__Chart_Of_Account__c == null || poli[x].ERP7__Chart_Of_Account__c == undefined || poli[x].ERP7__Chart_Of_Account__c == '') {
                        return true;
                    }
                    for(var y in acc){
                        if(acc[y].ERP7__Project__c == null || acc[y].ERP7__Project__c == undefined || acc[y].ERP7__Project__c == ''){
                            return true;
                        }
                    }
                }
            }
        }
        return arshbool;
    },
    
    fetchcurrency : function(component, event, helper) {
        var action=component.get("c.getCurrencies");
        action.setParams({});
        action.setCallback(this,function(response){
            component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
            component.set("v.currencyList",response.getReturnValue().currencyList);
        });
        $A.enqueueAction(action);
    },
    
    fetchPOCurrncy : function(component, event, helper) {
        var action=component.get("c.getPOCurrencies");
        action.setParams({
            "PoId" : component.get("v.Bill.ERP7__Purchase_Order__c")
        });
        action.setCallback(this,function(response){
            component.set("v.Bill.CurrencyIsoCode",response.getReturnValue());
            
        });
        $A.enqueueAction(action);
    },
    
    fetchOrgCurrncy : function(component, event, helper) {
        var action=component.get("c.getOrgCurrencies");
        action.setParams({'OrgId' : component.get("v.Bill.ERP7__Organisation__c")});
        action.setCallback(this,function(response){
            if(response.getReturnValue() != null) component.set("v.Bill.CurrencyIsoCode",response.getReturnValue());
            
        });
        $A.enqueueAction(action);
    },
    
    getBillDetails : function(component, event, helper) {
        console.log('getBillDetails called');
        
        var action=component.get("c.getBillDetailAndItems");
        action.setParams({'recId' : component.get("v.recordId")});
        action.setCallback(this,function(response){
            console.log('response.getState() getBillDetailAndItems : ',response.getState());
            if(response.getState() === 'SUCCESS'){
                console.log('response.getReturnValue() getBillDetailAndItems : ',response.getReturnValue());
                if(response.getReturnValue() != null) {
                    var result =response.getReturnValue();
                    if(result.eror != undefined && result.eror != null && result.eror != ''){
                        helper.showToast('Error','error',result.eror);
                    }
                    else{
                        component.set("v.Bill",result.bill);
                        component.set("v.ShowBillType",false);
                        component.set("v.showPage",true);
                        component.set('v.setRT',component.get("v.Bill.RecordType.Name"));
                        console.log('getBillDetails v.clone~>'+component.get("v.clone"));
                        
                        if(!component.get("v.clone")){
                            component.set('v.uploadedFile',result.attachments); //Moin added this on 14th August 2023 if(!component.get("v.clone"))
                        	console.log('inhere');
                        }
                        
                        var billItems = result.billItems;
                        var dimensions = result.dimens;
                        var poliAcc = [];
                        if(billItems != null && billItems != undefined){
                            console.log('1');
                            if(dimensions != null && dimensions != undefined){
                                console.log('2');
                                for(var x in billItems){
                                    console.log('3');
                                    poliAcc = [];
                                    for(var y in dimensions){
                                        console.log('4');
                                        if(billItems[x].Id == dimensions[y].ERP7__Bill_Line_Item__c)  {
                                            console.log('5');
                                            poliAcc.push(dimensions[y]);
                                        } 
                                    }
                                    console.log('poliAcc : ',JSON.stringify(poliAcc));
                                    billItems[x].Accounts = poliAcc;
                                    
                                }
                            }
                        }
                        component.set("v.billItems",billItems); 
                        
                    }
                    
                }
            }else{
                console.log('Error getBillDetailAndItems:',response.getError());
            }
            
            
        });
        $A.enqueueAction(action);
    },
    
    saveAtt : function(component,event,file,parentId){
        try{
            
            console.log('saveAtt called ');
            //var files = cmp.get("v.FileList");  
            //var file = files[0][0];
            //var filek = JSON.stringify(file);
            //var parentId = event.getSource().get("v.name");
            //if (files && files.length > 0) {
            var reader = new FileReader();
            console.log('saveAtt 1');
            reader.onloadend = function() {
                var contents = reader.result;
                var base64Mark = 'base64,';
                var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                var fileContents = contents.substring(dataStart);
                
                
                var action = component.get("c.uploadFile");
                console.log('saveAtt 2');
                action.setParams({
                    parent: parentId,
                    fileName: file.name,
                    base64Data: encodeURIComponent(fileContents),
                    contentType: file.type,
                    SyncSales: component.get("v.SyncSalesforce"),
                    SyncGDrive: component.get("v.SyncGDrive")
                });
                console.log('saveAtt 3');
                action.setCallback(this, function(response) {
                    console.log('response.getState() saveAtt: ',response.getState());
                    if(response.getState() === 'SUCCESS'){
                        console.log('saveAtt 4 : ',response.getReturnValue());
                    }else{
                        console.log('Error :',response.getError());
                    }
                });
                $A.enqueueAction(action); 
            }
            reader.readAsDataURL(file);
        }
        catch(e){
            console.log('catch Error :',e);
        }
        //}
    },
    
    //Moin added this 13th june 2023 SyncSales : true, SyncGDrive : false as the syntax was changed
    /*saveCloneAtt : function(component,event,file,parentId){
        try{ 
            console.log('saveCloneAtt called parentId~>'+parentId);
            
            var getchunk,filename,fileType, fileContents ;
            var objFileReader = new FileReader();
            // set onload function of FileReader object   
            objFileReader.onload = $A.getCallback(function() {
                fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
                fileContents = fileContents.substring(dataStart);
                var startPosition = 0;
                var endPosition = Math.min(fileContents.length, startPosition + 750000);
                getchunk = fileContents.substring(startPosition, endPosition);
                
                var saveAction = component.get("c.save_attachment");
                
                saveAction.setParams({
                    "parentId": parentId,
                    "FileName": file.name, 
                    "FileType" :file.type,
                    "Base64":fileContents.substring(startPosition, endPosition)
                });
                saveAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        console.log('inhere success saveCloneAtt');
                    }else{
                        var errors = response.getError();
                        console.log("server error in saveCloneAtt : ", JSON.stringify(errors));
                    }
                });
                $A.enqueueAction(saveAction);
                
                setTimeout($A.getCallback(function () {
                    console.log('setTimeout'); 
                }), 1000);   //dont remove setTimeout - for loading issue fix for upload files - Arshad
                
            });
            
            objFileReader.onerror = $A.getCallback(function() {
                console.log('objFileReader err~>'+reader.error);
            });
            
            objFileReader.readAsDataURL(file);
        }catch(err){
        } 
    },*/
    //Moin changed this method by commenting above one
    saveCloneAtt: function(component, event, file, parentId) {
        try {
            console.log('saveCloneAtt called parentId~>' + parentId);

            var objFileReader = new FileReader();

            // Set onload function of FileReader object
            objFileReader.onload = $A.getCallback(function () {
                var fileContents = objFileReader.result.split(',')[1]; // Remove 'base64,' from the result

                var saveAction = component.get("c.save_attachment");

                saveAction.setParams({
                    "parentId": parentId,
                    "FileName": file.name,
                    "FileType": file.type,
                    "Base64": fileContents
                });

                saveAction.setCallback(this, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        console.log('in here success saveCloneAtt');
                    } else {
                        var errors = response.getError();
                        console.error("Server error in saveCloneAtt: ", JSON.stringify(errors));
                    }
                });

                $A.enqueueAction(saveAction);
            });

            objFileReader.onerror = $A.getCallback(function () {
                console.error('objFileReader error~>', objFileReader.error);
            });

            // Read the file as Data URL
            objFileReader.readAsDataURL(file);
        } catch (err) {
            console.error("Error in saveCloneAtt: ", err);
        }
    },

    createBill_PO_Lightning_button : function(component,event,helper){         
        var fetchpoliAction = component.get("c.fetch_Polis_bill");
        fetchpoliAction.setParams({"Id":component.get('v.Bill.ERP7__Purchase_Order__c'),BillId:component.get('v.recordId')});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    var poliList = JSON.parse(resultList[1]);
                    if(!$A.util.isEmpty(poliList)){
                        return false;
                    }else{
                        return true;
                    }
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
    },
    
    /*AnalyticalAccountingAccountCheck : function(component, event, helper) {
        var poli = component.get("v.billItems");
        var arshbool = true;
        for(var x in poli){
            var acc = [];
            acc = poli[x].Accounts;
            console.log('acc',acc);
            if(acc != undefined && acc != null && acc!=''){
                continue;
            }else{
                arshbool=false;
                break;
            }
        }
        return arshbool;
    },*/
    AnalyticalAccountingAccountCheck : function(component, event, helper) {
        var poli = component.get("v.billItems");
        
        for (var x = 0; x < poli.length; x++) {
            var item = poli[x];
            console.log('item'+JSON.stringify(item));
            // Check if valid object
            if (typeof item !== 'object' || item === null) {
                console.warn('Invalid item in billItems at index', x, item);
                continue; // or return false;
            }
            
            // Check if Accounts is a non-empty array
            if (!Array.isArray(item.Accounts) || item.Accounts.length === 0 ||  !item.Accounts[0].ERP7__Project__c) {
                console.warn('Missing or empty Accounts in item at index', x, item);
                return false;
            }
        }
        
        return true;
    },
    
    
    // the OCR part code by saqlain khan
    
  
        
    //      processFile: function(file, component, helper) {
    //     if (file.type === 'application/pdf') {
    //         helper.processPDF(file, component, helper);
    //     } else if (file.type.startsWith('image/')) {
    //          helper.processImage(file, component, helper);
    //          alert('Please select a PDF file for processing.');
    //     } else {
    //         alert('Please select a PDF or image file.');
    //     }
    // },
         
        
  
    //    processPDF: function (file, component, helper) {
    // var reader = new FileReader();
    // reader.onload = function () {
    //     var typedArray = new Uint8Array(reader.result);
    //     pdfjsLib.getDocument(typedArray).promise.then(pdf => {
    //         var textPromises = [];
    //         for (let i = 1; i <= pdf.numPages; i++) {
    //             textPromises.push(
    //                 pdf.getPage(i).then(page =>
    //                     page.getTextContent().then(textContent => {
    //                         return textContent.items.map(item => ({
    //                             text: item.str,
    //                             x: item.transform[4], // x-coordinate
    //                             y: item.transform[5]  // y-coordinate
    //                         }));
    //                     })
    //                 )
    //             );
    //         }
    //         return Promise.all(textPromises);
    //     }).then(pagesText => {
    //         let extractedText = '';
    //         let lastY = null;
    //         let lastX = null;

    //         pagesText.forEach(page => {
    //             page.forEach(item => {
    //                 // Check for new line based on vertical position
    //                 if (lastY !== null && Math.abs(item.y - lastY) > 10) { // Adjust "10" as needed
    //                     extractedText += '\n';
    //                     lastX = null; // Reset horizontal tracking for new lines
    //                 }

    //                 // Add extra spaces based on horizontal distance
    //                 if (lastX !== null) {
    //                     let spaceThreshold = 20; // Adjust "20" as needed
    //                     let spaceCount = Math.floor((item.x - lastX) / spaceThreshold);
    //                     if (spaceCount > 1) {
    //                         extractedText += ' '.repeat(spaceCount); // Add multiple spaces
    //                     } else {
    //                         extractedText += ' '; // Normal single space
    //                     }
    //                 }

    //                 extractedText += item.text;
    //                 lastY = item.y;
    //                 lastX = item.x;
    //             });
    //             extractedText += '\n'; // Add a new line at the end of each page
    //         });

    //           // Set extracted text to the component
    //         component.set("v.extractedText", extractedText);
    //         const setRT = component.get("v.setRT");
    //         const isactive = component.get("v.isActive");
    //         const isactiveExp = component.get("v.isActiveExp");
            
    //             // Send the extracted text to the Apex method to process the line items
    //         if(setRT == 'PO Bill' && isactive){
    //             console.log("extractedText for bill:", extractedText);
    //             helper.callGeminiAPI(component, extractedText);

    //         }
    //         else if(setRT == 'Expense Bill' && isactiveExp){
    //             console.log("extractedText for Expense bill:", extractedText);
    //             helper.callGeminiAPIExpense(component, extractedText);
    //         }
    //         else{
    //             alert("⚠️ OCR is not active for this Bill type. Please contact your administrator.");
    //         }


    //         // console.log("Navigating to Bills tab");
    //         //     helper.callGeminiAPI(component, extractedText);
    //         }).catch(error => {
    //             console.error("Error reading PDF:", JSON.stringify(error, Object.getOwnPropertyNames(error)));
    //              alert("⚠️ Error reading PDF via OCR. Please try again later.");
    //                         console.log("Navigating to Bills tab");

    //                         setTimeout($A.getCallback(function () {
    //                             var evt = $A.get("e.force:navigateToComponent");
    //                             evt.setParams({
    //                                 componentDef: "c:Accounts_Payable",
    //                                 componentAttributes: {
    //                                     "selectedTab": "Bills",
    //                                     "setrefreshtrue": true
    //                                 }
    //                             });
    //                             evt.fire();
    //                         }), 200);
    //         });
    //     };
    //     reader.readAsArrayBuffer(file);
    // },        
             
    

    processFile: function (file, component, helper) {
    const isPdf = file.type === 'application/pdf';
    const isImage = file.type.startsWith('image/');

    if (isPdf || isImage) {
        helper.processFileAsBase64(file, component, helper);
    } else {
        alert('Please select a PDF or image file.');
    }
},

processFileAsBase64: function (file, component, helper) {
    var reader = new FileReader();

    reader.onload = function () {
        try {
            // reader.result = "data:application/pdf;base64,JVBERi0xLjcKJ..."
            var dataUrl = reader.result;

            // Extract only Base64 part
            var base64Data = dataUrl.split(',')[1];

            const setRT = component.get("v.setRT");
            const isactive = component.get("v.isActive");
            const isactiveExp = component.get("v.isActiveExp");

            console.log('Sending Base64 to Gemini, file type:', file.type);

            if (setRT === 'PO Bill' && isactive) {
                helper.callGeminiAPI(component, base64Data, file.type);
            }
            else if (setRT === 'Expense Bill' && isactiveExp) {
                helper.callGeminiAPIExpense(component, base64Data, file.type);
            }
            else {
                alert("⚠️ OCR is not active for this Bill type. Please contact your administrator.");
            }

        } catch (e) {
            console.error('Base64 processing error:', e);
            alert("⚠️ Failed to process file.");
        }
    };

    // IMPORTANT: Read as Data URL (Base64)
    reader.readAsDataURL(file);
},


  
// for the expance part 

callGeminiAPIExpense: function (component, base64Data, fileType) {
    component.set("v.showSpinner", true);

   var action = component.get("c.extractExpenseItemsFromText");
   action.setParams({ base64Pdf: base64Data });


    action.setCallback(this, function (response) {
        component.set("v.showSpinner", false);

        if (response.getState() === "SUCCESS") {
            var textData = response.getReturnValue();

            if (!textData || textData.startsWith("Error:")) {
                this.showToast('Error', 'error', 'OCR could not extract expense items. Try again.');
                return;
            }

            let lines = textData.split("\n").filter(Boolean);

            let items = [];

            // 6 lines per item
            for (let i = 0; i < lines.length; i += 6) {
                items.push({
                    qty: parseFloat(lines[i]) || 0,
                    unitPrice: parseFloat(lines[i + 1]) || 0,
                    discount: parseFloat(lines[i + 2]) || 0,
                    taxPercent: parseFloat(lines[i + 3]) || 0,
                    taxAmount: parseFloat(lines[i + 4]) || 0,
                    description: lines[i + 5] || ''
                });
            }

            console.log("EXPENSE ITEMS:", JSON.stringify(items));
            component.set("v.extractedExpenseItems", items);

           let expenseRows = [];

            items.forEach(item => {
                expenseRows.push({
                    ERP7__Quantity__c: item.qty,
                    ERP7__Amount__c: item.unitPrice,
                    ERP7__Discount__c: item.discount,
                    ERP7__Tax_Rate__c: item.taxPercent,
                    ERP7__Tax_Amount__c: item.taxAmount,
                    ERP7__Total_Amount__c: (item.unitPrice - item.discount),
                    ERP7__Description__c: item.description
                });
            });

            // Set rows to the UI component
            component.set("v.billItems", expenseRows);

            console.log("Expense Rows Set:", JSON.stringify(expenseRows));
            console.log("the bill data", JSON.stringify(component.get("v.billItems")));
            // 🔥 Force UI to update (Aura rerender)
            var uiRefresh = component.get("c.Newone");
            $A.enqueueAction(uiRefresh);



        } else {
            this.showToast('Error', 'error', 'Failed to reach OCR API.');
        }
    });

    $A.enqueueAction(action);
},


//for bill part
callGeminiAPI: function (component, base64Data, fileType) {
    console.log("📤 Sending text to API...");
    component.set("v.showSpinner", true);

    var action = component.get("c.extractLineItemsFromText");
    action.setParams({ base64Pdf: base64Data });

    action.setCallback(this, function (response) {
        if (response.getState() === "SUCCESS") {
            var textData = response.getReturnValue();
            console.log("📥 Received text from API:", textData);

            // --- Check if API sent error (503 or any message starting with 'Error:') ---
            if (textData && textData.startsWith("Error:")) {
                component.set("v.showSpinner", false);

                console.error("❌ API returned error string:", textData);
                this.showToast('Error', 'error', '⚠️ OCR couldn’t process this invoice right now. Please try again later...........');

                setTimeout($A.getCallback(() => {
                    this.navigateToBills();
                }), 5000);

                
                return; // 🚫 stop further execution
            }

            // ---- Parse invoice ----
            var rows = [];
            var poNumber = "";
            var parts = textData.split("\n").filter(Boolean);

            // // 🚀 Remove header row if first qty is not numeric
            // if (parts.length >= 4 && isNaN(parseFloat(parts[1]))) {
            //     console.log("⚠️ Removing header line:", parts[0]);
            //     parts.shift();
            // }

            // ✅ Parse line items
            for (let i = 0; i < parts.length; i += 4) {
                if (i + 3 < parts.length) {
                    let productName = (parts[i] || "").trim();
                    let qty = parseFloat(parts[i + 1]) || 0;
                    let unitPrice = parseFloat(parts[i + 2]) || 0;
                    let po = (parts[i + 3] || "").trim();

                    rows.push({
                        productName: productName,
                        quantity: qty,
                        unitPrice: unitPrice,
                        poNumber: po
                    });

                    if (!poNumber && po) {
                        poNumber = po;
                    }
                }
            }

            console.log("✅ Parsed Items:", JSON.stringify(rows));
            console.log("📌 PO Number:", poNumber);

            component.set("v.poNumber", poNumber);
            component.set("v.extractedItems", rows);

            // ⚡ continue with PO checking logic
            this.handlePOChecks(component, rows, poNumber);

        } else {
            // --- Salesforce-side error ---
            var errors = response.getError();
             component.set("v.showSpinner", false);
            console.error("❌ Apex call error:", errors && errors[0] && errors[0].message ? errors[0].message : "Unknown error");

            this.showToast('Error', 'error', ' OCR couldn’t process this invoice right now. Please try again in a bit...');

            setTimeout($A.getCallback(() => {
                this.navigateToBills();
            }), 5000);

            component.set("v.showSpinner", false);
        }
    });

    $A.enqueueAction(action);
},


// 🔹 Refactored PO handling logic in separate function
handlePOChecks: function (component, rows, poNumber) {
    let cleanPONumber = poNumber.replace(/\s+/g, '');
    var existingPO = component.get("v.Bill.ERP7__Purchase_Order__c");
    var multiplePOs = component.get("v.POIdsList");
    var productNames = rows.map(item => item.productName);

    console.log("📦 Product Names:", productNames);
    console.log("ℹ️ Existing PO:", existingPO);
    console.log("ℹ️ Multiple POs:", multiplePOs);

    // --- Case 1: No existing PO AND no multiple POs ---
    if (!existingPO && (!multiplePOs || multiplePOs.length === 0)) {
        console.log("🟢 ENTERED IF block → No existing PO and no multiple POs");

        var poCheckAction = component.get("c.checkPOName");
        poCheckAction.setParams({ poName: cleanPONumber });

        poCheckAction.setCallback(this, function (resp) {
            if (resp.getState() === "SUCCESS") {
                var poId = resp.getReturnValue();
                console.log("📡 checkPOName response:", poId);

                if (poId) {
                    console.log("✅ Found PO:", poId);
                    component.set("v.ShowBillLineItems", true);

                    var productAction = component.get("c.getProductIdsByNames");
                    productAction.setParams({ poId: poId, productNames: productNames });

                    productAction.setCallback(this, function (response) {
                        if (response.getState() === "SUCCESS") {
                            var result = response.getReturnValue();
                            console.log("📦 Product Results:", result);

                            // var productsWithNoDesc = result.filter(r => r.idValue && (!r.description || r.description.trim() === ''));
                            var productsWithNoDesc = result.filter(r => !r.description && r.description.trim() === '');

                            var notInPOProducts = result.filter(r => !r.idValue);

                            console.log("🚫 Products not in PO:", JSON.stringify(notInPOProducts));

                            component.set("v.productKeyIdList", notInPOProducts);

                            if (productsWithNoDesc.length > 0) {
                                var rows = component.get("v.extractedItems") || [];
                                productsWithNoDesc.forEach(function (prod) {
                                    var matchRow = rows.find(r => r.productName === prod.keyName);
                                    if (matchRow) {
                                        prod.quantity = matchRow.quantity;
                                    }
                                });
                                component.set("v.missingDescProducts", productsWithNoDesc);

                                 component.set("v.Bill.ERP7__Purchase_Order__c", poId); // 🔹 set PO at last
                            }

                            else{
                                    component.set("v.showSpinner", false);
                                    console.log("No products with missing descriptions found.");
                                this.showToast('Error', 'error', 'The items on the uploaded invoice don’t match the purchase order line items.');
                                setTimeout($A.getCallback(() => { this.navigateToBills(); }), 5000);

                            }

                           
                        } else {
                            console.error("❌ Error in getProductIdsByNames:", response.getError());
                            this.showToast('Error', 'error', '⚠️ No matching purchase order was found.');
                            setTimeout($A.getCallback(() => { this.navigateToBills(); }), 5000);
                        }
                        component.set("v.showSpinner", false);
                    });
                    $A.enqueueAction(productAction);
                } else {
                    console.warn("⚠️ No PO returned from checkPOName");
                     component.set("v.showSpinner", false);
                    this.showToast('Error', 'error', '⚠️ No matching purchase order was found."d');
                    console.log("Navigating to Bills tab");
                    setTimeout($A.getCallback(() => { this.navigateToBills(); }), 5000);
                    component.set("v.showSpinner", false);
                }
            } else {
                console.error("❌ checkPOName error:", resp.getError());
                 component.set("v.showSpinner", false);
                this.showToast('Error', 'error', '⚠️ No matching purchase order was found."');
                setTimeout($A.getCallback(() => { this.navigateToBills(); }), 5000);
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(poCheckAction);
    }
    // --- Case 2: Either existingPO OR multiplePOs exist ---
    else {
        console.log("🟡 ENTERED ELSE block → Using existingPO or multiplePOs");
        var multiPOIds = component.get("v.POIdsList") || [];
        var poIds = multiPOIds.length > 0 ? multiPOIds : [existingPO];

        if (poIds.length > 0) {
            var productAction = component.get("c.getProductIdsByNamesForMultiPO");
            productAction.setParams({ poIds: poIds, productNames: productNames });

            component.set("v.ShowBillLineItems", true);

            productAction.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("📦 Product Results:", result);

                    var productsWithNoDesc = result.filter(r => !r.description && r.description.trim() === '');
                    var notInPOProducts = result.filter(r => !r.idValue);

                    component.set("v.productKeyIdList", notInPOProducts);

                    if (productsWithNoDesc.length > 0) {
                        var rows = component.get("v.extractedItems") || [];
                        productsWithNoDesc.forEach(function (prod) {
                            var matchRow = rows.find(r => r.productName === prod.keyName);
                            if (matchRow) {
                                prod.quantity = matchRow.quantity;
                            }
                        });
                        component.set("v.missingDescProducts", productsWithNoDesc);

                        // 🔹 Refresh PO data
                        if (existingPO) {
                            var controllerMethod = component.get("c.fetchPolis");
                            controllerMethod.setParams({ Id: existingPO });
                            $A.enqueueAction(controllerMethod);
                        } else {
                            $A.enqueueAction(component.get("c.fetchMultiPolis"));
                        }
                    } else {
                         component.set("v.showSpinner", false);
                        this.showToast('Error', 'error', '⚠️ The items on the uploaded invoice don’t match the purchase order line items.');
                        setTimeout($A.getCallback(() => { this.navigateToBills(); }), 4000);
                    }
                } else {
                     component.set("v.showSpinner", false);

                    console.error("❌ Error in getProductIdsByNamesForMultiPO:", response.getError());
                    this.showToast('Error', 'error', '⚠️ No matching purchase order was found.');
                    setTimeout($A.getCallback(() => { this.navigateToBills(); }), 4000);
                }
                component.set("v.showSpinner", false);
            });
            $A.enqueueAction(productAction);
        } else {
            console.warn("⚠️ poIds is empty (ELSE block)");
            this.showToast('Error', 'error', '⚠️ No matching purchase order was found.');
            setTimeout($A.getCallback(() => { this.navigateToBills(); }), 4000);
            component.set("v.showSpinner", false);
        }
    }
},






navigateToBills: function() {
    console.log("Creating and adding Accounts Payable component");
         var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Accounts_Payable",
            componentAttributes: {
                "selectedTab" : 'Bills'
                
            }
        });

        console.log("Firing event to navigate to Accounts Payable");
        evt.fire();
        console.log("Event fired successfully");
    
}
});