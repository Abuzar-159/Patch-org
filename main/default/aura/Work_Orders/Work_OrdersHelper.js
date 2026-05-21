({
    getSolis: function(cmp, event, helper) {
        
        var reId = cmp.get("v.soliId");
        
        if(reId != undefined && reId != ""){
            var action = cmp.get("c.getAllSOLI");            
            
            action.setParams({
                "soliId":cmp.get("v.soliId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    cmp.set("v.WorkOrder", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getRMALI: function(cmp, event, helper) {
        var reId = cmp.get("v.rmarecordId");
        if(reId != undefined && reId != ""){
            var stDate = cmp.get("v.WorkOrder.ERP7__Start_Date__c");
            var expDate = cmp.get("v.WorkOrder.ERP7__Expected_Date__c");
            var action = cmp.get("c.getAllRMALI");
            action.setParams({
                "rmarecordId":cmp.get("v.rmarecordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    cmp.set("v.WorkOrder", response.getReturnValue());
                    cmp.set("v.WorkOrder.ERP7__Start_Date__c",stDate);
                    cmp.set("v.WorkOrder.ERP7__Expected_Date__c",expDate);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getParams: function(cmp, event, helper) {
        var pId = cmp.get("v.PID");
        var rId = cmp.get("v.RID");
        var ver = cmp.get("v.VER");
        var quan = cmp.get("v.QUAN"); 
        if(pId != undefined && pId != ""){
            cmp.set("v.WorkOrder.ERP7__Product__c",pId);
        }
        if(rId != undefined && rId != ""){
            cmp.set("v.WorkOrder.ERP7__Routing__c",rId);
        }
        if(ver != undefined && ver != ""){
            cmp.set("v.WorkOrder.ERP7__Version__c",ver);
        }
        if(quan != undefined && quan != ""){
            cmp.set("v.WorkOrder.ERP7__Quantity_Ordered__c",quan);
        }
    },
    
    focusTOscan:function(component, event){
        $(document).ready(function() {
            component.set("v.scanValue",'');  
            var barcode = "";
            var pressed = false;
            var chars = [];
            $(window).keypress(function(e) {
                chars.push(String.fromCharCode(e.which));                      
                if (pressed == false) {
                    setTimeout(
                        $A.getCallback(function() {
                            if (chars.length >= 4) {
                                var barcode = chars.join("");
                                barcode = barcode.trim();
                                component.set("v.scanValue",barcode); 
                            }
                            chars = [];
                            pressed = false;
                        }), 250
                    );                            
                }              
                pressed = true;
            }); // end of window key press function         
            
            $(window).keydown(function(e){
                if ( e.which === 13 ) { 
                    e.preventDefault();
                }
            }); 
            
        });       
        
    },
    
    getSOLIDetails : function (cmp, event, curSoliId) {
        var workOrd = cmp.get("v.WorkOrder");
        var action = cmp.get("c.getSoliFromId");
        action.setParams({
            soliID : curSoliId
        });
        action.setCallback(this, function(response){
            var quantity = response.getReturnValue().ERP7__Quantity_Needed__c;
            workOrd.ERP7__Sales_Order_Line_Item__c = curSoliId;
            workOrd.ERP7__Quantity_Ordered__c = quantity;
            workOrd.ERP7__Product__c = response.getReturnValue().ERP7__Product__c;
            workOrd.ERP7__Version__c = response.getReturnValue().ERP7__Product__r.ERP7__Version__c;
            workOrd.ERP7__Routing__c = response.getReturnValue().ERP7__Product__r.ERP7__Routing__c;
            workOrd.ERP7__Sales_Order__c = response.getReturnValue().ERP7__Sales_Order__c;
            cmp.set("v.WorkOrder", workOrd);
        });
        $A.enqueueAction(action);
    },
     CreateMO : function(cmp, event, helper,MRPId) { 
        //var MRPId = event.currentTarget.getAttribute('data-mosoliId');
        var URL_RMA = '/apex/ERP7__ManufacturingOrderLC?mrpId='+MRPId;
        window.open(URL_RMA,'_self');
    },
    
})