({
	getAllDetails : function(cmp, event, helper) {
        var mpsId = cmp.get("v.MPSId");
        var FromSRR=cmp.get("v.SRR");
        var prod=cmp.get("v.ProdId");
        let currentProduct = cmp.get("v.SelectedProduct");
        console.log('SelectedProduct : ',JSON.stringify(currentProduct));
        let MPS = {};
        if(currentProduct != null) MPS = {sObjectType :'ERP7__MPS__c',ERP7__Default_Demand_Forecast__c : (currentProduct.MRPDemand + currentProduct.OrdDemand),ERP7__Start_Date__c : currentProduct.StartDate,ERP7__End_Date__c :currentProduct.EndDate,ERP7__Lot_Size__c : (currentProduct.toProduce == 0) ? currentProduct.rrRule.ERP7__Minimum_Quantity__c : currentProduct.toProduce,ERP7__Minimum_Inventory_Level__c :currentProduct.rrRule.ERP7__Minimum_Quantity__c,ERP7__Product__c :currentProduct.Prod.Id,ERP7__Starting_Inventory__c : currentProduct.NetInventory   };
        console.log('MPS : ',MPS);
        if(FromSRR == 'true'){
        var action = cmp.get("c.getAllSTockRR"); 
            action.setParams({ mpsId : mpsId , onload:cmp.get("v.onloadDate"),ProdId : prod,MPSDetails : JSON.stringify(MPS)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    console.log('response getAllSTockRR : ',response.getReturnValue());
                	cmp.set("v.prevent", true);
                    cmp.set("v.MPS", response.getReturnValue());
                  
                    cmp.set("v.Dirty", response.getReturnValue().Dirty);
                    cmp.set("v.Dirtys", response.getReturnValue().Dirtys);
                    //cmp.find("mpsStatus").set("v.options", response.getReturnValue().mpsStatus);
                    cmp.set("v.mpsStatusOptions",response.getReturnValue().mpsStatus);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    //alert(response.getReturnValue().errMsg);
                    //alert(response.getReturnValue().MPS.ERP7__Schedule_Period__c);
                    //alert(response.getReturnValue().MPSLines.length);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    
                    var version = cmp.get('v.MPS.MPS.ERP7__Version__c');
                    console.log('version : ',version);
                    if(version != null && version != undefined && version != '') {
                        helper.getBOMS(cmp,event, helper);
                    }else helper.helperEvaluate(cmp);
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
        }else{
           var action = cmp.get("c.getAll"); 
        action.setParams({ mpsId : mpsId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    console.log('response getAll : ',response.getReturnValue());
                	cmp.set("v.MPS", response.getReturnValue());
                    cmp.set("v.Dirty", response.getReturnValue().Dirty);
                    cmp.set("v.Dirtys", response.getReturnValue().Dirtys);
                    //cmp.find("mpsStatus").set("v.options", response.getReturnValue().mpsStatus);
                    cmp.set("v.mpsStatusOptions",response.getReturnValue().mpsStatus);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    //alert(response.getReturnValue().errMsg);
                    //alert(response.getReturnValue().MPS.ERP7__Schedule_Period__c);
                    //alert(response.getReturnValue().MPSLines.length);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action); 
        }
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    MOorWO: function (cmp, event) {
        var RecId = event.getSource().get("v.title");
        var action = cmp.get("c.MO_WO_URL");
        action.setParams({ RecId : RecId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() !== ""){
                    var RecUrl = response.getReturnValue();
                    window.open(RecUrl,'_blank');
                    //$A.get("e.force:navigateToURL").setParams(
                    //{"url": RecUrl}).fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    Dirty : function (cmp, event) {
        cmp.set("v.Dirty", true);
        cmp.set("v.Dirtys", true);
    },
    
    DirtyChange : function (cmp, event) {
        var MPS = cmp.get("v.MPS");
        var count = event.getSource().get("v.name");
        console.log('count : ',count);
        var quantity = event.getSource().get("v.value");
        console.log('quantity : ',quantity);
        for(var x in MPS.MPSS){
            var MPSSSLInes = MPS.MPSS[x].MPSLines;
            console.log('MPSSSLInes : ',MPSSSLInes.length);
            for(var y in MPS.MPSS[x].MPSLines){
                if(count == y) {
                    console.log('match');
                    MPS.MPSS[x].MPSLines[y].MPSLine.ERP7__Demand_Forecast__c = (quantity >= 0 && MPS.MPSS[x].MPS.ERP7__Bill_Of_Material__r.ERP7__Quantity__c >= 0)? (quantity * MPS.MPSS[x].MPS.ERP7__Bill_Of_Material__r.ERP7__Quantity__c) : 0;
                    console.log('MPS.MPSS[x].MPSLines[y].MPSLine.ERP7__Demand_Forecast__c : ',MPS.MPSS[x].MPSLines[y].MPSLine.ERP7__Demand_Forecast__c);
                }               
            }
        }
        cmp.set("v.MPS", MPS);
        cmp.set("v.Dirty", true);
        cmp.set("v.Dirtys", true);
    },
    
    Evaluate : function (cmp, event,helper) {
        window.scrollTo(0, 0);
        helper.helperEvaluate(cmp);
       /* $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var MPS = cmp.get("v.MPS");
        var action = cmp.get("c.Evaluates");
        var MPSS = JSON.stringify(MPS);
        action.setParams({ StrMPS : MPSS });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                try { 
                    console.log('res Evaluates : ',response.getReturnValue());
                	cmp.set("v.MPS", response.getReturnValue());
                	cmp.set("v.Dirty", false);
                    cmp.set("v.Dirtys", true);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);*/
    },
    
    Save : function (cmp, event) {
        window.scrollTo(0, 0);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var MPS = cmp.get("v.MPS");
        var action = cmp.get("c.Saves");
        var MPSS = JSON.stringify(MPS);
        action.setParams({ StrMPS : MPSS });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                try { 
                    console.log('saves response : ',response.getReturnValue());
                	cmp.set("v.MPS", response.getReturnValue());
                	cmp.set("v.Dirty", false);
                    cmp.set("v.Dirtys", false);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    reloadAllDetails: function (cmp, event,helper) {
        window.scrollTo(0, 0);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var MPS = cmp.get("v.MPS");
        var action = cmp.get("c.SavesMPS");
        var MPSS = JSON.stringify(MPS);
        action.setParams({ StrMPS : MPSS });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                try { 
                    console.log('SavesMPS response : ',response.getReturnValue());
                	cmp.set("v.MPS", response.getReturnValue());
                	cmp.set("v.Dirty", false);
                    cmp.set("v.Dirtys", false);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    helper.helperEvaluate(cmp);
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    navigateToSchedular : function(cmp, event, helper){
        var MPSId=event.currentTarget.dataset.record;
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                mrpId : MPSId,
                FromMPS : true,
                MpId : event.currentTarget.getAttribute('data-pId'),
                soliID : event.currentTarget.getAttribute('data-mosoliId'),
                ProId :   event.currentTarget.getAttribute('data-moprId')
            }
        });
        evt.fire();
        /*$A.createComponent("c:WorkCenterSchedule",{
            "mrpId" : MPSId,
                "FromMPS" : true,
                "MpId" : event.currentTarget.getAttribute('data-pId'),
            "soliID" : event.currentTarget.getAttribute('data-mosoliId')
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        
        
        /*var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                
            }
        });
        evt.fire();*/
        
    },
    getVersionBOMs : function(cmp, event, helper){
        console.log('getVersionBOMs called  ');
     if(!cmp.get('v.prevent')){
        var version = cmp.get('v.MPS.MPS.ERP7__Version__c');
        console.log('version : ',version);
        if(version != null && version != undefined && version != ''){
            var action = cmp.get("c.getBomMPS");
            var MPSS = cmp.get("v.MPS.MPS");
            console.log('MPS : ',JSON.stringify(MPSS));
            action.setParams({ StrMPS : JSON.stringify(MPSS),versionId : version ,siteId : cmp.get('v.siteId')});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    try {
                        console.log('res getBomMPS : ',response.getReturnValue());
                        cmp.set("v.MPS", response.getReturnValue());
                        cmp.set("v.Dirty", false);
                        cmp.set("v.Dirtys", false);
                        cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                        cmp.set("v.prevent", true);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        helper.helperEvaluate(cmp);
                    } catch(err) {
                        cmp.set("v.exceptionError", err.message);
                        //alert("Exception : "+err.message);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }
                else{
                    console.log('error getBomMPS : ',response.getError());
                }
            });
            $A.enqueueAction(action);
            
        }  
     }
       
    }
})