({
	Configure : function(cmp, event, helper) {
        var RId = cmp.get("v.RId"); 
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.ConfigureMO");
        action.setParams({"RId":RId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state); 
            if (state === "SUCCESS") {
                cmp.set("v.NewVersion", response.getReturnValue().SelectedVersion);
                cmp.set("v.NewRouting", response.getReturnValue().SelectedRouting);
                if(response.getReturnValue().SelectedRouting.Name == undefined) cmp.set("v.RoutingConfigure", false);
                else cmp.set("v.RoutingConfigure", true);
                cmp.set("v.SelectedRouting", response.getReturnValue().Routing);
                cmp.set("v.SelectedVersion", response.getReturnValue().Version);
                cmp.set("v.BOMS", response.getReturnValue().BOMS);
                cmp.set("v.BOMWrapperList", response.getReturnValue().BOMWrapperList);
                cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    
    Back : function(cmp, event, helper) {
        $A.createComponent("c:WorkCenterSchedule",{
            "VerId": cmp.get("v.SelectedRouting").ERP7__BOM_Version__c,
            "RouId": cmp.get("v.SelectedRouting").Id,
            "ProId": cmp.get("v.SelectedRouting").ERP7__Product__c
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    VarianceSelection : function(cmp, event, helper) {
        var count = event.getSource().get("v.name");
        var value = event.getSource().get("v.checked");
        var recId = event.getSource().get("v.value");
        var BOMWrapperList = cmp.get("v.BOMWrapperList");
        if(value == true){
            for(var y in BOMWrapperList){
                var BOMWrapper = BOMWrapperList[y];
                if(y == count){
                    if(BOMWrapper.BOM.Id == recId){
                        for(var x in BOMWrapper.Variances){
                            BOMWrapper.Variances[x].ERP7__Active__c = false;
                        }
                    } else{
                        BOMWrapper.BOM.ERP7__Active__c = false;
                        for(var x in BOMWrapper.Variances){
                            if(BOMWrapper.Variances[x].Id != recId) BOMWrapper.Variances[x].ERP7__Active__c = false;
                        }
                    }
                }
    		}
        }
        cmp.set("v.BOMWrapperList",BOMWrapperList);
    },
    
    Confirm : function(cmp, event, helper){
        var BOMWrapperList = cmp.get("v.BOMWrapperList");
        var NewRouting = cmp.get("v.NewRouting");
        var NewVersion = cmp.get("v.NewVersion");
        cmp.set("v.errorMsg","");
        if(NewRouting.Name == undefined || NewRouting.Name == "" || NewVersion.Name == undefined || NewVersion.Name == "")
            cmp.set("v.errorMsg","Required fields are missing");
        else {
            var error = false;
            for(var y in BOMWrapperList){
                var BOMWrapper = BOMWrapperList[y];
                var exist = false;
                if(BOMWrapper.BOM.ERP7__Active__c == true){
                    exist = true;
                } else{
                    for(var x in BOMWrapper.Variances){
                        if(BOMWrapper.Variances[x].ERP7__Active__c == true) {
                            exist = true;
                            break;
                        }
                    }
                }
                if(!exist) {
                    cmp.set("v.errorMsg","Sorry cannot confirm, configuration is incomplete");
                    error = true;
                    break;
                }
            } 
            if(!error){
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            	var action = cmp.get("c.SaveConfiguration");
                action.setParams({"BOMWrapperList":JSON.stringify(BOMWrapperList), "RoutingId":cmp.get("v.SelectedRouting").Id, "NewRouting":JSON.stringify(NewRouting), "NewVersion":JSON.stringify(NewVersion)});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                        cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                        if(response.getReturnValue().errorMsg == ''){
                            $A.createComponent("c:WorkCenterSchedule",{
                                "VerId": response.getReturnValue().SelectedRouting.ERP7__BOM_Version__c,
                                "RouId": response.getReturnValue().SelectedRouting.Id,
                                "ProId": response.getReturnValue().SelectedRouting.ERP7__Product__c
                            },function(newCmp, status, errorMessage){
                                if (status === "SUCCESS") {
                                    var body = cmp.find("body");
                                    body.set("v.body", newCmp);
                                }
                            });
                        }
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    ConfirmNew : function(cmp, event, helper) {
        var BOMWrapperList = cmp.get("v.BOMWrapperList");
        var NewVersion = cmp.get("v.NewVersion");
        cmp.set("v.errorMsg","");
        if(NewVersion.Name == undefined || NewVersion.Name == "")
            cmp.set("v.errorMsg","Required fields are missing");
        else {
            var error = false;
            for(var y in BOMWrapperList){
                var BOMWrapper = BOMWrapperList[y];
                var exist = false;
                if(BOMWrapper.BOM.ERP7__Active__c == true){
                    exist = true;
                } else{
                    for(var x in BOMWrapper.Variances){
                        if(BOMWrapper.Variances[x].ERP7__Active__c == true) {
                            exist = true;
                            break;
                        }
                    }
                }
                if(!exist) {
                    cmp.set("v.errorMsg","Sorry cannot confirm, configuration is incomplete");
                    error = true;
                    break;
                }
            } 
            if(!error){
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            	var action = cmp.get("c.SaveConfigurationVersion");
                action.setParams({"BOMWrapperList":JSON.stringify(BOMWrapperList), "VersionId":cmp.get("v.SelectedVersion").Id, "NewVersion":JSON.stringify(NewVersion)});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                        cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                        if(response.getReturnValue().errorMsg == ''){
                            var recordId = response.getReturnValue().SelectedVersion.Id;
                            var sObjectUrl='https://'+window.location.hostname.split('--')[0]+'.lightning.force.com/lightning/r/ERP7__Version__c/'+recordId+'/view';
                            window.open(sObjectUrl,'_parent');
                    	}
                    } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
        }
    },
     
    closeError : function (cmp, event) {
    	cmp.set("v.errorMsg",'');
    },
})