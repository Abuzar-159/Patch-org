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
    
    
     saveAtt : function(component,event,file,parentId){
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
                    }else{
                        console.log('Error :',response.getError());
                    }
                });
                $A.enqueueAction(action); 
            }
            reader.readAsDataURL(file);
    },
    
    /*
    AnalyticalAccountCheck : function(component, event, helper) {
        var poli = component.get("v.lineItems");
        var arshbool = false;
        for(var x in poli){
            var TotalAmount = 0.00;
            TotalAmount = parseFloat(poli[x].ERP7__Total_Amount__c); //.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            console.log('TotalAmount~>'+TotalAmount+' typeof ~>'+typeof TotalAmount);
            //if(poli[x].ERP7__Tax_Amount__c!= null && poli[x].ERP7__Tax_Amount__c!= undefined && poli[x].ERP7__Tax_Amount__c!= '') TotalAmount = parseFloat(poli[x].ERP7__Total_Amount__c- poli[x].ERP7__Tax_Amount__c);
            //else TotalAmount = poli[x].ERP7__Total_Amount__c;
            var acc = [];
            console.log('AnalyticalAccountCheck : ',JSON.stringify(poli[x]));
            acc = poli[x].Accounts;
            var accTotal = 0.00;
            if(acc != undefined && acc != null){
                if(acc.length > 0){
                    for(var y in acc){
                        if(acc[y].ERP7__Allocation_Amount__c!= undefined && acc[y].ERP7__Allocation_Amount__c!= null && acc[y].ERP7__Allocation_Amount__c!= ''){
                            if(acc[y].ERP7__Allocation_Amount__c> 0) accTotal += parseFloat(acc[y].ERP7__Allocation_Amount__c);
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
    
/*    AnalyticalAccountCheck : function(component, event, helper) {
        var poli = component.get("v.lineItems");
        var bool = false;
        for(var x in poli){
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
                        if(acc[y].ERP7__Allocation_Amount__c!= undefined && acc[y].ERP7__Allocation_Amount__c!= null && acc[y].ERP7__Allocation_Amount__c!= ''){
                            if(acc[y].ERP7__Allocation_Amount__c> 0) accTotal += ((parseFloat(parseFloat(poli[x].ERP7__Quantity__c) * parseFloat(poli[x].ERP7__Amount__c) * acc[y].ERP7__Allocation_Percentage__c)/100)); 
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
    },  */
    
    
    AnalyticalAccountCheck : function(component, event, helper) {
    var poli = component.get("v.lineItems");
    console.log('🔎 lineItems:', JSON.stringify(poli));

    var bool = false;
    for (var x in poli) {
        console.log(`➡️ Checking lineItem index: ${x}`, poli[x]);

        var TotalAmount = 0.00;
        TotalAmount = parseFloat(poli[x].ERP7__Total_Amount__c)
                        .toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
        console.log(`   TotalAmount (step 1): ${TotalAmount}, type: ${typeof TotalAmount}`);

        TotalAmount = parseFloat(TotalAmount)
                        .toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
        console.log(`   TotalAmount (step 2): ${TotalAmount}, type: ${typeof TotalAmount}`);

        TotalAmount = parseFloat(TotalAmount)
                        .toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
        console.log(`   TotalAmount (step 3): ${TotalAmount}, type: ${typeof TotalAmount}`);

        var acc = poli[x].Accounts;
        console.log(`   Accounts for lineItem[${x}]:`, acc);

        var accTotal = 0.00;
        if (acc != undefined && acc != null) {
            if (acc.length > 0) {
                for (var y in acc) {
                    console.log(`      Checking Account index: ${y}`, acc[y]);

                    if (acc[y].ERP7__Allocation_Amount__c != undefined && 
                        acc[y].ERP7__Allocation_Amount__c != null && 
                        acc[y].ERP7__Allocation_Amount__c != '') {

                        if (acc[y].ERP7__Allocation_Amount__c > 0) {
                            var calcValue = (
                                parseFloat(poli[x].ERP7__Quantity__c) *
                                parseFloat(poli[x].ERP7__Amount__c) *
                                acc[y].ERP7__Allocation_Percentage__c
                            ) / 100;

                            accTotal += calcValue;

                            console.log(`         ➕ Added allocation for Account[${y}] = ${calcValue}, running accTotal = ${accTotal}`);
                        }
                    } else {
                        console.log(`         ⚠️ Allocation Amount missing/invalid for Account[${y}]`);
                    }
                }

                console.log(`   accTotal (raw): ${accTotal}, type: ${typeof accTotal}`);

                accTotal = parseFloat(accTotal)
                            .toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                console.log(`   accTotal (step 1): ${accTotal}, type: ${typeof accTotal}`);

                accTotal = parseFloat(accTotal)
                            .toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                console.log(`   accTotal (step 2): ${accTotal}, type: ${typeof accTotal}`);

                console.log(`   ✅ Comparison for item ${x}: TotalAmount = ${TotalAmount}, accTotal = ${accTotal}`);

                if (accTotal > TotalAmount) {
                    console.error(`❌ Analytical Account total (${accTotal}) > Line item total (${TotalAmount}) for lineItem[${x}]`);
                    return true;
                } else if (TotalAmount > accTotal) {
                    console.error(`❌ Line item total (${TotalAmount}) > Analytical Account total (${accTotal}) for lineItem[${x}]`);
                    return true;
                }
            } else {
                console.log(`   Accounts is empty for lineItem[${x}]`);
            }
        } else {
            console.log(`   Accounts is null/undefined for lineItem[${x}]`);
        }
    }

    console.log('✅ All lineItems validated, returning:', bool);
    return bool;
},

    
   AnalyticalAccountCoaCheck : function(component, event, helper) {
    var poli = component.get("v.lineItems");
    console.log('🔎 lineItems:', JSON.stringify(poli));

    var arshbool = false;
    for (var x in poli) {
        console.log(`➡️ Checking lineItem index: ${x}`, poli[x]);

        var acc = poli[x].Accounts;
        console.log(`   Accounts for lineItem[${x}]:`, acc);

        if (acc != undefined && acc != null) {
            if (acc.length > 0) {
                console.log(`   Accounts length: ${acc.length}`);

                if (poli[x].ERP7__Chart_Of_Account__c == null || 
                    poli[x].ERP7__Chart_Of_Account__c == undefined || 
                    poli[x].ERP7__Chart_Of_Account__c == '') {

                    console.warn(`⚠️ Missing Chart Of Account on lineItem[${x}]`);
                    return true;
                }

                for (var y in acc) {
                    console.log(`      Checking Account index: ${y}`, acc[y]);

                    if (acc[y].ERP7__Project__c == null || 
                        acc[y].ERP7__Project__c == undefined || 
                        acc[y].ERP7__Project__c == '') {

                        console.warn(`⚠️ Missing Project on lineItem[${x}], Account[${y}]`);
                        return true;
                    }
                }
            } else {
                console.log(`   Accounts is empty for lineItem[${x}]`);
            }
        } else {
            console.log(`   Accounts is null/undefined for lineItem[${x}]`);
        }
    }

    console.log('✅ All lineItems validated, returning:', arshbool);
    return arshbool;
},

    
    
    checkForTotalAmount : function(component, event, helper) {
        var Billobj = component.get("v.DebitNote");
        Billobj.ERP7__Purchase_Orders__r= null;
        Billobj.ERP7__Posted__c= component.get('v.setBillPost');
        
        var totalAmount=parseFloat(Billobj.ERP7__Amount__c);
        let jsonBill  = JSON.stringify(Billobj);
        var action = component.get("c.checkTotalAmount");
        action.setParams({"Bill": jsonBill});
        action.setCallback(this,function(response){
        if(response.getState() === 'SUCCESS'){
            var totalAmount = false;
            totalAmount = response.getReturnValue();
            return totalAmount;
        }
        });
        $A.enqueueAction(action);
    },
    
    checkforBill : function(component, event, helper){
        var fetchpoliAction = component.get("c.fetch_billItems");
        fetchpoliAction.setParams({"Id":component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    var poliList = JSON.parse(resultList[1]);
                    if(!$A.util.isEmpty(poliList)){
                        return true;
                    }else{
                        component.set("v.showMmainSpin",false);
                        this.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_DB_Has_Already_Been_Created'));
                        setTimeout(
                            $A.getCallback(function() {
                                //$A.enqueueAction(component.get("c.cancelclick"));
                            }), 3000
                        );
                        return false;
                    }
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
    }
})