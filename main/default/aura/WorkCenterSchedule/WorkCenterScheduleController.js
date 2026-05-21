({
    fetchRoutingInfo : function(cmp, event, helper) {
        console.log('fetchRoutingInfo called : ',cmp.get('v.prodRecordId'));
        try{
            
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var MOId = cmp.get("v.MOId");
            var WOId = cmp.get("v.WOId");
            if(cmp.get('v.prodRecordId') != null && cmp.get('v.prodRecordId') != '' && cmp.get('v.prodRecordId') != undefined){
                cmp.set('v.ProId',cmp.get('v.prodRecordId'));
            }
            var action = cmp.get("c.fetchRoutingDetails");
            console.log('OrdItmId : ',cmp.get("v.OrdItmId"));
            action.setParams({
                "VId"  : cmp.get("v.VerId"),
                "RId"  : cmp.get("v.RouId"),
                "PId"  : cmp.get("v.ProId"),
                "WCId" : "",
                "Flow" : cmp.get("v.Flow"),
                "OrderItemId1" : cmp.get("v.OrdItmId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    console.log('response : ',JSON.stringify(response.getReturnValue()));
                    
                    console.log('stock details : ',response.getReturnValue().prodStocks);
                    cmp.set("v.showPlanner",response.getReturnValue().showPlanner);
                    cmp.set("v.showSheduler",response.getReturnValue().showSheduler);
                    cmp.set("v.showBuilder",response.getReturnValue().showBuilder); 
                    cmp.set("v.Types", response.getReturnValue().Types);
                    cmp.set("v.setVerBasedOnOrdPod", response.getReturnValue().showVerbasedOnOrder);
                    if(MOId != undefined && MOId != ''){
                        cmp.set("v.Type", $A.get('$Label.c.Manufacturing_Order'));
                        cmp.fetchProducts();
                    } 
                    else if(WOId != undefined && WOId != ''){
                        cmp.set("v.Type", $A.get('$Label.c.Work_Order'));
                        cmp.fetchProducts();
                    } else {
                        cmp.set("v.Prevent", true);
                        cmp.set("v.Type", response.getReturnValue().Type);
                        cmp.set("v.Routings", response.getReturnValue().Routings);
                        cmp.set("v.Versions", response.getReturnValue().Versions);
                        cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                        cmp.set("v.VersionId", response.getReturnValue().SelectedVersion.Id);
                        cmp.set("v.Products", response.getReturnValue().prodStocks);
                        console.log('Products : ',response.getReturnValue().prodStocks);
                        cmp.set("v.SelectedProduct", response.getReturnValue().SelectedProduct);
                        cmp.set('v.isStandardOrd',response.getReturnValue().StandOrder);
                        if(response.getReturnValue().StandOrder){
                            cmp.set("v.SoliItems", response.getReturnValue().OrderItems);
                            cmp.set("v.SelectedSoliItem", response.getReturnValue().SelectedOrderItems);
                        }
                        else {
                            cmp.set("v.Solis", response.getReturnValue().Solis);
                            cmp.set("v.SelectedSoli", response.getReturnValue().SelectedSoli);
                        }
                        cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                        cmp.set("v.WOS", response.getReturnValue().WOS);
                        cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                        cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                       // console.log('v.QTY : ',cmp.get("v.OrdItmId"));
                         console.log('v.QTY : ',cmp.get("v.QTY"));
                       // if(cmp.get("v.QTY") == null || cmp.get("v.QTY") == undefined || cmp.get("v.QTY") == ''){
                            if(cmp.get("v.OrdItmId") != null && cmp.get("v.OrdItmId") != '' && cmp.get("v.OrdItmId") != undefined)   cmp.set("v.QTY", response.getReturnValue().selecteQty);
                            else cmp.set("v.QTY", response.getReturnValue().qtyMultiplier);
                            
                            if(response.getReturnValue().StandOrder){
                                //cmp.set("v.QTY", cmp.get("v.SelectedSoliItem.Quantity"));
                                cmp.set("v.QTY", cmp.get("v.SelectedSoliItem.ERP7__MO_Remaining_Quantity__c"));
                            }
                            else cmp.set("v.QTY", cmp.get("v.SelectedSoli.ERP7__MO_Remaining_Quantity__c"));//cmp.set("v.QTY", cmp.get("v.SelectedSoli.ERP7__Quantity__c")); 
                       //}//
                        console.log('v.QTY after: ',cmp.get("v.QTY"));
                        cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                        var qry;
                        if(response.getReturnValue().SelectedProduct.Id == undefined) qry = ' ';
                        else qry = ' And ERP7__Status__c = \'Certified\' And ERP7__Active__c = true And ERP7__To_Date__c >= TODAY And ERP7__Product__c = \''+response.getReturnValue().SelectedProduct.Id+'\'';
                        cmp.set("v.qry",qry);
                        //alert(response.getReturnValue().errorMsg);
                        cmp.set("v.Prevent", false);
                        cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                       	if(cmp.get('v.SuggestedQTY') > 0) cmp.set("v.QTY",cmp.get('v.SuggestedQTY'));
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //cmp.set("v.showSpinner",false);
                        setTimeout(
                            $A.getCallback(function() {
                                try{
                                    if(cmp.get("v.Type") == 'Product' && cmp.get("v.SelectedProduct") != null && cmp.get("v.SelectedProduct") == '' && cmp.get("v.SelectedProduct") != undefined){
                                        var uscroll = document.getElementById(cmp.get("v.SelectedProduct").Id);
                                        uscroll.scrollIntoView();
                                    } else if(response.getReturnValue().Type == 'Sales Order' && cmp.get("v.SelectedProduct") != null && cmp.get("v.SelectedProduct") == '' && cmp.get("v.SelectedProduct") != undefined){
                                        var uscroll = document.getElementById(cmp.get("v.SelectedSoli").Id);
                                        uscroll.scrollIntoView();
                                    }
                                } catch(e){ console.log('*** AutoScroll Error 1 : '+e); } 
                            }), 1000
                        );
                    }  
                }
            });
            $A.enqueueAction(action);
        } catch(e){ console.log('*** AutoScroll Error 2 : '+e); } 
    },
    
    
    //Added this for not navigating back to home page 
    
    NavScheduler: function(component, event, helper) {
    console.log("NavScheduler clicked!");

    // Prevent page reload
    event.preventDefault();

    // Get the tab to show
    let tabToShow = document.getElementById("timetracking");
    if (tabToShow) {
        tabToShow.scrollIntoView({ behavior: "smooth" });
    } else {
        console.warn("timetracking section not found!");
    }
},
    
    fetchProductRoutingInfo : function(cmp, event, helper) {
        try{
            var pId = event.currentTarget.getAttribute('data-pId');
            console.log('pId : ',pId);
            var sId = event.currentTarget.getAttribute('data-sId');
            var count = event.currentTarget.getAttribute('data-count');
            
            if(sId != '' && cmp.get('v.Type') == 'Sales Order'){
                if(cmp.get("v.isStandardOrd")) {
                    cmp.set("v.SelectedSoliItem", cmp.get("v.SoliItems")[count]);
                    cmp.set('v.OrdItmId',cmp.get("v.SelectedSoliItem.Id"));
                }
                else cmp.set("v.SelectedSoli", cmp.get("v.Solis")[count]);
            }
            else  cmp.set('v.OrdItmId','');
            //var selectedDate = cmp.get("v.selDate"); commented  because getting comp error
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var action = cmp.get("c.fetchRoutingDetails");
            action.setParams({"VId":"", "RId":"", "PId":pId, "WCId":"", "Flow":cmp.get("v.Flow"), "OrderItemId1" : cmp.get("v.OrdItmId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    console.log('fetchProductRoutingInfo res: ',response.getReturnValue());
                    cmp.set("v.Prevent", true);
                    cmp.set("v.isChanged", false);
                    cmp.set("v.VersionId", response.getReturnValue().SelectedVersion.Id);
                    cmp.set("v.isChanged", true);
                    cmp.set("v.Versions", response.getReturnValue().Versions);
                    cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                    cmp.set("v.Routings", response.getReturnValue().Routings);
                    cmp.set("v.SelectedProduct", response.getReturnValue().SelectedProduct);
                    
                    cmp.set("v.WOS", response.getReturnValue().WOS);
                    cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                    cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                    if(response.getReturnValue().selecteQty != 0) cmp.set("v.QTY", response.getReturnValue().selecteQty);
                    else cmp.set("v.QTY", response.getReturnValue().qtyMultiplier);
                    if(cmp.get("v.isStandardOrd")) {
                        cmp.set("v.QTY", cmp.get("v.SelectedSoliItem.Quantity"));
                    }
                    else cmp.set("v.QTY", cmp.get("v.SelectedSoli.ERP7__Quantity__c"));
                        
                    console.log('QTY **** : ',cmp.get("v.QTY"));
                    cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                    cmp.set("v.Prevent", false);
                    //cmp.set('v.ItemsInStock',response.getReturnValue().Stock);
                    //cmp.set('v.demand',response.getReturnValue().Demand);
                    //cmp.set('v.AwaitingStock',response.getReturnValue().AwaitingStk);
                   
                    var WOOS = cmp.get("v.WOS")
                   
                    var qry;
                    if(response.getReturnValue().SelectedProduct.Id == undefined) qry = ' ';
                    else qry = ' And ERP7__Status__c = \'Certified\' And ERP7__Active__c = true And ERP7__To_Date__c >= TODAY And ERP7__Product__c = \''+response.getReturnValue().SelectedProduct.Id+'\'';
                    cmp.set("v.qry",qry);
                      
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.set("v.showSpinner",false);
                    setTimeout(
                        $A.getCallback(function() {
                            try{
                                if(cmp.get("v.Type") == 'Product'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedProduct").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Sales Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedSoli").Id);
                                    uscroll.scrollIntoView();
                                }
                            } catch(e){ console.log('*** AutoScroll Error 3 : '+e); } 
                        }), 1000
                    );             
                }
            });
            $A.enqueueAction(action);
            
        } catch(e){ console.log('*** Catch error =>'+e); } 
    },
    
    fetchProductRoutingInfo2 : function(cmp, event, helper) {
        try{
            var pId = cmp.get("v.pId");
            var sId = cmp.get("v.sId");
            var count = cmp.get("v.count");
            
            if(sId != ''){
                cmp.set("v.SelectedSoli", cmp.get("v.Solis")[count]);
            }
           // var selectedDate = cmp.get("v.selDate"); commented by shaguftha because getting comp error
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var action = cmp.get("c.fetchRoutingDetails");
            action.setParams({"VId":"", "RId":"", "PId":pId, "WCId":"", "Flow":cmp.get("v.Flow"), "OrderItemId1" : cmp.get("v.OrdItmId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.Prevent", true);
                    cmp.set("v.isChanged", false);
                    cmp.set("v.VersionId", response.getReturnValue().SelectedVersion.Id);
                    cmp.set("v.isChanged", true);
                    cmp.set("v.Versions", response.getReturnValue().Versions);
                    cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                    cmp.set("v.Routings", response.getReturnValue().Routings);
                    cmp.set("v.SelectedProduct", response.getReturnValue().SelectedProduct);
                    console.log('Selected Products:',cmp.get("v.SelectedProduct"));
                    cmp.set("v.WOS", response.getReturnValue().WOS);
                    cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                    cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                    cmp.set("v.QTY", response.getReturnValue().qtyMultiplier);
                    console.log('QTY **** 2: ',cmp.get("v.QTY"));
                    cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                    cmp.set("v.Prevent", false);
                    var qry;
                    if(response.getReturnValue().SelectedProduct.Id == undefined) qry = ' ';
                    else qry = ' And ERP7__Status__c = \'Certified\' And ERP7__Active__c = true And ERP7__To_Date__c >= TODAY And ERP7__Product__c = \''+response.getReturnValue().SelectedProduct.Id+'\'';
                    cmp.set("v.qry",qry);
                    
                    cmp.set("v.pId", "");
                    cmp.set("v.sId", "");
                    cmp.set("v.count", "");
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.set("v.showSpinner",false);
                }
            });
            $A.enqueueAction(action);
            
        } catch(e){ cmp.set("v.errorMsg", e); } 
    },
    
    RoutingChange : function(cmp, event, helper) {
        var SelectedRouting = cmp.get("v.SelectedRouting");
        var Type = cmp.get("v.Type");
        cmp.set("v.Configure", true);
        if(SelectedRouting != undefined && SelectedRouting.Id != undefined && SelectedRouting.ERP7__Product__r.ERP7__Configure__c == true && Type != 'Work Order' && Type != 'Manufacturing Order')
            cmp.set("v.Configure", true);
        else cmp.set("v.Configure", false);
        console.log('RoutingChange called');
        //alert('fetchSpecificRoutingInfo'+SelectedRouting.Name);
        //cmp.fetchSpecificRoutingInfo();
    },
    
    VersionChange : function(cmp, event, helper) {
        var versionId = cmp.get("v.SelectedVersion").Id;
        
        if(!cmp.get("v.Prevent") && versionId != undefined && versionId != ''){
            console.log('VersionChange called');
            cmp.fetchVersionRoutingInfo();
        }
    },
    
    fetchVersionRoutingInfo : function(cmp, event, helper) {
        try{
            var pId = cmp.get("v.SelectedProduct").Id;
            var versionId = cmp.get("v.SelectedVersion").Id;
            if(!cmp.get("v.Prevent") && versionId != undefined && versionId != ''){
                //alert(versionId);
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                //cmp.set("v.showSpinner",true);
                var action = cmp.get("c.fetchRoutingDetails");
                action.setParams({"VId":versionId, "RId":"", "PId":pId, "WCId":"", "Flow":cmp.get("v.Flow"), "OrderItemId1" : cmp.get("v.OrdItmId")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        cmp.set("v.Prevent", true);
                        cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                        cmp.set("v.VersionId", response.getReturnValue().SelectedVersion.Id);
                        cmp.set("v.Routings", response.getReturnValue().Routings);
                        cmp.set("v.SelectedProduct", response.getReturnValue().SelectedProduct);
                        cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                        cmp.set("v.WOS", response.getReturnValue().WOS);
                        cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                        cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                        if(cmp.get("v.QTY") == null || cmp.get("v.QTY") == 0 || cmp.get("v.QTY") == undefined) cmp.set("v.QTY", response.getReturnValue().qtyMultiplier);
                        console.log('QTY **** 3: ',cmp.get("v.QTY"));
                        cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                        cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                        //alert(response.getReturnValue().errorMsg);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //cmp.set("v.showSpinner",false);
                        cmp.set("v.Prevent", false);
                        
                        setTimeout(
                            $A.getCallback(function() {
                                try{
                                    if(cmp.get("v.Type") == 'Product'){
                                        var uscroll = document.getElementById(cmp.get("v.SelectedProduct").Id);
                                        uscroll.scrollIntoView();
                                    } else if(response.getReturnValue().Type == 'Sales Order'){
                                        var uscroll = document.getElementById(cmp.get("v.SelectedSoli").Id);
                                        uscroll.scrollIntoView();
                                    }
                                } catch(e){ console.log('*** AutoScroll Error 4: '+e); }
                            }), 1000
                        );
                    }
                });
                $A.enqueueAction(action);
            }
        } catch(e){ console.log('*** Catch error =>'+e); } 
    },
    
    fetchSpecificRoutingInfo : function(cmp, event, helper) {
        try{
            var routingId = cmp.get("v.RoutingId");
            var versionId = cmp.get("v.VersionId");
            var pId = cmp.get("v.SelectedProduct").Id;
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var action = cmp.get("c.fetchRoutingDetails");
            action.setParams({"VId":versionId, "RId":routingId, "PId":pId, "WCId":"", "Flow":cmp.get("v.Flow"), "OrderItemId1" : cmp.get("v.OrdItmId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.Prevent", true);
                    cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                    cmp.set("v.WOS", response.getReturnValue().WOS);
                    cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                    cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                    if(cmp.get("v.QTY") == null || cmp.get("v.QTY") == undefined || cmp.get("v.QTY") == '') cmp.set("v.QTY", response.getReturnValue().qtyMultiplier);
                    console.log('QTY **** 4: ',cmp.get("v.QTY"));
                    cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    //alert(response.getReturnValue().errorMsg);
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.set("v.showSpinner",false);
                    cmp.set("v.Prevent", false);
                    
                    setTimeout(
                        $A.getCallback(function() {
                            try{
                                if(cmp.get("v.Type") == 'Product'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedProduct").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Sales Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedSoli").Id);
                                    uscroll.scrollIntoView();
                                }
                            } catch(e){ console.log('*** AutoScroll Error 5: '+e); }    }), 1000
                    );
                }
            });
            $A.enqueueAction(action);
        } catch(e){ console.log('*** Catch error =>'+e); } 
    },
    
    QTY : function(cmp, event, helper) {
        var qty = event.currentTarget.getAttribute('data-name');
        var multiplier = cmp.get("v.qtyMultiplier");
       if(cmp.get("v.Type") != 'Manufacturing Order') cmp.set("v.QTY", qty*multiplier); 
        console.log('QTY **** 5: ',cmp.get("v.QTY"));
    }, 
    
    fetchProducts : function(cmp, event, helper) {
        cmp.set("v.errorMsg",'');
        var type = cmp.get("v.Type");
        var searchString = cmp.get("v.searchStr");
        cmp.set("v.WOS",[])
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        //cmp.set("v.showSpinner",true);
        var action = cmp.get("c.fetchAllProducts");
        console.log('searchStr:',searchString);
        action.setParams({
            "searchStr":searchString,
            "Type":type,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                console.log('prodStocks',response.getReturnValue().prodStocks);
                cmp.set("v.Products", response.getReturnValue().prodStocks);
                cmp.set("v.Solis", response.getReturnValue().Solis);
                cmp.set("v.MOS", response.getReturnValue().MOS);
                cmp.set("v.WorkOrders", response.getReturnValue().WOS);
                cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                //cmp.set("v.showSpinner",false);
               try{
                    if(cmp.get("v.Type") == 'Product' && response.getReturnValue().Products.length > 0){
                        cmp.set("v.pId",response.getReturnValue().Products[0].Id);
                        cmp.set("v.sId","");
                        cmp.set("v.count","0");
                        cmp.fetchProductRoutingInfo2();
                    } else if(cmp.get("v.Type") == 'Sales Order'){
                        cmp.set("v.pId",response.getReturnValue().Solis[0].ERP7__Product__c);
                        cmp.set("v.sId",response.getReturnValue().Solis[0].Id);
                        cmp.set("v.count","0");
                        cmp.fetchProductRoutingInfo2();
                    } else if(cmp.get("v.Type") == 'Manufacturing Order'){
                        var MOId = cmp.get("v.MOId").substring(0,15);
                        if(MOId != undefined && MOId != ''){
                            for(var x in response.getReturnValue().MOS){
                                var cMOId = response.getReturnValue().MOS[x].Id.substring(0,15);
                                if(cMOId == MOId){
                                    cmp.set("v.pId", MOId);
                                	cmp.set("v.count", x);
                                    break;
                                }
                            }
                            cmp.set("v.MOId","");
                            cmp.fetchMOInfo2();
                        } 
                        else {
                            cmp.set("v.pId",response.getReturnValue().MOS[0].Id);
                        	cmp.set("v.count","0");
                            cmp.fetchMOInfo2();
                        }
                    } else if(cmp.get("v.Type") == 'Work Order'){
                        var WOId = cmp.get("v.WOId").substring(0,15);
                        if(WOId != undefined && WOId != ''){
                            for(var x in response.getReturnValue().WOS){
                               var cWOId = response.getReturnValue().WOS[x].Id.substring(0,15);
                                if(cWOId == WOId){
                                    cmp.set("v.pId", WOId);
                                	cmp.set("v.count", x);
                                    break;
                                }
                            }
                            cmp.set("v.WOId","");
                            cmp.fetchWOInfo2();
                        } 
                        else { 
                            cmp.set("v.pId",response.getReturnValue().WOS[0].Id);
                            cmp.set("v.count","0");
                            cmp.fetchWOInfo2();
                        }
                    }
                     

               } catch(e){ console.log('*** AutoScroll Error 10: '+e);}
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchProductsonSearch : function(cmp, event, helper) {
        
        //if(event.which == 13){
            var type = cmp.get("v.Type");
            var searchString = cmp.get("v.searchStr");
        	let IsStandard = cmp.get("v.isStandardOrd");
            cmp.set("v.WOS",[])
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var action = cmp.get("c.fetchAllProducts");
            action.setParams({
                "searchStr":searchString,
                "Type":type,
                "Flow":cmp.get("v.Flow")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    console.log('OrderItems***',response.getReturnValue().OrderItems);
                    cmp.set("v.Products", response.getReturnValue().prodStocks);
                    if(!IsStandard)cmp.set("v.Solis", response.getReturnValue().Solis);
                   	if(IsStandard)cmp.set("v.SoliItems", response.getReturnValue().OrderItems);
                   	cmp.set("v.MOS", response.getReturnValue().MOS);
                    cmp.set("v.WorkOrders", response.getReturnValue().WOS);
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.set("v.showSpinner",false);
                    try{
                        if(cmp.get("v.Type") == 'Product' && response.getReturnValue().Products.length > 0){
                            cmp.set("v.pId",response.getReturnValue().Products[0].Id);
                            cmp.set("v.sId","");
                            cmp.set("v.count","0");
                            cmp.fetchProductRoutingInfo2();
                        } else if(cmp.get("v.Type") == 'Sales Order'){
                            
                            
                            if(IsStandard){
                                cmp.set("v.pId",response.getReturnValue().OrderItems[0].Product2.Id);
                                //cmp.set("v.sId",response.getReturnValue().OrderItems[0].Id);
                               	cmp.set("v.OrdItmId",response.getReturnValue().OrderItems[0].Id);
                                cmp.set("v.SelectedSoliItem",response.getReturnValue().OrderItems[0]);
                                cmp.set("v.count","0");
                            }
                            else{
                                cmp.set("v.pId",response.getReturnValue().Solis[0].ERP7__Product__c);
                                cmp.set("v.sId",response.getReturnValue().Solis[0].Id);
                                cmp.set("v.count","0");
                            }
                            
                            cmp.fetchProductRoutingInfo2();
                        } else if(cmp.get("v.Type") == 'Manufacturing Order'){
                            var MOId = cmp.get("v.MOId").substring(0,15);
                            if(MOId != undefined && MOId != ''){
                                for(var x in response.getReturnValue().MOS){
                                    var cMOId = response.getReturnValue().MOS[x].Id.substring(0,15);
                                    if(cMOId == MOId){
                                        cmp.set("v.pId", MOId);
                                        cmp.set("v.count", x);
                                        break;
                                    }
                                }
                                cmp.set("v.MOId","");
                                cmp.fetchMOInfo2();
                            } 
                            else {
                                cmp.set("v.pId",response.getReturnValue().MOS[0].Id);
                                cmp.set("v.count","0");
                                cmp.fetchMOInfo2();
                            }
                        } else if(cmp.get("v.Type") == 'Work Order'){
                            var WOId = cmp.get("v.WOId").substring(0,15);
                            if(WOId != undefined && WOId != ''){
                                for(var x in response.getReturnValue().WOS){
                                    var cWOId = response.getReturnValue().WOS[x].Id.substring(0,15);
                                    if(cWOId == WOId){
                                        cmp.set("v.pId", WOId);
                                        cmp.set("v.count", x);
                                        break;
                                    }
                                }
                                cmp.set("v.WOId","");
                                cmp.fetchWOInfo2();
                            } 
                            else { 
                                cmp.set("v.pId",response.getReturnValue().WOS[0].Id);
                                cmp.set("v.count","0");
                                cmp.fetchWOInfo2();
                            }
                        }
                    } catch(e){ console.log('*** AutoScroll Error 6: '+e); } 
                }
            });
            $A.enqueueAction(action);
        //}
        /*if(event.which == undefined){
            if(cmp.get("v.searchStr") == null || cmp.get("v.searchStr") == undefined || cmp.get("v.searchStr") == ""){
                var action_JS = cmp.get("c.fetchProducts");
                $A.enqueueAction(action_JS);
            }
        }*/
    },
    
    UpdateMO: function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide"); 
        //cmp.set("v.showSpinner",true);
        var action = cmp.get("c.UpdateM");
       
        var obj = cmp.get("v.SelectedMO");
        obj.ERP7__Quantity__c = cmp.get('v.QTY');
        cmp.set("v.SelectedMO",obj);
        //after setting start date, expected date and end date of MO and WOS save both
        action.setParams({"MO":JSON.stringify(cmp.get("v.SelectedMO")), "WOS":JSON.stringify(cmp.get("v.WOS2Upsert"))});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
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
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    UpdateWO: function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        //cmp.set("v.showSpinner",true);
        var action = cmp.get("c.SaveW");
        var wo = cmp.get("v.WOS2Upsert")[0];
        wo.ERP7__Quantity_Ordered__c = cmp.get("v.QTY");
        action.setParams({"WO":JSON.stringify(wo)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
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
            	$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                //cmp.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    Schedule : function(cmp, event, helper) {
        var SelectedRouting = cmp.get("v.SelectedRouting");
        var SelectedSoli = cmp.get("v.SelectedSoli");
        var SelectedSoliItem = cmp.get("v.SelectedSoliItem");
        var QTY = cmp.get("v.QTY");
        var type = cmp.get("v.Type");  
        console.log('SelectedRouting : ',JSON.stringify(SelectedRouting));
        
        var errmsg = '';
        
        if($A.util.isEmpty(SelectedRouting) || $A.util.isUndefinedOrNull(SelectedRouting) || $A.util.isEmpty(SelectedRouting.Id) || $A.util.isUndefinedOrNull(SelectedRouting.Id)){
            errmsg = $A.get('$Label.c.Routing_is_required'); //replace it with :- errmsg = $A.get('$Label.c.Error_UsersShiftMatch'); for translations of error messages
            cmp.set("v.errorMsg",errmsg);
            return;
        }
        if($A.util.isEmpty(SelectedRouting.ERP7__Process__c) || $A.util.isUndefinedOrNull(SelectedRouting.ERP7__Process__c)){
            errmsg = $A.get('$Label.c.Process_is_missing_on_Selected_Routing');
            cmp.set("v.errorMsg",errmsg);
            return;
        }
        if($A.util.isEmpty(SelectedRouting.ERP7__Process__r) || $A.util.isUndefinedOrNull(SelectedRouting.ERP7__Process__r) || $A.util.isEmpty(SelectedRouting.ERP7__Process__r.RecordType) || $A.util.isUndefinedOrNull(SelectedRouting.ERP7__Process__r.RecordType) || $A.util.isEmpty(SelectedRouting.ERP7__Process__r.RecordType.Name) || $A.util.isUndefinedOrNull(SelectedRouting.ERP7__Process__r.RecordType.Name)){
            errmsg = $A.get('$Label.c.Process_record_type_is_missing_on_Selected_Routing');
            cmp.set("v.errorMsg",errmsg);
            return;
        }
        if($A.util.isEmpty(SelectedRouting.ERP7__Product__c) || $A.util.isUndefinedOrNull(SelectedRouting.ERP7__Product__c)){
            errmsg = $A.get('$Label.c.Product_is_missing_on_Selected_Routing');
            cmp.set("v.errorMsg",errmsg);
            return;
        }
        if($A.util.isEmpty(SelectedRouting.ERP7__BOM_Version__c) || $A.util.isUndefinedOrNull(SelectedRouting.ERP7__BOM_Version__c)){
            errmsg = $A.get('$Label.c.Version_is_missing_on_Selected_Routing');
            cmp.set("v.errorMsg",errmsg);
            return;
        }
        if($A.util.isEmpty(cmp.get("v.SelectedVersion")) || $A.util.isUndefinedOrNull(cmp.get("v.SelectedVersion")) || $A.util.isEmpty(cmp.get("v.SelectedVersion.Id")) || $A.util.isUndefinedOrNull(cmp.get("v.SelectedVersion.Id"))){
            errmsg = $A.get('$Label.c.Version_is_required');
            cmp.set("v.errorMsg",errmsg);
            return;
        }
        
        if(SelectedRouting.ERP7__Process__r.RecordType.Name == 'Manufacturing Process'){
            var manuOrder = cmp.get("v.manuOrder");
            console.log('manuOrder bfr : ',JSON.stringify(manuOrder));
            var task = cmp.get("v.Mtask");
            if(cmp.get("v.Mtask") != null && cmp.get("v.Mtask") != undefined && cmp.get("v.Mtask") != ""){
                manuOrder.ERP7__Tasks__c = task.Id;
                manuOrder.ERP7__Project__c = task.ERP7__Project__c;
            }
            manuOrder.ERP7__Product__c = SelectedRouting.ERP7__Product__c;
            if(cmp.get("v.setVerBasedOnOrdPod")) manuOrder.ERP7__Version__c = cmp.get("v.SelectedVersion.Id");
            else manuOrder.ERP7__Version__c = SelectedRouting.ERP7__BOM_Version__c;
            manuOrder.ERP7__Routing__c = SelectedRouting.Id;
            manuOrder.ERP7__Quantity__c = QTY;
            if(type == 'Sales Order'){
                console.log('isStandardOrd : ',cmp.get("v.isStandardOrd"));
                if(cmp.get("v.isStandardOrd")){
                    manuOrder.ERP7__Order__c = SelectedSoliItem.OrderId;
                    manuOrder.ERP7__Order_Product__c = SelectedSoliItem.Id; 
                }
                else{
                    manuOrder.ERP7__Sales_Order__c = SelectedSoli.ERP7__Sales_Order__c;
                    manuOrder.ERP7__Sales_Order_Line_Item__c = SelectedSoli.Id; 
                }
                console.log('@@@@@');
            }
            console.log('manuOrder : ',JSON.stringify(manuOrder));
            if(!$A.util.isEmpty(cmp.get("v.OrdItmId")) && !$A.util.isUndefinedOrNull(cmp.get("v.OrdItmId"))){
                manuOrder.ERP7__Order_Product__c = cmp.get("v.OrdItmId");
                //manuOrder.ERP7__Order__c = cmp.get("v.OrdId");
            }
            cmp.set("v.manuOrder",manuOrder);
            helper.SaveMO(cmp, event, helper);
        }
        else if(SelectedRouting.ERP7__Process__r.RecordType.Name == 'Maintenance Process'){
            var WorkOrder = cmp.get("v.WOS2Upsert")[0];
            var task = cmp.get("v.Mtask");
            if(cmp.get("v.Mtask") != null && cmp.get("v.Mtask") != undefined && cmp.get("v.Mtask") != ""){
                WorkOrder.ERP7__Tasks__c = task.Id;
                WorkOrder.ERP7__Project__c = task.ERP7__Project__c;
            }
            WorkOrder.Name = SelectedRouting.ERP7__Product__r.Name;
            WorkOrder.ERP7__ExpectedDate__c = WorkOrder.ERP7__End_Date__c;
            WorkOrder.ERP7__Product__c = SelectedRouting.ERP7__Product__c;
            WorkOrder.ERP7__Version__c = SelectedRouting.ERP7__BOM_Version__c;
            WorkOrder.ERP7__Routing__c = SelectedRouting.Id;
            WorkOrder.ERP7__Quantity_Ordered__c = QTY;
            WorkOrder.ERP7__Work_Center__c = SelectedRouting.ERP7__Work_Center__c;
            
            if(type == 'Sales Order'){
                WorkOrder.ERP7__Sales_Order__c = SelectedSoli.ERP7__Sales_Order__c;
                WorkOrder.ERP7__Sales_Order_Line_Item__c = SelectedSoli.Id;
            }
            cmp.set("v.WorkOrder",WorkOrder);
            helper.SaveWO(cmp, event, helper);
        }
        cmp.set('v.disableScheduleMO',true);
    },
    
    handleSchedulerEvent: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        //cmp.set("v.showSpinner",true);
        console.log('handleSchedulerEvent called');
        var SelectedRouting = cmp.get("v.SelectedRouting");
        var WO = event.getParam("WO");
        var index = event.getParam("Index");
         console.log('index : ',index);
        var selectedbyuser1 =  event.getParam("selectedbyuser");
        console.log('selectedbyuser1 : ',selectedbyuser1);
        if(SelectedRouting.ERP7__Process__r.RecordType.Name == 'Manufacturing Process' || SelectedRouting.ERP7__Process__r.RecordType.Name == 'Maintenance Process'){
            var wos = cmp.get("v.WOS");
            console.log('wos bfr: ',JSON.stringify(wos));
            wos[index].ERP7__Start_Date__c = WO.ERP7__Start_Date__c;
            wos[index].ERP7__End_Date__c = WO.ERP7__End_Date__c;
           for(var x in wos){
               console.log('x : ',x);
                if(x != index && x > index){
                  //  wos[x].ERP7__Start_Date__c = WO.ERP7__Start_Date__c;
                  //  wos[x].ERP7__End_Date__c = WO.ERP7__End_Date__c;
                    console.log('start date : ',wos[x].ERP7__Start_Date__c);
                    let act = cmp.find('CallfetchWorkCenterInfo');
                    console.log('act :',act);
                    if(act != undefined){ //&&  wos[x].ERP7__Start_Date__c != WO.ERP7__Start_Date__c
                        act[x].fetchInfo(WO.ERP7__Start_Date__c,selectedbyuser1);
                    } 
                }
            }
           // cmp.set("v.WOS",wos);
            //console.log('wos after: ',cmp.get("v.WOS"));
            cmp.set("v.WOS2Upsert",wos);
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",false);
        }
    },
    
    fetchMOInfo : function(cmp, event, helper) {
        try{
            var moId = event.currentTarget.getAttribute('data-pId');
            var count = event.currentTarget.getAttribute('data-count');
            cmp.set("v.SelectedMO", cmp.get("v.MOS")[count]);   
            cmp.set("v.QTY", cmp.get("v.SelectedMO").ERP7__Quantity__c);
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var action = cmp.get("c.fetchMODetails");
            action.setParams({"MOId":moId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.Prevent", true);
                    cmp.set("v.SelectedProduct", response.getReturnValue().SelectedProduct);
                    cmp.set("v.isChanged", false);
                    cmp.set("v.VersionId", response.getReturnValue().SelectedVersion.Id);
                    cmp.set("v.isChanged", true);
                    cmp.set("v.Versions", response.getReturnValue().Versions);
                    cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                    cmp.set("v.Routings", response.getReturnValue().Routings);
                    cmp.set("v.WOS", response.getReturnValue().WOS);
                    cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                    cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                    cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                    cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                    cmp.set("v.QTY", response.getReturnValue().MOS[0].ERP7__Quantity__c);
                    console.log('QTY **** 6: ',cmp.get("v.QTY"));
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    cmp.set("v.Prevent", false);
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.set("v.showSpinner",false);
                    setTimeout(
                        $A.getCallback(function() {
                            try{
                                if(cmp.get("v.Type") == 'Product'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedProduct").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Sales Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedSoli").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Manufacturing Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedMO").Id);
                                    uscroll.scrollIntoView();
                                }
                            } catch(e){ console.log('*** AutoScroll Error 7: '+e); }
                        }), 1000
                    );
                }
            });
            $A.enqueueAction(action);
            
        } catch(e){ cmp.set("v.errorMsg", e); } 
    },
    
    fetchMOInfo2 : function(cmp, event, helper) {
        try{
            cmp.set("v.errorMsg",'');
            var moId = cmp.get("v.pId");
            var count = cmp.get("v.count");
            
            cmp.set("v.SelectedMO", cmp.get("v.MOS")[count]);   
            cmp.set("v.QTY", cmp.get("v.SelectedMO").ERP7__Quantity__c);
            console.log('QTY **** 7: ',cmp.get("v.QTY"));
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var action = cmp.get("c.fetchMODetails");
            action.setParams({"MOId":moId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.Prevent", true);
                    cmp.set("v.SelectedProduct", response.getReturnValue().SelectedProduct);
                    cmp.set("v.isChanged", false);
                    cmp.set("v.VersionId", response.getReturnValue().SelectedVersion.Id);
                    cmp.set("v.isChanged", true);
                    cmp.set("v.Versions", response.getReturnValue().Versions);
                    cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                    cmp.set("v.Routings", response.getReturnValue().Routings);
                    cmp.set("v.WOS", response.getReturnValue().WOS);
                    cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                    cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                    cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                    cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                    cmp.set("v.QTY", response.getReturnValue().MOS[0].ERP7__Quantity__c);
                    console.log('QTY **** 8: ',cmp.get("v.QTY"));
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    cmp.set("v.Prevent", false);
                    
                    cmp.set("v.pId","");
                    cmp.set("v.count","");
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.set("v.showSpinner",false);
                }
            });
            $A.enqueueAction(action);
            
        } catch(e){ cmp.set("v.errorMsg", e); } 
    },
    
    fetchWOInfo : function(cmp, event, helper) {
        try{
            var woId = event.currentTarget.getAttribute('data-pId');
            var count = event.currentTarget.getAttribute('data-count');
            cmp.set("v.SelectedWO", cmp.get("v.WorkOrders")[count]);   
            cmp.set("v.QTY", cmp.get("v.SelectedWO").ERP7__Quantity__c);
            console.log('QTY **** :9 - ',cmp.get("v.QTY"));
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var action = cmp.get("c.fetchWODetails");
            action.setParams({"WOId":woId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.Prevent", true);
                    cmp.set("v.SelectedProduct", response.getReturnValue().SelectedProduct);
                    cmp.set("v.isChanged", false);
                    cmp.set("v.VersionId", response.getReturnValue().SelectedVersion.Id);
                    cmp.set("v.isChanged", true);
                    cmp.set("v.Versions", response.getReturnValue().Versions);
                    cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                    cmp.set("v.Routings", response.getReturnValue().Routings);
                    cmp.set("v.WOS", response.getReturnValue().WOS);
                    cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                    cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                    cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                    cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                    cmp.set("v.QTY", response.getReturnValue().WOS[0].ERP7__Quantity__c);
                    console.log('QTY **** 10: ',cmp.get("v.QTY"));
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    cmp.set("v.Prevent", false);
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.set("v.showSpinner",false);
                    setTimeout(
                        $A.getCallback(function() {
                            try{
                                if(cmp.get("v.Type") == 'Product'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedProduct").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Sales Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedSoli").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Manufacturing Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedMO").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Work Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedWO").Id);
                                    uscroll.scrollIntoView();
                                }
                            } catch(e){ console.log('*** AutoScroll Error 8: '+e); } 
                        }), 1000
                    );
                }
            });
            $A.enqueueAction(action);
            
        } catch(e){ cmp.set("v.errorMsg", e); } 
    },
    
    fetchWOInfo2 : function(cmp, event, helper) {
        try{
            var woId = cmp.get("v.pId");
            var count = cmp.get("v.count");
            cmp.set("v.SelectedWO", cmp.get("v.WorkOrders")[count]);   
            cmp.set("v.QTY", cmp.get("v.SelectedWO").ERP7__Quantity__c);
            console.log('QTY **** :11 ',cmp.get("v.QTY"));
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //cmp.set("v.showSpinner",true);
            var action = cmp.get("c.fetchWODetails");
            action.setParams({"WOId":woId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    cmp.set("v.Prevent", true);
                    cmp.set("v.SelectedProduct", response.getReturnValue().SelectedProduct);
                    cmp.set("v.isChanged", false);
                    cmp.set("v.VersionId", response.getReturnValue().SelectedVersion.Id);
                    cmp.set("v.isChanged", true);
                    cmp.set("v.Versions", response.getReturnValue().Versions);
                    cmp.set("v.SelectedVersion", response.getReturnValue().SelectedVersion);
                    cmp.set("v.Routings", response.getReturnValue().Routings);
                    cmp.set("v.WOS", response.getReturnValue().WOS);
                    cmp.set("v.WOS2Upsert", response.getReturnValue().WOS);
                    cmp.set("v.SelectedRouting", response.getReturnValue().SelectedRouting);
                    cmp.set("v.RoutingId", response.getReturnValue().SelectedRouting.Id);
                    cmp.set("v.qtyMultiplier", response.getReturnValue().qtyMultiplier);
                    cmp.set("v.QTY", response.getReturnValue().WOS[0].ERP7__Quantity__c);
                    console.log('QTY **** 12: ',cmp.get("v.QTY"));
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    cmp.set("v.Prevent", false);
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.set("v.showSpinner",false);
                    setTimeout(
                        $A.getCallback(function() {
                            try{
                                if(cmp.get("v.Type") == 'Product'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedProduct").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Sales Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedSoli").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Manufacturing Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedMO").Id);
                                    uscroll.scrollIntoView();
                                } else if(response.getReturnValue().Type == 'Work Order'){
                                    var uscroll = document.getElementById(cmp.get("v.SelectedWO").Id);
                                    uscroll.scrollIntoView();
                                }
                            } catch(e){ console.log('*** AutoScroll Error 9: '+e); }  
                        }), 1000
);
                }
            });
            $A.enqueueAction(action);
            
        } catch(e){ cmp.set("v.errorMsg", e);  } 
    },
    
    Configure : function(cmp, event, helper) {
        $A.createComponent("c:ProductConfigurator",{
            "SelectedRouting": cmp.get("v.SelectedRouting"),
            "RId": cmp.get("v.SelectedRouting").Id
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    NavPlanner : function (component, event) {
        var RecUrl = "/lightning/n/ERP7__Work_Center_Capacity_Planning";
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": RecUrl
        });
        urlEvent.fire();*/
    	window.open(RecUrl,"_self");
        
    },

    NavServicePlanner : function (component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterCapacityPlanningMaintenance",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    NavBuilder : function (component, event) {
        var RecUrl = "/lightning/n/ERP7__Manufacturing_Builder";  //"/apex/ERP7__ManageMOS";
        //$A.get("e.force:navigateToURL").setParams(
    	//{"url": RecUrl}).fire();
    	window.open(RecUrl,"_self");
    },

    NavServiceBuilder : function (component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:MaintenanceBuilder",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    fullScreen : function (cmp, event) {
    	cmp.set("v.fullScreen",!cmp.get("v.fullScreen"));
    },
    
    closeError : function (cmp, event) {
    	cmp.set("v.errorMsg",'');
    },
    
    goBackTask : function(component, event) {
        $A.createComponent("c:AddMilestoneTask",{
            "aura:id" : "taskCmp",
            "projectId" : component.get("v.projectId"),
            "taskId" : component.get("v.Mtask.Id"),
            "newTask" : component.get("v.Mtask"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    navigatetoOrdItm : function(component, event, helper) {
        var orditmid = component.get("v.OrdItmId");        
        var RecUrl = "/" + orditmid;
        window.open(RecUrl,'_blank');
    }
    
})