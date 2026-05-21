({
	doInit : function(component, event, helper) {
		console.log('do init Yodlee Transaction');
    },
    
    fetchTransaction : function(component, event, helper) {
        /*if(component.get("v.bankAccid")==null || component.get("v.bankAccid")==undefined || component.get("v.bankAccid")==''){
            helper.showToast('Error!','error','Please select the Bank Account');
            return;
        }*/
        if(component.get("v.startDate")==null){
            helper.showToast('Error!','error','Please select the Start Date');
            return;
        }
        if(component.get("v.endDate")==null){
            helper.showToast('Error!','error','Please select the End Date');
            return;
        }
        console.log('fetchTransaction');
        component.set("v.showMmainSpin", true);
        var action = component.get("c.getYodleeTransactionList");	
        action.setParams({
            bankAccid : component.get("v.bankAccid"),
            startDate : component.get("v.startDate"),
            endDate : component.get("v.endDate"),
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.transactionList", response.getReturnValue());
                component.set("v.showMmainSpin", false);
            }else{
                component.set("v.showMmainSpin", false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    cancelCalled : function(component, event, helper) {
        history.back();
    }
})