({
    doInit : function(component, event, helper) {
        component.set("v.criteriaMsgInv",'Please select the vendor');
    },
    
    fetchDetails : function(component, event, helper) {
		//alert(component.get("v.recordId"));
        var action = component.get("c.fetchVouchers");
        action.setParams({vId:component.get("v.vId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() != null && response.getReturnValue() != ''){
                    component.set("v.vouchers",response.getReturnValue());
                    component.set("v.criteriaMsgInv",'');
                }else{
                    component.set("v.vouchers",null);
                    component.set("v.criteriaMsgInv",'No Vouchers Found');
                    //helper.showToast('Error!','error','Stripe Id is not linked for this vendor');
                    //$A.get("e.force:closeQuickAction").fire();
                }
                
             }
        });
        $A.enqueueAction(action);
	},
    
	myAction : function(component, event, helper) {
		//alert(component.get("v.recordId"));
        var action = component.get("c.fetchVoucherDetails");
        action.setParams({vId:component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() != null && response.getReturnValue().ERP7__Vendor__r.ERP7__Stripe_Account_Id__c){
                    component.set("v.voucher",response.getReturnValue());
                }else{
                    helper.showToast('Error!','error','Stripe Id is not linked for this vendor');
                    $A.get("e.force:closeQuickAction").fire();
                }
                
             }
        });
        $A.enqueueAction(action);
	},
    
    recordPayment : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.recordStripePayment");
        action.setParams({'vId':component.get("v.recordId"), 'Amount':component.get("v.payAmount")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() != null && response.getReturnValue() == 'success'){
                    helper.showToast('Success!','success','Payment sent successfully');
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.showMmainSpin",false);
                }else{
                    component.set("v.showMmainSpin",false);
                    helper.showToast('Error!','error',response.getReturnValue());
                    //helper.showToast('Error!','error','Stripe Id is not linked for this vendor');
                    //$A.get("e.force:closeQuickAction").fire();
                }
                
             }
        });
        $A.enqueueAction(action);
    },
    
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    checkboxSelect : function(component, event, helper) {
        var SelectedId = event.getSource().get("v.name");
        var selectedVOUList =[];
        selectedVOUList = component.get("v.SelVouchers");
        if(event.getSource().get("v.checked")){
            selectedVOUList.push(SelectedId);
         }else{
            for(var x =0;x < selectedVOUList.length;x++){
                if(selectedVOUList[x] === SelectedId){
                    selectedVOUList.splice(x,1);
                    break;
                } 
                
            }
        }
        component.set("v.SelVouchers",selectedVOUList);
    },
    
    schedulePay : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.scheduleStripePayment");
        action.setParams({'VIds':component.get("v.SelVouchers"), 'VendorId':component.get("v.vId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() != null && response.getReturnValue() == 'success'){
                    helper.showToast('Success!','success','Payment Scheduled successfully');
                    component.set("v.showMmainSpin",false);
                    var showModal = component.get('v.showModal');
                    component.set('v.showModal', !showModal);
                    $A.enqueueAction(component.get("c.fetchDetails"));
                }else{
                    component.set("v.showMmainSpin",false);
                    helper.showToast('Error!','error',response.getReturnValue());
                }
                
             }
        });
        $A.enqueueAction(action);
    },
    
    closeModal : function(component, event, helper) {
        var showModal = component.get('v.showModal');
        component.set('v.showModal', !showModal);
    },
    
    openConfirmDialog : function(component, event, helper) {
        var showModal = component.get('v.showModal');
        component.set('v.showModal', !showModal);
    },
})