({
    doInit: function(component, event, helper) {
        var action = component.get("c.getpickval");
        var inputsel = component.find("ExpenseCategory");
        var opts = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                opts.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputsel.set("v.options", opts);
            component.set("v.ExpenseCategoryOptions",opts);
        });
        $A.enqueueAction(action);
    },
    handleDelClick: function(component, event, helper) {
        var recId = component.get("v.eLineItem.Id");
        if (recId != null && recId != undefined) {
            var self = this;
            var deleteAction = component.get("c.deleteElineItem");
            deleteAction.setParams({
                "recordId": recId
            });
            deleteAction.setCallback(self, function(a) {
                var recordId = a.getReturnValue();
                if (recordId == null) {} else {
                    var deleteEvent = component.getEvent("delete");
                    deleteEvent.setParams({
                        "listIndex": event.target.dataset.index,
                        "oldRecord": recId
                    }).fire();
                }
            });
            $A.enqueueAction(deleteAction);
        } else {
            component.destroy('null');
        }
    },
    handleAccountDelete: function(component, event, helper) {
        component.destroy();
    },
    handleApplicationEventFired: function(component, event, helper) {
        var SA = component.find("SubmittedAmount");
        var submittedAmtVal = SA.get("v.value");
        var CA = component.find("ClaimedAmount");
        var claimedAmtVal = CA.get("v.value");
        if (claimedAmtVal > submittedAmtVal) {
            CA.set("v.errors", [{
                message: "Claimed Amount should not be greater than Submitted Amount"
            }]);
        } else {
            CA.set("v.errors", null);
            var Obj = component.get("v.eLineItem");
            for (var i in event.getParams('eLineEntry').eLineEntry) {
                if (event.getParams('eLineEntry').eLineEntry[i] != null)
                    Obj[i] = event.getParams('eLineEntry').eLineEntry[i];
            }
            component.set("v.eLineItem", Obj);
            component.set("v.eLineItem.ERP7__Organisation__c", event.getParams('orgId').orgId);
            component.set("v.eLineItem.ERP7__Organisation_Business_Unit__c", event.getParams('buId').buId);
            component.set("v.eLineItem.ERP7__Expense__c", event.getParams('expenseName').expenseName);
            component.set("v.eLineItem.ERP7__Employees__c", event.getParams('employeeName').employeeName);
			var action = component.get("c.saveExpenseLineItem");
            action.setParams({
                eLineEntry1: JSON.stringify(component.get("v.eLineItem"))
            });
            action.setCallback(this, function(response) {
               var state = response.getState();
                if (state === "SUCCESS") {
					component.set("v.parentId", response.getReturnValue().Id);
                    var prId = response.getReturnValue().Id;
                    //Atttachment
                    //var valF = $(component.find("fval")).val();
                    //if(component.get("v.parentId") != null && valF != '') {
                        //helper.save(component, event, helper);
                    //}
                    if (prId != null) {
                        location.reload();
                    }
                }  else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +errors[0].message + errors);
                        }
                    } else {
                        console.log("Unknown error" + errors);
                    }
                 }
            });
            $A.enqueueAction(action);
        }
    },
    getAttachmentsC: function(component) {
        var action = component.get("c.getAttachments");
        action.setParams({
            parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var attachments = a.getReturnValue();
                component.set("v.attachments", attachments);
            } else if (a.getState() === "ERROR") {
            }
        });
        $A.enqueueAction(action);
    },
  /* uploadFileClick: function (component, event, helper) {
    var fileEle = component.find("fval");
    $(fileEle.getElement()).click();
    $(function () {
        $(fileEle.getElement()).change(function () {
            if (this.files && this.files[0]) {
                var totalRequestSize = 0;
                var files = this.files;

                for (var i = 0; i < files.length; i++) {
                    var fileSize = files[i].size;

                    if (fileSize > 2000000) {
                        helper.showToast('Error', 'error', 'File ' + files[i].name + ' exceeds the 2 MB limit.');
                        return;
                    }

                    totalRequestSize += fileSize;

                    if (totalRequestSize > 6000000) {
                        helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                        return;
                    }
                }

                var reader = new FileReader();
                reader.onload = function (e) {
                    $(component.find("myImg").getElement()).attr('src', e.target.result);
                };
                reader.readAsDataURL(files[0]);
            }
        });
    });
},*/
      uploadFileClick : function(cmp, event, helper) {
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//7
        cmp.set("v.showSpinner",true);
        try{
            let files = cmp.get("v.FileList");  
             var totalRequestSize = 0;
            for (let i = 0; i < files[0].length; i++) {
                let file = files[0][i];
               
    // Validate individual file size (max 2 MB) before processing
    if (file.size > 2000000) {
        helper.showToast("Error", "error", "File " + file.name + " exceeds the 2 MB limit.");
        cmp.set("v.showSpinner", false);
        return; // Skip processing for this file
    }
             totalRequestSize += file.size;
console.log("totalRequestSize",totalRequestSize);
            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                cmp.set("v.showSpinner", false);
                return;
            }}
console.log('FileList : ', JSON.stringify(FileList));
            let fileNameList = [];
            let base64DataList = [];
            let contentTypeList = [];
            
            if (files && files.length > 0) {
                let parentId = event.getSource().get("v.name");
                console.log('files : ',files.length);
                console.log('files[0] : ',files[0].length);
                if(files[0].length > 0){
                    for (let i = 0; i < files[0].length; i++) {
                         var totalRequestSize = 0;

       /* for ( i = 0; i < files.length; i++) {
            var fileSize = files[i][0].size;

            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + files[i][0].name + ' exceeds the 2 MB limit.');
                return;
            }

            totalRequestSize += fileSize;

            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                return;
            }
        }*/
                        console.log('i~>'+i);
                        let file = files[0][i];
                        let reader = new FileReader();
                        //reader.onloadend is asynchronous using let instead of var inside for loop arshad 
                        reader.onloadend = function() {
                            
                            console.log('inside reader.onloadend');
                            let contents = reader.result;
                            let base64Mark = 'base64,';
                            let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                            let fileContents = contents.substring(dataStart);
                           
                            
                            fileNameList.push(file.name);
                            base64DataList.push(encodeURIComponent(fileContents));
                            contentTypeList.push(file.type);

                            
                            console.log('fileNameList~>'+fileNameList.length);
                            console.log('base64DataList~>'+base64DataList.length);
                            console.log('contentTypeList~>'+contentTypeList.length);
                            
                            if(fileNameList.length == files[0].length){
                            helper.finishAllFilesUpload(parentId,fileNameList,base64DataList,contentTypeList,cmp,event,helper);
                            }else console.log('notequal');
                        }
                        reader.onerror = function() {
                            console.log('for i~>'+i+' err~>'+reader.error);
                            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//8
                            cmp.set("v.showSpinner",false);
                        };
                        reader.readAsDataURL(file);
                    }
                }
            }
        }catch(err){
            console.log("Error catch:",err);
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//9
            cmp.set("v.showSpinner",false);
        }
        
    },
    
    Navigate: function(component, event, helper) {
        $A.createComponent(
            "c:Expense_Line_Item", {
                "expenseComp": component.get("Expense"),
            },
            function(newCmp) {
                if (component.isValid()) {
                    /*var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);*/
                    var bodycmp = component.find("TimeCEContent");
                    var body = bodycmp.get("v.body");
                    body.reverse();
                    body[body.length] = newCmp;
                    body.reverse();
                    bodycmp.set("v.body", body);
                }
            }
        );
    }
})