({
    doInit: function(component, event) {
        var prId = component.get("v.prId");
        var newPro = component.get("v.newProduct");
        var action = component.get("c.fetchProductDetails");
        action.setParams({
            "products1": JSON.stringify(newPro),
            prId: prId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.newProduct", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        
        /*PriceBook Details*/
        var newPro = component.get("v.pbEntries");
        var action = component.get("c.fetchPricebook");
        action.setParams({
            prId: prId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.pbEntries", a.getReturnValue());
                pbEntriesName = component.get("v.pbEntries[0].Pricebook2.Name");
            }
        });
        $A.enqueueAction(action);
        
        /*TDA Details*/
        var action = component.get("c.fetchTDA");
        action.setParams({
            prId: prId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.tdiscounts", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        /*Warranty Details*/
        var action = component.get("c.fetchWarrantyDetails");
        action.setParams({
            prId: prId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.warranties", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        /*Product Location Details*/
        var newPro = component.get("v.locations");
        var action = component.get("c.fetchProductLocations");
        action.setParams({
            prId: prId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.locations", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        /*Product Versions Details*/
        var newPro = component.get("v.Vboms");
        var action = component.get("c.fetchProductVersions");
        action.setParams({
            prId: prId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.Vboms", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        /*Routing Details*/
        var newPro = component.get("v.routs");
        var action = component.get("c.fetchRoutings");
        action.setParams({
            prId: prId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.routs", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    closeToast: function(component, event) {
        component.set("v.ShowToast", false);
        component.set("v.ShowErrorToast", false);
        component.set("v.ShowErrorToast2", false);
        component.set("v.ProductNameError",false);
        component.set("v.VersionCodeError",false);
        component.set("v.RoutingCode",false);
        component.set("v.DiscountName",false);
        component.set("v.WarrantyName",false);
        component.set("v.WarehouseName",false);
    },
    
    Reset: function(component, event) {
        location.reload();
    },
    
    AddBillOfMaterials:function(component, event, helper) {
       
        var addR = component.get("v.boms");
        var len = addR.length;
        addR.push({ERP7__Active__c:'true',ERP7__Unit_of_Measure__c:'',ERP7__Phase__c:'',ERP7__Type__c:'',ERP7__Quantity__c:'',Name:''});
        component.set("v.boms",addR);
        
     },
    AddOprs:function(component, event) {
        var addR = component.get("v.operations");
        var len = addR.length;
        addR.push({
            'Name':''
        });
        component.set("v.operations",addR);
        
    },

    EditTda: function(component, event, helper) {
        
        component.set("v.DiscountComponent",true);
        component.set("v.BackToDiscount",false);
        
        var picVal = event.target.dataset.record;
        component.set("v.recordIndex",picVal);
        var data = component.get("v.tdiscounts");
        var tda2 = component.get("v.tda2");
        
        tda2.Name = data[picVal].Name;
        component.set("v.tda2", tda2);
    },
    
    deleteTDA: function(component, event, helper) {
        var result = confirm("Are you sure want to delete?");
        if (result) {
        var recId = event.currentTarget.dataset.target;
        var action = component.get("c.deleteTierDiscounts");
        action.setParams({
            "recId" : recId
        });
        var index = event.currentTarget.dataset.index;
        var Del = component.get("v.tdiscounts");
        Del.splice(index, 1);
        component.set("v.tdiscounts", Del);
        
        $A.enqueueAction(action);
        }
    },
    
    
    EditBomVersion: function(component, event, helper) {
        component.set("v.VersionComponent",true);
        component.set("v.ShowMainComponent",false);
        var rId = event.currentTarget.dataset.target;
        var action = component.get("c.getProductVersionsById");
        action.setParams({
            recId: rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                var obj = response.getReturnValue();
                component.set("v.Vbom", obj.version);
                component.set("v.boms", obj.bomList);
                }catch(err) {}    
            }
        });
        $A.enqueueAction(action);
        
        /*Status Picklist*/
        var action = component.get("c.getStatuspickval");
        var inputsel = component.find("InputSelectStatus");
        var opts = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                opts.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputsel.set("v.options", opts);
            component.set("v.InputSelectStatusOptions",opts);
        });
        $A.enqueueAction(action);
        
        
        /*UoM Picklist*/
        var action = component.get("c.getpickvalExpType");
        var inputselUoM = component.find("InputSelectUoM");
        var optsUom = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                optsUom.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputselUoM.set("v.options", optsUom);
            component.set("v.InputSelectUoMOptions",optsUom);
        });
        $A.enqueueAction(action);
        
        /*Type Picklist*/
        var action = component.get("c.getpickvalType");
        var inputselType = component.find("InputSelectType");
        var optsType = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                optsType.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputselType.set("v.options", optsType);
            component.set("v.InputSelectTypeOptions",optsType);
        });
        $A.enqueueAction(action);
        
        /*Category Picklist*/
        var action = component.get("c.getpickvalCategory");
        var inputselCat = component.find("InputSelectCategory");
        var optsCategory = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                optsCategory.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputselCat.set("v.options", optsCategory);
            component.set("v.InputSelectCategoryOptions",optsCategory);
        });
        $A.enqueueAction(action);
    },
  
    EditpLoc:function(component, event, helper) {
        component.set("v.LocationComponent",true);
        component.set("v.BackToLocation",false);
        
        var ival = event.target.dataset.record;
        component.set("v.LocIndex",ival);
        var data = component.get("v.locations");
        var pl = component.get("v.pl");
        component.set("v.pl", pl);
        
    },
    
    deletePL: function(component, event, helper) {
        var result = confirm("Are you sure want to delete?");
        if (result) {
        var recId = event.currentTarget.dataset.target;
        var action = component.get("c.deleteProductLocation");
        action.setParams({
            "recId" : recId
        });
        var index = event.currentTarget.dataset.index;
        var Del = component.get("v.locations");
        Del.splice(index, 1);
        component.set("v.locations", Del);
        $A.enqueueAction(action);
        }
    },
    
    deleteBOM: function(component, event) {
        var picVal = event.currentTarget.dataset.record;
        var Del = component.get("v.boms");
        Del.splice(picVal, 1);
        component.set("v.boms", Del);
    },
    
    deleteBOMVersions: function(component, event, helper) {
        var result = confirm("Are you sure want to delete?");
        if (result) {
        var recId = event.currentTarget.dataset.target;
        var action = component.get("c.deleteProductVersion");
        action.setParams({
            "recId" : recId
        });
        
        var index = event.currentTarget.dataset.index;
        var Del = component.get("v.Vboms");
        Del.splice(index, 1);
        component.set("v.Vboms", Del);
        $A.enqueueAction(action);
        }
    },
    
    EditRouting: function(component, event, helper) {
        component.set("v.RoutingComponent",true);
        component.set("v.BackToRouting",false);
        var rId = event.currentTarget.dataset.target;
        var action = component.get("c.getRoutingbyId");
        action.setParams({
            recId: rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                 component.set("v.rout", obj.routing);
                 component.set("v.operations", obj.operationList);
                
            }
        });
        $A.enqueueAction(action);
        
        
        /*Routing Status Picklist*/
        var action = component.get("c.getpickvalRoutingStatus");
        var inputselStatus = component.find("RoutingStatus");
        var rStatus = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                rStatus.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputselStatus.set("v.options", rStatus);
            component.set("v.RoutingStatusOptions",rStatus);
        });
        $A.enqueueAction(action);
        
        
        /*Routing Type Picklist*/
        var action = component.get("c.getpickvalRoutingType");
        var inputselRType = component.find("RoutingType");
        var rType = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                rType.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputselRType.set("v.options", rType);
            component.set("v.RoutingTypeOptions",rType);
        });
        $A.enqueueAction(action);
    },
    
    deleteRoutings: function(component, event) {
        var result = confirm("Are you sure want to delete?");
        if (result) {
        var recId = event.currentTarget.dataset.target;
        var action = component.get("c.deleteRouting");
        action.setParams({
            "recId" : recId
        });
        var index = event.currentTarget.dataset.index;
        var Del = component.get("v.routs");
        Del.splice(index, 1);
        component.set("v.routs", Del);
        $A.enqueueAction(action);
        }
    },
    
    deleteOpeartions: function(component, event) {
        var oprDel = component.get("v.operations");
        oprDel.splice(0, 1);
        component.set("v.operations", oprDel);
    },
    
    SaveAll: function(component, event) {
        
        
        /*Save Bill Of materials*/
        var bom = component.get("v.boms");
        var action = component.get("c.SaveBillOfMaterials");
        action.setParams({
            "bom": JSON.stringify(bom),
            bomId: component.get("v.prId"),
            vId: component.get("v.vId")
            
            
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
            }
        });
        $A.enqueueAction(action)
        /*Save Bill Of materials ends here*/
        
        /*Save Operations*/
        var opr = component.get("v.operations");
        var action = component.get("c.insertOperations");
        action.setParams({
            "opr": JSON.stringify(opr),
            rId: component.get("v.rId")
            
            
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
            }
        });
        $A.enqueueAction(action)
        /*Save Operations ends here*/
        
        
        
        var ProId = component.get("v.prId");
        if (ProId != null)
            component.set("v.ShowToast", true);
    },
    VersionComponent: function(component, event, helper) {
       component.set("v.VersionComponent",true);
       component.set("v.Vbom",{'sobjectType': 'ERP7__Version__c','Name': '','ERP7__Barcode__c':'','ERP7__Status__c':'','ERP7__Unit_of_Measure__c':'','ERP7__Start_Date__c':'','ERP7__To_Date__c':'','ERP7__Type__c':'','ERP7__Category__c':'','ERP7__Description__c':'','ERP7__Process__c':''});
       component.set("v.boms",{'sObjectType':'ERP7__BOM__c','Name':'','ERP7__Process_Cycle__c':'','ERP7__Quantity__c':'','ERP7__Type__c':'','ERP7__Phase__c':'','ERP7__Unit_of_Measure__c':'','ERP7__Active':true});
       component.set("v.ShowMainComponent",false);
        
        /*Status Picklist*/
        var action = component.get("c.getStatuspickval");
        var inputsel = component.find("InputSelectStatus");
        var opts = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                opts.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            inputsel.set("v.options", opts);
        });
        $A.enqueueAction(action);
        
        
        /*UoM Picklist*/
        var action = component.get("c.getpickvalExpType");
        var inputselUoM = component.find("InputSelectUoM");
        var optsUom = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                optsUom.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            inputselUoM.set("v.options", optsUom);
        });
        $A.enqueueAction(action);
        
        /*Type Picklist*/
        var action = component.get("c.getpickvalType");
        var inputselType = component.find("InputSelectType");
        var optsType = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                optsType.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            inputselType.set("v.options", optsType);
        });
        $A.enqueueAction(action);
        
        /*Category Picklist*/
        var action = component.get("c.getpickvalCategory");
        var inputselCat = component.find("InputSelectCategory");
        var optsCategory = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                optsCategory.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            inputselCat.set("v.options", optsCategory);
        });
        $A.enqueueAction(action);
    },
    
    ProductVersion2insert: function(component, event, helper) {
         var action = component.get("c.productVersionRecord2Insert");
            action.setParams({
                "newVersion1": component.get("v.Vbom"),
                "productId":component.get("v.prId"),
                "relatedBom" : JSON.stringify(component.get("v.boms"))
                
            });
            /*Testing*/
        	
        	action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                }
            });
        	/*End Testing*/
            $A.enqueueAction(action);
            
            //table
            var a = component.get("c.fetchProductVersions");
            
            a.setParams({
                "prId":component.get("v.prId")
                
            });
            a.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.Vboms", response.getReturnValue());
                }
            });
            $A.enqueueAction(a);
            component.set("v.ShowMainComponent",true);
            component.set("v.VersionComponent",false);
    },
    
    AddVersions:function(component, event){
        var name = component.find("VersionName");
        var vName = name.get("v.value");
        if (!vName) {
            component.set("v.VersionCodeError",true);
        } else {
            
            component.set("v.ShowMainComponent",true);
            var recordIndex = component.get("v.BomIndex");
            var bomDisplay = component.get("v.Vboms");
            var bom = component.get("v.Vbom");
            
            
            if(recordIndex == 'newBomVersion' || recordIndex=='' || recordIndex==undefined){
                bomDisplay.push({
                    'Name': bom.Name,
                    'ERP7__Barcode__c': bom.ERP7__Barcode__c,
                    'ERP7__Category__c': bom.ERP7__Category__c,
                    'ERP7__Active__c': bom.ERP7__Active__c,
                    'ERP7__Description__c': bom.ERP7__Description__c,
                    'ERP7__Start_Date__c': bom.ERP7__Start_Date__c,
                    'ERP7__To_Date__c': bom.ERP7__To_Date__c,
                    'ERP7__Unit_of_Measure__c': bom.ERP7__Unit_of_Measure__c,
                    'ERP7__Process__c': bom.ERP7__Process__c,
                    'ERP7__Product__c': bom.ERP7__Product__c,
                    'ERP7__Type__c': bom.ERP7__Type__c,
                    'ERP7__Status__c': bom.ERP7__Status__c,
                    'ERP7__Asset__c': bom.ERP7__Asset__c
                });
                component.set("v.Vboms", bomDisplay);
               
                component.set("v.VersionComponent",false);
                component.set("v.VersionCodeError",false);
                
            }
            else{
                var indexVal=component.get("v.BomIndex");
                bomDisplay[indexVal].Name=bom.Name;
                bomDisplay[indexVal].ERP7__Barcode__c=bom.ERP7__Barcode__c;
                bomDisplay[indexVal].ERP7__Category__c=bom.ERP7__Category__c;
                bomDisplay[indexVal].ERP7__Description__c=bom.ERP7__Description__c;
                bomDisplay[indexVal].ERP7__To_Date__c=bom.ERP7__To_Date__c;
                bomDisplay[indexVal].ERP7__Start_Date__c=bom.ERP7__Start_Date__c;
                bomDisplay[indexVal].ERP7__Unit_of_Measure__c=bom.ERP7__Unit_of_Measure__c;
                bomDisplay[indexVal].ERP7__Process__c=bom.ERP7__Process__c;
                bomDisplay[indexVal].ERP7__Type__c=bom.ERP7__Type__c;
                bomDisplay[indexVal].ERP7__Status__c=bom.ERP7__Status__c;
                bomDisplay[indexVal].ERP7__Asset__c=bom.ERP7__Asset__c;
                
                
                component.set("v.Vboms",bomDisplay);
                component.set("v.VersionComponent",false); 
                component.set("v.VersionCodeError",false);
            }
            /* save BoMversions */
            var newVer = component.get("v.Vboms");
            var action = component.get("c.SaveBOMVersion");
            action.setParams({
                "bomV": JSON.stringify(newVer),
                "bomVId":component.get("v.prId")
            });
            
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    
                    var versionId = a.getReturnValue();
                    
                    component.set("v.vId", versionId.Id);
                    
                }
            });
            $A.enqueueAction(action);
            /* save BoMversions ends here*/
            component.set("v.boms",[]);
            
            
        }
    },
    
    CancelVersions:function(component, event){
        component.set("v.ShowMainComponent",true);
        component.set("v.VersionComponent",false);
    },
    RoutingComponent: function(component, event) {
        var val = event.target.dataset.record;
        component.set("v.RoutingIndex", val);
        
        component.set("v.RoutingComponent",true);
        
        //Operations addition
        var boms = new Array();
        component.set("v.operations",[]);
        boms = component.get("v.operations");
        boms.push({'Name':'','ERP7__Fixed_Cost__c':'','ERP7__Move_Time__c':'',
                   'ERP7__Next_Operation_No__c':'','ERP7__Operation_No__c':'','ERP7__Process_Cycle__c':'','ERP7__Quantity__c':'',
                   'ERP7__Required__c':'','ERP7__Routing__c':'','ERP7__Run_Time__c':'',
                   'ERP7__Setup_Time__c':'','ERP7__Variable_Cost__c':'','ERP7__Wait_Time__c':''
                  });
        component.set("v.operations",boms);
        component.set("v.rout",{ 'sobjectType': 'ERP7__Routing__c','Name': '', 'ERP7__Status__c':'','ERP7__Type__c':'','ERP7__Description__c':'','ERP7__Process__c':'','ERP7__Site__c':'','ERP7__Planner__c':'','ERP7__Version__c':'','ERP7__Engineer__c':''});
        component.set("v.BackToRouting",false);
        
        
        /*Routing Status Picklist*/
        var action = component.get("c.getpickvalRoutingStatus");
        var inputselStatus = component.find("RoutingStatus");
        var rStatus = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                rStatus.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            inputselStatus.set("v.options", rStatus);
        });
        $A.enqueueAction(action);
        
        
        /*Routing Type Picklist*/
        var action = component.get("c.getpickvalRoutingType");
        var inputselRType = component.find("RoutingType");
        var rType = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                rType.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            inputselRType.set("v.options", rType);
        });
        $A.enqueueAction(action);
        
    },
    
    AddRoutings:function(component, event){
        var name = component.find("rName");
        var rName = name.get("v.value");
        if (!rName) {
            component.set("v.RoutingCode",true);
        } 
        else {
            var recordIndex = component.get("v.RoutingIndex");
            component.set("v.BackToRouting",true);
            var routDisplay = component.get("v.routs");
            var rot = component.get("v.rout");
            if(recordIndex == 'newRouting' || recordIndex=='' || recordIndex==undefined){
                routDisplay.push({
                    'Name': rot.Name,
                    'ERP7__Version__c': rot.ERP7__Version__c,
                    'ERP7__Description__c': rot.ERP7__Description__c,
                    'ERP7__Engineer__c': rot.ERP7__Engineer__c,
                    'ERP7__Description__c': rot.ERP7__Description__c,
                    'ERP7__Planner__c': rot.ERP7__Planner__c,
                    'ERP7__Process__c': rot.ERP7__Process__c,
                    'ERP7__Product__c': rot.ERP7__Product__c,
                    'ERP7__Site__c': rot.ERP7__Site__c,
                    'ERP7__Type__c': rot.ERP7__Type__c,
                    'ERP7__Status__c': rot.ERP7__Status__c
                });
                component.set("v.routs", routDisplay);
                component.set("v.RoutingCode",false);
                component.set("v.RoutingComponent",false);
            }
            else{
                var indexVal=component.get("v.RoutingIndex");
                routDisplay[indexVal].Name=rot.Name;
                routDisplay[indexVal].ERP7__Version__c=rot.ERP7__Version__c;
                routDisplay[indexVal].ERP7__Description__c=rot.ERP7__Description__c;
                routDisplay[indexVal].ERP7__Engineer__c=rot.ERP7__Engineer__c;
                routDisplay[indexVal].ERP7__Planner__c=rot.ERP7__Planner__c;
                routDisplay[indexVal].ERP7__Process__c=rot.ERP7__Process__c;
                routDisplay[indexVal].ERP7__Status__c=rot.ERP7__Status__c;
                routDisplay[indexVal].ERP7__Product__c=rot.ERP7__Product__c;
                routDisplay[indexVal].ERP7__Site__c=rot.ERP7__Site__c;
                routDisplay[indexVal].ERP7__Type__c=rot.ERP7__Type__c;
                component.set("v.routs",routDisplay);
                component.set("v.RoutingCode",false);
                component.set("v.RoutingComponent",false); 
            }
             /* save Routings */
            var newVer = component.get("v.routs");
            var action = component.get("c.insertRoutings");
            action.setParams({
                "rout": JSON.stringify(newVer),
                "routId":component.get("v.prId"),
                "vId":component.get("v.vId"),
            });
            
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    
                    var versionId = a.getReturnValue();

                    component.set("v.rId", versionId.Id);
                    
                }
            });
            $A.enqueueAction(action);
            /* save Routings ends here*/
            
        }
    },
    CancelRoutings:function(component, event){
        component.set("v.BackToRouting",true);
        component.set("v.RoutingComponent",false);
    },
    
    DiscountComponent: function(component, event) {
        var val = event.target.dataset.record;
        component.set("v.recordIndex", val);
        component.set("v.DiscountComponent",true);
        component.set("v.BackToDiscount",false);
         try{ 
            component.set("v.tda2.Name", "");
            component.set("v.tda2.ERP7__Order_Profile__c", null);
            component.set("v.tda2.ERP7__Discount_Plan__c", null);
            component.set("v.tda2.ERP7__Tier__c", null);
            component.set("v.tda2.ERP7__Active__c", false);
            component.set("v.tda2.ERP7__Default__c", false);
        } catch(err){}
    },
    
    AddDiscounts:function(component, event){
        var name = component.find("tdaName");
        var vName = name.get("v.value");
        if (!vName) {
            component.set("v.DiscountName",true);
        } else {
            var recordIndex = component.get("v.recordIndex");
            component.set("v.BackToDiscount",true);
            var tda = component.get("v.tda2");
            var tdaDisplay = component.get("v.tdiscounts");
            if(recordIndex == 'newTda' || recordIndex=='' || recordIndex==undefined){
                tdaDisplay.push({
                    'Name': tda.Name,
                    'ERP7__Discount_Plan__r.Name': tda.ERP7__Discount_Plan__r.Name,
                    'ERP7__Order_Profile__c': tda.ERP7__Order_Profile__c,
                    'ERP7__Tier__c': tda.ERP7__Tier__c,
                    'ERP7__Active__c': tda.ERP7__Active__c,
                    'ERP7__Default__c': tda.ERP7__Default__c,
                    'ERP7__Product__c': tda.ERP7__Product__c
                });
                component.set("v.tdiscounts", tdaDisplay);
                component.set("v.DiscountName",false);
                component.set("v.DiscountComponent",false);
            }
            else{
                
                var indexVal=component.get("v.recordIndex");
                tdaDisplay[indexVal].Name=tda.Name;
                tdaDisplay[indexVal].ERP7__Discount_Plan__c=tda.ERP7__Discount_Plan__c;
                tdaDisplay[indexVal].ERP7__Tier__c=tda.ERP7__Tier__c;
                tdaDisplay[indexVal].ERP7__Order_Profile__c=tda.ERP7__Order_Profile__c;
                tdaDisplay[indexVal].ERP7__Active__c=tda.ERP7__Active__c;
                component.set("v.tdiscounts",tdaDisplay);
                component.set("v.DiscountName",false);
                component.set("v.DiscountComponent",false);
            }
            
            /*Save Discount Allocations*/
            var tda = component.get("v.tdiscounts");
            var action = component.get("c.SaveTDA2");
            
            action.setParams({
                "tda2": JSON.stringify(tda),
                tdaId: component.get("v.prId")
                
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    
                }
            });
            
            $A.enqueueAction(action)
            /*Save Discount Allocations Ends here*/
            
            
        }
    },
    CancelDiscounts:function(component, event){
        component.set("v.BackToDiscount",true);
        component.set("v.DiscountComponent",false);
    },
    
    
  
    AddWarranty:function(component, event){
        var name = component.find("wName");
        var vName = name.get("v.value");
        if (!vName) {
            component.set("v.WarrantyName",true);
        } else {
            var recordIndex = component.get("v.WarIndex");
            component.set("v.BackToWarranty",true);
            var war = component.get("v.war");
            var warDisplay = component.get("v.warranties");
            if(recordIndex=='newWarranty' || recordIndex=='' || recordIndex==undefined){
                warDisplay.push({
                    'Name': war.Name,
                    'ERP7__Days_of_Warranty__c': war.ERP7__Days_of_Warranty__c,
                    'ERP7__Active__c': war.ERP7__Active__c,
                    'ERP7__Number_Days_From_Trans_Return_Accepted__c': war.ERP7__Number_Days_From_Trans_Return_Accepted__c,
                    'ERP7__Exchange__c': war.ERP7__Exchange__c,
                    'ERP7__Standard_Manufacturing_Warranty__c': war.ERP7__Standard_Manufacturing_Warranty__c
                    
                });
                
                component.set("v.warranties", warDisplay);
                component.set("v.WarrantyName",false);
                component.set("v.WarrantyComponent",false);
            }
            else{
                var indexVal=component.get("v.WarIndex");
                warDisplay[indexVal].Name=war.Name;
                warDisplay[indexVal].ERP7__Days_of_Warranty__c=war.ERP7__Days_of_Warranty__c;
                warDisplay[indexVal].ERP7__Active__c=war.ERP7__Active__c;
                warDisplay[indexVal].ERP7__Number_Days_From_Trans_Return_Accepted__c=war.ERP7__Number_Days_From_Trans_Return_Accepted__c;
                warDisplay[indexVal].ERP7__Exchange__c=war.ERP7__Exchange__c;
                warDisplay[indexVal].ERP7__Standard_Manufacturing_Warranty__c=war.ERP7__Standard_Manufacturing_Warranty__c;
                
                component.set("v.warranties",warDisplay);
                component.set("v.WarrantyName",false);
                component.set("v.WarrantyComponent",false);
            }
            
            /*Save Warranty and Return*/
            var war = component.get("v.warranties");
            var action = component.get("c.SaveWarranty");
            action.setParams({
                "war": JSON.stringify(war),
                warId: component.get("v.prId")
                
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {}
            });
            $A.enqueueAction(action)
            /*Save Warranty and Return ends here*/
        }
    },
    CancelWarranty:function(component, event){
        component.set("v.BackToWarranty",true);
        component.set("v.WarrantyComponent",false);
        
    },
    
    
    
    LocationComponent: function(component, event) {
        var val = event.target.dataset.record;
        component.set("v.LocIndex", val);
        component.set("v.LocationComponent",true);
        component.set("v.BackToLocation",false);
    },
    
    AddLocation:function(component, event){
        var name = component.find("plName");
        var Loc = component.find("Ploc");
        var vName = name.get("v.value");
        var pLoc = Loc.get("v.value");
        if (!pLoc) {
            component.set("v.WarehouseName",true);
        } else {
            var recordIndex = component.get("v.LocIndex");
            component.set("v.BackToLocation",true);
            var pl = component.get("v.pl");
            var locDisplay = component.get("v.locations");
            if(recordIndex == 'newLocation' || recordIndex=='' || recordIndex==undefined){
                locDisplay.push({
                    'Name': pl.Name,
                    'ERP7__Capacity__c': pl.ERP7__Capacity__c,
                    'ERP7__Location__c': pl.ERP7__Location__c,
                    'ERP7__Site__c': pl.ERP7__Site__c,
                    'ERP7__Storage_Container__c': pl.ERP7__Storage_Container__c,
                    'ERP7__Active__c': pl.ERP7__Active__c
                });
                
                component.set("v.locations", locDisplay);
                component.set("v.WarehouseName",false);
                component.set("v.LocationComponent",false);
            }
            else{
                var indexVal=component.get("v.LocIndex");
                locDisplay[indexVal].Name=pl.Name;
                locDisplay[indexVal].ERP7__Capacity__c=pl.ERP7__Capacity__c;
                locDisplay[indexVal].ERP7__Location__c=pl.ERP7__Location__c;
                locDisplay[indexVal].ERP7__Product__c=pl.ERP7__Product__c;
                locDisplay[indexVal].ERP7__Active__c=pl.ERP7__Active__c;
                locDisplay[indexVal].ERP7__Site__c=pl.ERP7__Site__c;
                locDisplay[indexVal].ERP7__Storage_Container__c=pl.ERP7__Storage_Container__c;
                component.set("v.locations",locDisplay);
                component.set("v.WarehouseName",false);
                component.set("v.LocationComponent",false); 
            }
            
            
            /*Save Product Locations*/
            var pl = component.get("v.locations");
            var action = component.get("c.insertPLocations");
            action.setParams({
                "ploc": JSON.stringify(pl),
                pId: component.get("v.prId")
                
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {}
            });
            $A.enqueueAction(action)
            /*Save Product Locations ends here*/
        }
    },
    CancelLocation:function(component, event){
        component.set("v.BackToLocation",true);
        component.set("v.LocationComponent",false);
    },
    
   
    
    AddPbes:function(component, event){
        var pbe = component.get("v.pbe");
        var pbeDisplay = component.get("v.pbEntries");
        if(pbeDisplay.length==0 && pbe.Pricebook2Id != '01s240000048zt7AAA'){
            component.set("v.ShowErrorToast", true);
        }
        
        else if(pbeDisplay.length >= 1 && pbe.Pricebook2Id == '01s240000048zt7AAA'){
            component.set("v.ShowErrorToast2", true);
        }
        
            else{
                component.set("v.BackToPriceBook",true);
                pbeDisplay.push({
                    'Pricebook2Id': pbe.Pricebook2Id,
                    'ERP7__Selling_Price__c': pbe.ERP7__Selling_Price__c,
                    'ERP7__Purchase_Price__c': pbe.ERP7__Purchase_Price__c,
                    'ERP7__Barcode__c': pbe.ERP7__Barcode__c,
                    'ERP7__Track_Inventory__c': pbe.ERP7__Track_Inventory__c,
                    'IsActive': pbe.IsActive,
                    'UnitPrice': pbe.UnitPrice
                });
                component.set("v.pbEntries", pbeDisplay);
                component.set("v.PriceBookComponent",false);
                component.set("v.ShowErrorToast", false);
                component.set("v.ShowErrorToast2", false);
            }
        
        
        
        /*Save PriceBook Entry*/
        var pbes = component.get("v.pbEntries");
        var action = component.get("c.SavePricebook");
        action.setParams({
            "pbe": JSON.stringify(pbes),
            productId: component.get("v.prId")
            
            
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.pbEntries",a.getReturnValue());
            }else{
                // error msg....
            }
        });
        $A.enqueueAction(action)
        /*Save PriceBook Entry ends here*/
        
        
    },
    
    CancelPriceBook:function(component, event){
        component.set("v.BackToPriceBook",true);
        component.set("v.PriceBookComponent",false);
    },
    
   
    onclickTab2:function(component, event) {
        component.set("v.RoutingComponent",false);
        component.set("v.VersionComponent",false);
        
        component.set("v.ShowTab2",true);
        component.set("v.ShowTab3",false);
        component.set("v.ShowTab4",false);
        component.set("v.ShowTab5",false);
        component.set("v.ShowTab6",false);
        component.set("v.ShowTab7",false);
        
    },
    onclickTab3:function(component, event) {
        component.set("v.VersionComponent",false);
        component.set("v.ShowMainComponent",true);  
        component.set("v.RoutingComponent",false);
        component.set("v.ShowTab2",false);
        component.set("v.ShowTab3",true);
        component.set("v.ShowTab4",false);
        component.set("v.ShowTab5",false);
        component.set("v.ShowTab6",false);
        component.set("v.ShowTab7",false);
        
        //Bill Of Materials addition
        var boms = new Array();
        component.set("v.boms",[]);
        boms = component.get("v.boms");
        boms.push({'Name':'','ERP7__Active__c':'','ERP7__BOM_Product__c':''
                   ,'ERP7__Process_Cycle__c':'','ERP7__Raw_Material_Required_Amount__c':'','ERP7__Quantity__c':'','ERP7__Type__c':''
                  });
        component.set("v.boms",boms);
    },
    onclickTab4:function(component, event) {
        component.set("v.BackToRouting",true);
        component.set("v.VersionComponent",false);
        component.set("v.RoutingComponent",false);
        component.set("v.ShowTab2",false);
        component.set("v.ShowTab3",false);
        component.set("v.ShowTab4",true);
        component.set("v.ShowTab5",false);
        component.set("v.ShowTab6",false);
        component.set("v.ShowTab7",false);
        
        //Operations addition
        var boms = new Array();
        component.set("v.operations",[]);
        boms = component.get("v.operations");
        boms.push({'Name':'','ERP7__Fixed_Cost__c':'','ERP7__Move_Time__c':'',
                   'ERP7__Next_Operation_No__c':'','ERP7__Operation_No__c':'','ERP7__Process_Cycle__c':'','ERP7__Quantity__c':'',
                   'ERP7__Required__c':'','ERP7__Routing__c':'','ERP7__Run_Time__c':'',
                   'ERP7__Setup_Time__c':'','ERP7__Variable_Cost__c':'','ERP7__Wait_Time__c':''
                  });
        component.set("v.operations",boms);
    },
    onclickTab5:function(component, event) {
        component.set("v.RoutingComponent",false);
        component.set("v.VersionComponent",false);
        component.set("v.ShowTab2",false);
        component.set("v.ShowTab3",false);
        component.set("v.ShowTab4",false);
        component.set("v.ShowTab5",true);
        component.set("v.ShowTab6",false);
        component.set("v.ShowTab7",false);
        
    },
    onclickTab6:function(component, event) {
        component.set("v.RoutingComponent",false);
        component.set("v.VersionComponent",false);
        
        component.set("v.ShowTab2",false);
        component.set("v.ShowTab3",false);
        component.set("v.ShowTab4",false);
        component.set("v.ShowTab5",false);
        component.set("v.ShowTab6",true);
        component.set("v.ShowTab7",false);
        
    },
    onclickTab7:function(component, event) {
        component.set("v.RoutingComponent",false);
        component.set("v.VersionComponent",false);
        
        component.set("v.ShowTab2",false);
        component.set("v.ShowTab3",false);
        component.set("v.ShowTab4",false);
        component.set("v.ShowTab5",false);
        component.set("v.ShowTab6",false);
        component.set("v.ShowTab7",true);
        
    },
    
    editTDARecord: function(component, event, helper) {
        component.set("v.DiscountComponent",true);
        component.set("v.BackToDiscount",false);
       
        var rId = event.currentTarget.dataset.target;
        var action = component.get("c.getTDAbyId");
        action.setParams({
            recId: rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                component.set("v.tda2", obj);
             }
         });
        $A.enqueueAction(action);
    },
    
    Tda2insert: function(component, event, helper) {
        var name = component.find("tdaName");
        var vName = name.get("v.value");
        if (!vName) {
            component.set("v.DiscountName",true);
        } else {
            
            var action = component.get("c.tdaRecord2Insert");
            action.setParams({
                "newTDA1": JSON.stringify(component.get("v.tda2")),
                "productId":component.get("v.prId")
                
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {}
            });
            $A.enqueueAction(action)
            
            //table
            var a = component.get("c.fetchTDA");
            a.setParams({
                "prId":component.get("v.prId")
                
            });
            a.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.tdiscounts", response.getReturnValue());
                }
            });
            $A.enqueueAction(a);
            component.set("v.DiscountComponent",false);
            component.set("v.BackToDiscount",true);
            
        }
        
    },
    
    pLocation2insert: function(component, event, helper) {
        var Loc = component.find("Ploc");
        var pLoc = Loc.get("v.value");
        if (!pLoc) {
            component.set("v.WarehouseName",true);
        } else {
            
            var action = component.get("c.ProductLocation2Insert");
            action.setParams({
                "newPLoc1": JSON.stringify(component.get("v.pl")),
                "productId":component.get("v.prId")
                
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {}
            });
            $A.enqueueAction(action)
            
            //table
            var a = component.get("c.fetchProductLocations");
             a.setParams({
                "prId":component.get("v.prId")
            });
            a.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.locations", response.getReturnValue());
                    component.set("v.pl",{'sobjectType': 'ERP7__Product_Location__c','Name': ''});
                }
            });
            $A.enqueueAction(a);
            component.set("v.LocationComponent",false); 
            component.set("v.BackToLocation",true); 
            
        }
    },
    
    editPLocationRecord: function(component, event, helper) {
        component.set("v.LocationComponent",true);
        component.set("v.BackToLocation",false);
        var rId = event.currentTarget.dataset.target;
        var action = component.get("c.getProductlocationById");
        action.setParams({
            recId: rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                component.set("v.pl", obj);
            }
        });
        $A.enqueueAction(action);
    },
    
    PriceBookEntryComponent: function(component, event) {
        component.set("v.PriceBookComponent",true);
        component.set("v.BackToPriceBook",false);
            component.set("v.pbe.Pricebook2Id", null);
            component.set("v.pbe.UnitPrice", "");
            component.set("v.pbe.ERP7__Barcode__c", "");
            component.set("v.pbe.IsActive", false);
            component.set("v.pbe.ERP7__Purchase_Price__c", "");
            component.set("v.pbe.ERP7__Selling_Price__c", "");
            component.set("v.pbe.ERP7__Track_Inventory__c", false);
        	component.set("v.pbe.ERP7__Version__c","");
        	component.set("v.pbe.ERP7__Warranty_Return_Policy__c","");
        	component.set("v.pbe.ERP7__Admin_Shipping_Price__c","");
        	component.set("v.pbe.ERP7__Shipping_Price__c","");
        	component.set("v.pbe.ERP7__MOQ__c","");
        	component.set("v.pbe.ERP7__Tax_Exempt__c",false);
            component.set("v.pbe.ERP7__Discount_Plan__c","");
    },
  
    PBE2Insert: function(component, event, helper) {
        
        var action = component.get("c.pricebookEntry2Insert");
        action.setParams({
            "newPBE1": JSON.stringify(component.get("v.pbe")),
            "productId":component.get("v.prId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {}
        });
        $A.enqueueAction(action);
          //table
        var a = component.get("c.fetchPricebook");
        a.setParams({
            "prId":component.get("v.prId")
        });
        a.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.pbEntries", response.getReturnValue());
                    component.set("v.pbe.Pricebook2Id", null);
                    component.set("v.pbe.UnitPrice", "");
                    component.set("v.pbe.ERP7__Barcode__c", "");
                    component.set("v.pbe.IsActive", false);
                    component.set("v.pbe.ERP7__Purchase_Price__c", "");
                    component.set("v.pbe.ERP7__Selling_Price__c", "");
                    component.set("v.pbe.ERP7__Track_Inventory__c", false);
                	
            }
        });
        $A.enqueueAction(a);
        component.set("v.PriceBookComponent",false);
        component.set("v.BackToPriceBook",true);
    },
    
     editPbe: function(component, event, helper) {
        component.set("v.PriceBookComponent",true);
        component.set("v.BackToPriceBook",false);
        var rId = event.currentTarget.dataset.target;
        var action = component.get("c.getPricebookentrybyId");
        action.setParams({
            recId: rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                
                component.set("v.pbe", obj);
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
     deletePbe: function(component, event, helper) {
        var result = confirm("Are you sure want to delete?");
        if (result) {
        var recId = event.currentTarget.dataset.target;
        var action = component.get("c.deletePriceBook");
        action.setParams({
            "recId" : recId
        });
        
        var index = event.currentTarget.dataset.index;
        var Del = component.get("v.pbEntries");
        Del.splice(index, 1);
        component.set("v.pbEntries", Del);
        
        $A.enqueueAction(action);
        }
    },
    
    WarrantyComponent: function(component, event, helper) {
        
        component.set("v.WarrantyComponent",true);
        component.set("v.BackToWarranty",false);
        component.set("v.war.Name","");
        component.set("v.war.ERP7__Days_of_Warranty__c","");
        component.set("v.war.ERP7__Number_Days_From_Trans_Return_Accepted__c","");
        component.set("v.war.ERP7__Active__c",false);
        component.set("v.war.ERP7__Standard_Manufacturing_Warranty__c",false);
        component.set("v.war.ERP7__Exchange__c",false);
        
    },
    
      Warranty2insert: function(component, event, helper) {
            var action = component.get("c.warrantyAndReturn2Insert");
            action.setParams({
                "newWarrantyReturn1": JSON.stringify(component.get("v.war")),
                "productId":component.get("v.prId")
                
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {}
            });
            $A.enqueueAction(action)
            
            //table
            var a = component.get("c.fetchWarrantyDetails");
            a.setParams({
                "prId":component.get("v.prId")
                
            });
            a.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.warranties", response.getReturnValue());
                    component.set("v.war",{'sobjectType': 'ERP7__Warranty_Return_Policy__c','Name': '','ERP7__Days_of_Warranty__c':'','ERP7__Number_Days_From_Trans_Return_Accepted__c':'',
                                          'ERP7__Active__c':false,'ERP7__Standard_Manufacturing_Warranty__c':false,'ERP7__Exchange__c':false});
                   
                }
            });
            $A.enqueueAction(a);
            component.set("v.WarrantyComponent",false);
            component.set("v.BackToWarranty",true);
    },
  
 	 editWarranty: function(component, event, helper) {
         component.set("v.WarrantyComponent",true);
        component.set("v.BackToWarranty",false);
        var rId = event.currentTarget.dataset.target;
        var action = component.get("c.getWarrantyById");
        action.setParams({
            recId: rId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                 component.set("v.war", obj);
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteWarranty: function(component, event, helper) {
        var result = confirm("Are you sure want to delete?");
        if (result) {
        var recId = event.currentTarget.dataset.target;
        var action = component.get("c.deleteWarrantyRecord");
        action.setParams({
            "recId" : recId
        });
        var index = event.currentTarget.dataset.index;
        var Del = component.get("v.warranties");
        Del.splice(index, 1);
        component.set("v.warranties", Del);
        $A.enqueueAction(action);
        }
    },
    
     Routing2insert: function(component, event, helper) {
         var rout = component.get("v.rout");
         if($A.util.isEmpty(rout.ERP7__Version__c) || $A.util.isUndefined(rout.ERP7__Version__c)){
            alert('BOM Version is Required');
            return;
        }    
       		var action = component.get("c.routingRecord2Insert");
         	action.setParams({
                "newRouting1": JSON.stringify(component.get("v.rout")),
				"productId":component.get("v.prId"),
                "versionId":component.get("v.vId"),
                "relatedOper":JSON.stringify(component.get("v.operations"))
                
            });
         	
         	action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                }
            });
            $A.enqueueAction(action);
        
            var a = component.get("c.fetchRoutings");
            a.setParams({
                "prId":component.get("v.prId")
            });
            a.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.routs", response.getReturnValue());
                }
            });
            $A.enqueueAction(a);
            component.set("v.BackToRouting",true);
			component.set("v.RoutingComponent",false);
        
    },
    
    Navigate : function(component, event, helper) {
        var bomitems = component.get('v.boms');
        bomitems.push({'sObjectType':'ERP7__BOM__c','Name':'','ERP7__Process_Cycle__c':'','ERP7__Quantity__c':'','ERP7__Type__c':'','ERP7__Phase__c':'','ERP7__Unit_of_Measure__c':'','ERP7__Active':true});
		component.set('v.boms',bomitems);
    },
    
    operationsAdd : function(component, event, helper) {
        var operItems = component.get('v.operations');
        operItems.push({'sObjectType':'ERP7__Operation__c', 'Name':'', 'ERP7__Operation_No__c':'', 'ERP7__Setup_Time__c':'', 
                       'ERP7__Run_Time__c':'', 'ERP7__Wait_Time__c':'', 'ERP7__Move_Time__c':'', 'ERP7__Quantity__c':'', 
                       'ERP7__Variable_Cost__c':'', 'ERP7__Fixed_Cost__c':''});
		component.set('v.operations',operItems);
    },
    
    
    handleDelClick: function(component, event, helper) {
        var self = this;
        var deleteAction = component.get("c.deleteVersions");
        deleteAction.setParams({
            "recordId": event.target.dataset.target
        });
        deleteAction.setCallback(self, function(a) {
            var recordId = a.getReturnValue();
            if (recordId == null) {} else {
                var deleteEvent = component.getEvent("delete");
                deleteEvent.setParams({
                    "listIndex": event.target.dataset.index,
                    "oldRecord": component.get("v.Vboms")[event.target.dataset.index]
                }).fire();
            }
        });
        // Enqueue the action
        $A.enqueueAction(deleteAction);
    },
    handleVersionDelete: function(component, event, helper) {
        var items = component.get("v.Vboms");
        items.splice(event.getParam("listIndex"), 1);
        component.set("v.Vboms", items);
    }
    
})