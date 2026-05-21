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
    
   /* expli2expliWP : function(component, event) {
        
        var expli1 = component.get("v.expli");
        var accList1 = component.get("v.accList");
        var expList = component.get("v.expenseWrap");
        for(var i=0; i<expli1.length; i++){
           
            expList.push({sObjectType :'ExpenseWrapper'});
            expList[i].ExpLI = expli1[i];
            expList[i].isSelected = true;
            for(var j=0;j<accList1.length;j++){
                if(accList1[j].ParentId == expli1[i].Id){
                    expList[i].Attach = accList1[j];
                }
            }

        }
       
        component.set("v.expenseWrap", expList);
        console.log("expenseWrapXXXXXXX", component.get("v.expenseWrap"));
        
    },*/
    expli2expliWP: function(component, event, helper) {
    var expli1 = component.get("v.expli"); // List of Expense Line Items
    var accList1 = component.get("v.accList"); // List of Attachments from Apex
    var expList = component.get("v.expenseWrap");

    // Create a map to group attachments by their parent ID
    var attachmentMap = {};
    if (accList1) {
        for (var j = 0; j < accList1.length; j++) {
            var attachment = accList1[j];
            var parentId = attachment.ParentId;

            // If the parentId doesn't exist in the map, create a new empty array for it
            if (!attachmentMap[parentId]) {
                attachmentMap[parentId] = [];
            }
            // Push the current attachment to the corresponding parentId array
            attachmentMap[parentId].push(attachment);
        }
    }

    // Now, iterate through the expense line items and assign the list of attachments from the map
    for (var i = 0; i < expli1.length; i++) {
        var expenseLineItem = expli1[i];

        // Push a new wrapper object for the current line item
        expList.push({sObjectType: 'ExpenseWrapper'});
        expList[i].ExpLI = expenseLineItem;
        expList[i].isSelected = true;

        // Assign the list of attachments from the map to the wrapper
        // Use the logical OR operator to handle cases where a line item has no attachments
        expList[i].Attachments = attachmentMap[expenseLineItem.Id] || [];
    }

    component.set("v.expenseWrap", expList);
},
    
    validationCheckName : function (component, event) {
        var NOerrors = true;
        var exName = component.find("exName1");
        if(!$A.util.isUndefined(exName))
            NOerrors =  this.checkValidationField(exName);
        
        return NOerrors;
    },
    
    validationCheckexpliName : function (component, event, helper) {
        
        var NOerrors = true;       
        var expliNameEle = []; 
         if(!component.get("v.isEditAll")){
        expliNameEle = component.get("v.expenseWrap");
       
        try{  
            for(var i in expliNameEle){   
                if(expliNameEle[i].ExpLI.Name == null || expliNameEle[i].ExpLI.Name == '' ||  expliNameEle[i].ExpLI.Name == undefined) {
                  
                    NOerrors = false; 
                    return NOerrors;
                }
                else{ 
                    NOerrors = true;
                    
                }
            }   
        }catch(ex){}
        
       // return NOerrors;
         }
        else{
             expliNameEle = component.get("v.expWrapList");
       
        try{  
            for(var i in expliNameEle){   
                if(expliNameEle[i].expline.Name == null || expliNameEle[i].expline.Name == '' ||  expliNameEle[i].expline.Name == undefined) {
                  
                    NOerrors = false; 
                    return NOerrors;
                }
                else{ 
                    NOerrors = true;
                    
                }
            }   
        }catch(ex){}
        }
        return NOerrors;
         
        
    },
    
    checkvalidationLookup : function(poli_List){
        if($A.util.isEmpty(poli_List.get("v.selectedRecord.Id"))){
            poli_List.set("v.inputStyleclass","hasError");
            return false;
        }else{
            poli_List.set("v.inputStyleclass",""); 
            return true;
        }
    },
    
    checkValidationField : function(cmp){
        if($A.util.isEmpty(cmp.get("v.value"))){
            cmp.set("v.class","hasError");
            return false;
        }else{
            cmp.set("v.class","");
            return true;
        }
        
    },
    
    FieldAccess:function (component, event) {
       
        var action=component.get("c.AddExpenseCheckFLS");
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                console.log('AddExpenseCheckFLS:',response.getReturnValue());
                component.set('v.AddExpenseFLSCheck',response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
            }
        });
        $A.enqueueAction(action);
    },
    
})