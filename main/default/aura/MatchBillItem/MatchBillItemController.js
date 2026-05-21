({
	doInit : function(component, event, helper) {
        component.set('v.IsApprovedShow',$A.get("$Label.c.IsApprovedShow"));
        component.set('v.isTotalAmtShow',$A.get("$Label.c.isTotalAmtShow"));
         var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        var dayDigit = today.getDate();
        if(dayDigit <= 9){
            dayDigit = '0' + dayDigit;
        }
        component.set('v.today', today.getFullYear() + "-" + monthDigit + "-" + dayDigit);
    },
    
    NavigateToManageBill: function(component,event,helper){
        var item = component.get("v.item");
        var url = '/apex/ERP7__ManageBill?BId='+item.Id;
        window.open(url,"_self");
    },
    
    getSelectedBill : function(cmp,event,h){
        var SelectedId = event.getSource().get("v.name");
        var selBills = cmp.get('v.SelectedBillIds'); 
        if(selBills=='')selBills.pop();
        if(event.getSource().get("v.value")){
            selBills.push(SelectedId);
         }else{
            for(var x =0;x < selBills.length;x++){
                if(selBills[x] === SelectedId){
                    selBills.splice(x,1);
                    break;
                } 
                
            }
        }
        cmp.set('v.SelectedBillIds', selBills);       
    },
    updateBill : function(component,event,helper){
        var recId = event.target.dataset.record;
        var item = component.get("v.item");
        var postvalue = item.ERP7__Posted__c;
        item.ERP7__Posted__c = !(postvalue);
        var updateAction = component.get("c.updateBillById");
        updateAction.setParams({"recordId":recId,"fieldValue":item.ERP7__Posted__c});
        updateAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.item",item);
                let msg = (item.ERP7__Posted__c)?$A.get("$Label.c.Acc_Recev_Posted") + ' #'+item.Name:$A.get("$Label.c.Acc_Recev_Unpost")+ ' #'+item.Name +' '+$A.get("$Label.c.Success");//let msg = (item.ERP7__Posted__c)?'Post Bill #'+item.Name+' Successfully':'UnPost Bill #'+item.Name+' Successfully'
                helper.showToast($A.get('$Label.c.Success'),'success',msg); 
            }
            
        });
       $A.enqueueAction(updateAction); 
    },
   /*updateBillToApprove : function(component, event, helper){
       
        var recId = event.target.dataset.record;
        var item = component.get("v.item");
        //component.set("v.item.ERP7__Approved__c",true); 
       
       if((component.get("v.item.ERP7__Matched__c")&&component.get("v.item.RecordType.DeveloperName")=='PO_Bill')||component.get("v.item.RecordType.DeveloperName")=='Expense_Bill'){
           component.set("v.item.ERP7__Approved__c",true); 
           var approve = item.ERP7__Approved__c;
        item.ERP7__Approved__c = true;
        var updateAction = component.get("c.update_Bill");
        updateAction.setParams({"obj":JSON.stringify(item)});
        updateAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
            }
            
        });
       $A.enqueueAction(updateAction);
       }else{
           
               helper.showToast('Error!','error','Please Match the Bill Before Approve'); 
                            // component.set("v.SaveErrorMsg","Please Match the Bill Before Approve");
                        
          
       }
   },*/
    
    
    
    updateBillToApprove : function(component, event, helper){
        
        var recId = event.target.dataset.record;
        var item = component.get("v.item");
        //component.set("v.item.ERP7__Approved__c",true); 
        //(component.get("v.item.ERP7__Matched__c")&&component.get("v.item.RecordType.DeveloperName")=='PO_Bill')||
        if((component.get("v.item.RecordType.DeveloperName")=='Expense_Bill') || (component.get("v.item.RecordType.DeveloperName")=='Advance_to_vendor')){
            component.set("v.item.ERP7__Posted__c",true); 
            var approve = item.ERP7__Posted__c;
            item.ERP7__Posted__c = true;
            var updateAction = component.get("c.update_Bill");
            updateAction.setParams({"obj":JSON.stringify(item)});
            updateAction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                }else{
                    var errors = response.getError();
                    component.set("v.item.ERP7__Posted__c",false); 
                    helper.showToast('Error!','error',$A.get("$Label.c.Entries_not_matched")); 
                        item.ERP7__Posted__c = false;
            			item.ERP7__Approved__c = false;
                    	
                    }
                
            });
            $A.enqueueAction(updateAction);
        }else if((component.get("v.item.ERP7__Matched__c")&&component.get("v.item.RecordType.DeveloperName")=='PO_Bill')){
            //alert('called');
            component.set("v.item.ERP7__Posted__c",true); 
            var approve = item.ERP7__Posted__c;
            item.ERP7__Posted__c = true;
            item.ERP7__Approved__c = true;
            var updateAction = component.get("c.update_Bill");
            updateAction.setParams({"obj":JSON.stringify(item)});
            updateAction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                }else{
                    var errors = response.getError();
                    component.set("v.item.ERP7__Posted__c",false); 
                    helper.showToast('Error!','error',$A.get("$Label.c.Entries_not_matched")); 
                        item.ERP7__Posted__c = false;
            			item.ERP7__Approved__c = false;
                    	
                    }
                
            });
            $A.enqueueAction(updateAction);
        }else{
            var action1 = component.get("c.checkBillDetails");
            action1.setParams({BillId:component.get("v.item.Id")});
            action1.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue()){
                        helper.HelperSaveRecord(component, event, helper);
                    }else{
                        helper.showToast('Error!','error','Please Match the Bill Before Approve'); 
                    }
                }
                else{
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!','error',errors[0].message); 
                        }
                    }
                }
            });
            $A.enqueueAction(action1);
        }
    },
    
    onClick:function(component, event, helper) {
        component.set("v.SaveErrorMsg",'');
    },
    hideModal : function(component,event,helper){
        component.set("v.showModal",false);
    },
    CreateVoucher : function(component,event,helper){
        var item = component.get("v.item");
        var items=JSON.stringify(item);
        
        var saveAction = component.get("c.checkVoucherApex");
        saveAction.setParams({"record":items});
        saveAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue().isValid){
                    var vou = component.get("v.voucher");
                    vou.ERP7__Vendor__c = item.ERP7__Vendor__c;
                    vou.ERP7__Vendor_invoice_Bill__c = item.Id;
                    vou.ERP7__Payment_Summary__c = response.getReturnValue().vendorBillNumber;
                    if(item.ERP7__Purchase_Order__c!=null) vou.ERP7__Purchase_Orders__c = item.ERP7__Purchase_Order__c;
                    if(item.ERP7__TDS_Amount__c!=null && item.ERP7__TDS_Amount__c > 0)vou.ERP7__Amount__c = item.ERP7__Amount_Due__c-item.ERP7__TDS_Amount__c;
                    else vou.ERP7__Amount__c = response.getReturnValue().Amount;
                    component.set("v.vList",response.getReturnValue().vouchers);
                    vou.Name = item.Name;
                    component.set("v.voucher",vou);
                    component.set("v.showModal",true);
                }
                else{
                    helper.showToast('Warning!','warning','Voucher Has Already Been Created'); 
                }
            }  
        });
        $A.enqueueAction(saveAction);
    },
    
    
   save_Voucher : function(component,event,helper){
        component.noErrors = true;
        helper.checkvalidation(component,event);
        if(component.noErrors){
        component.set("v.showMmainSpin", true);
        var saveAction = component.get("c.saveVoucher");
            var vou = component.get("v.voucher");
            /*if(!$A.util.isUndefined(component.get("v.org.Id")))
                vou.ERP7__Organisation__c = component.get("v.org.Id");*/
            vou.ERP7__Organisation__c=component.get("v.item.ERP7__Organisation__c");
            var voucher = JSON.stringify(vou);
            
        saveAction.setParams({"voucherRecord":voucher});
        saveAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                component.set("v.item",response.getReturnValue());
                component.set("v.showModal",false);
                component.set("v.showMmainSpin", false);
                helper.showToast('Success!','success','Voucher Created Successfully'); 
                console.log("Creating and adding Accounts Payable component");
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:Accounts_Payable",
                    componentAttributes: {
                        "selectedTab" : 'Vouchers'
                        
                    }
                });

                console.log("Firing event to navigate to Accounts Payable");
                evt.fire();
                console.log("Event fired successfully");
            }else{
                component.set("v.showMmainSpin", false);
            }  
        });
        $A.enqueueAction(saveAction);
       }else
           helper.showToast('Error!','error','Review All Errors'); 
    },
        
     updateBillToPost : function(component,event,helper){
         $A.enqueueAction(component.get("c.updateBillToApprove"));
       var paymentAction =  component.get("c.save_Bill");
        let recId = component.get('v.item');//event.target.dataset.record;
        component.set('v.item.ERP7__Posted__c',true);
        
        paymentAction.setParams({"record":JSON.stringify(recId)}); 
        paymentAction.setCallback(this,function(response){
            var state=response.getState();
            if(response.getState() === 'SUCCESS'){
               // component.set("v.Payments",Payments);
                //let msg = (item.ERP7__Posted__c)?'Post Payment #'+item.Name+' Successfully':'UnPost Payment #'+item.Name+' Successfully'
                //helper.showToast('Success!','success',msg);
            }
        });
        $A.enqueueAction(paymentAction);
                                 
    },
    
    navToCreateBill : function(component,event,helper){
        //var BLIId = event.currentTarget.getAttribute('data-BLIId');  
        var item=component.get('v.item');
        var pId=item.Id;
         var evt = $A.get("e.force:navigateToComponent");
         evt.setParams({
             componentDef : "c:ManageBill",
             componentAttributes: {
                 "Bill":item,
                 "pId": pId,
                 "fromAP":true,
                 "navigateToRecord":false
             }
         });
         evt.fire();
        
        /*$A.createComponent("c:CreateBill",{
            "aura:id": "mBill",
             "Bill": item,
            "navigateToRecord":false
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
            var body = component.find("body");
            body.set("v.body", newCmp);
        }
        });*/
    },
    
    navigatetoPO : function(component, event, helper) {
        var POId = event.currentTarget.getAttribute('data-POId');  
         var evt = $A.get("e.force:navigateToComponent");
         evt.setParams({
             componentDef : "c:CreatePurchaseOrder",
             componentAttributes: {
                 recordId : POId,
                 fromAPB : true
             }
         });
         evt.fire();        
    },
    
    ManageBill :  function(component, event, helper) {
        var recId = event.target.closest('a').dataset.record;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreateBill",
            componentAttributes: {
                recordId:recId,
                fromAP : true,
                navigateToRecord : false,
                showPage : true,
                ShowBillType : false
            }
        });
        evt.fire();
    },
    
    CloneBill : function(component, event, helper) {
        var recId = event.currentTarget.dataset.record;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreateBill",
            componentAttributes: {
                recordId:recId,
                fromAP : true,
                navigateToRecord : false,
                showPage : true,
                ShowBillType : false,
                clone:true
            }
        });
        evt.fire();
    },
   
})