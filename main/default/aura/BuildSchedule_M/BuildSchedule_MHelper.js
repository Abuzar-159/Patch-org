({
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
    
    getSerials : function(cmp,stockAssignedSerialIds){
        var action1 = cmp.get("c.getSerialNumbers");
        var MOId = cmp.get("v.ManuOrder.Id");
        action1.setParams({"offsetVal" : 0,"Mo" : MOId,"limitSer" : 1000,'SerialIds' : stockAssignedSerialIds});
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS") {
                var NewSerialsForAllocation = [];
                var moSerialNos = response1.getReturnValue();
                cmp.set("v.moSerialNos",moSerialNos);
                var moBatchNos = cmp.get("v.moBatchNos"); 
                var newSOL = cmp.get("v.NewSOLI");
                for(var y in moSerialNos){
                    console.log('inhere moSerialNos innerloop');
                    if(stockAssignedSerialIds.includes(moSerialNos[y].Id) == false) {
                        console.log('inhere moSerialNos innerloop if');
                        moSerialNos[y].SelectItem = false;
                        NewSerialsForAllocation.push(moSerialNos[y]);
                    }
                }
                if(NewSerialsForAllocation.length > 0){
                    newSOL.ERP7__MO_WO_Serial__c = NewSerialsForAllocation[0].Id;
                }
                if(moBatchNos.length == 1){
                    newSOL.ERP7__MO_WO_Material_Batch_Lot__c = moBatchNos[0].Id;
                }
                cmp.set("v.NewSOLI",newSOL);
                cmp.set("v.SerialsForAllocation", NewSerialsForAllocation);
                console.log('SelectMRP1 moSerialNos.length~>'+moSerialNos.length); 
                cmp.set("v.saPage",true);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                console.log('settimeout saPage SelectMRP1'); 
            }
        });
        $A.enqueueAction(action1);
    },
    
    
    finalFinishWO : function(cmp, event,helper){
        var WORec = cmp.get("v.WO2Fin");
        console.log('WORec : ',WORec);
        var flows = JSON.stringify(cmp.get("v.WIPFlows"));console.log('byPassWOComplete ',cmp.get('v.byPassWOComplete'));
        //calculate wip qty to WO.
        var obj = cmp.get("v.WIPFlows");console.log('WORec.ERP7__Quantity_Built__c ',WORec.ERP7__Quantity_Built__c);console.log(' WORec.ERP7__Quantity_Scrapped__c ', WORec.ERP7__Quantity_Scrapped__c);console.log('WORec.ERP7__Quantity_Ordered__c ',WORec.ERP7__Quantity_Ordered__c);
        if(!cmp.get('v.byPassWOComplete') && (WORec.ERP7__Quantity_Built__c  + WORec.ERP7__Quantity_Scrapped__c) == WORec.ERP7__Quantity_Ordered__c){console.log('set status of wo in finalfinishwo'); WORec.ERP7__Status__c = 'Complete';}
        if(obj.length > 0){
            var producedQty = 0;
            var scrapQty = 0;
            for(var y in obj){
                if(obj[y].wipFlow.ERP7__Status__c == "Completed"){
                    if(obj[y].wipFlow.ERP7__Type__c == "Produced" || obj[y].wipFlow.ERP7__Type__c == "Processed")
                        producedQty += Number(obj[y].wipFlow.ERP7__Quantity__c);
                    if(obj[y].wipFlow.ERP7__Type__c == "Scrapped")
                        scrapQty += Number(obj[y].wipFlow.ERP7__Quantity__c);
                }
            }
           // producedQty = Math.round((producedQty + Number.EPSILON) * 100) / 100;
            //scrapQty = Math.round((scrapQty + Number.EPSILON) * 100) / 100;    
            //cmp.set("v.WO2Fin.ERP7__Quantity_Built__c",producedQty);
            //cmp.set("v.WO2Fin.ERP7__Quantity_Scrapped__c",scrapQty);
        }
       
        var action = cmp.get("c.UpdateWORec");
        action.setParams({ WO2Update1 : JSON.stringify(WORec), WIPFlows : flows});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                cmp.set("v.ToProduce", 0);
                cmp.set("v.ToScrap", 0);
                console.log('response.getReturnValue() UpdateWORec: ',response.getReturnValue());
               // $A.util.removeClass(cmp.find("finishModal"),"slds-fade-in-open");
                //$A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
                if(WORec.ERP7__Status__c == 'Complete'){
                    this.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.Work_Order_Completed_Successfully'));
                    
                   // cmp.SaveTaskValues(cmp, event,helper);
                }
                else if(response.getReturnValue().WorkOrder.ERP7__Status__c == 'Complete'){
                    this.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.Work_Order_Completed_Successfully'));
                   
                   // cmp.SaveTaskValues(cmp, event,helper);
                }
                 cmp.set("v.fPage",false); 
                if(response.getReturnValue().manuOrders.ERP7__Status__c == 'Complete'){
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:Manufacturing_Orders",
                        componentAttributes: {
                            "MO":response.getReturnValue().manuOrders.Id,
                            "NAV":'mp',
                            "RD":'yes'
                        }
                    });
                    evt.fire();
                }
                else {
                    
                    cmp.popInit();
                }
                $A.util.removeClass(cmp.find("mainSpin"),"slds-hide");
            }
            
        });
        $A.enqueueAction(action);
    },
    navigateto: function(cmp, event){
         var loc = window.location.href;
        loc.replace("/apex",'');
        var URL_RMA = 'lightning/n/ERP7__Work_Center_Capacity_Planning';
             window.open(URL_RMA,'_self');
    },
    getpicklistValues : function(cmp,event){ //,checkval
         $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
       var obj11 =  cmp.get("v.objDetail");
         var controllingFieldAPI = cmp.get("v.controllingFieldAPI");
        var dependingFieldAPI = cmp.get("v.dependingFieldAPI");
         var action = cmp.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : obj11,
            'contrfieldApiName': controllingFieldAPI,
            'depfieldApiName': dependingFieldAPI 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
				var arrayMapKeys = [];
                for(var key in StoreResponse){
                    arrayMapKeys.push({key: key, value: StoreResponse[key]});
                }                
                // once set #StoreResponse to depnedentFieldMap attribute 
                cmp.set("v.depnedentFieldMap",arrayMapKeys);
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                 $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                cmp.set("v.listControllingValues", ControllerField);
                
               // cmp.set("v.SelectedTask",cmp.get("v.SelectedTask"));
               /* if(checkval !='' && checkval != undefined && checkval != null )  {
                    cmp.set("v.Checklist",checkval);                     
                }*/
            }else{
            }
        });
        $A.enqueueAction(action);
   
    },
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
       
     
    },
     showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            //component.set("v.showMainSpin",false);
            toastEvent.fire();
        }
    },
    getSearchDetails : function(cmp, event){
        console.log('getSearchDetails');
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var woId = cmp.get("v.WO");
        var action = cmp.get("c.getgradeandProducts");
        action.setParams({woId:woId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('getSearchDetails state : ',state);
            if (state === "SUCCESS") {
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                console.log('response getgradeandProducts : ',response.getReturnValue());
                cmp.set('v.WIPProducts',response.getReturnValue().products);
                 cmp.set('v.gradeList',response.getReturnValue().grades);
                 cmp.set('v.thicknessList',response.getReturnValue().thichkness);
                 cmp.set('v.widthList',response.getReturnValue().widths);
                cmp.set('v.lengthList',response.getReturnValue().lengths);
                
            }
            else{
                console.log('error getgradeandProducts : ',response.getError());
            }
        });
        $A.enqueueAction(action);
       
    }
})