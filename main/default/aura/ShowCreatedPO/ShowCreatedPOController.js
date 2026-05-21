({
    init : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var initaction = component.get('c.showPO');
        initaction.setParams({"POlist":JSON.stringify(component.get('v.CreatedPOPOLIs'))});
        initaction.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var obj  = response.getReturnValue();
                console.log('obj : '+JSON.stringify(obj));
                for(var x in obj){
                    obj[x].selected = false;
                }
                component.set('v.CreatedPOPOLIs',obj);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(initaction);
        console.log('Inside ShowCreatePo Controller : ',component.get('v.submitApproval'));
    },
    cancelclick : function(cmp, event, helper) {
        if(cmp.get('v.fromAP')) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Accounts_Payable",
                componentAttributes: {
                    "aura:id": "AccountsPayable",
                    "selectedTab":"Purchase_Orders"
                }
            });
            evt.fire();
        }
        else{
            var returl = '/lightning/n/ERP7__Multi_Purchase_Orders';
            window.open(returl,'_parent');
        }
        
    },
    gotoMO : function(component, event, helper) {
        console.log('MOId bfr: ',component.get('v.MOId'));
        var MoId = component.get("v.MOId");
        $A.createComponent("c:Manufacturing_Orders",{
            "MO": MoId,
            "NAV":'mp',
            "RD":'yes',
            "allowNav" : true
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                console.log('MOId inside: ',component.get('v.MOId'));
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
        /*if(cmp.get('v.MOId')){//added by asra 16/11
             console.log('MOId inside: ',cmp.get('v.MOId'));
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Manufacturing_Orders",
                componentAttributes: {
                    "MO": cmp.get('v.MOId'), 
                }
            });
            evt.fire();
        }*/
    },
    handleEdit : function(component, event, helper) {
        var recId = event.getSource().get('v.name');
        //var recId = event.currentTarget.dataset.record;
        console.log('recId : ',recId);
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
     let oldpoli = [];
        oldpoli.push(recId);
        $A.createComponent("c:ShowAllPOLIAndPO",{
            "poliIds":oldpoli,
            "ALLPO" : component.get('v.CreatedPOPOLIs'),
            "editenableUnitPrice" : true,
            "fromCreatePO" : true,
            "dChannelId" : component.get('v.dChannelId'),
            "dChannelName" : component.get('v.dChannelName'),
            "ChannelName" : component.get('v.ChannelName'),
            "channelId" :  component.get('v.channelId'),
            "showfileUpload" : component.get('v.showfileUpload'),
            "showAllocations" : component.get('v.showAllocations'),
            "submitApproval" : component.get('v.submitApproval'),
            "MOId" : component.get('v.MOId'),
            "plolist" : component.get('v.plolist'),
            "addressRequired" : component.get('v.addressRequired'),
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        /* $A.createComponent("c:CreatePurchaseOrder",{
            "recordId": recId,
            "fromMultiPO" : true
            
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    SubmitforApproval : function(component, event, helper) {
        var recId = event.getSource().get('v.name');
        console.log('recId : ',recId);
        var lst = [];
        let allPos = component.get('v.CreatedPOPOLIs');
        for(var x in allPos){
            if(allPos[x].Id == recId){
                allPos[x].selected =true;
                lst.push(allPos[x]);
                break;
            }
        }
        console.log('lst :',JSON.stringify(lst));
        component.set('v.POSubmittedforApproval',lst);
        component.set('v.CreatedPOPOLIs',allPos);
        component.set('v.showForm',true);
    },
    closeModel : function(component, event, helper) {
        component.set('v.showForm',false);
    },
    SubmitallforApproval : function(component, event, helper){
        let lst =[];
        let allPos = component.get('v.CreatedPOPOLIs');
        for(var x in allPos){
            if(allPos[x].selected == true) lst.push(allPos[x]);
        }
        if(lst.length > 0){
          component.set('v.POSubmittedforApproval',lst);
            component.set('v.showForm',true);  
        }
        else{
          helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_Please_select_Purchase_Order_to_Submit_for_Approval'));  
        }
        
    },
    //Submitted for Approval
    submitDetails : function(component, event, helper) {
        let lst =[];
        let allPos = component.get('v.CreatedPOPOLIs');
        for(var x in allPos){
            console.log('allPos[x].selected : ',allPos[x].selected);
            if(allPos[x].selected == true){ lst.push(allPos[x]);}
        }
        component.set('v.POSubmittedforApproval',lst);
        var recId = component.get('v.POSubmittedforApproval');
        console.log('recId : ',recId);
        if(recId.length > 0){
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action = component.get('c.updatePOs');
            action.setParams({POs : JSON.stringify(recId)});
            console.log('state : ');
            action.setCallback(this,function(response){
                var state = response.getState();
                console.log('state : ',state);
                if(state==='SUCCESS'){
                    let obj = response.getReturnValue();
                    console.log('obj : ',JSON.stringify(obj));
                    let newpos = [];
                    
                        for(var x in allPos){
                            for(var i in obj){
                            console.log('allPos[x] : ',JSON.stringify(allPos[x]));
                            console.log('allPos[x].Id : ',allPos[x].Id);
                            console.log('obj[x].Id : ',obj[i].Id);
                            if(allPos[x].Id == obj[i].Id) { allPos[x] = obj[i]; }
                           // else newpos.push(allPos[x]);
                           
                        }
                        
                    }
                    console.log('allPos after : ',JSON.stringify(allPos));
                    component.set('v.CreatedPOPOLIs',allPos);
                    component.set('v.showForm',false);
                    component.set('v.checkAll',false);
                    let lst = [];
                    component.set('v.POSubmittedforApproval',lst);
                    helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.PH_Purchase_Order_Submitted_for_Approval'));
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
            
        }
        
    },
    CheckPO : function(component, event, helper) {
        let allPos = component.get('v.CreatedPOPOLIs');
        let lst = [];
        for(var x in allPos){
            console.log('allPos[x] : ',allPos[x].selected);
            if(allPos[x].selected == true) lst.push(allPos[x]);
            
        }
        component.set('v.POSubmittedforApproval',lst);
        
        
    },
    SelectAll : function(component, event, helper) {
        console.log('SelectAll');
    	var cehk = component.get("v.checkAll");//event.target.checked;
        console.log('cehk : ',cehk);
		let allPos = component.get('v.CreatedPOPOLIs');
            for(var x in allPos){
                if(allPos[x].ERP7__Status__c != 'Submitted for Approval') allPos[x].selected = cehk;
                
            }
            component.set('v.CreatedPOPOLIs',allPos);
        	if(cehk == true) component.set('v.POSubmittedforApproval',allPos);
        else if (cehk == false){ let lst = []; component.set('v.POSubmittedforApproval',lst);}
    },
    
})