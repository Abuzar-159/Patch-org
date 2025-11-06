({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        console.log('prodRecordId 1st line: ',component.get('v.prodRecordId'));
        if(component.get('v.prodRecordId') != null && component.get('v.prodRecordId') != '' && component.get('v.prodRecordId') != undefined){
            helper.getProductDetails(component,helper);
            component.set('v.showPOType',false);
            component.set('v.Mtask',false);
        }
        
        component.set("v.CostCardFilter"," AND ERP7__Supplier__c != null AND ERP7__Product__c != null AND ERP7__Cost__c >= 0 AND ERP7__Active__c = true AND ERP7__Quantity__c >= 0 And ERP7__Minimum_Quantity__c >= 0 And ERP7__Start_Date__c <= TODAY And ERP7__End_Date__c >= TODAY ");
        if(component.get('v.showPOType')) helper.getRecTypePO(component);
        
        console.log('create PO init called:',component.get('v.showPOType'));
        
        helper.fetchcurrency(component, event, helper);
        
        console.log('prSelectedOrder : ',component.get('v.prSelectedOrder'));
        if(component.get('v.salesOrder')) {
            if(component.get('v.prSelectedOrder') != null && component.get('v.prSelectedOrder') != '' && component.get('v.prSelectedOrder') != undefined) component.set('v.PO.ERP7__Sales_Order__c',component.get('v.prSelectedOrder'));
        }
        else if(component.get('v.prSelectedOrder') != null && component.get('v.prSelectedOrder') != '' && component.get('v.prSelectedOrder') != undefined) component.set('v.PO.ERP7__Order__c',component.get('v.prSelectedOrder'));
        
        //helper.getOrgDefault(component,event,helper);
        /*var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        //var iddd=context.attributes.recordId;
        component.set("v.recordId1", context.attributes.recordId);*/
        //alert('recordId :',iddd);
        /*var ref = component.get("v.pageReference");
        var state = ref.state; 
        var context = state.inContextOfRef;
        if (context.startsWith("1\.")) {
            context = context.substring(2);
            var addressableContext = JSON.parse(window.atob(context));
            alert('addressableContext----->'+JSON.stringify(addressableContext));
        }*/
        
        helper.getDependentPicklists(component, event, helper);
        helper.contactRT(component, event);
        helper.fetchEmployeeRequester(component, event);
        // helper.fetchShipmentType(component, event);
        console.log('ShipmentId : '+component.get("v.ShipmentId"));
        if((component.get("v.ShipmentId") != null && component.get("v.ShipmentId") != undefined && component.get("v.ShipmentId") != "") || (component.get("v.PackIds") != "" && component.get("v.PackIds").length > 0)){
            helper.getPLIfromshipment(component, event);
        }
        if(component.get("v.ProjId") != null && component.get("v.ProjId") != undefined && component.get("v.ProjId") != ""){
            component.set("v.PO.ERP7__Project__c", component.get("v.ProjId"));
        }
        
        
        console.log('doInit recordId~>',component.get('v.recordId'));
        console.log('doInit returnToVendor~>',component.get('v.returnToVendor'));
        console.log('doInit mrplineId~>',component.get('v.mrplineId'));
        console.log('doInit quantityMultiplier~>',component.get('v.quantityMultiplier'));
        console.log('doInit clonePOId : ',component.get("v.clonePOId"));
        if((component.get("v.recordId") != null && component.get("v.recordId") != undefined && component.get("v.recordId") != "") || (component.get("v.clonePOId") != null && component.get("v.clonePOId") != undefined && component.get("v.clonePOId") != "")){
            //helper.setPOandPOLIs(component, event);
            //var isMulticurrency = component.get('v.isMultiCurrency');
            component.set("v.showPOType",false);
            console.log('Inside getAttachedfiles');
            helper.getAttchedFiles(component,event,helper);
            
            if(component.get("v.returnToVendor")){
                component.set("v.purchaseOrderId", component.get("v.recordId"));
            }
            if(component.get("v.returnToVendor")){
                component.set("v.recordId", component.get("v.purchaseOrderId"));
            }
            
            console.log('calling setPOandPOLIs from doInit');
            helper.setPOandPOLIs(component, event, helper);
            
            console.log('calling fetchDetails from doInit');
            helper.fetchDetails(component,event,helper);
        }
        else{
            console.log('RFP flow');
            if(component.get("v.RFPsupplier") != null && component.get("v.RFPsupplier") != undefined && component.get("v.RFPsupplier") != '' && component.get("v.RFPrequest") != null && component.get("v.RFPrequest") != undefined && component.get("v.RFPrequest") != ''){
                console.log('RFP flow inhere');
                if(component.get("v.RFPsupplier.ERP7__Supplier__c") != null && component.get("v.RFPsupplier.ERP7__Supplier__c") != undefined && component.get("v.RFPsupplier.ERP7__Supplier__c") != ''){
                    component.set("v.PO.ERP7__Vendor__c", component.get("v.RFPsupplier.ERP7__Supplier__c"));
                    component.set("v.PO.ERP7__Vendor__r.Id", component.get("v.RFPsupplier.ERP7__Supplier__c"));
                    if(component.get("v.RFPsupplier.ERP7__Supplier__r.Name") != null && component.get("v.RFPsupplier.ERP7__Supplier__r.Name") != undefined && component.get("v.RFPsupplier.ERP7__Supplier__r.Name") != '') component.set("v.PO.ERP7__Vendor__r.Name", component.get("v.RFPsupplier.ERP7__Supplier__r.Name"));
                } 
                if(component.get("v.RFPrequest.ERP7__Organisation__c") != null && component.get("v.RFPrequest.ERP7__Organisation__c") != undefined && component.get("v.RFPrequest.ERP7__Organisation__c") != ''){
                    component.set("v.PO.ERP7__Organisation__c", component.get("v.RFPrequest.ERP7__Organisation__c"));
                    component.set("v.PO.ERP7__Organisation__r.Id", component.get("v.RFPrequest.ERP7__Organisation__c"));
                    if(component.get("v.RFPrequest.ERP7__Organisation__r.Name") != null && component.get("v.RFPrequest.ERP7__Organisation__r.Name") != undefined && component.get("v.RFPrequest.ERP7__Organisation__r.Name") != '') component.set("v.PO.ERP7__Organisation__r.Name", component.get("v.RFPrequest.ERP7__Organisation__r.Name"));
                } 
                if(component.get("v.RFPrequest.Id") != null && component.get("v.RFPrequest.Id") != undefined && component.get("v.RFPrequest.Id") != '') component.set("v.PO.ERP7__Request__c", component.get("v.RFPrequest.Id"));
                if(component.get("v.RFPrequest.ERP7__Channel__c") != null && component.get("v.RFPrequest.ERP7__Channel__c") != undefined && component.get("v.RFPrequest.ERP7__Channel__c") != '') component.set("v.channelId", component.get("v.RFPrequest.ERP7__Channel__c"));
                if(component.get("v.RFPrequest.ERP7__Distribution_Channel__c") != null && component.get("v.RFPrequest.ERP7__Distribution_Channel__c") != undefined && component.get("v.RFPrequest.ERP7__Distribution_Channel__c") != '') component.set("v.dChannelId", component.get("v.RFPrequest.ERP7__Distribution_Channel__c"));
                
                //var prod = component.get("v.RFPrequest.ERP7__Product__c");
                var poliList = [];
                if(component.get("v.poli") != null) poliList = component.get("v.poli");
                if(component.get("v.RFPrequest.ERP7__Product__c") != null && component.get("v.RFPrequest.ERP7__Product__c") != undefined && component.get("v.RFPrequest.ERP7__Product__c") != '') poliList.push({sObjectType :'ERP7__Purchase_Line_Items__c', ERP7__Product__c : component.get("v.RFPrequest.ERP7__Product__c")});
                
                component.set("v.poli",poliList);
                helper.fetchOrgCurrncy(component,event,helper); //added by asra 7/3/24 for org curr wen coming through RFP
            }
            
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//1
            
            let poStatus = component.get("c.getStatus");
            poStatus.setCallback(this,function(response){
                let resList = response.getReturnValue();
                component.set("v.POStatusoptions",resList);                
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//2   
                component.set("v.showSpinner",false);//uncomment         
            });
            $A.enqueueAction(poStatus);
            let poPackageType = component.get("c.getPackageType");
            poPackageType.setCallback(this,function(response){
                let resList = response.getReturnValue();
                component.set("v.POTypeoptions",resList);                
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//2   
                component.set("v.showSpinner",false);//uncomment         
            });
            $A.enqueueAction(poPackageType);
            //Moin added below code to navigate from Accounts Payable on create po from vendor section to prepoulate the vendor on 10th january 2024
            if(component.get('v.vId') !=undefined && component.get('v.vId') !=null && component.get('v.vId') != ''){
                component.set('v.PO.ERP7__Vendor__c',component.get("v.vId"));
            }
            var defVendor = component.get("v.PO.ERP7__Vendor__c");
            if(defVendor == undefined || defVendor == '' || defVendor == null){
                var poliList = component.get("v.poli");
                var myproIds = [];
                var totalAmount = 0;
                if(poliList != undefined && poliList.length > 0){
                    for(let y=0;y<poliList.length;y++){
                        if(poliList[y].ERP7__Product__c != undefined){
                            //alert(poliList[y].ERP7__Product__c);
                            totalAmount = totalAmount + poliList[y].ERP7__Unit_Price__c * poliList[y].ERP7__Quantity__c;
                            myproIds.push(poliList[y].ERP7__Product__c);
                        }
                    }
                }
                console.log('inside doinit');
                component.set("v.SubTotal",totalAmount);
                component.set("v.TotalAmount",totalAmount);
                component.set("v.PO.ERP7__Total_Amount__c",totalAmount);
                
                if(myproIds.length > 0){
                    //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//3
                    component.set("v.showSpinner",true);
                    var action = component.get("c.getDefaultVendor");
                    action.setParams({ 
                        SelectedSite: component.get("v.distributionChannel.Id"),
                        ProIds: myproIds
                    });
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            if(response.getReturnValue().Id != undefined && response.getReturnValue().Id != null) component.set("v.PO.ERP7__Vendor__r",response.getReturnValue());
                            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//4
                            component.set("v.showSpinner",false);//uncomment
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
            
            if(!$A.util.isUndefined(component.get("v.rmaliID")) && !$A.util.isEmpty(component.get("v.rmaliID")))
                helper.RMADOInit(component, event, helper);
            if(!$A.util.isUndefined(component.get("v.soliID")) && !$A.util.isEmpty(component.get("v.soliID")))
                helper.SOLIDOInit(component, event, helper);
            if(!$A.util.isUndefined(component.get("v.mpslineId")) && !$A.util.isEmpty(component.get("v.mpslineId")))
                helper.mpslineInit(component, event, helper); 
            
            if(!$A.util.isUndefined(component.get("v.mrplineId")) && !$A.util.isEmpty(component.get("v.mrplineId")))
                helper.mrplineInit(component, event, helper);
            
            if(!$A.util.isUndefined(component.get("v.MOId")) && !$A.util.isEmpty(component.get("v.MOId")))
                helper.MOInit(component, event, helper);
            console.log("The start");
            var billPayload = component.get("v.billPayload");
            // this code added by saqlain khan For OCR funtionality
            if(!$A.util.isUndefined(component.get("v.billPayload")) && !$A.util.isEmpty(component.get("v.billPayload"))) {
                  console.log("Received Bill Data from Bill screen OCR ==========> ", JSON.stringify(billPayload));
                  helper.handleBillPayload(component, component.get("v.billPayload"));
              }
            
            console.log("The end ");
            
            if(!$A.util.isUndefined(component.get("v.SOId")) && !$A.util.isEmpty(component.get("v.SOId")))
                helper.SOInit(component, event, helper);
            if(!$A.util.isUndefined(component.get("v.WOId")) && !$A.util.isEmpty(component.get("v.WOId")))
                helper.WOInit(component, event, helper);
            if(!$A.util.isUndefined(component.get("v.orderId")) && !$A.util.isEmpty(component.get("v.orderId")))
                helper.OrdItmDOInit(component, event, helper);
            component.set("v.PO.ERP7__Order__c",component.get("v.orderId"));
            if(!$A.util.isUndefined(component.get("v.SelectedcustomerOrders")) && !$A.util.isEmpty(component.get("v.SelectedcustomerOrders")) && component.get("v.SelectedcustomerOrders")!=''){
                helper.OrdItmsDOInit(component, event, helper);
            }
            
            
        }
        
        component.set('v.PO.ERP7__Status__c','New');
        if(component.get("v.QueryRecentRecord")){
            helper.queryRecentRecord(component, event);
        }
        
        let poFC = component.get("c.getPOFC");
        poFC.setCallback(this,function(response){
            console.log('state getPOFC~>',response.getReturnValue());
            component.set("v.showTaxRate",response.getReturnValue().TaxRate);
            component.set("v.showpackageType",response.getReturnValue().packageType);
            component.set("v.showTaxName",response.getReturnValue().TaxAccess);
            component.set("v.showAllocations", response.getReturnValue().AllocationAccess);
            component.set("v.venAddressRequired", response.getReturnValue().VendorAddRequired);
            component.set("v.venConRequired", response.getReturnValue().VendorContactRequired);
            component.set("v.versionAccess",response.getReturnValue().versionAccess);
            component.set("v.showVenName",response.getReturnValue().displayVPO);
            component.set("v.QuoteAccess", response.getReturnValue().QuoteAccess);
            component.set("v.ProjectAccess", response.getReturnValue().ProjectOnPOScreen);
            component.set("v.DepartmentAccess", response.getReturnValue().DepartmentOnPOScreen);
            component.set("v.showfileUpload", response.getReturnValue().showUpload);
            component.set("v.POLINameAcc", response.getReturnValue().POLINameAcc);
            component.set("v.allowCustomProd", response.getReturnValue().allowCustomProds);
            
            if(response.getReturnValue().skipTypeSelection){
                component.set("v.showPOType",false);
                let selectedRecType = component.get('v.POType');
                
                //Parveez commented this on 27th september 2023
                /*for(var x in selectedRecType){
                    component.set("v.selectedRecType",selectedRecType[0].label);
                    component.set("v.PO.RecordTypeId",selectedRecType[0].value);
                }*/
                
                for(var x = 0; x < selectedRecType.length; x++){
                    component.set("v.selectedRecType",selectedRecType[0].label);
                    component.set("v.PO.RecordTypeId",selectedRecType[0].value);
                }
            }
            
        });
        $A.enqueueAction(poFC);
        
        /* let prodFamily = component.get("c.getFamily");
        prodFamily.setCallback(this,function(response){
            console.log('getFamily response : ',response.getReturnValue());
            let resList = response.getReturnValue();
            component.set("v.familylst",resList);                
            $A.util.addClass(component.find('mainSpin'), "slds-hide");            
        });
        $A.enqueueAction(prodFamily); 
        
        let prodSubFamily = component.get("c.getSubFamily");
        prodSubFamily.setCallback(this,function(response){
            console.log('subfamilylst response : ',response.getReturnValue());
            let resList = response.getReturnValue();
            component.set("v.subfamilylst",resList);                
            $A.util.addClass(component.find('mainSpin'), "slds-hide");            
        });
        $A.enqueueAction(prodSubFamily); */
        
    },
    
    updatepocurrency : function(component, event, helper){
        console.log('updatepocurrency called v.POCurrencyIsoCode~>'+component.get("v.POCurrencyIsoCode"));
        component.set("v.PO.CurrencyIsoCode",component.get("v.POCurrencyIsoCode"));
        console.log('v.PO.CurrencyIsoCode after setting here1~>'+component.get("v.PO.CurrencyIsoCode"));
    },
    
    fetchDetailsonPO : function(component, event, helper){
        console.log('fetchDetailsonPO called');
        if(component.get("v.purchaseOrderId")!='' && component.get("v.purchaseOrderId")!=null && component.get("v.purchaseOrderId")!=undefined){
            component.set("v.recordId", component.get("v.purchaseOrderId"));
            
            helper.getAttchedFiles(component,event,helper);
            
            console.log('calling setPOandPOLIs from fetchDetailsonPO');
            helper.setPOandPOLIs(component, event, helper);
            
            console.log('calling fetchDetails from fetchDetailsonPO');
            helper.fetchDetails(component,event,helper);
        }else{
            component.set("v.PO.PO_Purchase_Order_Number", '');
            component.set("v.PO.ERP7__Vendor__c", '');
            component.set("v.PO.ERP7__Vendor_Contact__c", '');
            component.set("v.PO.ERP7__Vendor_Address__c", '');
            component.set("v.PO.ERP7__Total_Amount__c", 0.00);
            component.set("v.SubTotal", 0.00);
            component.set("v.TotalTax", 0.00);
            component.set("v.TotalAmount", 0.00);
            
            component.set("v.poli", []);
            //component.set("v.recordId", null);
        }
        
    },
    
    //Added by Arshad
    getOrderItemsforDropShip : function(component, event, helper){
        if(component.get("v.recordId") == null || component.get("v.recordId") == undefined || component.get("v.recordId") == ""){ 
            if(component.get("v.selectedRecType") == component.get("v.DropShipPOrecType")){
                console.log('getOrderItemsforDropShip called');
                var orderId = '';
                var vendorId = '';
                var vendorAddress= '';
                if(component.get("v.PO.ERP7__Order__c") != undefined && component.get("v.PO.ERP7__Order__c") != null && component.get("v.PO.ERP7__Order__c") != ""){
                    
                    orderId = component.get("v.PO.ERP7__Order__c");
                    if(component.get("v.PO.ERP7__Vendor__c") != undefined && component.get("v.PO.ERP7__Vendor__c") != null) vendorId = component.get("v.PO.ERP7__Vendor__c");
                    if(component.get("v.PO.ERP7__Vendor_Address__c") != undefined && component.get("v.PO.ERP7__Vendor_Address__c") != null) vendorAddress = component.get("v.PO.ERP7__Vendor_Address__c");
                    var action = component.get("c.getOrderItemsforPOLIDropShip");
                    action.setParams({
                        "orderId": orderId,
                        "vendId" : vendorId,
                        "venAdd" : vendorAddress
                        
                    });
                    action.setCallback(this, function(response){
                        if(response.getState() === "SUCCESS"){
                            console.log('res of getOrderItemsforDropShip:~>',response.getReturnValue());
                            var pli = response.getReturnValue().wPOLIs;
                            if(pli == undefined){
                                helper.showToast('warning','warning','No products available based on selected order/vendor');
                                component.set('v.poli',[]);
                            }
                            else{
                                var stocklst = response.getReturnValue().productStocks;
                                var totalAmount = 0.0;
                                var tax = 0.0;
                                var subtotal = 0.0;
                                var totalTax = 0.0;
                                
                                //Parveez Commented this on 27th September 2023
                                /*for(var x in pli){
                                    for(var y in stocklst){
                                        if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                            pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                            pli[x].demand = stocklst[y].Demand;
                                            pli[x].ItemsinStock = stocklst[y].Stock;
                                        }
                                    }
                                }
                                
                                for(var x in pli){
                                    var tax = 0;
                                    pli[x].ERP7__Tax__c = tax = parseFloat(parseFloat(pli[x].ERP7__Unit_Price__c/100) * parseFloat(pli[x].ERP7__Tax_Rate__c) * pli[x].ERP7__Quantity__c);     
                                    pli[x].ERP7__Total_Price__c = (parseFloat(pli[x].ERP7__Quantity__c) * parseFloat(pli[x].ERP7__Unit_Price__c)) + parseFloat(tax);
                                    
                                    subtotal = subtotal + (parseFloat(pli[x].ERP7__Quantity__c) * parseFloat(pli[x].ERP7__Unit_Price__c));
                                    totalAmount = totalAmount + (parseFloat(pli[x].ERP7__Quantity__c) * parseFloat(pli[x].ERP7__Unit_Price__c)) + parseFloat(pli[x].ERP7__Tax__c);
                                    tax = (pli[x].ERP7__Unit_Price__c/100)*pli[x].ERP7__Tax_Rate__c;
                                    tax = (tax) * pli[x].ERP7__Quantity__c;
                                    totalTax = totalTax + tax;
                                }*/
                                
                                //Parveez Added this on 27th September 2023
                                for(var x = 0; x < pli.length; x++){
                                    for(var y = 0; y < stocklst.length; y++){
                                        if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                            pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                            pli[x].demand = stocklst[y].Demand;
                                            pli[x].ItemsinStock = stocklst[y].Stock;
                                        }
                                    }
                                }
                                
                                for(var x = 0; x < pli.length; x++){
                                    var tax = 0;
                                    pli[x].ERP7__Tax__c = tax = parseFloat(parseFloat(pli[x].ERP7__Unit_Price__c/100) * parseFloat(pli[x].ERP7__Tax_Rate__c) * pli[x].ERP7__Quantity__c);     
                                    pli[x].ERP7__Total_Price__c = (parseFloat(pli[x].ERP7__Quantity__c) * parseFloat(pli[x].ERP7__Unit_Price__c)) + parseFloat(tax);
                                    
                                    subtotal = subtotal + (parseFloat(pli[x].ERP7__Quantity__c) * parseFloat(pli[x].ERP7__Unit_Price__c));
                                    totalAmount = totalAmount + (parseFloat(pli[x].ERP7__Quantity__c) * parseFloat(pli[x].ERP7__Unit_Price__c)) + parseFloat(pli[x].ERP7__Tax__c);
                                    tax = (pli[x].ERP7__Unit_Price__c/100)*pli[x].ERP7__Tax_Rate__c;
                                    tax = (tax) * pli[x].ERP7__Quantity__c;
                                    totalTax = totalTax + tax;
                                }
                                
                                component.set("v.poli",pli); 
                                component.set("v.TotalAmount",totalAmount);
                                component.set("v.PO.ERP7__Total_Amount__c",totalAmount);
                                component.set("v.SubTotal",subtotal);
                                component.set("v.TotalTax",totalTax);
                                component.set("v.dChannelId",null);
                            }
                            
                        }else{
                            var errors = response.getError();
                            console.log("server error in getOrderItemsforDropShip : ", JSON.stringify(errors));
                            component.set("v.exceptionError", errors[0].message);
                            setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
                        } 
                    });
                    $A.enqueueAction(action);
                    
                    if(orderId != ''){
                        var ordAddrAction = component.get("c.getOrderAddress");
                        ordAddrAction.setParams({
                            "orderId": orderId,
                        });
                        ordAddrAction.setCallback(this, function(response){
                            if(response.getState() === "SUCCESS"){
                                console.log('res of getOrderAddress:~>',response.getReturnValue());
                                if(response.getReturnValue() != null){
                                    if(response.getReturnValue().Id != null){
                                        if(response.getReturnValue().AccountId != undefined && response.getReturnValue().AccountId != null && response.getReturnValue().AccountId != '' && (component.get("v.PO.ERP7__Customer__c") == null || component.get("v.PO.ERP7__Customer__c") == '' || component.get("v.PO.ERP7__Customer__c") == undefined)){ 
                                            component.set("v.PO.ERP7__Customer__c",response.getReturnValue().AccountId);
                                        }
                                        if(response.getReturnValue().ERP7__Ship_To_Address__c != undefined && response.getReturnValue().ERP7__Ship_To_Address__c != null){
                                            if(response.getReturnValue().ERP7__Ship_To_Address__c != ''){
                                                component.set("v.PO.ERP7__Delivery_Address__c",response.getReturnValue().ERP7__Ship_To_Address__c);
                                                console.log('getOrderAddress ERP7__Delivery_Address__c set here~>',response.getReturnValue().ERP7__Ship_To_Address__c);
                                            }
                                        }
                                        
                                    }
                                }
                            }else{
                                var errors = response.getError();
                                console.log("server error in getOrderAddress : ", JSON.stringify(errors));
                                component.set("v.exceptionError", errors[0].message);
                                setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
                            } 
                        });
                        $A.enqueueAction(ordAddrAction);
                    }
                }
                else{
                    component.set("v.poli",[]); 
                }
            }
        }
    },
    
    //Changed by Arshad 02 Aug 23 proceedDefaultTaxRateChange
    checkforTaxRate : function(component, event, helper) {
        console.log('checkforTaxRate PO Details~>',JSON.stringify(component.get("v.PO")));
        console.log('checkforTaxRate proceedDefaultTaxRateChange ~>'+component.get("v.proceedDefaultTaxRateChange"));
        var proceedDefaultTaxRateChange = component.get("v.proceedDefaultTaxRateChange");
        
        console.log('checkforTaxRate inhere');
        if(component.get("v.PO.ERP7__Vendor_Address__c") != null && component.get("v.PO.ERP7__Vendor_Address__c") != undefined && component.get("v.PO.ERP7__Vendor_Address__c") != ""){
            console.log('checkforTaxRate inhere2:',component.get("v.PO.ERP7__Vendor_Address__c"));
            //component.set("v.POTaxPercentage", 0);
            var action = component.get("c.checkforTax");
            action.setParams({
                "addId":component.get("v.PO.ERP7__Vendor_Address__c"),
                "AccId":component.get("v.PO.ERP7__Vendor__c")
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log('defaultTaxRate response.getReturnValue() : ',response.getReturnValue());
                    component.set("v.defaultTaxRate",response.getReturnValue());
                    console.log('checkforTaxRate proceedDefaultTaxRateChange var inside action~>'+proceedDefaultTaxRateChange);
                    if(component.get("v.defaultTaxRate") >= 0 && proceedDefaultTaxRateChange){
                        let poli = component.get("v.poli");
                        var totalAmount = 0.0;
                        var tax = 0.0;
                        var subtotal = 0.0;
                        var totalTax = 0.0;
                        
                        //for(var x in poli)
                        
                        for(var x = 0; x < poli.length; x++){
                            var totalPrice = 0;
                            poli[x].ERP7__Tax_Rate__c = component.get("v.defaultTaxRate");
                            if (poli[x].ERP7__Unit_Price__c >= 0 && poli[x].ERP7__Quantity__c >= 0) totalPrice = poli[x].ERP7__Unit_Price__c * poli[x].ERP7__Quantity__c;
                            subtotal = subtotal + totalPrice;
                            console.log('subtotal : ',subtotal);
                            var taxAmount = (poli[x].ERP7__Tax_Rate__c * totalPrice)/100;
                            poli[x].ERP7__Tax__c = taxAmount.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            totalTax = parseFloat(parseFloat(totalTax) + parseFloat(poli[x].ERP7__Tax__c)).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            console.log('totalTax : ',totalTax);
                            var totAmount = 0.00;
                            totAmount = parseFloat(totalPrice.toFixed($A.get("$Label.c.DecimalPlacestoFixed"))) + parseFloat(taxAmount.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
                            poli[x].ERP7__Total_Price__c = totAmount;
                            totalAmount = totalAmount + poli[x].ERP7__Total_Price__c;
                            console.log('totalAmount : ',totalAmount);
                        }
                        
                        console.log('checkforTaxRate inhere setting poli again');
                        component.set("v.poli",poli);
                        component.set("v.TotalAmount",totalAmount);
                        component.set("v.PO.ERP7__Total_Amount__c",totalAmount);
                        component.set("v.SubTotal",subtotal);
                        component.set("v.TotalTax",totalTax);
                    }
                    else{
                        console.log('checkforTaxRate not going to update poli');
                    }
                }else{
                    console.log('err~>',response.getError());
                }
            });
            $A.enqueueAction(action);
        }
        
        console.log('PO details 2: ',JSON.stringify(component.get("v.PO")));
        console.log('component.get("v.PO.ERP7__Vendor_Address__c") checkforTaxRate 3~> ',component.get("v.PO.ERP7__Vendor_Address__c"));
        
    },
    
    fetchPoli : function(component, event, helper) {
        console.log('fetchPoli called');
        if(component.get("v.returnToVendor")){
            component.set("v.recordId", component.get("v.purchaseOrderId"));
        }
        console.log('calling setPOandPOLIs from fetchPoli');
        helper.setPOandPOLIs(component, event, helper);
    },
    
    addCustomproductNew : function(component, event, helper) {
        var poliList = [];
        if(component.get("v.poli") != null) poliList = component.get("v.poli");
        poliList.push({sObjectType :'ERP7__Purchase_Line_Items__c',ItemsinStock : 0.0, demand: 0.0,AwaitingStock :0.0, Accounts : [], Category:'', AccAccount:'',CustomProd : true});
        component.set("v.poli",poliList);
        console.log('pli : '+JSON.stringify(component.get("v.poli")));
        // component.set("v.showAddProducts",true);
    },
    
    addNew : function(component, event, helper) {
        console.log('addNew called');
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//5
        component.set("v.showSpinner",true);
        component.set('v.listOfProducts',[]);
        component.set('v.selectedListOfProducts',[]);
        component.set('v.searchItem','');
        component.set('v.seachItemFmily','');
        component.set('v.addProductsMsg','');
        helper.getDependentPicklistsFamily(component, event, helper);
        var action = component.get("c.getProducts");
        action.setParams({
            "venId":component.get('v.PO.ERP7__Vendor__c'),
            "searchString": component.get('v.searchItem'),
            "searchFamily": component.get('v.seachItemFmily'),
            "DCId": component.get('v.dChannelId')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('response getProducts : ',response.getReturnValue());
                console.log('setting listOfProducts here1');
                component.set('v.listOfProducts',response.getReturnValue().wrapList);
                
                //Added by Arshad 03 Aug 2023
                try{
                    var standProds = component.get('v.listOfProducts');
                    
                    // for(var x in standProds)  Commented by Parveez on 27 Sept 2023
                    for(var x = 0; x < standProds.length; x++){
                        if(standProds[x].selCostCardId != undefined && standProds[x].selCostCardId != null && standProds[x].selCostCardId != ''){
                            console.log('in here1 standProds[x].selCostCardId~>'+standProds[x].selCostCardId);
                            var res = standProds[x].selectedCostCard;
                            console.log('standProds[x].selectedCostCard res~>',res);
                            
                            standProds[x].unitPrice  = parseFloat(res.ERP7__Cost__c);
                            standProds[x].VendorPartNumber = res.ERP7__Vendor_Part_Number__c;
                            if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                            
                            console.log('defaultTaxRate~>'+component.get("v.defaultTaxRate"));
                            if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(component.get("v.defaultTaxRate"));
                            
                            let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                            console.log('tax  bfr:  ',tax);
                            
                            tax = tax * standProds[x].quantity;
                            
                            standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            
                            if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                            console.log('unitPrice : ',standProds[x].unitPrice);
                            console.log('quantity : ',standProds[x].quantity);
                            console.log('taxAmount : ',standProds[x].taxAmount);
                            console.log('taxPercent : ',standProds[x].taxPercent);
                            
                            standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                            console.log('TotalPrice : ',standProds[x].TotalPrice);
                        }
                    }
                    console.log('setting listOfProducts here11');
                    component.set('v.listOfProducts',standProds);
                }catch(e){
                    console.log('err~>',e);
                }
                component.set('v.addProductsMsg',response.getReturnValue().Msg);
                component.set('v.globalProdSearch',response.getReturnValue().globalSearch);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//6
                component.set("v.showSpinner",false);
            }else{
                console.log('Error addNew:',response.getError());
                component.set("v.exceptionError",response.getError());
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//7
                component.set("v.showSpinner",false);
            }
            component.set("v.showAddProducts",true);
            component.set("v.showStandardProducts",true);
            component.set("v.toggleChecked",false);
        });
        $A.enqueueAction(action);
        
        /* var poliList = [];
        if(component.get("v.poli") != null) poliList = component.get("v.poli");
        poliList.unshift({sObjectType :'ERP7__Purchase_Line_Items__c',ItemsinStock : 0.0, demand: 0.0,AwaitingStock :0.0, Accounts : [], Category:'', AccAccount:''});
        component.set("v.poli",poliList);
        console.log('pli : '+JSON.stringify(component.get("v.poli")));*/
    },
    
    deletePoli :function(component, event, helper) {
        console.log('inside deletePoli fromRequisition: ',component.get('v.fromRequisition'));
        if(!component.get('v.fromRequisition')){
            component.set("v.reRenderPOLIS",false);
            console.log('inside deletePoli');
            var poliList =[]; 
            poliList=component.get("v.poli");
            console.log('poliList before~>',JSON.stringify(poliList));
            var index=event.getParam("Index"); //component.get("v.Index2del");
            poliList.splice(index,1);        
            console.log('poliList after~>',JSON.stringify(poliList));
            //component.set("v.poli",poliList);
            console.log('v.poli after~>',JSON.stringify(component.get("v.poli")));
            component.set("v.reRenderPOLIS",true);
            
            var items=component.get('v.poli');
            var amt=0;
            /* for(var x in items){
            console.log('inside loop');
            amt+=items[x].ERP7__Quantity__c * items[x].ERP7__Unit_Price__c 
        }
        console.log('amt:',amt);
        if(amt>=0) component.set("v.PO.ERP7__Total_Amount__c",amt.toFixed(2));
        if(amt == 0){
            component.set("v.SubTotal",amt.toFixed(2));
            component.set("v.TotalTax",amt.toFixed(2));
            component.set("v.TotalAmount",amt.toFixed(2));
        }*/
            
            var itemToDel=component.get('v.itemToDel');
            itemToDel.push(event.getParam("itemToDelCurr"));
            console.log('itemToDelCurr in PO:',event.getParam("itemToDelCurr"));
            component.set('v.itemToDel',itemToDel);
            console.log('itemToDel:',component.get('v.itemToDel'));
            
            //$A.enqueueAction(updateTotalPrice.(component, event, helper));
            //component.set('v.itemToDel',event.getParam("itemToDel"));  
        }
        var a = component.get('c.updateTotalPrice');
        $A.enqueueAction(a);
        var taxtotal = component.get('c.updateTotalTax');
        $A.enqueueAction(taxtotal);
        
    },
    
    validateField : function(component, event, helper){
        var poName = component.find("poName");
        if(!$A.util.isUndefined(poName)) 
            helper.checkValidationField(poName);
    },
    
    savePO : function(component, event, helper){
        try{
            console.log('savePO called');
            //var button = event.getSource();
            //button.set('v.disabled',true);
            var filesDataToUpload = component.get("v.filesData2Upload");
            var totalRequestSize = 0; // To track total size for the request
            if(component.get("v.PO.ERP7__Package_Type__c")=='--None--'){
                component.set("v.PO.ERP7__Package_Type__c", '');
            }
            for (var i = 0; i < filesDataToUpload.length; i++) {
                var fileSize = filesDataToUpload[i].base64Data.length;
                console.log('fileSize : ',fileSize);
                // Check individual file size (max 5 MB)
                if (fileSize > 2000000) { // 2 MB limit
                    console.log('inhereeee');
                    alert(" Error : File " + filesDataToUpload[i].fileName + " exceeds the 2 MB limit.");
                    //helper.showToast('Error', 'error', 'File ' + filesDataToUpload[i].fileName + ' exceeds the 2 MB limit.'); commented by bushra 16/06/25
                    return;
                }

                // Check total request size (max 3 MB)
                totalRequestSize += fileSize;
                console.log('totalRequestSize : ',totalRequestSize);
                if (totalRequestSize > 3000000) { // 3 MB total request size limit
                    alert(" Error :Total request size exceeds the 3 MB limit. Please upload fewer or smaller files.");
                    //helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                    return;
                }
            }

            
            var itemToDel=component.get('v.itemToDel');
            if(itemToDel.length > 0){
                if(!component.get("v.returnToVendor")) helper.deletePOLI1(component, event,itemToDel);            
            }
            
            component.set("v.exceptionError",'');
            component.set("v.qmsg",'');
            var poLIst = component.get("v.poli");
            
            
            if(component.get("v.Mtask") != null && component.get("v.Mtask") != undefined && component.get("v.Mtask") != ""){
                var task = component.get("v.Mtask");
                component.set("v.PO.ERP7__Tasks__c", task.Id);
                component.set("v.PO.ERP7__Project__c", task.ERP7__Project__c);
            }
            
            component.set("v.PO.ERP7__Channel__c",component.get("v.channelId"));
            component.set("v.PO.ERP7__Distribution_Channel__c",component.get("v.dChannelId"));
            
            if(component.get("v.PO.ERP7__Shipment_Type__c") == null || component.get("v.PO.ERP7__Shipment_Type__c") == undefined || component.get("v.PO.ERP7__Shipment_Type__c") == ''){
                component.set("v.PO.ERP7__Shipment_Preference_Speed__c",'');
            }
            
            //component.set("v.PO.ERP7__Order_Date__c", system.today());
            console.log('ERP7__Shipment_Preference_Speed__c set here~>'+component.get("v.PO.ERP7__Shipment_Preference_Speed__c"));
            
            //var errorDisplay = helper.validationCheckName(component, event); 
            if(component.get("v.PO.ERP7__EmployeeRequester__c")==null || component.get("v.PO.ERP7__EmployeeRequester__c")=='' || component.get("v.PO.ERP7__EmployeeRequester__c") == undefined){
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PO_Please_select_the_Employee_Requester'));
            }
            else if(component.get("v.PO.ERP7__Vendor__c") == component.get("v.PO.ERP7__Organisation__c")){
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PO_The_organisation_and_the_vendor_cannot_be_the_same'));
            }
                else{
                    var flag = helper.validationCheck(component,event);
                    var flagCon = true; //helper.validationVendorCon(component,event);
                    //if(component.get("v.venAddressRequired"))flagCon = helper.validationVendorAdd(component,event);
                    var flagOrg = helper.validationCheckOrg(component, event);
                    var isErrors = helper.validationCheckQuantity(component, event, helper);
                    var isErrorsUP = helper.validationCheckUnitPrice(component, event, helper);
                    var isErrorsAA = helper.AnalyticalAccountCheck(component, event, helper); 
                    var isErrorsAACOA = helper.AnalyticalAccountCoaCheck(component, event, helper); 
                    var returnPOflag = (component.get("v.returnToVendor")) ? helper.validationRTVPOqtyCheck(component, event, helper) : false; 
                }
            var isDCSelected = false;
            var isCustomerSelected = false;
            var isOrderSelected = true;
            var analyticalAccAdded = true;
            if(component.get("v.selectedRecType") != component.get("v.DropShipPOrecType") && component.get("v.dChannelId") !=null && component.get("v.dChannelId") !='' && component.get("v.dChannelId") != undefined){
                isDCSelected = true;
            }
            if(component.get("v.selectedRecType") == component.get("v.DropShipPOrecType") && component.get("v.PO.ERP7__Customer__c") !=null && component.get("v.PO.ERP7__Customer__c") !='' && component.get("v.PO.ERP7__Customer__c") != undefined){
                isCustomerSelected = true;
            }
            if(component.get("v.selectedRecType") == component.get("v.DropShipPOrecType") && component.get("v.isSalesOrder") && component.get("v.PO.ERP7__Order__c") !=null && component.get("v.PO.ERP7__Order__c") !='' && component.get("v.PO.ERP7__Order__c") != undefined){
                isOrderSelected = true;
            }
            
            var isVenderSelected = false;
            if(component.get("v.PO.ERP7__Vendor__c") !=null && component.get("v.PO.ERP7__Vendor__c") !='' && component.get("v.PO.ERP7__Vendor__c") != undefined){
                isVenderSelected = true;
            }
            if(component.get("v.venAddressRequired") && (component.get("v.PO.ERP7__Vendor_Address__c") ==null || component.get("v.PO.ERP7__Vendor_Address__c") =='' || component.get("v.PO.ERP7__Vendor_Address__c") == undefined)){
                isVenderSelected = false
            }
            if(component.get("v.venConRequired") && component.get("v.PO.ERP7__Vendor_Contact__c") == null || component.get("v.PO.ERP7__Vendor_Contact__c") == '' && component.get("v.PO.ERP7__Vendor_Contact__c") == undefined){
                isVenderSelected = false;
            }
            console.log('isVenderSelected : ',isVenderSelected);
            if(component.get("v.showAllocations")){
                analyticalAccAdded = helper.AnalyticalAccountingAccountCheck(component, event, helper);
            }
            helper.AnalyticalAccountCheck(component, event, helper);
            /*console.log('isCustomerSelected-->'+isCustomerSelected);
            console.log('isOrderSelected-->'+isOrderSelected);
            console.log('selectedRecType-->'+component.get("v.selectedRecType"));
            console.log('DropShipPOrecType-->'+component.get("v.DropShipPOrecType"));
            console.log('isSalesOrder-->'+component.get("v.isSalesOrder"));
            console.log('isVenderSelected-->'+isVenderSelected);
            console.log('flag'+flag);
            console.log('flagCon-->'+flagCon);
            console.log('flagOrg-->'+flagOrg);
            console.log('!returnPOflag-->'+!returnPOflag);
            console.log('!isErrors-->'+!isErrors);
            console.log('!isErrorsUP-->'+!isErrorsUP);
            console.log('analyticalAccAdded-->'+analyticalAccAdded);
            console.log('!isErrorsAA-->'+!isErrorsAA);
            console.log('!isErrorsAACOA-->'+!isErrorsAACOA);*/
            if((isCustomerSelected || isDCSelected) && ((isOrderSelected && component.get("v.selectedRecType") == component.get("v.DropShipPOrecType") && component.get("v.isSalesOrder")) || component.get("v.selectedRecType") != component.get("v.DropShipPOrecType")) && isVenderSelected && flag && flagCon && flagOrg && !returnPOflag && !isErrors && !isErrorsUP && analyticalAccAdded && !isErrorsAA &&!isErrorsAACOA && (component.get("v.PO.ERP7__EmployeeRequester__c") != null && component.get("v.PO.ERP7__EmployeeRequester__c") != '')){
                //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//8
                component.set("v.showSpinner",true);
                if(component.get("v.selectedRecType") == component.get("v.DropShipPOrecType")) component.set("v.PO.ERP7__Distribution_Channel__c",null);
                if(poLIst.length>0){
                    //Moin commented
                    //if(poLIst[0].CurrencyIsoCode != undefined) component.set("v.PO.CurrencyIsoCode",poLIst[0].CurrencyIsoCode);
                    if(component.get("v.returnToVendor"))  component.set("v.PO.ERP7__Master_Purchase_Orders__c",component.get("v.purchaseOrderId"));
                    console.log('JSON.stringify(component.get(v.PO)) : ',JSON.stringify(component.get("v.PO")));
                    
                    console.log('poLIst 1 : ',JSON.stringify(poLIst));
                    
                    var acc = [];
                    
                    //for(var x in poLIst)
                    for(var x = 0; x < poLIst.length; x++){
                        if(poLIst[x].ERP7__Product__r != null && poLIst[x].ERP7__Product__r != undefined && poLIst[x].ERP7__Product__r != '') delete poLIst[x].ERP7__Product__r;
                        if(component.get("v.isMultiCurrency")) poLIst[x].CurrencyIsoCode = component.get("v.PO.CurrencyIsoCode");
                        if(poLIst[x].Accounts != undefined && poLIst[x].Accounts != null){
                            if(poLIst[x].Accounts.length > 0){
                                //for(var y in poLIst[x].Accounts){
                                for(var y = 0; y < poLIst[x].Accounts.length; y++){
                                    if(poLIst[x].Accounts[y].ERP7__Sort_Order__c != undefined && poLIst[x].Accounts[y].ERP7__Sort_Order__c != null){
                                        console.log('before poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+poLIst[x].Accounts[y].ERP7__Sort_Order__c);
                                        if(!component.get("v.returnToVendor")) poLIst[x].Accounts[y].ERP7__Sort_Order__c = parseInt(parseInt(x)+1);
                                        console.log('after poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+poLIst[x].Accounts[y].ERP7__Sort_Order__c);
                                    }
                                }
                                acc.push(poLIst[x].Accounts);
                            }
                        }
                    }
                    console.log('dimensionList : ',acc);
                    
                    component.set("v.dimensionList",acc);
                    //for(var x in poLIst){
                    for(var x = 0; x < poLIst.length; x++){
                        poLIst[x].Accounts = [];
                    }
                    
                    //for(var x in poLIst)
                    
                    for(var x = 0; x < poLIst.length; x++){
                        try{ console.log('before saving tax of '+x+' ~>'+poLIst[x].ERP7__Tax__c); }catch(e){}
                        if(poLIst[x].ERP7__Tax__c!=null) poLIst[x].ERP7__Total_Price__c = poLIst[x].ERP7__Total_Price__c - poLIst[x].ERP7__Tax__c;
                        //poLIst[x].Accounts = [];
                    }
                    
                    //Added by Arshad 04 Dec 23 to save po and save attachments together in same synchronous process
                    var filesData2Upload = component.get("v.filesData2Upload");
                    console.log('filesData2Upload~>',filesData2Upload);
                    
                    console.log('before saveAction');
                    var saveAction = component.get("c.save_PurchaseOrder");
                    saveAction.setParams({
                        "purchaseOrder" : JSON.stringify(component.get("v.PO")),
                        "POLI_List" : JSON.stringify(poLIst),
                        "rfpSupp" : JSON.stringify(component.get("v.RFPsupplier")),
                        "rfpReq" : JSON.stringify(component.get("v.RFPrequest")),
                        "orderId":component.get("v.orderId"),
                        "shipmentid" : component.get("v.ShipmentId"),
                        "pacakgeids" : component.get("v.PackIds"),
                        "returnPO" : component.get("v.returnToVendor"),
                        "filesData": (filesData2Upload.length > 0) ? JSON.stringify(filesData2Upload) : '',
                    });
                    console.log('before calling save_PurchaseOrder');
                    
                    saveAction.setCallback(this,function(response){
                        try{
                            console.log('After calling save_PurchaseOrder:',JSON.stringify(response));
                            if(response.getState() === 'SUCCESS'){
                                
                                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//9
                                component.set("v.showSpinner",false);
                                
                                if(component.get("v.showfileUpload")){
                                    //commented by Arshad as new code adde above for filesData
                                    /*
                                    console.log('file uplaod');
                                    var fillList11=component.get("v.fillList");
                                    console.log('fillList11 :',fillList11.length);
                                    console.log('component.find("fileId").get("v.files") :',component.find("fileId").get("v.files"));
                                    if(component.find("fileId").get("v.files")!=null){
                                        var recordId=response.getReturnValue().Id;
                                        console.log('recordId : ',recordId);
                                        if (component.find("fileId").get("v.files").length > 0 && fillList11.length > 0) {   
                                            console.log('here 2');
                                            var fileInput = component.get("v.FileList");
                                            for(var i=0;i<fileInput.length;i++) helper.saveAtt(component,event,fileInput[i],recordId);
                                            
                                        }
                                    }
                                    */
                                    
                                    if(!$A.util.isUndefined(component.get("v.clonePOId")) && !$A.util.isEmpty(component.get("v.clonePOId"))){ //Added by parveez on 16-Nov-23 for cloning the Attachment from the source PO.
                                        var AttachmentIds = [];
                                        var uploadedfiles = component.get('v.uploadedFile');
                                        if(uploadedfiles.length > 0){
                                            
                                            for(var i=0;i<uploadedfiles.length;i++){
                                                AttachmentIds.push(uploadedfiles[i].Id);
                                            }
                                            console.log('AttachmentIds:',AttachmentIds);
                                            var action = component.get("c.cloneAttachment");
                                            action.setParams({
                                                "recId":response.getReturnValue().Id,
                                                "attachmentIds" : AttachmentIds
                                            });
                                            action.setCallback(this,function(response){
                                                if(response.getState() === 'SUCCESS'){
                                                    if(response.getReturnValue() == null){   
                                                        console.log('inside Success');
                                                    }  
                                                }else{ console.log('Error cloneAttachment:',response.getError());}
                                            });
                                            $A.enqueueAction(action);
                                        }
                                    }
                                }
                                
                                console.log('bfr recId : ',component.get("v.recordId"));
                                //Moin Made Change
                                //commented if(component.get("v.recordId") != null && component.get("v.recordId") != undefined && component.get("v.recordId") != ''){
                                //Added if(response.getReturnValue().Id != null && response.getReturnValue().Id != undefined && response.getReturnValue().Id != ''){
                                if(response.getReturnValue().Id != null && response.getReturnValue().Id != undefined && response.getReturnValue().Id != ''){
                                    
                                    var recordId=response.getReturnValue().Id;
                                    
                                    var action=component.get("c.AnalyticalAccounts");
                                    action.setParams({'AA':JSON.stringify(component.get("v.dimensionList")), 'PId':recordId});
                                    action.setCallback(this,function(response){
                                        //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                                        //component.set("v.currencyList",response.getReturnValue().currencyList);
                                    });
                                    $A.enqueueAction(action);
                                    /*console.log('filesDataToUpload : ',filesDataToUpload);
                                    if (filesDataToUpload.length > 0) {
                                        helper.saveAttachments(component, filesDataToUpload, recordId);
                                    }*/
                                    
                                }
                                
                                if(component.get("v.recordId") != null && component.get("v.recordId") != undefined && component.get("v.recordId") != ''){
                                    console.log('here PO updated successfully ~>'+$A.get('$Label.c.PO_Purchase_Order_Updated_Successfully'));
                                    //helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.PO_Purchase_Order_Updated_Successfully'));
                                    component.set("v.successMsg",$A.get('$Label.c.PO_Purchase_Order_Updated_Successfully'));
                                }
                                else{
                                    console.log('here PO created successfully ~>'+$A.get('$Label.c.PO_Purchase_Order_Created_Successfully'));
                                    helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.PO_Purchase_Order_Created_Successfully'));
                                } 
                                if(component.get("v.Mtask")){
                                    
                                    helper.goBackTask(component, event);
                                }
                                else if(component.get("v.fromshipment")){
                                    
                                    helper.gobackshipment(component, event);
                                }
                                    else if(component.get('v.fromMultiPO')){
                                        var lst = [];
                                        lst.push(component.get('v.PO'));
                                        console.log('lst : ',lst.length,'   ',JSON.stringify(lst));
                                        $A.createComponent("c:ShowCreatedPO",{
                                            "CreatedPOPOLIs":lst,
                                            "channelId" : component.get('v.channelId'),
                                            "dChannelId" : component.get('v.dChannelId'),
                                            "ChannelName" : component.get('v.Channel.Name'),
                                            "dChannelName" : component.get('v.distributionChannel.Name')
                                        },function(newcomponent, status, errorMessage){
                                            if (status === "SUCCESS") {
                                                var body = component.find("body");
                                                body.set("v.body", newcomponent);
                                            }
                                        });
                                    }
                                        else{
                                            if(component.get("v.fromAPB")){
                                                var evt = $A.get("e.force:navigateToComponent");
                                                evt.setParams({
                                                    componentDef : "c:Accounts_Payable",
                                                    componentAttributes: {
                                                        "aura:id": "AccountsPayable",
                                                        "selectedTab":"Bills"
                                                    }
                                                });
                                                evt.fire();
                                            }
                                            else if(component.get("v.fromAP")){
                                                var evt = $A.get("e.force:navigateToComponent");
                                                evt.setParams({
                                                    componentDef : "c:Accounts_Payable",
                                                    componentAttributes: {
                                                        "aura:id": "AccountsPayable",
                                                        "selectedTab":"Purchase_Orders"
                                                    }
                                                });
                                                evt.fire();
                                                
                                                
                                                
                                                /*var url = '/apex/ERP7__CreateBIll?po=';
                                 url = url + component.get("v.recordId");
                                 window.location.replace(url);*/
                                                
                                            }
                                                else if(component.get("v.fromProject")){
                                                    var evt = $A.get("e.force:navigateToComponent");
                                                    evt.setParams({
                                                        componentDef : "c:Milestones",
                                                        componentAttributes: {
                                                            "currentProj" : component.get("v.currentProj"),
                                                            "projectId" : component.get("v.ProjId"),
                                                            "newProj" : false
                                                        }
                                                    });
                                                    evt.fire();
                                                }
                                                    else if(component.get("v.fromCB")){
                                                        var rId=component.get("v.recordId");
                                                        
                                                        /*var evt = $A.get("e.force:navigateToComponent");
                                 evt.setParams({
                                     componentDef : "c:CreateBill",
                                     componentAttributes: {
                                         "pId" : rId,
                                         "navigateToRecord":false,
                                         "Bill":{}
                                     }
                                 });
                                 evt.fire();*/
                                                    
                                                    $A.createComponent("c:CreateBill",{
                                                        "pId" : rId,
                                                        "navigateToRecord":false,
                                                        "Bill":{}
                                                    },function(newcomponent, status, errorMessage){
                                                        if (status === "SUCCESS") {
                                                            var body = component.find("body");
                                                            body.set("v.body", newcomponent);
                                                        }
                                                    });
                                                    
                                                    
                                                    /* $A.createComponent(
                                    "c:CreateBill", { 
                                        "pId" : rId,
                                         "setRT" : 'PO Bill',
                                         "showPage" : true,
                                         "ShowBillType":false
                                    },
                                    function(newComp) {
                                    if (status === "SUCCESS") {
                                        var content = component.find("body");
                                        content.set("v.body", newComp);  
                                        }
                                    }
                                );  */
                                                    
                                                    /*var url = '/apex/ERP7__CreateBIll?po=';
                                 url = url + component.get("v.recordId");
                                 window.location.replace(url);*/
                                                    
                                                }
                                                    else{
                                                        if(component.get("v.navigateToRecord")){
                                                            console.log('arshad here navigateToRecord true');
                                                            var recordId=response.getReturnValue().Id;
                                                            var sObjectUrl = "/lightning/r/ERP7__PO__c/" + recordId + "/view";
                                                            // var sObjectUrl='https://'+window.location.hostname.split('--')[0]+'.lightning.force.com/lightning/r/ERP7__PO__c/'+recordId+'/view'; // commented by shaguftha on 20_11_23 issue after creating the PO it was not navigating to the record
                                                            //  window.open(sObjectUrl,'_parent');
                                                            if(!$A.util.isUndefined(component.get("v.SOId")) && !$A.util.isEmpty(component.get("v.SOId")))
                                                                window.history.back();
                                                            //window.open(sObjectUrl,'_parent');
                                                            else if(!$A.util.isUndefined(component.get("v.mpslineId")) && !$A.util.isEmpty(component.get("v.mpslineId"))){
                                                                window.open(sObjectUrl,'_parent'); 
                                                            }
                                                                else if((!$A.util.isUndefined(component.get("v.MOId")) && !$A.util.isEmpty(component.get("v.MOId"))) || (!$A.util.isUndefined(component.get("v.MPsMOId")) && !$A.util.isEmpty(component.get("v.MPsMOId")))){//
                                                                    var MoId = (!$A.util.isUndefined(component.get("v.MOId")) && !$A.util.isEmpty(component.get("v.MOId"))) ? component.get("v.MOId"): component.get("v.MPsMOId");
                                                                    $A.createComponent("c:Manufacturing_Orders",{
                                                                        "MO": MoId,
                                                                        "NAV":'mp',
                                                                        "RD":'yes',
                                                                        "allowNav" : true
                                                                    },function(newcomponent, status, errorMessage){
                                                                        if (status === "SUCCESS") {
                                                                            var body = component.find("body");
                                                                            body.set("v.body", newcomponent);
                                                                        }
                                                                    });
                                                                    //location.reload(); 
                                                                }
                                                                    else if(!$A.util.isUndefined(component.get("v.soliID")) && !$A.util.isEmpty(component.get("v.soliID"))){
                                                                        var SO = poLIst[0].ERP7__Sales_Order__c;
                                                                        var RecId = event.getSource().get("v.title");
                                                                        var RecUrl = "/lightning/r/ERP7__Sales_Order__c/" + SO + "/view";
                                                                        window.open(RecUrl,'_parent');
                                                                    }
                                                                        else{
                                                                            console.log('arshad here navigateToRecord in else atlast');  
                                                                            
                                                                            if (component.find("fileId") != undefined && component.find("fileId").get("v.files")!=null){ // added component.find("fileId") != undefined by shaguftha on 12-12-23 if the uplaod file option is not visible to user it throws error
                                                                                setTimeout($A.getCallback(function() {
                                                                                    var RecUrl = "/lightning/r/ERP7__PO__c/" + recordId + "/view";
                                                                                    window.open(RecUrl,'_parent');
                                                                                }), 1000);
                                                                            }
                                                                            else{
                                                                                var RecUrl = "/lightning/r/ERP7__PO__c/" + recordId + "/view";
                                                                                window.open(RecUrl,'_parent');
                                                                            }
                                                                            
                                                                        }
                                                        }
                                                        else{
                                                            console.log('here navigateToRecord false');
                                                            var params = event.getParam('arguments');
                                                            var callback;
                                                            if (params) { callback = params.callback; }
                                                            if (callback) callback(response.getReturnValue());
                                                        }
                                                    }
                                        }
                            }else{
                                //button.set('v.disabled',false);
                                //alert(response.getState());
                                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//10
                                component.set("v.showSpinner",false);
                                var errors = response.getError();
                                console.log('server err~>'+JSON.stringify(errors));
                                console.log('server err~>',JSON.stringify(errors));
                                console.log('server err~>',errors);
                                console.log('server err~>',errors[0]);
                                try{
                                    if(errors != undefined && errors.length >0){
                                        let err = errors[0].message;
                                        if(err.includes($A.get('$Label.c.Please_select_the_approved_vendor_for_the_Purchase_Order'))){
                                            component.set("v.exceptionError", $A.get('$Label.c.Please_select_the_approved_vendor_for_the_Purchase_Order'));  
                                        } else if(err.includes('Budget')){
                                            component.set("v.exceptionError", 'There is no enough approved Budget amount to spend'); 
                                        } else if (err.includes('Purchase quantity') && err.includes('cannot be less than total received quantity')) {
                                            // Extract message using regex to isolate meaningful part
                                            let match = err.match(/Purchase quantity.*?cannot be less than total received quantity.*?\.\:/);
                                            if (match && match.length > 0) {
                                                component.set("v.exceptionError", match[0]);
                                            } else {
                                                component.set("v.exceptionError", 'Purchase quantity cannot be less than received quantity.');
                                            }
                                            
                                        } else{
                                            component.set("v.exceptionError", errors[0].message); 
                                        }
                                    }
                                }catch(e){ component.set("v.exceptionError", errors[0].message);  }
                                //component.set("v.exceptionError", errors[0].message);
                                
                                /*
                            if (!$A.util.isUndefinedOrNull(errors[0].message) && errors && Array.isArray(errors) && errors.length > 0) {
                                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                component.set("v.exceptionError",errors[0].message);
                            }                         
                            if(!$A.util.isEmpty(errors[0].fieldErrors)){//.ERP7__Description__c[0].message                             
                                if(!$A.util.isUndefinedOrNull(errors[0].fieldErrors.ERP7__Description__c))
                                component.set("v.exceptionError",errors[0].fieldErrors.ERP7__Description__c[0].message);
                            }
                            if(!$A.util.isEmpty(errors[0].pageErrors)){
                                component.set("v.exceptionError",'please select the approved vendor for the purchase order');
                            }
                            */
                            }
                        }catch(e){
                            console.log('ctach err~>'+e);
                            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//11
                            component.set("v.showSpinner",false);
                        }
                    });
                    $A.enqueueAction(saveAction);
                }    
                else{
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");//12
                    component.set("v.showSpinner",false);
                    //helper.showToast('Error!','error','Please add a Line Item');
                    component.set("v.exceptionError",$A.get('$Label.c.PO_Error_Please_add_a_Line_Item'));
                    //button.set('v.disabled',false);
                }
            }
            else{
                console.log('isDCSelected : ',isDCSelected);
                console.log('selectedRecType : ',component.get("v.selectedRecType"));
                console.log('DropShipPOrecType : ',component.get("v.DropShipPOrecType"));
                
                var errorMessage = '';
                if(!isVenderSelected){
                    if(component.get("v.venAddressRequired")) errorMessage = $A.get('$Label.c.Please_select_the_Vendor_Address');
                    else if(component.get("v.venConRequired")) errorMessage = $A.get('$Label.c.Please_select_Vendor_Contact');
                        else errorMessage = $A.get('$Label.c.Please_select_Vendor_Account');
                    //if(component.get("v.venAddressRequired")) errorMessage = errorMessage + ' and Address';
                    //component.set("v.exceptionError",$A.get('$Label.c.PO_Purchase_Order_Updated_Successfully'));
                    //helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please select Vendor Account and Contact.');
                }
                //Moin Removed this
                /*else if(!isOrderSelected && component.get("v.selectedRecType") == component.get("v.DropShipPOrecType")){
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Please Select Order');
            }*/
                else if(!isCustomerSelected && component.get("v.selectedRecType") == component.get("v.DropShipPOrecType")){
                    errorMessage =$A.get('$Label.c.PH_RMA_Please_Select_Customer');
                }else if(!isDCSelected && component.get("v.selectedRecType") != component.get("v.DropShipPOrecType")){
                    errorMessage =$A.get('$Label.c.Please_Select_Receiving_Center');
                    console.log('erro in DC');
                    
                }else if(component.get("v.returnToVendor") && returnPOflag){
                    errorMessage = $A.get('$Label.c.Quantity_cannot_exceed_allowed_return_qty');
                }else if(!flagCon && !flag && !flagOrg && isErrors && isErrorsUP ){
                    errorMessage = $A.get('$Label.c.PO_Please_enter_the_required_fields_that_are_marked');
                }else if(!flagCon && !flag && !flagOrg){
                    errorMessage = $A.get('$Label.c.PO_Please_enter_the_required_fields_that_are_marked');
                }else if (flagCon && flag && flagOrg && isErrors && isErrorsUP){
                    errorMessage = $A.get('$Label.c.Please_check_the_POLI_Quantity_and_Unit_Price');
                }else if (!flagCon){
                    errorMessage = $A.get('$Label.c.Please_select_the_Vendor_Address');                 
                }else if(!analyticalAccAdded){
                    errorMessage = $A.get('$Label.c.AddAnalyticalAccount');
                }else if(isErrorsAACOA){
                    errorMessage = $A.get('$Label.c.Please_select_the_Accounting_Account_and_Analytical_Account');
                }else if(isErrorsAA){
                    errorMessage = $A.get('$Label.c.Total_Analytical_Account_amount_of_an_item_cannot_be_greater');
                }
                    else{
                        errorMessage = $A.get('$Label.c.Please_enter');
                        if (!flagCon) errorMessage += $A.get('$Label.c.Contact_Record_Name');
                        if(!flag){
                            if(errorMessage != $A.get('$Label.c.Please_enter')) errorMessage += ", ";
                            
                            errorMessage += ' '+ $A.get('$Label.c.InventoryConsole_Vendor');
                            if(flagOrg) errorMessage += "information";
                        }
                        if (!flagOrg){
                            if(errorMessage != $A.get('$Label.c.Please_enter')) errorMessage += ", ";
                            
                            errorMessage += "Organisation";
                            if(flag) errorMessage += "information";
                        }
                        if (isErrors){
                            if(errorMessage != $A.get('$Label.c.Please_enter ')) errorMessage += ", ";
                            
                            errorMessage += ' '+$A.get('$Label.c.valid_quantity');
                        }
                        if (isErrorsAA){
                            if(errorMessage != $A.get('$Label.c.Please_enter')) errorMessage += ", ";
                            errorMessage += $A.get('$Label.c.Total_Analytical_Account_amount_of_an_item_cannot_be_greater');
                        }
                        if (isErrorsAACOA){
                            if(errorMessage != $A.get('$Label.c.Please_enter') ) errorMessage += ", ";
                            
                            errorMessage += $A.get('$Label.c.Please_select_the_Accounting_Account_and_Analytical_Account');
                        }
                        if (isErrorsUP){
                            if(errorMessage != $A.get('$Label.c.Please_enter')) errorMessage += ", ";
                            
                            errorMessage += $A.get('$Label.c.PurchaseOrderPDF_Unit_Price');
                        }
                        if (!flag && !flagOrg) errorMessage += " Information";
                        errorMessage += ".";
                    }
                component.set("v.exceptionError",errorMessage);
                //button.set('v.disabled',false);
                console.log("TestLabel",errorMessage);
            }
        }
        catch(e){
            console.log('Error in save PO:~>',e);
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//13
            component.set("v.showSpinner",false);
        }  
    },
    
    goBack : function(component,event,helper){
        console.log('goback called');
        console.log('fromMultiPO~>'+component.get("v.fromMultiPO"));
        var rId=component.get("v.recordId");
        //Moin added below code to navigate to Accounts Payable on edit po click on 10th january 2024
        if(component.get("v.fromAP")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Accounts_Payable",
                componentAttributes: {
                    "aura:id": "AccountsPayable",
                    "selectedTab":"Purchase_Orders"
                }
            });
            evt.fire();
        }else if(component.get('v.fromCB')){
            $A.createComponent("c:CreateBill",{
                "pId" : rId,
                "navigateToRecord":false,
                "Bill":{}
            },function(newcomponent, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newcomponent);
                }
            });
        }else if(component.get('v.interCompanyPO')){
            $A.createComponent("c:InterCompanyInvoicing",{
                
            },function(newcomponent, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newcomponent);
                }
            });
        }
            else if(component.get('v.fromMultiPO')){
                console.log('from PO');
                var lst = [];
                lst.push(component.get('v.PO'));
                console.log('lst : ',lst.length,'   ',JSON.stringify(lst));
                $A.createComponent("c:ShowCreatedPO",{
                    "CreatedPOPOLIs":lst,
                    "channelId" : component.get('v.channelId'),
                    "dChannelId" : component.get('v.dChannelId'),
                    "ChannelName" : component.get('v.Channel.Name'),
                    "dChannelName" : component.get('v.distributionChannel.Name')
                },function(newcomponent, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newcomponent);
                    }
                });
            }
                else{
                    console.log('rmaid~>'+component.get("v.rmaId"));
                    if(component.get("v.RFPsupplier") != null && component.get("v.RFPsupplier") != undefined && component.get("v.RFPsupplier") != ''){
                        console.log('back to RMA 1');
                        location.reload();
                    } else if(!$A.util.isEmpty(component.get("v.rmaId")) ){
                        /*var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:RMA",
                componentAttributes: {
                    RMAId : component.get("v.rmaId"),
                    
                }
            });
            evt.fire();*/
                    
                    $A.createComponent("c:RMA",{
                        "RMAId":component.get("v.rmaId")
                    },function(newcomponent, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = component.find("body");
                            body.set("v.body", newcomponent);
                        }
                    }); 
                }else{
                    console.log('back to RMA 2');
                    window.history.back();
                }
        }
    },
    
    goBackTask : function(component, event, helper) {
        
        $A.createComponent("c:AddMilestoneTask",{
            "aura:id" : "taskcomponent",
            "projectId" : component.get("v.projectId"),
            "taskId" : component.get("v.Mtask.Id"),
            "newTask" : component.get("v.Mtask"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
    },
    
    UpdateCustomer : function(component,event,helper){
        var po = component.get("v.PO");
        if(po.ERP7__Customer__r.Id != null && po.ERP7__Customer__r.Id != undefined) component.set("v.PO.ERP7__Customer__C",po.ERP7__Customer__r.Id);
    },
    
    UpdatePO : function(component,event,helper){
        console.log('UpdatePO called : ',component.get("v.PO.ERP7__Vendor__c"));
        var po = component.get("v.PO");
        if(component.get("v.PO.ERP7__Vendor__c") != null && component.get("v.PO.ERP7__Vendor__c") != undefined && component.get("v.PO.ERP7__Vendor__c") != ''){
            console.log('UpdatePO calling fetchVendorDetails, setVendorAddress');
            //component.set("v.PO.ERP7__Vendor__c",po.ERP7__Vendor__r.Id);
            
            helper.fetchVendorDetails(component,event,helper); 
            if(component.get("v.recordId") == null || component.get("v.recordId") == undefined || component.get("v.recordId") == ""){
                helper.setVendorAddress(component,event,helper); 
            }
            
            let venID = component.get('v.PO.ERP7__Vendor__c');
            
            console.log('venID : ',venID);
            if(venID != '' && venID != null && venID != undefined){
                let defaultCon = {'RecordTypeId':component.get("v.ConRecId"),'AccountId':component.get('v.PO.ERP7__Vendor__c')};
                component.set("v.defaultVenCon",defaultCon);
                let defaultAdd = {'ERP7__Organisation__c':component.get("v.PO.ERP7__Organisation__c"),'ERP7__Customer__c':component.get('v.PO.ERP7__Vendor__c')};
                component.set("v.defaultVenAddress",defaultAdd); 
            }
        }
        
        else{
            console.log('UpdatePO else update');
            component.set("v.PO.ERP7__Vendor_Contact__c",''); 
            component.set("v.PO.ERP7__Vendor_Address__c",'');
            console.log('UpdatePO PO details 1: ',JSON.stringify(component.get("v.PO")));
            
        }
        console.log(' UpdatePO contact after : ',component.get("v.PO.ERP7__Vendor_Contact__c"));
        console.log(' UpdatePO address after 1: ',component.get("v.PO.ERP7__Vendor_Address__c"));
    },
    
    UpdateCO : function(component,event,helper){
        var po = component.get("v.PO");
        if(po.ERP7__Vendor_Contact__c != null && po.ERP7__Vendor_Contact__c != undefined && po.ERP7__Vendor_Contact__c != ''){
            component.set("v.PO.ERP7__Vendor_Contact__c",po.ERP7__Vendor_Contact__c);
        }
        else component.set("v.PO.ERP7__Vendor_Contact__c",null);
    },
    
    UpdateER: function(component,event,helper){
        var po = component.get("v.PO");
        if(po.ERP7__EmployeeRequester__r.Id != null && po.ERP7__EmployeeRequester__r.Id != undefined){
            component.set("v.PO.ERP7__EmployeeRequester__c",po.ERP7__EmployeeRequester__r.Id);
        }
    },
    
    UpdateFA: function(component,event,helper){
        var po = component.get("v.PO");
        if(po.ERP7__FinalApprover__r.Id != null && po.ERP7__FinalApprover__r.Id != undefined){
            component.set("v.PO.ERP7__FinalApprover__c",po.ERP7__FinalApprover__r.Id);
        }
    },
    
    UpdateOA: function(component,event,helper){
        console.log('UpdateOA called');
        var po = component.get("v.PO");
        if(component.get("v.PO.ERP7__Organisation__c") != null && component.get("v.PO.ERP7__Organisation__c") != undefined){
            // component.set("v.PO.ERP7__Organisation__c",po.ERP7__Organisation__r.Id);
            
            var showdefault =  $A.get("$Label.c.DefaultValuesOnPO");
            
            if(showdefault == true) { 
                console.log('calling fetchAddressDetails from UpdateOA');
                helper.fetchAddressDetails(component,event,helper); 
            }
            
            var isMulticurrency = component.get('v.isMultiCurrency');
            if(isMulticurrency == true) { 
                if(component.get("v.recordId") == null || component.get("v.recordId") == undefined || component.get("v.recordId") == ""){
                    helper.fetchOrgCurrncy(component,event,helper); 
                }
            }
        }
    },
    
    UpdateVA: function(component,event,helper){
        console.log('UpdateVA called');
        var po = component.get("v.PO");
        if(po.Vendor_Address__r.Id != null && po.Vendor_Address__r.Id != undefined){
            component.set("v.PO.Vendor_Address__c",po.Vendor_Address__r.Id);
        }
        console.log('ERP7__Vendor_Address__c 2 : ',component.get("v.PO.ERP7__Vendor_Address__c"));
    },
    
    /*
    UpdateDA: function(component,event,helper){
        var po = component.get("v.PO");
        if(po.ERP7__Delivery_Address__r.Id != null && po.ERP7__Delivery_Address__r.Id != undefined){
            component.set("v.PO.ERP7__Delivery_Address__c",po.ERP7__Delivery_Address__r.Id);
        }
    },
    */
    
    UpdateIA: function(component,event,helper){
        var po = component.get("v.PO");
        if(po.ERP7__Invoice_Address__r.Id != null && po.ERP7__Invoice_Address__r.Id != undefined){
            component.set("v.PO.ERP7__Invoice_Address__c",po.ERP7__Invoice_Address__r.Id); 
        }
        
    },
    
    UpdateChan: function(component,event,helper){
        console.log('arshad UpdateChan called');
        var po = component.get("v.PO");
        if(po.ERP7__Channel__r.Id != null && po.ERP7__Channel__r.Id != undefined){
            component.set("v.channelId",po.ERP7__Channel__r.Id);
        }
    },
    
    UpdateDChan: function(component,event,helper){
        console.log('arshad UpdateDChan called');
        var po = component.get("v.PO");
        if(po.ERP7__Distribution_Channel__r.Id != null && po.ERP7__Distribution_Channel__r.Id != undefined){
            component.set("v.distributionChannel",po.ERP7__Distribution_Channel__r.Id);
        }
    },
    
    closeError : function (component, event) {
        component.set("v.exceptionError",'');
        component.set("v.successMsg",'');
    },
    
    displayRecords: function(component, event, helper) {
        console.log('displayRecords called');
        if(!(component.get("v.recordId") != null && component.get("v.recordId") != undefined && component.get("v.recordId") != "")){
            if(component.get("v.RFPrequest") != null && component.get("v.RFPrequest") != undefined && component.get("v.RFPrequest") != ''){
                component.set("v.channelId",component.get("v.RFPrequest.ERP7__Channel__c"));
                component.set("v.PO.ERP7__Channel__c", component.get("v.RFPrequest.ERP7__Channel__c"));
                component.set("v.distributionChannel.Id", component.get("v.RFPrequest.ERP7__Distribution_Channel__c"));
                component.set("v.distributionChannel.Name", component.get("v.RFPrequest.ERP7__Distribution_Channel__r.Name"));
                //if(component.get("v.soliID") != null || component.get("v.soliID") != undefined || component.get("v.soliID") != ''){ component.set("v.PO.ERP7__Sales_Order__c",component.get("v.soliID"));}
            }
            else{
                console.log('calling fetchDetails from displayRecords');
                helper.fetchDetails(component,event,helper);
            }
        }
    },
    
    showLogisticRecordDetailsPage:function(comp,event,helper){ 
        var recordId = event.target.dataset.record;  
        comp.set("v.nameUrl",'/'+recordId); 
    },
    
    gobacktoshipment : function(component,event,helper){
        $A.createComponent("c:InternalShipment",{
            "shipmentID":component.get("v.ShipmentId"),
            "packageIDS" : component.get("v.PackIds"),
            "showHeader":  false
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
    },
    
    updateTotalPrice: function(c, e, h){
        console.log('arshad inside updateTotalPrice');
        
        var items=c.get('v.poli');
        console.log('arshad inside updateTotalPrice : ',items);
        if($A.util.isUndefined(items.length)){
            var amt = items.ERP7__Quantity__c * items.ERP7__Unit_Price__c;
            if(amt>=0) c.set("v.PO.ERP7__Total_Amount__c",amt.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
        }
        else{
            var amt=0;
            var subTotal=0;
            //for(var x in items){
            for(var x = 0; x < items.length; x++){
                if($A.util.isEmpty(items[x].ERP7__Unit_Price__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Unit_Price__c)) items[x].ERP7__Unit_Price__c=0;
                if($A.util.isEmpty(items[x].ERP7__Tax__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Tax__c)) items[x].ERP7__Tax__c=0;
                if($A.util.isEmpty(items[x].ERP7__Quantity__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Quantity__c)) items[x].ERP7__Quantity__c=0;
                amt += ((items[x].ERP7__Quantity__c * items[x].ERP7__Unit_Price__c) + parseFloat(items[x].ERP7__Tax__c));
                subTotal += (items[x].ERP7__Quantity__c * items[x].ERP7__Unit_Price__c);
            }
            console.log('arshad inside updateTotalPrice amt~>'+amt);
            console.log('arshad inside updateTotalPrice subTotal~>'+subTotal);
            if(amt >= 0) amt = amt.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            if(subTotal >= 0) subTotal = subTotal.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            //if(amt >= 0) {
            c.set("v.TotalAmount",amt);
            c.set("v.SubTotal",subTotal);
            c.set("v.PO.ERP7__Total_Amount__c",amt);
            //}
        }
    },
    
    updateTotalTax : function(c, e, h){
        try{
            console.log('arshad inside updateTotalTax');
            var items=c.get('v.poli');
            
            console.log('items.length:',items.length);
            console.log('poli Details:',JSON.stringify(items));
            
            if($A.util.isUndefined(items.length)){
                
                for(var x = 0; x < items.length; x++){
                    if(items[x].ERP7__Unit_Price__c==undefined) items[x].ERP7__Unit_Price__c=0;
                    if(items[x].ERP7__Tax_Rate__c==undefined) items[x].ERP7__Tax_Rate__c=0;
                    if(items[x].ERP7__Quantity__c==undefined) items[x].ERP7__Quantity__c=0;
                }
                
                var tax=(items.ERP7__Unit_Price__c/100)*items.ERP7__Tax_Rate__c;
                var totalTax=(tax)*items.ERP7__Quantity__c;
                
                c.set("v.Tax",totalTax);
                c.set("v.TotalTax",totalTax);
                c.set("v.SubTotal",c.get("v.PO.ERP7__Total_Amount__c"));
                $A.enqueueAction(c.get("c.updateTotalPrice"));
                //var itemTotal = c.get("v.PO.ERP7__Total_Amount__c");
                //c.set("v.PO.ERP7__Total_Amount__c",itemTotal+totalTax);
            }
            else{
                
                
                var totaltax=0;
                var tax = 0;
                var OTtax = 0;
                var subTotal=0;
                
                //Commented by Parveez on 27 sept 2023
                /*for(var x in items){
                            if($A.util.isEmpty(items[x].ERP7__Unit_Price__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Unit_Price__c)) items[x].ERP7__Unit_Price__c=0;
                            if($A.util.isEmpty(items[x].ERP7__Tax_Rate__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Tax_Rate__c)) items[x].ERP7__Tax_Rate__c=0;
                            if($A.util.isEmpty(items[x].ERP7__Quantity__c) || $A.util.isUndefinedOrNull(items[x].ERP7__Quantity__c)) items[x].ERP7__Quantity__c=0;
                            tax = ((items[x].ERP7__Unit_Price__c/100)*items[x].ERP7__Tax_Rate__c);
                            totaltax += ((tax) * items[x].ERP7__Quantity__c);
                            subTotal += (items[x].ERP7__Unit_Price__c * items[x].ERP7__Quantity__c);
                        }*/
                
                for(var x=0; x<items.length;x++){
                    var item = items[x];
                    if($A.util.isEmpty(item.ERP7__Unit_Price__c) || $A.util.isUndefinedOrNull(item.ERP7__Unit_Price__c)) item.ERP7__Unit_Price__c=0;
                    if($A.util.isEmpty(item.ERP7__Tax_Rate__c) || $A.util.isUndefinedOrNull(item.ERP7__Tax_Rate__c)) item.ERP7__Tax_Rate__c=0;
                    if($A.util.isEmpty(item.ERP7__Quantity__c) || $A.util.isUndefinedOrNull(item.ERP7__Quantity__c)) item.ERP7__Quantity__c=0;
                    tax = ((item.ERP7__Unit_Price__c/100)*item.ERP7__Tax_Rate__c);
                    totaltax += ((tax) * item.ERP7__Quantity__c);
                    subTotal += (item.ERP7__Unit_Price__c * item.ERP7__Quantity__c);
                }
                
                console.log('arshad inside updateTotalPrice totaltax~>'+totaltax);
                console.log('arshad inside updateTotalPrice subTotal~>'+subTotal);
                if(totaltax >= 0) totaltax = totaltax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                if(subTotal >= 0) subTotal = subTotal.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                
                c.set("v.TotalTax",totaltax);
                c.set("v.SubTotal",subTotal);
                c.set("v.Tax",totaltax);
                $A.enqueueAction(c.get("c.updateTotalPrice"));
                //var itemTotal = c.get("v.PO.ERP7__Total_Amount__c");
                //c.set("v.PO.ERP7__Total_Amount__c",itemTotal+totalTax);
            }
            
        }
        catch(e){
            console.log('Error in updateTotalTax:',e);
            console.log("Error occurred at line number:", e.lineNumber);
        }
    },
    
    //changed by Arshad 02 Aug 23 proceedDeliveryAddChange 
    getDeliveryAdd : function(component, event, helper){
        console.log('getDeliveryAdd called proceedDeliveryAddChange~>'+component.get("v.proceedDeliveryAddChange"));
        if(component.get("v.proceedDeliveryAddChange")){
            let DCId = component.get('v.dChannelId');
            console.log('DCId~>'+DCId);
            
            console.log("before ERP7__Delivery_Address__c here5~>"+component.get("v.PO.ERP7__Delivery_Address__c"));
            if(component.get("v.PO.ERP7__Delivery_Address__c") == null || component.get("v.PO.ERP7__Delivery_Address__c") == '' || component.get("v.PO.ERP7__Delivery_Address__c") == undefined){
                if(DCId != '' && DCId != null && DCId != undefined && component.get("v.selectedRecType") != component.get("v.DropShipPOrecType")){
                    console.log('getDeliveryAdd calling getDC');
                    var action = component.get('c.getDC');
                    action.setParams({ DC : DCId});
                    action.setCallback(this,function(response){
                        if(response.getState() === 'SUCCESS'){
                            var res = response.getReturnValue();
                            if(res != null){
                                console.log('getDeliveryAdd in resp');
                                component.set("v.PO.ERP7__Delivery_Address__c",res.ERP7__Site__r.ERP7__Address__c);
                                console.log('after ERP7__Delivery_Address__c set here5~>',res.ERP7__Site__r.ERP7__Address__c);
                            }
                        }else{
                            //button.set('v.disabled',false);
                            console.log('Error getDeliveryAdd:',response.getError());
                            component.set("v.exceptionError",response.getError());
                        }
                    });
                    $A.enqueueAction(action);
                    
                }
                
            }
        }
    },
    
    //changed by Arshad 02 Aug 23 proceedDeliveryAddChange 
    setDeliveryAdd : function(component, event, helper){
        console.log('setDeliveryAdd called proceedDeliveryAddChange~>'+component.get("v.proceedDeliveryAddChange"));
        if(component.get("v.proceedDeliveryAddChange")){
            if(component.get("v.selectedRecType") != component.get("v.DropShipPOrecType")){
                let custID = component.get('v.PO.ERP7__Customer__c');
                console.log('getCust custID : ',custID);
                if(custID != null && custID != '' && custID != undefined){
                    var action = component.get('c.getCust');
                    action.setParams({ customer : custID});
                    action.setCallback(this,function(response){
                        if(response.getState() === 'SUCCESS'){
                            var res = response.getReturnValue();
                            if(res != null){
                                component.set("v.PO.ERP7__Delivery_Address__c",res.Id);
                                console.log('getCust ERP7__Delivery_Address__c set here6~>',res.Id);
                            }
                        }else{
                            //button.set('v.disabled',false);
                            console.log('Error setDeliveryAdd:',response.getError());
                            component.set("v.exceptionError",response.getError());
                        }
                    });
                    $A.enqueueAction(action); 
                }
            }
        }
    },
    
    parentFieldChange : function(component, event, helper){
        try{
            console.log('parentFieldChange called');
            var controllerValue = component.get("v.PO.ERP7__Shipment_Type__c");//component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
            var pickListMap = component.get("v.depnedentFieldMap");
            console.log('controllerValue : '+controllerValue);
            if (controllerValue != '' && controllerValue != null && controllerValue != undefined) {
                //get child picklist value
                var childValues = pickListMap[controllerValue];
                var childValueList = [];
                if(childValues != undefined && childValues != null){
                    if(childValues.length > 0){
                        //childValueList.push('');
                        for (var i = 0; i < childValues.length; i++) {
                            childValueList.push(childValues[i]);
                        }
                    }
                }
                // set the child list
                console.log('childValueList~>'+JSON.stringify(childValueList));
                component.set("v.listDependingValues", childValueList);
                
                if(childValueList.length > 0){
                    component.set("v.bDisabledDependentFld" , false);  
                }else{
                    component.set("v.bDisabledDependentFld" , true); 
                }
            } else {
                var list = [];
                component.set("v.listDependingValues", list);
                component.set("v.bDisabledDependentFld" , true);
                component.set("v.PO.ERP7__Shipment_Type__c", '');
                component.set("v.PO.ERP7__Shipment_Preference_Speed__c",'');
            }
            
            console.log('parentFieldChange in here');
            var currentShippingSpeed = component.get("v.PO.ERP7__Shipment_Preference_Speed__c");
            console.log('currentShippingSpeed : ',currentShippingSpeed);
            if(component.get("v.listDependingValues").length > 0){
                var listdependingValues = component.get("v.listDependingValues");
                console.log('listdependingValues~>'+JSON.stringify(listdependingValues[0]));
                var isSpeedInList = listdependingValues.some(function (item) {
                    return item.value === currentShippingSpeed;
                });
                console.log('isSpeedInList : ',isSpeedInList);
               if(currentShippingSpeed == null || currentShippingSpeed == '' || currentShippingSpeed == undefined || currentShippingSpeed == '--None--' ||   !isSpeedInList) 
                   component.set("v.PO.ERP7__Shipment_Preference_Speed__c",listdependingValues[0].value);
            }
            
            console.log('v.PO.ERP7__Shipment_Preference_Speed__c~>'+component.get("v.PO.ERP7__Shipment_Preference_Speed__c"));
        }catch(e){
            console.log('err parentFieldChange~>',e);
        }
    },
    
    handleFilesChange: function(component, event, helper) {
        component.set("v.showDelete",true);
        var fileName = 'No File Selected..';
        //var files = component.get("v.FileList");  
        
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            console.log('fileName : ',fileName);
            var fileItem = [];
            for(var i=0;i<event.getSource().get("v.files").length;i++){
                 console.log('files : ',event.getSource().get("v.files")[i]['name']);
                fileItem.push(event.getSource().get("v.files")[i]['name']);
            }
        }
        //alert(fileItem);
        component.set("v.fillList",fileItem);
        component.set("v.fileName", fileName);
        
        
        //Added by Arshad 4 Dec 2023
        if(component.get("v.showfileUpload")){
            console.log('showfileUpload');
            try{
                let files = component.get("v.FileList");  
                console.log('FileList : ',FileList);
                let filesData = [];
                console.log('filesData before~>',filesData);
                
                if (files && files.length > 0) {
                    console.log('files : ',files.length);
                    if(files.length > 0){
                        for (let i = 0; i < files.length; i++) {
                            console.log('i~>'+i);
                            let file = files[i];
                            let reader = new FileReader();
                            //reader.onloadend is asynchronous using let instead of var inside for loop arshad 
                            reader.onloadend = function() {
                                console.log('inside reader.onloadend');
                                let contents = reader.result;
                                let base64Mark = 'base64,';
                                let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                                let fileContents = contents.substring(dataStart);
                                
                                console.log('inhere filesData.push');
                                //filesData = component.get("v.filesData2Upload");
                                console.log('filesData2Upload before here~>',filesData.length);
                                console.log('fileContents~>',encodeURIComponent(fileContents));
                                console.log('fileContents~>',fileContents);
                                filesData.push({
                                    "parentId": '',
                                    "fileName": file.name,
                                    "base64Data": encodeURIComponent(fileContents),
                                    "contentType": file.type
                                }); 
                                component.set("v.filesData2Upload",filesData);
                                
                                console.log('filesData '+i+' ~>',filesData);
                                
                            }
                            reader.onerror = function() {
                                console.log('for i~>'+i+' err~>'+reader.error);
                            };
                            reader.readAsDataURL(file);
                        }
                    }
                }
                
                console.log('filesData after~>',filesData);
            }catch(err){
                console.log("Error catch:",err);
            }
        }
    },
    
    removeAttachment : function(component, event, helper) {
        component.set("v.showDelete",false);
        var fileName = 'No File Selected..';
        component.set("v.fileName", fileName);        
        var fillList=component.get("v.fillList");
        fillList.splice(0, fillList.length); 
        component.set("v.fillList",fillList);
        component.set("v.filesData2Upload", []);
    // Reset file input component (if applicable)
    if (component.find("fileId")) {
        component.find("fileId").set("v.files", null);
    }
    },
    
    backToMainPage : function(component, event, helper) {
        component.set("v.showAddProducts",false);
    },
    
    fetchProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.searchItem'));
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        helper.getSearchProducts(component);
    },
    
    fetchFamilyProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.seachItemFmily'));
        if(component.get('v.seachItemFmily') == '--None--') component.set('v.seachItemFmily','');
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        helper.getSearchProducts(component);
        helper.familyFieldChange(component, event, helper);
    },
    
    fetchSubFamilyProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.subItemFmily'));
        if(component.get('v.subItemFmily') == '--None--') component.set('v.subItemFmily','');
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        helper.getSearchProducts(component);
    },
    
    closeaddProductsMsg : function(component, event, helper) {
        component.set('v.addProductsMsg','');
    },
    
    handletoggle : function(component, event, helper) {
        console.log('checked vfr: ',component.get('v.toggleChecked'));
        
        if(component.get('v.toggleChecked')){
            component.set('v.showStandardProducts',false);
            let customProd = [];
            console.log('customProd 1 : ',customProd);
            console.log('component.get("v.ClistOfProducts") :',component.get("v.ClistOfProducts"));
            if(component.get("v.ClistOfProducts") != null && component.get("v.ClistOfProducts") != undefined &&  component.get("v.ClistOfProducts") != {})  customProd = component.get('v.ClistOfProducts');
            console.log('customProd 12: ',customProd.length);
            if(customProd == undefined || customProd.length == 0){
                var NameLabel = $A.get('$Label.c.Enter_Name');
                customProd.push({Name :NameLabel ,quantity : 0,unitPrice:0,taxPercent:0,CustomProd : true});
                component.set('v.ClistOfProducts',customProd);
                console.log('component.get("v.ClistOfProducts") after:',component.get("v.ClistOfProducts"));
            }
            else{
                console.log('ClistOfProducts else: ',component.get('v.ClistOfProducts'));
            }
            
        }
        else{
            component.set('v.showStandardProducts',true);
        }
    },
    
    AddNewLine : function(component, event, helper) {
        console.log('AddNewLine called');
        console.log('ClistOfProducts length:',component.get("v.ClistOfProducts").length);
        var NameLabel = $A.get('$Label.c.Enter_Name');
        if(component.get("v.ClistOfProducts").length == 1){
            var custProd = component.get("v.ClistOfProducts");
            console.log('custProd[0].Name : ',custProd[0].Name);
            if(custProd[0].Name == NameLabel || custProd[0].Name == null || custProd[0].Name == undefined){
                component.set('v.addProductsMsg','Please complete details on current item');
                return;
            }
        }
        var customProd=component.get("v.ClistOfProducts");
        if(component.get("v.ClistOfProducts") != null && component.get("v.ClistOfProducts") != undefined && component.get("v.ClistOfProducts") != {}) customProd = component.get('v.ClistOfProducts');
        console.log('customProd 14: ',customProd);
        
        customProd.push({Name :NameLabel,quantity : 0,unitPrice:0,taxPercent:0,CustomProd : true});
        console.log('customProd:',customProd);
        component.set('v.ClistOfProducts',customProd);
    },
    
    /* handleCheckbox : function(component, event, helper) {
        let checkedval= event.getSource().get("v.checked");
        var index = event.getSource().get("v.name");
        var selectedProds = component.get('v.selectedListOfProducts');
        if(checkedval && index != null && index != undefined){
            console.log('in 1');
            let standProds = component.get('v.listOfProducts');
            for(var x in standProds){
                if(x == index || standProds[x].prod.Id == index){
                    selectedProds.push(standProds[x]);
                   // console.log('in');
                    //standProds[x].checkSelected = checkedval;
                    //standProds[x].quantity = parseFloat(1);
                }
            }
            component.set('v.selectedListOfProducts',selectedProds);
        }
        else{
            for(var x in selectedProds){
                if(selectedProds[x].prod.Id == index){
                    selectedProds.remove(selectedProds[x]);
                }
            }
            component.set('v.selectedListOfProducts',selectedProds);
        }
        
    },*/
    
    handleCheckbox: function(component, event, helper) {
        let checkedval = event.getSource().get("v.checked");
        let index = event.getSource().get("v.name");
        var selectedProds = component.get('v.selectedListOfProducts');
        console.log('selectedProds bfr : ',selectedProds);
        if (checkedval && index != null && index != undefined && index != '') {
            console.log('in 1');
            let standProds = component.get('v.listOfProducts');
            for (let i = 0; i < standProds.length; i++) {
                if (i == index || standProds[i].prod.Id == index) {
                    selectedProds.push(standProds[i]);
                }
            }
            component.set('v.selectedListOfProducts', selectedProds);
        } else if (checkedval == false && index != null && index != undefined && index != '') {
            if(selectedProds != undefined && selectedProds != null && selectedProds != []){
                for (let i = selectedProds.length - 1; i >= 0; i--) {
                    if (selectedProds[i].prod.Id == index) {
                        selectedProds.splice(i, 1);
                    }
                }
                component.set('v.selectedListOfProducts', selectedProds); 
            }
        }
        console.log('selectedProds : ',selectedProds);
    },
    
    handleCostCardChange: function(component, event, helper) {
        try{
            console.log('handleCostCardChange called');
            
            var index = event.currentTarget.getAttribute("data-index");
            console.log("handleCostCardChange index-: " + index);
            
            if(index != undefined && index != null){
                var standProds = component.get('v.listOfProducts');
                
                var value = (standProds[index].selCostCardId != undefined && standProds[index].selCostCardId != null && standProds[index].selCostCardId != '') ? standProds[index].selCostCardId : '';
                console.log('handleCostCardChange value~>' + value);
                
                if(value != ''){
                    console.log('getPrice calling value~>'+value);
                    var action = component.get("c.fetchPrice");
                    action.setParams({
                        "ccId": value
                    });
                    action.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            if(response.getReturnValue() != null){
                                var res = response.getReturnValue().costcard;
                                console.log('res~>',res);
                                if (res != null) {
                                    
                                    //for(var x in standProds){
                                    for(var x = 0; x < standProds.length; x++){
                                        if(x == index){
                                            console.log('in here1 res.ERP7__Cost__c~>'+res.ERP7__Cost__c);
                                            standProds[x].selectedCostCard = res;
                                            if(res.ERP7__Vendor_Part_Number__c != null && res.ERP7__Vendor_Part_Number__c != '' && res.ERP7__Vendor_Part_Number__c != undefined) standProds[x].VendorPartNumber = res.ERP7__Vendor_Part_Number__c;
                                            else standProds[x].VendorPartNumber = res.ERP7__Product__r.ERP7__Vendor_product_Name__c;
                                            standProds[x].unitPrice  = parseFloat(res.ERP7__Cost__c);
                                            
                                            if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                                            
                                            console.log('defaultTaxRate~>'+component.get("v.defaultTaxRate"));
                                            if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(component.get("v.defaultTaxRate"));
                                            
                                            let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                                            console.log('tax  bfr:  ',tax);
                                            
                                            tax = tax * standProds[x].quantity;
                                            
                                            standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                            
                                            if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                                            console.log('unitPrice : ',standProds[x].unitPrice);
                                            console.log('quantity : ',standProds[x].quantity);
                                            console.log('taxAmount : ',standProds[x].taxAmount);
                                            console.log('taxPercent : ',standProds[x].taxPercent);
                                            
                                            standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                                            console.log('TotalPrice : ',standProds[x].TotalPrice);
                                        }
                                    }
                                    console.log('setting listOfProducts here3');
                                    component.set('v.listOfProducts',standProds);
                                }
                            } else{
                                console.log('getPrice response  null');
                            }
                            
                        }else{
                            console.log('getPrice Exception Occured~>',JSON.stringify(response.getError()));  
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
        }catch(e){
            console.log('err~>',e);
        }
    },
    
    handleQuantity : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            ///for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].quantity = parseFloat(value);
                    if(standProds[x].unitPrice == null || standProds[x].unitPrice == '' || standProds[x].unitPrice == undefined) standProds[x].unitPrice = parseFloat(0);
                    if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(0);
                    let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                    console.log('tax  bfr:  ',tax);
                    tax = tax * standProds[x].quantity;
                    standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                    standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                    console.log('TotalPrice : ',standProds[x].TotalPrice);
                }
            }
            console.log('setting listOfProducts here2');
            component.set('v.listOfProducts',standProds);
        }
    },
    
    handleUnitPrice : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].unitPrice  = parseFloat(value);
                    if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                    if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(component.get("v.defaultTaxRate"));
                    let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                    console.log('tax  bfr:  ',tax);
                    tax = tax * standProds[x].quantity;
                    standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                    console.log('unitPrice : ',standProds[x].unitPrice);
                    console.log('quantity : ',standProds[x].quantity);
                    console.log('taxAmount : ',standProds[x].taxAmount);
                    console.log('taxPercent : ',standProds[x].taxPercent);
                    standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                    console.log('TotalPrice : ',standProds[x].TotalPrice);
                }
            }
            console.log('setting listOfProducts here3');
            component.set('v.listOfProducts',standProds);
        }
    },
    
    handletaxPercent : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].taxPercent = parseFloat(value);
                    if(standProds[x].unitPrice == null || standProds[x].unitPrice == '' || standProds[x].unitPrice == undefined) standProds[x].unitPrice = parseFloat(0);
                    if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                    let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                    console.log('tax  bfr:  ',tax);
                    tax = tax * standProds[x].quantity;
                    standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                    standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                    console.log('TotalPrice : ',standProds[x].TotalPrice);
                }
            }
            console.log('setting listOfProducts here4');
            component.set('v.listOfProducts',standProds);
        }
    },
    
    removeName : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        if(index != null && index != undefined){
            var NameLabel = $A.get('$Label.c.Enter_Name');
            let customProds = component.get('v.ClistOfProducts');
            //for(var x in customProds){
            for(var x = 0; x < customProds.length; x++){
                if(x == index){
                    console.log('in');
                    if(customProds[x].Name === NameLabel){
                        customProds[x].Name = '';
                    }
                }
            }
            component.set('v.ClistOfProducts',customProds);
            
        }
        
    },
    
    handleProdQuantity : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.ClistOfProducts');
            var NameLabel = $A.get('$Label.c.Enter_Name');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    if(standProds[x].Name == null || standProds[x].Name == undefined || standProds[x].Name == '' || standProds[x].Name == NameLabel){
                        component.set('v.addProductsMsg','Name is required for Custom Products');  
                        return;
                    }
                    else{
                        console.log('in');
                        standProds[x].quantity  = parseFloat(value);
                        if(standProds[x].unitPrice == null || standProds[x].unitPrice == '' || standProds[x].unitPrice == undefined) standProds[x].unitPrice = parseFloat(0);
                        if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(0);
                        let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                        console.log('tax  bfr:  ',tax);
                        tax = tax * standProds[x].quantity;
                        standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                        if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                        standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                        console.log('TotalPrice : ',standProds[x].TotalPrice);
                    }
                }
            }
            component.set('v.ClistOfProducts',standProds);
        }
    },
    
    handleProdUnitPrice : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.ClistOfProducts');
            var NameLabel = $A.get('$Label.c.Enter_Name');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    if(standProds[x].Name == null || standProds[x].Name == undefined || standProds[x].Name == '' || standProds[x].Name == NameLabel){
                        component.set('v.addProductsMsg','Name is required for Custom Products');  
                        return;
                    }
                    else{
                        console.log('in');
                        standProds[x].unitPrice   = parseFloat(value);
                        if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                        if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(0);
                        let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                        console.log('tax  bfr:  ',tax);
                        tax = tax * standProds[x].quantity;
                        standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                        if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                        standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                        console.log('TotalPrice : ',standProds[x].TotalPrice);
                    }
                }
            }
            component.set('v.ClistOfProducts',standProds);
        }
    },
    
    handleProdtaxPercent : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.ClistOfProducts');
            var NameLabel = $A.get('$Label.c.Enter_Name');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    if(standProds[x].Name == null || standProds[x].Name == undefined || standProds[x].Name == '' || standProds[x].Name == NameLabel){
                        component.set('v.addProductsMsg','Name is required for Custom Products');  
                        return;
                    }
                    else{
                        console.log('in');
                        standProds[x].taxPercent   = parseFloat(value);
                        if(standProds[x].unitPrice == null || standProds[x].unitPrice == '' || standProds[x].unitPrice == undefined) standProds[x].unitPrice = parseFloat(0);
                        if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                        let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                        console.log('tax  bfr:  ',tax);
                        tax = tax * standProds[x].quantity;
                        standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                        if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                        standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                        console.log('TotalPrice : ',standProds[x].TotalPrice);  
                    }
                    
                }
            }
            component.set('v.ClistOfProducts',standProds);
        }
    },
    
    addProducts : function(component, event, helper) {
        console.log('addProducts callled');
        
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//14
        component.set("v.showSpinner",true);
        
        try{
            component.set('v.successMsg','');
            let customProds = component.get('v.ClistOfProducts');
            let standProds = component.get('v.selectedListOfProducts');
            let productsToAdd = [];
            console.log('Tesetth ');
            var totalAmount = 0.0;
            var tax = 0.0;
            var subtotal = 0.0;
            var totalTax = 0.0;
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                let poliadd = {};
                //  if(standProds[x].checkSelected){
                poliadd.AwaitingStock = standProds[x].AwaitStock;
                poliadd.demand = standProds[x].demand; 
                poliadd.ItemsinStock = standProds[x].stock;
                poliadd.ERP7__Product__c = standProds[x].prod.Id;
                poliadd.ERP7__Chart_of_Account__c = standProds[x].prod.ERP7__Inventory_Account__c 
                if(standProds[x].prod.ProductCode != null && standProds[x].prod.ProductCode != '' && standProds[x].prod.ProductCode != undefined) poliadd.ERP7__Product__r = { ProductCode : standProds[x].prod.ProductCode };
                poliadd.Name = standProds[x].prod.Name;
                poliadd.ERP7__Cost_Card__c = (standProds[x].selCostCardId != undefined && standProds[x].selCostCardId != null && standProds[x].selCostCardId != '') ? standProds[x].selCostCardId : ''; //added by arshad
                console.log('poliadd.ERP7__Cost_Card__c~>'+poliadd.ERP7__Cost_Card__c);
                poliadd.ERP7__Quantity__c = standProds[x].quantity;
                poliadd.ERP7__Vendor_product_Name__c = (standProds[x].VendorPartNumber == null || standProds[x].VendorPartNumber == '' ||  standProds[x].VendorPartNumber == undefined) ? standProds[x].prod.ERP7__Vendor_product_Name__c : standProds[x].VendorPartNumber;
                poliadd.ERP7__Unit_Price__c = standProds[x].unitPrice;
                poliadd.ERP7__Tax_Rate__c = standProds[x].taxPercent;
                poliadd.ERP7__Tax__c = standProds[x].taxAmount;
                poliadd.ERP7__Total_Price__c = standProds[x].TotalPrice;
                poliadd.ERP7__Description__c = standProds[x].prod.Description;
                poliadd.ERP7__Lead_Time_Days__c = standProds[x].LeadTime; //standProds[x].prod.ERP7__Purchase_Lead_Time_days__c;
                subtotal = subtotal + (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice));
                totalAmount = totalAmount + (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                tax = (poliadd.ERP7__Unit_Price__c/100)*poliadd.ERP7__Tax_Rate__c;
                tax = (tax) * poliadd.ERP7__Quantity__c;
                totalTax = totalTax + tax;
                console.log('poliadd : ',poliadd);
                productsToAdd.push(poliadd); 
                // } 
            }
            
            console.log('Tedwewrsetth ');
            console.log('customProds ',customProds);
            var NameLabel = $A.get('$Label.c.Enter_Name');
            //for(var y in customProds){
            for(var y = 0; y < customProds.length; y++){
                let poliadd = {};
                if(customProds[y].Name != null && customProds[y].Name != undefined && customProds[y].Name != '' && customProds[y].Name != NameLabel){
                    poliadd.Name = customProds[y].Name;
                    poliadd.ERP7__Quantity__c = customProds[y].quantity;
                    poliadd.ERP7__Unit_Price__c = customProds[y].unitPrice;
                    poliadd.ERP7__Tax_Rate__c = customProds[y].taxPercent;
                    poliadd.ERP7__Tax__c = customProds[y].taxAmount;
                    poliadd.ERP7__Total_Price__c = customProds[y].TotalPrice;
                    poliadd.ERP7__Description__c = customProds[y].Description;
                    poliadd.CustomProd = customProds[y].CustomProd;
                    subtotal = subtotal + (parseFloat(customProds[y].quantity) * parseFloat(customProds[y].unitPrice));
                    totalAmount = totalAmount + (parseFloat(customProds[y].quantity) * parseFloat(customProds[y].unitPrice)) + parseFloat(customProds[y].taxAmount);
                    tax = (poliadd.ERP7__Unit_Price__c/100)*poliadd.ERP7__Tax_Rate__c;
                    tax = (tax) * poliadd.ERP7__Quantity__c;
                    totalTax = totalTax + tax;
                    productsToAdd.push(poliadd);
                }
            }
            
            console.log('productsToAdd : ',productsToAdd.length);
            if(productsToAdd.length > 0){
                let polilst = component.get('v.poli');
                console.log('polilst bfr: ',polilst.length);
                if(component.get('v.poli') != null && component.get('v.poli') != undefined) polilst = component.get('v.poli');
                polilst = polilst.concat(productsToAdd);
                console.log('polilst after: ',polilst.length);
                component.set('v.poli',polilst);
                component.set('v.showAddProducts',false);
                component.set('v.TotalAmount',totalAmount);
                component.set("v.PO.ERP7__Total_Amount__c",totalAmount);
                component.set("v.SubTotal",subtotal);
                component.set("v.TotalTax",totalTax);
                
                component.set('v.successMsg',$A.get('$Label.c.Products_added_successfully'));
                window.setTimeout( $A.getCallback(function() {  component.set('v.successMsg',''); }),5000);
            }
            else{
                component.set('v.addProductsMsg',$A.get('$Label.c.Please_select_products_to_add'));
                window.setTimeout( $A.getCallback(function() {  component.set('v.addProductsMsg',''); }), 5000 );
            }
        }
        catch(err){
            console.log('error : ',err);
        }
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");//15
        component.set("v.showSpinner",false);
    },
    
    deleteNewLine : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        console.log('here index deleteNewLine: ',index);
        if(index != null && index != undefined){
            component.set("v.reRenderCustPOli",false);
            console.log('bfr: ',component.get("v.reRenderCustPOli"));
            var custliList;// =[]; 
            custliList=component.get("v.ClistOfProducts");
            console.log('bfr ClistOfProducts: ',component.get("v.ClistOfProducts"));
            custliList.splice(index,1);    
            console.log('coming in here 1',custliList);
            component.set("v.ClistOfProducts",'');
            component.set("v.ClistOfProducts",custliList);
            console.log('coming in here 2');
            component.set("v.reRenderCustPOli",true);
            console.log('aftr ClistOfProducts: ',component.get("v.ClistOfProducts"));
            console.log('aftr: ',component.get("v.reRenderCustPOli"));
            
        }
    },
    
    DeleteRecordAT: function(component, event) {
        var result = confirm("Are you sure?");
        console.log('result : ',result);
        var RecordId = event.getSource().get("v.name");
        console.log('RecordId : ',RecordId);
        var parentId = event.getSource().get("v.title");
        console.log('parentId : ',parentId);
        
        //New code added by Parveez 26/11/23 for deleting attachments on the Clone PO page.
        if(result && (!$A.util.isUndefined(component.get("v.clonePOId")) && !$A.util.isEmpty(component.get("v.clonePOId")))){
            console.log('Inside Clone : ');
            let myArray = component.get("v.uploadedFile");
            let indexToRemove = myArray.findIndex(item => item.Id === RecordId);
            if (indexToRemove > -1) {
                myArray.splice(indexToRemove, 1); 
                component.set("v.uploadedFile", myArray);
            } 
            else { console.error("Attachment not found in the array."); }
        }
        
        if (result && (component.get("v.clonePOId") =='' || component.get("v.clonePOId") == undefined || component.get("v.clonePOId") == null)) {
            console.log('Inside Manage/Create:');
            //window.scrollTo(0, 0);
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
            try{
                var action = component.get("c.DeleteAttachment");
                action.setParams({
                    attachId: RecordId,
                    parentId: parentId,
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        console.log("DeleteRecordAT resp: ", JSON.stringify(response.getReturnValue()));
                        component.set('v.uploadedFile',response.getReturnValue());
                        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }
                    else{
                        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                        var errors = response.getError();
                        console.log("server error in doInit : ", JSON.stringify(errors));
                        component.set("v.exceptionError", errors[0].message);
                    }
                });
                $A.enqueueAction(action);
            }
            catch(err) {
                console.log('Exception : ',err);
            }
        } 
    },
    
    imageError: function(component,event,helper){
        console.log('imageError called');
        event.target.style.display = 'none';
    },   
    
    removeHtmltags : function(component,event,helper){
        console.log('removeHtmltags called');
        var textareaValue = component.find("description").get("v.value");
        var strippedValue = textareaValue.replace(/(<([^>]+)>)/ig,"");
        component.find("description").set("v.value", strippedValue);
    },
    
    NextClicked : function(component,event,helper){
        let selectedRecType = component.get('v.POType');
        //for(var x in selectedRecType){
        for(var x = 0; x < selectedRecType.length; x++){
            if(selectedRecType[x].selected){
                component.set('v.selectedRecType',selectedRecType[x].label);
                component.set("v.PO.RecordTypeId",selectedRecType[x].value);
                component.set("v.PO.RecordType.Name",selectedRecType[x].label);
                component.set("v.PO.RecordType.Id",selectedRecType[x].value);
                break;
            }
        }
        console.log('selectedRecType : ',component.get('v.selectedRecType'));
        if(component.get('v.selectedRecType') == component.get("v.ReturnPOrecType")) component.set('v.returnToVendor',true);
        else if(component.get("v.selectedRecType") == component.get("v.DropShipPOrecType")){
            component.set("v.PO.ERP7__Delivery_Address__c",'');
        }
        component.set("v.showPOType",false);
    },
    
    setSelectedRec : function(component,event,helper){
        console.log('setSelectedRec called');
        var selectedVal = event.getSource().get('v.name');
        console.log('selectedVal : ',selectedVal);
        if(selectedVal != null && selectedVal != '' && selectedVal != undefined){
            let selectedRecType = component.get('v.POType');
            //for(var x in selectedRecType){
            for(var x = 0; x < selectedRecType.length; x++){
                if(selectedRecType[x].label == selectedVal){
                    selectedRecType[x].selected = true;
                }
                else selectedRecType[x].selected = false;
            } 
            component.set('v.POType',selectedRecType);
        }
        
        
    },
    goToRecTypeSelection : function(component,event,helper){
        console.log('goToRecTypeSelection called');
        var MoId = (!$A.util.isUndefined(component.get("v.MOId")) && !$A.util.isEmpty(component.get("v.MOId"))) ? component.get("v.MOId"): component.get("v.MPsMOId");
        var ClonePoId = (!$A.util.isUndefined(component.get("v.clonePOId")) && !$A.util.isEmpty(component.get("v.clonePOId"))) ? component.get("v.clonePOId"): '';
        //Moin added below code to navigate to Accounts Payable on edit po click on 10th january 2024
        if(component.get("v.fromAP")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Accounts_Payable",
                componentAttributes: {
                    "aura:id": "AccountsPayable",
                    "selectedTab":"Purchase_Orders"
                }
            });
            evt.fire();
        }else if(component.get("v.fromProject")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Milestones",
                componentAttributes: {
                    "currentProj" : component.get("v.currentProj"),
                    "projectId" : component.get("v.ProjId"),
                    "newProj" : false
                }
            });
            evt.fire();
        }else if(component.get('v.recordId') != null && component.get('v.recordId') != '' && component.get('v.recordId') != undefined){
            var RecUrl = "/lightning/r/ERP7__PO__c/" + component.get('v.recordId') + "/view";
            window.open(RecUrl,'_parent'); 
        }
            else if(MoId != null && MoId != '' && MoId != undefined){
                $A.createComponent("c:Manufacturing_Orders",{
                    "MO": MoId,
                    "NAV":'mp',
                    "RD":'yes',
                    "allowNav" : true
                },function(newcomponent, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newcomponent);
                    }
                });
            }
                else if(ClonePoId != null && ClonePoId != '' && ClonePoId != undefined){
                    var RecUrl = "/" + component.get("v.clonePOId");
                    sforce.one.navigateToURL(RecUrl);
                }
                    else if(component.get("v.RFPsupplier") != null && component.get("v.RFPsupplier") != undefined && component.get("v.RFPsupplier") != ''){//added by asra for RFP FLOW
                        console.log('back to RMA 1');
                        location.reload();
                    }
                        else {
                            var RecUrl = "/lightning/n/ERP7__Create_Purchase_Orders/";
                            window.open(RecUrl,'_parent'); 
                            //window.location.reload();
                        }
    }
})