({//AddExpensecontroller
    doInit: function(component, event, helper) {
       	var action = component.get("c.getDefaultOrganisation");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.Organisation",response.getReturnValue());
            }  
        });
        $A.enqueueAction(action); 
        
        if(component.get("v.AccId")!='') component.set("v.Expense.ERP7__Vendor_Account__c",component.get("v.AccId"));
        
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        if(component.get("v.isDraftEdit"))
            helper.expli2expliWP(component, event);
        var action = component.get("c.getEmployees");
        action.setCallback(this, function(a) {
            component.set("v.emp", a.getReturnValue());
            if(!component.get("v.EditRecord"))component.set("v.Expense.ERP7__Employees__c", component.get("v.emp.Id"));
            /*if(!component.get("v.isDraftEdit"))*/
                component.set("v.Expense.ERP7__Approver__c",component.get("v.emp.ERP7__Employee_User__r.ManagerId"));
            
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
        helper.FieldAccess(component, event);
        
          var expps=component.get("v.expWrapList");
        var newexpps=[];
        var neww=[];
        var n=[];
        console.log("Working??", expps);
        for(var i=0;i<expps.length;i++){ 
            newexpps.push(expps[i].expline); 
        }
             
		neww = newexpps.flat();
         for(var i=0;i<neww.length;i++){ 
            n.push(neww[i].Id); 
        }
                component.set("v.explilist",n);
        console.log("neww Ids explilist",component.get("v.explilist"));

       // console.log("newexpps", newexpps);
    },
    
    /*updateExpli : function(component, event, helper){
       
        var exliList = component.get("v.expli");
        exliList.push(component.get("v.eLineItem"));
        component.set("v.expli", exliList);
       
    },*/
    
    addNew : function(component, event, helper) {
        var expList = component.get("v.expenseWrap");
        expList.unshift({sObjectType :'ExpenseWrapper'});
        component.set("v.expenseWrap", expList);
        
    },
    
    deleteExxli :function(component, event, helper) {
       
        var exliList =[]; 
        exliList=component.get("v.expli");       
        var index=event.getParam("Index"); //component.get("v.Index2del");
        
        exliList.splice(index,1);
        
        component.set("v.expli",exliList);
        
    },
    
    deleteExxliWP : function(component, event, helper) {
        
        var exliList = component.get("v.expenseWrap");
        var index = event.getParam("Index");
       
        exliList.splice(index, 1);
        
        component.set("v.expenseWrap", exliList);
        
    },
   
    
    cancelClick: function(component, event, helper) {
        var eemp=component.get("v.uId");
       
         
       // console.log("v.uId", eemp);
        if(component.get("v.FromSP")){ 
             $A.createComponent(
                "c:SupplierPortalExpense", {
                    AccId:component.get("v.AccId"),
                    
                },
                function(newComp) {
                    var content = component.find("body");
                    content.set("v.body", newComp);
                }
            );
       }else{
           var evt = $A.get("e.force:navigateToComponent");
           evt.setParams({
               componentDef : "c:MyExpenses",
               componentAttributes: {
                   "TempUserId": eemp
               }
           });
           evt.fire();
        }
        
    },
    
    saveEX : function(component, event, helper){
        if(component.get("v.isEditAll")){
           // var valexpliName = helper.validationCheckexpliName(component, event);
            console.log('isEditAll called');
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var expps = component.get("v.expWrapList");
            var allexpenceitems=[];
            for(var i in expps){ 
                for(var j in expps[i].expline){
                    allexpenceitems.push(expps[i].expline[j]);
                }
            }
            console.log('allexpenceitems~>',JSON.stringify(allexpenceitems));
            var saveAction = component.get("c.upsateAllExpli");
            saveAction.setParams({
                expWrapList : JSON.stringify(allexpenceitems),
                posted : false
            });
            saveAction.setCallback(this,function(response){
                
                if(response.getState() === 'SUCCESS'){
                    console.log('insuccess');
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    helper.showToast('Success!','success','Expense Line Items Updated Successfully');
                    var eemp=component.get("v.uId");
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:MyExpenses",
                            componentAttributes: {
                                "TempUserId": eemp
                            }
                        });
                    evt.fire();

                }else{
                    console.log("Error", response.getError());
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(saveAction);
                
            
        }else{
        var exLIst = component.get("v.expenseWrap");
        var head = component.get("v.header");
        var valName = helper.validationCheckName(component, event);
        var valexpliName = helper.validationCheckexpliName(component, event);
        
        for(var x in exLIst){
            exLIst[x].Attach = undefined;
           
        }
        
        if(valName && valexpliName){
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var iEU = component.get("v.isDraftEdit");
            if(exLIst.length>0 && head === true){
                
                console.log('Save Expense Record:',JSON.stringify(component.get("v.Expense")));
                var saveAction = component.get("c.save_ExpenseIK");
                saveAction.setParams({
                    isExpenseUpdate : iEU,
                    exp : JSON.stringify(component.get("v.Expense")),
                    expliList : JSON.stringify(exLIst),
                    FromSP : component.get("v.FromSP")
                });
                
                saveAction.setCallback(this,function(response){
                    
                    if(response.getState() === 'SUCCESS'){
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        
                        if(component.get("v.EditRecord")) helper.showToast('Success!','success','Expense Updated Successfully');
                        else helper.showToast('Success!','success','Expense Created Successfully');
                        if(component.get("v.FromSP")){
                            $A.createComponent(
                                "c:SupplierPortalExpense", {
                                    AccId:component.get("v.AccId"),
                                    
                                },
                                function(newComp) {
                                    var content = component.find("body");
                                    content.set("v.body", newComp);
                                }
                            );
                        }else{
                        var eemp=component.get("v.uId");
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:MyExpenses",
                            componentAttributes: {
                                "TempUserId": eemp
                            }
                        });
                        evt.fire();
                        }
                        //location.reload();
                        /*if(component.get("v.navigateToRecord")){
                            var navEvt = $A.get("e.force:navigateToSObject");
                            if(navEvt != undefined){
                                navEvt.setParams({
                                    "isredirect": true,
                                    "recordId": response.getReturnValue().Id,
                                    "slideDevName": "detail"
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
                        }*/
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        var errors = response.getError();
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            //helper.showToast('Error!','error',errors[0].message);
                            console.log("errors[0].message -->", errors[0].message);
                            component.set("v.exceptionError", errors[0].message);
                        }
                    }
                });
                $A.enqueueAction(saveAction);
            }
            else if(exLIst.length>0 && head === false){
                var eemp=component.get("v.uId");
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:MyExpenses",
                            componentAttributes: {
                                "TempUserId": eemp
                            }
                        });
                        evt.fire();
               /* console.log("JSON.stringify Expenses",JSON.stringify(component.get("v.Expenses")));
                  var saveAction = component.get("c.save_multi_ExpenseIK");
                   saveAction.setParams({
                    isExpenseUpdate : iEU,
                    Allexp : JSON.stringify(component.get("v.Expenses")),
                    expliList : JSON.stringify(exLIst),
                    FromSP : component.get("v.FromSP")
                });
                 saveAction.setCallback(this,function(response){
                     if(response.getState() === 'SUCCESS'){
                         $A.util.addClass(component.find('mainSpin'), "slds-hide");
                         if(component.get("v.EditRecord")) helper.showToast('Success!','success','Expense Updated Successfully');
                        else helper.showToast('Success!','success','Expense Created Successfully');
                        if(component.get("v.FromSP")){
                            $A.createComponent(
                                "c:SupplierPortalExpense", {
                                    AccId:component.get("v.AccId"),
                                    
                                },
                                function(newComp) {
                                    var content = component.find("body");
                                    content.set("v.body", newComp);
                                }
                            );
                        }else{
                        var eemp=component.get("v.uId");
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:MyExpenses",
                            componentAttributes: {
                                "TempUserId": eemp
                            }
                        });
                        evt.fire();
                        }
                        
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        var errors = response.getError();
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            //helper.showToast('Error!','error',errors[0].message);
                            console.log("errors[0].message -->", errors[0].message);
                            component.set("v.exceptionError", errors[0].message);
                        }
                    }
                });
                $A.enqueueAction(saveAction);*/
                 
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                
                component.set("v.exceptionError", "Please add a Line Item");
            }
        }
        else{
            if(!valName)
            	component.set("v.exceptionError", "Please Enter Expense Name.");    
            else if(!valexpliName)
            	component.set("v.exceptionError", "Please Enter Expense line item Name.");
        }
        }
    },
    
    savePostEX : function(component, event, helper){
        if(component.get("v.isEditAll")){
            console.log('isEditAll called');
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            //component.set("v.Expense.ERP7__Post__c", true);
            
            var expps = component.get("v.expWrapList");
            var allexpenceitems=[];
            for(var i in expps){ 
                for(var j in expps[i].expline){
                    allexpenceitems.push(expps[i].expline[j]);
                }
            }
            console.log('allexpenceitems~>',JSON.stringify(allexpenceitems));
            var saveAction = component.get("c.upsateAllExpli");
            saveAction.setParams({
                expWrapList : JSON.stringify(allexpenceitems),
                posted : true
            });
            saveAction.setCallback(this,function(response){
                
                if(response.getState() === 'SUCCESS'){
                    console.log('insuccess');
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    helper.showToast('Success!','success','Expense Line Items Updated Successfully');
                    var eemp=component.get("v.uId");
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:MyExpenses",
                            componentAttributes: {
                                "TempUserId": eemp
                            }
                        });
                    evt.fire();

                }else{
                    console.log("Error", response.getError());
                    component.set("v.exceptionError", JSON.stringify(response.getError()));
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(saveAction);
                
            
        }
        else{
        var exLIst = component.get("v.expenseWrap");
       
        var valName = helper.validationCheckName(component, event);
        var valexpliName = helper.validationCheckexpliName(component, event);
        
        for(var x in exLIst)
        {
            exLIst[x].Attach = undefined;
           
        }
        
        if(valName && valexpliName){
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            if(exLIst.length>0){
                var iEU = component.get("v.isDraftEdit");
                component.set("v.Expense.ERP7__Post__c", true);
                var saveAction = component.get("c.save_ExpenseIK");
                saveAction.setParams({
                    isExpenseUpdate : iEU,
                    exp : JSON.stringify(component.get("v.Expense")),
                    expliList : JSON.stringify(exLIst),
                    FromSP : component.get("v.FromSP")
                });
                
                saveAction.setCallback(this,function(response){
                    
                    if(response.getState() === 'SUCCESS'){
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        
                        if(component.get("v.EditRecord")) helper.showToast('Success!','success','Expense Updated Successfully');
                        else helper.showToast('Success!','success','Expense Created Successfully');
                        if(component.get("v.FromSP")){
                            $A.createComponent(
                                "c:SupplierPortalExpense", {
                                    AccId:component.get("v.AccId"),
                                    
                                },
                                function(newComp) {
                                    var content = component.find("body");
                                    content.set("v.body", newComp);
                                }
                            );
                        }else{
                        var eemp=component.get("v.uId");
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:MyExpenses",
                            componentAttributes: {
                                 "TempUserId": eemp
                            }
                        });
                        evt.fire();
                        }
                        //location.reload();
                        /*if(component.get("v.navigateToRecord")){
                            var navEvt = $A.get("e.force:navigateToSObject");
                            if(navEvt != undefined){
                                navEvt.setParams({
                                    "isredirect": true,
                                    "recordId": response.getReturnValue().Id,
                                    "slideDevName": "detail"
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
                        }*/
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        var errors = response.getError();
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            //helper.showToast('Error!','error',errors[0].message);
                            console.log("errors[0].message -->", errors[0].pageErrors);
                            var pageErrors = errors[0].pageErrors;
                            component.set("v.exceptionError", pageErrors[0].message);
                        }
                    }
                });
                $A.enqueueAction(saveAction);
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                
                component.set("v.exceptionError", "Please add a Line Item");
            }
        }
        else
        {
            if(!valName)
            	component.set("v.exceptionError", "Please Enter Expense Name.");    
            else if(!valexpliName)
            	component.set("v.exceptionError", "Please Enter Expense line item Name.");
        }
        }
    },
    
    closeError : function (cmp, event) {
    	cmp.set("v.exceptionError",'');
    },
    
    handleStatusChange: function(component, event, helper) {
        var selectedValue = event.getSource().get("v.value");
        console.log("Selected Status:", selectedValue);
    } 
    
})