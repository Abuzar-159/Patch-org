({
    focusTOscan:function(component, event){
        try{
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
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
        }catch(e){
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
        
        
    },
   /* getSerials : function(cmp,stockAssignedSerialIds){
        var action1 = cmp.get("c.getSerialNumbers");
        var MOId = cmp.get("v.manuOrder.Id");
        action1.setParams({"offsetVal" : 0,"Mo" : MOId,"limitSer" : 500,'SerialIds' : stockAssignedSerialIds});
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
                }else {
                    newSOL.MO_WO_Serial__c = null;
                }
                if(moBatchNos.length == 1){
                    newSOL.ERP7__MO_WO_Material_Batch_Lot__c = moBatchNos[0].Id;
                }
                cmp.set("v.NewSOLI",newSOL);
                cmp.set("v.SerialsForAllocation", NewSerialsForAllocation);
                console.log('SelectMRP1 moSerialNos.length~>'+moSerialNos.length); 
                cmp.set("v.saPage",true);
                cmp.set("v.showSpinner",false);
                console.log('settimeout saPage SelectMRP1'); 
            }
        });
        $A.enqueueAction(action1);
    },*/
    getSerials : function(cmp, stockAssignedSerialIds) {
    var action1 = cmp.get("c.getSerialNumbers");
    var MOId = cmp.get("v.manuOrder.Id");

    action1.setParams({
        offsetVal: 0,
        Mo: MOId,
        limitSer: 500,
        SerialIds: stockAssignedSerialIds
    });

    action1.setCallback(this, function(response1) {
        try {
            if (response1.getState() === "SUCCESS") {
                var NewSerialsForAllocation = [];
                var moSerialNos = response1.getReturnValue() || [];
                cmp.set("v.moSerialNos", moSerialNos);

                var moBatchNos = cmp.get("v.moBatchNos") || [];
                var newSOL = cmp.get("v.NewSOLI") || {};

                for (var y = 0; y < moSerialNos.length; y++) {
                    if (!stockAssignedSerialIds.includes(moSerialNos[y].Id)) {
                        moSerialNos[y].SelectItem = false;
                        NewSerialsForAllocation.push(moSerialNos[y]);
                    }
                }

                // keep field blank if no MO serials exist added by bushra
                if (NewSerialsForAllocation.length > 0) {
                    newSOL.MO_WO_Serial__c = NewSerialsForAllocation[0].Id;
                } else {
                    newSOL.MO_WO_Serial__c = null;
                }

                if (moBatchNos.length === 1) {
                    newSOL.MO_WO_Material_Batch_Lot__c = moBatchNos[0].Id;
                }

                cmp.set("v.NewSOLI", newSOL);
                cmp.set("v.SerialsForAllocation", NewSerialsForAllocation);

                // IMPORTANT: always stop loading and show page
                cmp.set("v.saPage", true);
                cmp.set("v.showSpinner", false);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                $A.util.addClass(cmp.find('mainSpinLoad'), "slds-hide");
            } else {
                cmp.set("v.SerialsForAllocation", []);
                cmp.set("v.showSpinner", false);
                cmp.set("v.saPage", true);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                $A.util.addClass(cmp.find('mainSpinLoad'), "slds-hide");
            }
        } catch (e) {
            console.log('getSerials error', e);
            cmp.set("v.SerialsForAllocation", []);
            cmp.set("v.showSpinner", false);
            cmp.set("v.saPage", true);
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            $A.util.addClass(cmp.find('mainSpinLoad'), "slds-hide");
        }
    });

    $A.enqueueAction(action1);
},
    
    getSolis: function(cmp, event, helper) {
        var msoliId = cmp.get("v.mosoliId");
        var mOrdItmId = cmp.get("v.MOrdItm");//MOrdItm
        if((msoliId != undefined && msoliId != '')||(mOrdItmId != undefined && mOrdItmId != '')){
            var action = cmp.get("c.getAllSOLI");
            action.setParams({
                "mosoliId": msoliId,
                "MOrdItm" : mOrdItmId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    cmp.set("v.manuOrder", response.getReturnValue().manuOrders);
                    var mo = response.getReturnValue();
                    var al = JSON.stringify(mo.Product);
                    //alert(al);
                    cmp.set("v.prevent", true);
                    cmp.set("v.Product", response.getReturnValue().Product);
                    console.log('Product 4 : ',response.getReturnValue().Product);
                    cmp.set("v.Version", response.getReturnValue().Version);
                    console.log('Version 4 : ',response.getReturnValue().Version);
                    cmp.set("v.Routing", response.getReturnValue().Routing);
                    cmp.set("v.prevent", false);
                    if(response.getReturnValue().manuOrders.ERP7__Sales_Order__c != undefined)  cmp.set("v.Back2Parent", true);
                    if(response.getReturnValue().manuOrders.ERP7__Order__c != undefined)  cmp.set("v.Back2Parent", true);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getMRPMO: function(cmp, event, helper) {
        var mrpId = cmp.get("v.mrpId");
        if(mrpId != undefined && mrpId != ''){
            var action = cmp.get("c.getAllMO");
            action.setParams({
                "mrpId": mrpId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    cmp.set("v.manuOrder", response.getReturnValue().MO);
                    if(response.getReturnValue().MRP.ERP7__MO__c != null && response.getReturnValue().MRP.ERP7__MO__c != undefined && response.getReturnValue().MRP.ERP7__MO__c != "") cmp.set("v.manuOrder.ERP7__Manufacturing_Order__r.Name",response.getReturnValue().MRP.ERP7__MO__r.Name);
                    else cmp.set("v.manuOrder.ERP7__Manufacturing_Order__r.Name",response.getReturnValue().MRP.Name);
                    
                    cmp.set("v.prevent", true);
                    cmp.set("v.Product", response.getReturnValue().Product);
                    console.log('Product 5 : ',response.getReturnValue().Product);
                    cmp.set("v.Version", response.getReturnValue().Version);
                    console.log('Version 5 : ',response.getReturnValue().Version);
                    cmp.set("v.Routing", response.getReturnValue().Routing);
                    cmp.set("v.prevent", false);
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getMPSLine: function(cmp, event, helper) {
        var mpslineId = cmp.get("v.mpslineId");
        if(mpslineId != undefined && mpslineId != ''){
            var action = cmp.get("c.getAllMPS");
            action.setParams({
                "mpslineId": mpslineId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    cmp.set("v.manuOrder", response.getReturnValue().MO);
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
            cmp.set("v.manuOrder.ERP7__Product__c",pId);
        }
        if(rId != undefined && rId != ""){
            cmp.set("v.manuOrder.ERP7__Routing__c",rId);
        }
        if(ver != undefined && ver != ""){
            cmp.set("v.manuOrder.ERP7__Version__c",ver);
        }
        if(quan != undefined && quan != ""){
            cmp.set("v.manuOrder.ERP7__Quantity__c",quan);
        }
        //debugger;
    },
    CreatePR:function(component, event, solid){
        var quanMultiplier = 1;
        var obj = component.get('v.MRPs');
        for(var x in obj){
            if(obj[x].MRP.Id == solid){
                quanMultiplier = obj[x].WeightMultiplier;
            }
        }
        $A.createComponent("c:CreatePurchaseRequisition",{
            "mrplineId":solid,
            "quantityMultiplier":quanMultiplier,
            "cancelclick":component.getReference("c.backMO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    CreatePO:function(component, event, solid){
        console.log('CreatePO called solid~>'+solid);
        
        var soliId = solid;
        var obj = component.get('v.MRPs');
        var quanMultiplier = 1;
        for(var x in obj){
            if(obj[x].MRP.Id == solid){
                quanMultiplier = obj[x].WeightMultiplier;
            }
        }
        
        console.log('CreatePO quanMultiplier~>'+quanMultiplier);
        
        $A.createComponent("c:CreatePurchaseOrder",{
            "mrplineId":soliId,
            "quantityMultiplier":quanMultiplier,
            "cancelclick":component.getReference("c.backMO"),
            "showPOType" : false
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    CreateMO : function(cmp, event, solid) { 
        //event.currentTarget.getAttribute('data-mosoliId');
        // var URL_RMA = '/apex/ERP7__ManufacturingOrderLC?mrpId='+MRPId;
        // window.open(URL_RMA,'_self');
        // var MPSId=event.currentTarget.dataset.record;
        var requiredQty = 1;
        var obj = cmp.get('v.MRPs');
        for(var x in obj){
            if(obj[x].MRP.ERP7__MRP_Product__c == solid){
                requiredQty = obj[x].MRP.ERP7__Total_Amount_Required__c*obj[x].WeightMultiplier;
            }
        }
        console.log('requiredQty : ',requiredQty);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                ProId :   solid,
                QTY : requiredQty
            }
        });
        evt.fire();
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
    deleteMRPs : function(component,selectedMRPs){
        var action = component.get('c.deleteSelectedMRP');
        action.setParams({MRPIds : selectedMRPs});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var obj = response.getReturnValue();
                if(obj == 'Success'){
                    var MRPslst = component.get('v.MRPs');
                    for(var a in selectedMRPs){
                        for(var x in MRPslst){
                            if(MRPslst[x].MRP.Id == selectedMRPs[a]){
                                MRPslst.splice(x,1); 
                            } 
                        }
                    }
                    component.set('v.MRPs',MRPslst);
                    
                    this.showToast($A.get('$Label.c.Success1'),'success',$A.get('$Label.c.Items_deleted_Successfully'));
                }
                else{
                    console.log('Error : ',response.getError());
                }
            }
        });
        $A.enqueueAction(action);
    },
    getStatus : function(cmp,event){
        try{
            var action = cmp.get('c.getInwardStatus');
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var obj = response.getReturnValue();
                    if(obj != null){
                        cmp.set('v.statusOption',obj);
                    }
                }
                else{
                    console.log('Error : ',response.getError());
                }
            });
            $A.enqueueAction(action);
        } catch(e){
            console.log('Error : ',e);
        }
    },
    getpicklistValues : function(cmp,event){
        try{
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
                        console.log('key~>'+key);
                        console.log('StoreResponse[key]~>'+JSON.stringify(StoreResponse[key]));
                        arrayMapKeys.push({key: key, value: StoreResponse[key]});
                    }                
                    console.log('arrayMapKeys~>',arrayMapKeys);
                    
                    cmp.set("v.depnedentFieldMap",arrayMapKeys);
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
                    
                    
                }else{
                    var error = response.getError();
                    console.log('getDependentMap err~>'+JSON.stringify(error));
                }
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('err',e);
        }        
    },
    fetchDepValues: function(component, ListOfDependentFields) {
        try{
            // create a empty array var for store dependent picklist values for controller field  
            var dependentFields = [];
            dependentFields.push('--- None ---');
            for (var i = 0; i < ListOfDependentFields.length; i++) {
                dependentFields.push(ListOfDependentFields[i]);
            }
            // set the dependentFields variable values to store(dependent picklist field) on lightning:select
            component.set("v.listDependingValues", dependentFields);
        }catch(e){
            console.log('err',e);
        }
        
    },
      finishAllFilesUploadforQAguidelines : function(parentId,fileNameList,base64DataList,contentTypeList,component, event, helper) {
        try{
            console.log('finishAllFilesUploadforQAguidelines parentId~>'+JSON.stringify(parentId));
            console.log('finishAllFilesUploadforQAguidelines fileNameList~>'+fileNameList.length);
            console.log('finishAllFilesUploadforQAguidelines base64DataList~>'+base64DataList.length);
            console.log('finishAllFilesUploadforQAguidelines contentTypeList~>'+contentTypeList.length);
            var action = component.get("c.uploadMultipleFilesforQAguideline");
            
            if(parentId.hasOwnProperty('Attachments')){
                delete parentId.Attachments;
            }
            console.log('finishAllFilesUploadforQAguidelines parentId final~>'+JSON.stringify(parentId));
            
            action.setParams({
                parent: JSON.stringify(parentId),
                fileName: fileNameList,
                base64Data: base64DataList,
                contentType: contentTypeList,
            });
            
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log("finishAllFilesUploadforQAguidelines resp: ", JSON.stringify(response.getReturnValue()));
                  	component.tabQA();
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
                else{ 
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    var errors = response.getError();
                    console.log("server error in finishAllFilesUploadforQAguidelines : ", JSON.stringify(errors));
                    component.set("v.exceptionError", errors[0].message);
                }
            });
            $A.enqueueAction(action);
            
            setTimeout($A.getCallback(function () {
                console.log('setTimeout'); 
            }), 1000);   //dont remove setTimeout - for loading issue fix for upload files - Arshad
        }catch(e){
            console.log('finishAllFilesUpload err',e);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
    },
calculatePagination: function(cmp, mrp) {
    console.log('calculatePagination called for MRP:', mrp.MRP ? mrp.MRP.Id : 'unknown');
    
    // Set default page size if not present
    if (!mrp.pageSize) {
        mrp.pageSize = 50;
    }
    
    var pageSize = mrp.pageSize;
    var solis = mrp.SOLIs || [];
    
    console.log('Total SOLIs:', solis.length, 'Page Size:', pageSize);
    
    // Calculate total pages
    mrp.totalPages = Math.ceil(solis.length / pageSize);
    if (mrp.totalPages < 1) {
        mrp.totalPages = 1;
    }
    
    // Set current page to 1 if not set
    if (!mrp.currentPage) {
        mrp.currentPage = 1;
    }
    
    // Validate current page is within bounds
    if (mrp.currentPage < 1) {
        mrp.currentPage = 1;
    }
    if (mrp.currentPage > mrp.totalPages && mrp.totalPages > 0) {
        mrp.currentPage = mrp.totalPages;
    }
    
    console.log('Current Page:', mrp.currentPage, 'Total Pages:', mrp.totalPages);
    
    // Calculate start and end index for current page
    var startIndex = (mrp.currentPage - 1) * pageSize;
    var endIndex = Math.min(startIndex + pageSize, solis.length);
    
    // Create paged SOLIs array
    mrp.pagedSOLIs = [];
    if (solis.length > 0 && startIndex < solis.length) {
        for (var i = startIndex; i < endIndex; i++) {
            mrp.pagedSOLIs.push(solis[i]);
        }
    }
    
    console.log('Paged SOLIs:', mrp.pagedSOLIs.length, 'Start:', startIndex, 'End:', endIndex);
    
    // Calculate display pages (page numbers to show)
    var maxPagesToShow = 40;
    var halfPages = Math.floor(maxPagesToShow / 2);
    var startPage = Math.max(1, mrp.currentPage - halfPages);
    var endPage = Math.min(mrp.totalPages, startPage + maxPagesToShow - 1);
    
    // Adjust startPage if we're near the end
    if (endPage - startPage < maxPagesToShow - 1) {
        startPage = Math.max(1, endPage - maxPagesToShow + 1);
    }
    
    // Build displayPages array
    mrp.displayPages = [];
    for (var pageNum = startPage; pageNum <= endPage; pageNum++) {
        mrp.displayPages.push(pageNum);
    }
    
    console.log('Display Pages:', mrp.displayPages.length, 'From:', startPage, 'To:', endPage);
    
    // Set page info text
    if (solis.length === 0) {
        mrp.pageInfo = 'No records found';
    } else {
        var displayStart = startIndex + 1;
        var displayEnd = endIndex;
        mrp.pageInfo = 'Showing ' + displayStart + ' to ' + displayEnd + ' of ' + solis.length + ' records';
    }
    
    console.log('Page Info:', mrp.pageInfo);
    console.log('calculatePagination completed');
    
    return mrp;
}
    /*calculatePagination: function(cmp, mrp) {
    var pageSize = mrp.pageSize || 50;
    var solis = mrp.SOLIs || [];
    
    mrp.totalPages = Math.ceil(solis.length / pageSize);
    mrp.currentPage = mrp.currentPage || 1;
    
    if (mrp.currentPage < 1) mrp.currentPage = 1;
    if (mrp.currentPage > mrp.totalPages && mrp.totalPages > 0) {
        mrp.currentPage = mrp.totalPages;
    }
    
    var startIndex = (mrp.currentPage - 1) * pageSize;
    var endIndex = Math.min(startIndex + pageSize, solis.length);
    
    mrp.pagedSOLIs = [];
    if (startIndex < solis.length) {
        for (var i = startIndex; i < endIndex; i++) {
            mrp.pagedSOLIs.push(solis[i]);
        }
    }
    
    var maxPagesToShow = 40;
    var startPage = Math.max(1, mrp.currentPage - Math.floor(maxPagesToShow / 2));
    var endPage = Math.min(mrp.totalPages, startPage + maxPagesToShow - 1);
    
    mrp.displayPages = [];
    for (var pageNum = startPage; pageNum <= endPage; pageNum++) {
        mrp.displayPages.push(pageNum);
    }
    
    var start = startIndex + 1;
    var end = endIndex;
    mrp.pageInfo = 'Showing ' + start + ' to ' + end + ' of ' + solis.length + ' records';
    
    return mrp;
}*/
    
})