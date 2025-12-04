({
	getAllDetails : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.getAll");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                cmp.set("v.Filter", response.getReturnValue().Filter);
                cmp.set("v.Cards", response.getReturnValue().Cards);
                cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                if(response.getReturnValue().Cards.length == 0 && response.getReturnValue().errorMsg == ''){
                    cmp.set("v.errorMsg", 'Sorry records unavailable');
                } 
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchAllDetails : function(cmp, event, helper) {
        var filter = cmp.get("v.Filter");
        var sType = cmp.get("v.Type");
        cmp.set("v.errorMsg",'');
        if(filter.ERP7__Product__c != undefined && filter.ERP7__Product__c != null && filter.ERP7__Product__c != ""){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            cmp.set("v.SelectedRouting","");
            cmp.set("v.SelectedLoc","");
            if(filter.Name == undefined) filter.Name = '';
            var action = cmp.get("c.fetchAll");
            action.setParams({"productId":filter.ERP7__Product__c,"Location":filter.Name,"Type":sType});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.Cards", response.getReturnValue().Cards);
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    if(response.getReturnValue().Cards.length == 0 && response.getReturnValue().errorMsg == '') {
                        cmp.set("v.errorMsg", 'Sorry records unavailable');
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        } else cmp.set("v.errorMsg",'Please select the product');
    },
    
    Toggle : function (cmp, event) {
        var locId = event.currentTarget.getAttribute('data-name');
        var RId = event.currentTarget.getAttribute('data-title');
        var obj = cmp.get("v.Cards");
        for(var x in obj){
            if(obj[x].AddressId == locId) { 
                for(var y in obj[x].Routings){
                    if(obj[x].Routings[y].Id == RId){
                        cmp.set("v.SelectedRouting",obj[x].Routings[y]);
                        cmp.set("v.SelectedLoc",locId);
                        break;
                    }
                }
            }
        }
    },
    
    NavWO : function (cmp, event) {
        var selectedRouting = cmp.get("v.SelectedRouting");
        var RId = selectedRouting.Id;
        if(RId != undefined && RId != ""){
            var obj = cmp.get("v.Cards");
            for(var x in obj){
                for(var y in obj[x].Routings){
                    if(obj[x].Routings[y].Id == RId){
                        var pId = obj[x].Routings[y].ERP7__Product__c;
                        var rId = obj[x].Routings[y].Id;
                        var ver = obj[x].Routings[y].ERP7__BOM_Version__c;
                        var RecUrl = "/apex/ERP7__WorkOrderLC?rd=yes&nav=scheduler&pId="+pId+"&rId="+rId+"&ver="+ver+"&quan=";
                        $A.get("e.force:navigateToURL").setParams(
                        {"url": RecUrl}).fire();
                    }
                }
            }
            
        }
    },
    
    NavMO : function (cmp, event) {
        var selectedRouting = cmp.get("v.SelectedRouting");
        var RId = selectedRouting.Id;
        if(RId != undefined && RId != ""){
            var obj = cmp.get("v.Cards");
            for(var x in obj){
                for(var y in obj[x].Routings){
                    if(obj[x].Routings[y].Id == RId){
                        var pId = obj[x].Routings[y].ERP7__Product__c;
                        var rId = obj[x].Routings[y].Id;
                        var ver = obj[x].Routings[y].ERP7__BOM_Version__c;
                        var RecUrl = "/apex/ERP7__ManufacturingOrderLC?rd=yes&nav=scheduler&pId="+pId+"&rId="+rId+"&ver="+ver+"&quan=";
                        $A.get("e.force:navigateToURL").setParams(
                        {"url": RecUrl}).fire(); 
                    }
                }
            }
            
        }
    },
    
    Proceed2MO : function (cmp, event) {
        var selectedRouting = cmp.get("v.SelectedRouting");
        var RId = selectedRouting.Id;
        if(RId != undefined && RId != ""){
        	$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.Proceed2MODetails");
            action.setParams({"RId":RId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    //alert(response.getReturnValue().errorMsg);
                    //alert(response.getReturnValue().WOS.length);
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    cmp.set("v.MO", response.getReturnValue().MO);
                    cmp.set("v.WOS", response.getReturnValue().WOS);
                    if(response.getReturnValue().WOS.length == 0 && response.getReturnValue().errorMsg == '') {
                        cmp.set("v.errorMsg", 'Sorry, operations unavailable');
                    }
                    if(response.getReturnValue().WOS.length > 0){
                        //alert('In');
                        cmp.set("v.proceed", true);
                    } 
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        } 
    },
    
    Back : function (cmp, event) {
    	cmp.set("v.proceed",false);
    },
    
    closeError : function (cmp, event) {
    	cmp.set("v.errorMsg",'');
    },
})