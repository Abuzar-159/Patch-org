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
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action=component.get("c.CreateBillCheckFLS");
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.CreateBillFLSCheck',response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("error -> ", errors);
            }
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    
    FieldBill:function (component, event) {
        var action=component.get("c.fetchBill");
        action.setParams({
            bId:component.get("v.BId"),
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.Bill',response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("error -> ", errors);
            }
        });
        $A.enqueueAction(action);
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
    //Moin added this 13th june 2023 SyncSales : true, SyncGDrive : false as the syntax was changed
    saveAtt : function(component,event,file,parentId){
        component.set("v.showMmainSpin",true);
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
                contentType: file.type, 
                SyncSales : true,
                SyncGDrive : false
            });
            action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS'){
                    if(component.get("v.navigateToRecord")){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        if(navEvt != undefined){
                            navEvt.setParams({
                                "isredirect": true,
                                "recordId": component.get("v.BillId"),
                                "slideDevName": "detail"
                            }); 
                            navEvt.fire();
                        }else {
                            var selectedBillList=[];
                            var url = '/'+component.get("v.BillId");
                            window.location.replace(url);
                        }
                    }else{
                        var selectedBillList=[];
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:Accounts_Payable",
                            componentAttributes: {
                                "selectedTab" : 'Bills',
                                "setSearch" : component.get("v.bbName")
                            }
                        });
                        evt.fire(); 
                    }
                }else{
                    if(component.get("v.navigateToRecord")){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        if(navEvt != undefined){
                            navEvt.setParams({
                                "isredirect": true,
                                "recordId": component.get("v.BillId"),
                                "slideDevName": "detail"
                            }); 
                            navEvt.fire();
                        }else {
                            var selectedBillList=[];
                            selectedBillList.push(result['bill'].Id);
                            var url = '/'+component.get("v.BillId");
                            window.location.replace(url);
                        }
                    }else{
                        var selectedBillList=[];
                        var result = response.getReturnValue(); 
                        var bilobj = result['bill2'];
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:Accounts_Payable",
                            componentAttributes: {
                                "selectedTab" : 'Bills',
                                "setSearch" : component.get("v.bbName")
                            }
                        });
                        evt.fire(); 
                    }
                }
            });
            $A.enqueueAction(action); 
        }
        reader.readAsDataURL(file);
    },
    
    navigation : function(component, event){
        
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
    
    fetchBillCurrncy : function(component, event, helper) {
        var action=component.get("c.getBillCurrencies");
        action.setParams({'BillId' : component.get("v.Bill.Id")});
        action.setCallback(this,function(response){
            if(response.getReturnValue() != '') component.set("v.Bill.CurrencyIsoCode",response.getReturnValue());
            
        });
        $A.enqueueAction(action);
    },
})