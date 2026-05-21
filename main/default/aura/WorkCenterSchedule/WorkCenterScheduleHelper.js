({
	SaveMO: function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        //cmp.set("v.showSpinner",true);
         console.log('manuOrder : ',JSON.stringify(cmp.get("v.manuOrder")));
        console.log('WOS2Upsert : ',JSON.stringify(cmp.get("v.WOS2Upsert")));
        //try{
        var action = cmp.get("c.SaveM");
       // console.log('manuOrder : ',JSON.stringify(cmp.get("v.manuOrder")));
       // console.log('WOS2Upsert : ',JSON.stringify(cmp.get("v.WOS2Upsert")));
        //after setting start date, expected date and end date of MO and WOS save both
        action.setParams({"MO":JSON.stringify(cmp.get("v.manuOrder")), "WOS":JSON.stringify(cmp.get("v.WOS2Upsert"))});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : ',state);
            //alert('state : '+state);
            if (state === "SUCCESS") {
                console.log('response~>'+JSON.stringify(response.getReturnValue()));
                var WOscreated = response.getReturnValue().WOS;
                if(WOscreated != undefined && WOscreated != null && WOscreated.length > 0){
                    var woaction =cmp.get("c.updateWOs");
                    woaction.setParams({"WOS":JSON.stringify(WOscreated)});
                    woaction.setCallback(this, function(response1) {
                        var state1 = response1.getState();
                        console.log('state1 : ',state1);
                        if (state1 === "SUCCESS") {
                            if(response1.getReturnValue() != null){
                                console.log('response1 : ',response1.getReturnValue());
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                //cmp.set("v.showSpinner",false);
                                if(response.getReturnValue().errorMsg == ''){
                                    if(cmp.get("v.Mtask")){
                                        $A.enqueueAction(cmp.get("c.goBackTask"));
                                    }
                                    else{
                                        var moId = response.getReturnValue().MO.Id;
                                        $A.createComponent("c:Manufacturing_Orders",{
                                            "MO":moId,
                                            "NAV":'scheduler',
                                            "RD":'yes',
                                            allowNav : true
                                        },function(newCmp, status, errorMessage){
                                            if (status === "SUCCESS") {
                                                var body = cmp.find("body");
                                                body.set("v.body", newCmp);
                                            }
                                        });
                                    }
                                }
                                else{ cmp.set('v.errorMsg', response.getReturnValue().errorMsg); }
                                
                            }
                        }
                    });
                    $A.enqueueAction(woaction);
                }
                
            }
            else{
                var errors = response.getError();
                console.log("server error in SaveMO : ", JSON.stringify(errors));
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                //cmp.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(action);//}catch(e){alert(e);}
    },
    
    SaveWO: function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        //cmp.set("v.showSpinner",true);
        var action = cmp.get("c.SaveW");
        //var wo = cmp.get("v.WOS2Upsert")[0];
        action.setParams({"WO":JSON.stringify(cmp.get("v.WorkOrder"))});
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS"){
                if(response.getReturnValue().errorMsg == ''){
                    if(cmp.get("v.Mtask")){
                        $A.enqueueAction(cmp.get("c.goBackTask"));
                    }
                    else{
                        var woId = response.getReturnValue().WO.Id;
                        $A.createComponent("c:Work_Orders",{
                            "WO":woId,
                            "NAV":'scheduler',
                            "RD":'yes'
                        },function(newCmp, status, errorMessage){
                            if (status === "SUCCESS") {
                                var body = cmp.find("body");
                                body.set("v.body", newCmp);
                            }
                        });
                    }
                }
            	$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                //cmp.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    
})