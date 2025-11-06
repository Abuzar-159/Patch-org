({
	doInit : function(component, event, helper) {
        component.set('v.IsApprovedShow',$A.get("$Label.c.IsApprovedShow"));
        component.set('v.isTotalAmtShow',$A.get("$Label.c.isTotalAmtShow"));
        var TabularPnl = component.find('autoReconcileBills');
        $A.util.addClass(TabularPnl, 'slds-hide');
        $A.util.removeClass(TabularPnl, 'slds-show');
        //if($A.util.isUndefined(component.get('v.BillList').length>0))
          //  helper.helper_MatchBill(component,event);
        //else
		helper.fetch_Bills(component, event);
        helper.fetchTolerance(component, event, helper);
	},    
    
    SortRecodEventHandler : function(cmp,event,helper){
        //cmp.set("v.showMainSpin",true); 
        //var showTabs=cmp.get("v.showTabs");
        var RecordList = event.getParam("RecordList");    
        cmp.set("v.BillList",RecordList);
        cmp.set("v.BillsSL",RecordList);
    }, 
    
    fetchMoreBills : function(component, event, helper) {
    	var scrollTop = event.currentTarget.scrollTop;
        var offsetHeight = event.currentTarget.offsetHeight;
        var scrollHeight = event.currentTarget.scrollHeight;
        var totalscroll = parseInt(scrollTop + offsetHeight); 
        if(totalscroll===scrollHeight){
            var offset = component.get("v.offSet");
            component.set("v.offSet",parseInt(offset+15));
            helper.showSpinner(component);
            helper.fetch_Bills(component, event);
        }
    },
    Match_Bill : function(component, event, helper) {
        //helper.showSpinner(component);
        helper.helper_MatchBill(component,event);
        //helper.helper_fetch(component,event,helper);
        
    },
    showMorestockInwards : function(component, event, helper){
        component.set("v.startInd",parseInt(component.get("v.startInd")+5));
        component.set("v.EndInd",parseInt(component.get("v.EndInd")+5));
    },
     showlessstockInwards : function(component, event, helper){
        component.set("v.startInd",parseInt(component.get("v.startInd")-5));
        component.set("v.EndInd",parseInt(component.get("v.EndInd")-5));
    },
    select_ALL : function(component, event, helper){
        var selectAll = component.find("selectAll").get("v.value");
        var arrayObj = component.get('v.BillList');
        
        for(var x=0;x<arrayObj.length;x++){
                arrayObj[x].isSelect=selectAll;
            }     
        component.set('v.BillList',arrayObj);
    },
    
    cancel :function(component, event, helper){
          helper.showSpinner(component);
        component.set("v.displayPage", false);
        //component.set('v.BillList',[]);
        component.set("v.offSet",parseInt(0));
        helper.fetch_Bills(component,event);
        var selectPnl = component.find('selectedBills');
        var TabularPnl = component.find('tablurdata');
        component.set("v.invoiceReconcileList",[]);
        component.set("v.stockInwarditems",[]);
        component.set("v.selecteBillList",[]);
        $A.util.addClass(selectPnl,'slds-hide');
        $A.util.addClass(TabularPnl,'slds-show');
        $A.util.removeClass(selectPnl,'slds-show');
        $A.util.removeClass(TabularPnl,'slds-hide');
    },
    
    save:function(component, event, helper){
        console.log('save called createIR_SR');
        
        helper.showSpinner(component);
        //component.set("v.displayPage", false);
        var billItem = component.get('v.BillList');
        var SelectedBillItems = component.get("v.SelectedBillItems");
        var invoiceReconcileList = component.get("v.invoiceReconcileList");
        var serviceReconcileList = component.get("v.serviceReconcileList");
        // var objt = SelectedBillItems[0];
        //alert(invoiceReconcileList[0].ERP7__Bill__r.Name)
        for(var y in SelectedBillItems){
            //('y '+y+' value of y '+SelectedBillItems[y]);
        }
        
        for(var a=0;a<invoiceReconcileList.length;a++){
            var billId = invoiceReconcileList[a].ERP7__Bill_Line_Item__c;
            if(invoiceReconcileList[a].ERP7__Quantity__c < SelectedBillItems[billId].ERP7__Quantity__c) 
                SelectedBillItems[billId].ERP7__Quantity__c -= invoiceReconcileList[a].ERP7__Quantity__c; 
            else
                invoiceReconcileList[a].ERP7__Quantity__c = SelectedBillItems[billId].ERP7__Quantity__c;
            
        }
        
        for(var a=0;a<serviceReconcileList.length;a++){
            var billId = serviceReconcileList[a].ERP7__Bill_Line_Item__c;
            if(serviceReconcileList[a].ERP7__Quantity__c < SelectedBillItems[billId].ERP7__Quantity__c) 
                SelectedBillItems[billId].ERP7__Quantity__c -= serviceReconcileList[a].ERP7__Quantity__c; 
            else
                serviceReconcileList[a].ERP7__Quantity__c = SelectedBillItems[billId].ERP7__Quantity__c;
        }
        
        console.log('invoiceReconcileList~>',JSON.stringify(invoiceReconcileList));        
        console.log('serviceReconcileList~>',JSON.stringify(serviceReconcileList));   
        
        var saveAction = component.get("c.createIR_SR");
        saveAction.setParams({"IRList":JSON.stringify(invoiceReconcileList),"SRList":JSON.stringify(serviceReconcileList)}); 
        saveAction.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.invoiceReconcileList",[]);
                component.set("v.serviceReconcileList",[]);
                component.set("v.stockInwarditems",[]);
                var arrayObj = component.get('v.BillList');
                var selectedItems =[];
                var selectedItemIds =[];
                for(var x=0;x<arrayObj.length;x++){
                    if(arrayObj[x].isSelect){
                        selectedItems.push(arrayObj[x]);
                        selectedItemIds.push(arrayObj[x].Id);
                    }     
                }
                var lineitems = component.get("c.getBillItems");
                lineitems.setParams({"BillId":selectedItemIds.toString()});
                lineitems.setCallback(this,function(response){
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        var items = response.getReturnValue();
                        
                        var custs = [];
                        for(var x in items){
                            for(var i =0;i<selectedItems.length;i++)
                                if(selectedItems[i].Id === x){
                                    custs.push({value:items[x], key:selectedItems[i]});
                                    break;
                                }
                        } 
                        component.set("v.selecteBillList",custs);
                        if(custs.length <= 0){
                            helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.PH_MatchBill_Successfully_Matched_the_Bill'));
                            helper.matchBill(component);
                            /*setTimeout(
                        $A.getCallback(function() {
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:Accounts_Payable",
                                componentAttributes: {
                                    "selectedTab" : 'Bills',
                                    "setSearch" : billItem[0].Name
                                }
                            });
                            evt.fire();
                            
                        }), 3000
					);*/
                        }
                        helper.hideSpinner(component);
                    }
                });
                $A.enqueueAction(lineitems);
                
            }
            else{
                helper.hideSpinner(component);
                var errors = response.getError();
                console.log("server error : ", errors);
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',errors[0].message);
            }   
        }); 
        $A.enqueueAction(saveAction);
    },
    
    searchStockInWard : function(component, event, helper) {
        console.log('searchStockInWard called');
        
        var SelectedBillItems = component.get("v.SelectedBillItems");
        if(SelectedBillItems === null) SelectedBillItems = {};
        helper.showSpinner(component);
        component.set("v.TotalSelected",0.00);
        var recordId = event.getSource().get("v.name");
        var record_Id = event.getSource().get("v.value"); //eventobj.getElement().parentElement.getAttribute("data-recordId");
       
        var array_Objects = component.get("v.selecteBillList");
        var selectedObj = '';
        for(var  y in array_Objects){
            if(array_Objects[y].key.Id === record_Id){
                var arrayObjects = array_Objects[y].value;
                for(var x=0;x<arrayObjects.length;x++){
                    if(arrayObjects[x].Id === recordId){
                        var obj = {};
                        selectedObj = arrayObjects[x];
						 if(!(recordId in SelectedBillItems)){
                            SelectedBillItems[recordId] = selectedObj;
                            //SelectedBillItems.push(obj);
                        }
                        break;
                    }
                }
                break;
            } 
        }
        
        component.set("v.SelectedItem",selectedObj);
        component.set("v.SelectedBillItems",SelectedBillItems);
        var stockInwardAction = component.get('c.getStockInWardLineItems');
        
        stockInwardAction.setParams({"BillItem":JSON.stringify(selectedObj)});
        
        stockInwardAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('getStockInWardLineItems success ');
                var objArray = response.getReturnValue();
                var selObjMap = component.get("v.stockInwarditems");
                var newobjMAp = [];
                for(var i=0;i<objArray.length;i++){
                    var Qty = (parseFloat(objArray[i].ERP7__Quantity__c) > parseFloat(objArray[i].ERP7__Reconciled_Quantity__c))?parseFloat(objArray[i].ERP7__Quantity__c)-parseFloat(objArray[i].ERP7__Reconciled_Quantity__c):parseFloat(objArray[i].ERP7__Reconciled_Quantity__c)-parseFloat(objArray[i].ERP7__Quantity__c);
                    if(Qty>0){
                        objArray[i].ERP7__Quantity__c = Qty;
                        objArray[i].isSelect = false;  
                        objArray[i].disabled = false;  
                        objArray[i].varianceExists = false;
                        newobjMAp.push(objArray[i]);
                    }
                }
                
                selObjMap.push({ value:newobjMAp, key:selectedObj, selectAll: false });  //changed by Arshad 23 Aug 2023
                component.set("v.Selected",false); //added by Arshad 23 Aug 2023
                
                component.set("v.stockInwarditems",selObjMap);
                helper.hideSpinner(component);
            }else{
                var errors = response.getError();
                console.log("server error in getStockInWardLineItems : ", JSON.stringify(errors));
            }            
        });
        
        var flag=true;
        if(selectedObj){
            var sel_ObjMap = component.get("v.stockInwarditems");
            if(sel_ObjMap.length>0)
                for(var x=0;x<sel_ObjMap.length;x++){
                    if(sel_ObjMap[x].key.Id === selectedObj.Id){
                        
                        //added by Arshad 23 Aug 2023
                        if(sel_ObjMap[x].selectAll) component.set("v.Selected",true);
                        else component.set("v.Selected",false);
                        
                        helper.hideSpinner(component);
                        flag=false;
                        break;
                    }
                }
        }
        
        if(flag) $A.enqueueAction(stockInwardAction);
        
    },
    
    validationcheck : function(component,event,helper){
        console.log('validationcheck called');
        
        var TotalQtyMap = 0;//component.get("v.TotalSelected");
        var invoiceReconcileList = component.get("v.invoiceReconcileList");
        var serviceReconcileList = component.get("v.serviceReconcileList");
        var invoiceReconcile = {};// component.get("v.invoiceReconcile");
        var eventobj = event.getSource();
        var inwardLi = eventobj.get("v.value");
        var billItem = component.get("v.SelectedItem");
        var selObjMap = component.get("v.stockInwarditems");
        component.set("v.invoiceReconcileList",invoiceReconcileList);
        for(var  y in selObjMap)
            if(selObjMap[y].key.Id === billItem.Id){
                var sel_ObjMap = selObjMap[y].value;
                var flag = false;
                if(sel_ObjMap.length==1){
                    for(var x=0;x<sel_ObjMap.length;x++){
                        if(sel_ObjMap[x].Id === inwardLi){
                            if(sel_ObjMap[x].isSelect){
                                if(sel_ObjMap[x].ERP7__Quantity__c === billItem.ERP7__Quantity__c){
                                    flag = true;  
                                }
                                
                                var DebitNoteUnitPrice = 0.00;
                                if(billItem.ERP7__Debit_Line_Item_Unit_Price__c!=null && billItem.ERP7__Debit_Line_Item_Unit_Price__c!=undefined && billItem.ERP7__Debit_Line_Item_Unit_Price__c!='') DebitNoteUnitPrice = billItem.ERP7__Debit_Line_Item_Unit_Price__c;
                                var unitPr = sel_ObjMap[x].ERP7__Unit_Price__c;
                                var amountB = billItem.ERP7__Amount__c;
                                var siQty = sel_ObjMap[x].ERP7__Quantity__c;
                                var biQty = billItem.ERP7__Quantity__c;
                                if(sel_ObjMap[x].ERP7__Quantity__c == null) {
                                    sel_ObjMap[x].varianceExists = true; 
                                }//|| unitPr != amountB
                                if(sel_ObjMap[x].ERP7__Unit_Price__c != billItem.ERP7__Amount__c && !sel_ObjMap[x].varianceExists && billItem.ERP7__Amount__c>sel_ObjMap[x].ERP7__Unit_Price__c){//Moin added this on 15th july 2023
                                    var amtD = ((((billItem.ERP7__Amount__c-DebitNoteUnitPrice)/sel_ObjMap[x].ERP7__Unit_Price__c)*100)-100).toFixed(2);
                                    if(amtD>component.get("v.unitPrTolerance")){
                                        sel_ObjMap[x].varianceExists = true;
                                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.UnitPriceMismatch'));
                                    }
                                    if(!sel_ObjMap[x].varianceExists && ((billItem.ERP7__Amount__c-DebitNoteUnitPrice)<sel_ObjMap[x].ERP7__Unit_Price__c)){
                                        sel_ObjMap[x].varianceExists = true;
                                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.UnitPriceMismatch'));
                                    }
                                }
                                if(sel_ObjMap[x].ERP7__Quantity__c != billItem.ERP7__Quantity__c && !sel_ObjMap[x].varianceExists && billItem.ERP7__Quantity__c>sel_ObjMap[x].ERP7__Quantity__c){//Moin added this on 02nd february 2023  && billItem.ERP7__Quantity__c>sel_ObjMap[x].ERP7__Quantity__c
                                    var amtD = (((billItem.ERP7__Quantity__c/sel_ObjMap[x].ERP7__Quantity__c)*100)-100).toFixed(2);
                                    if(amtD>component.get("v.qtyTolerance")){
                                        sel_ObjMap[x].varianceExists = true;
                                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.QuanityMismatch'));
                                    }
                                    if(!sel_ObjMap[x].varianceExists && (billItem.ERP7__Quantity__c<sel_ObjMap[x].ERP7__Quantity__c)){
                                        sel_ObjMap[x].varianceExists = true;
                                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.QuanityMismatch'));
                                    }
                                }
                                if(!sel_ObjMap[x].varianceExists){ //|| (unitPr === amountB)//added or condition shhh// &&(unitPr === amountB)
                                    invoiceReconcile.ERP7__Purchase_Orders__c= billItem.ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c;
                                    invoiceReconcile.ERP7__Price__c = sel_ObjMap[x].ERP7__Unit_Price__c;
                                    invoiceReconcile.ERP7__Bill_Line_Item__c = billItem.Id;
                                    invoiceReconcile.ERP7__Product__c = sel_ObjMap[x].ERP7__Product__c;
                                    invoiceReconcile.ERP7__Quantity__c = sel_ObjMap[x].ERP7__Quantity__c;//(sel_ObjMap[x].ERP7__Quantity__c > billItem.ERP7__Quantity__c)? billItem.ERP7__Quantity__c:sel_ObjMap[x].ERP7__Quantity__c;
                                    TotalQtyMap = parseFloat(TotalQtyMap+invoiceReconcile.ERP7__Quantity__c);
                                    if(billItem.ERP7__Product__r.ERP7__Item_Type__c != 'Service'){
                                        invoiceReconcile.ERP7__Stock_Inward_Line_Item__c = sel_ObjMap[x].Id;
                                        console.log('inhere ERP7__Inventory_Reconciliation__c~>'+sel_ObjMap[x].ERP7__Inventory_Reconciliation__c);
                                        if(sel_ObjMap[x].ERP7__Inventory_Reconciliation__c != 'On Hold' && sel_ObjMap[x].ERP7__Inventory_Reconciliation__c != 'Rejected'){
                                            console.log('arshad adding to invoiceReconcileList here1  if only one billi');
                                            invoiceReconcileList.push(invoiceReconcile);
                                        }else{
                                            //throw error here for ERP7__Inventory_Reconciliation__c
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.MatchBillStockInwardInventoryReconciliationException'));
                                        } 
                                    }
                                    else{
                                        invoiceReconcile.ERP7__Work_Order_Line_Items__c = sel_ObjMap[x].Id; 
                                        serviceReconcileList.push(invoiceReconcile);
                                    }
                                }
                            }
                            else{
                                sel_ObjMap[x].varianceExists = false;
                                if(billItem.ERP7__Product__r.ERP7__Item_Type__c != 'Service'){
                                    for(var k=0;k<invoiceReconcileList.length;k++){
                                        if(invoiceReconcileList[k].ERP7__Stock_Inward_Line_Item__c === sel_ObjMap[x].Id){
                                            TotalQtyMap -= invoiceReconcileList[k].ERP7__Quantity__c;
                                            console.log('arshad removing to invoiceReconcileList here1 if only one billi');
                                            invoiceReconcileList.splice(k,1);
                                        }
                                    }
                                }
                                else{
                                    for(var k=0;k<serviceReconcileList.length;k++){
                                        if(serviceReconcileList[k].ERP7__Work_Order_Line_Items__c === sel_ObjMap[x].Id){
                                            TotalQtyMap = parseFloat(TotalQtyMap-serviceReconcileList[k].ERP7__Quantity__c);
                                            serviceReconcileList.splice(k,1);
                                        }
                                    }
                                }
                            }
                            break;
                        }else
                            if(flag && !sel_ObjMap[x].varianceExists && !sel_ObjMap[x].isSelect)sel_ObjMap[x].disabled = true; 
                        
                    }
                }
                else{
                    var unitPr = 0;
                    var siQty = 0;
                    var UnitvarianceExist = true;
                    var QTYvarianceExist = true;                  
                    for(var x=0;x<sel_ObjMap.length;x++){
                        //if(sel_ObjMap[x].Id === inwardLi){
                        if(sel_ObjMap[x].isSelect){
                            /*if(sel_ObjMap[x].ERP7__Quantity__c === billItem.ERP7__Quantity__c){
                                    flag = true;  
                                }*/
                            
                            unitPr = unitPr + sel_ObjMap[x].ERP7__Unit_Price__c;
                            var amountB = billItem.ERP7__Amount__c;
                            siQty = siQty + sel_ObjMap[x].ERP7__Quantity__c;
                            var biQty = billItem.ERP7__Quantity__c;
                            var DebitNoteUnitPrice = 0.00;
                            if(billItem.ERP7__Debit_Line_Item_Unit_Price__c!=null && billItem.ERP7__Debit_Line_Item_Unit_Price__c!=undefined && billItem.ERP7__Debit_Line_Item_Unit_Price__c!='') DebitNoteUnitPrice = billItem.ERP7__Debit_Line_Item_Unit_Price__c;
                            if(sel_ObjMap[x].ERP7__Quantity__c == null) {
                                sel_ObjMap[x].varianceExists = true; 
                            }
                            //alert('Unit'+unitPr);
                            //alert('Bill'+billItem.ERP7__Amount__c);
                            /*if(unitPr != billItem.ERP7__Amount__c && !sel_ObjMap[x].varianceExists && billItem.ERP7__Amount__c>unitPr){
                                    var amtD = (((billItem.ERP7__Amount__c/unitPr)*100)-100).toFixed(2);
                                    if(amtD>component.get("v.unitPrTolerance")){
                                        sel_ObjMap[x].varianceExists = true;
                                        UnitvarianceExist = true
                                        //helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Their is some unit price mismatch with the bill please adjust the logistics and po');
                                    }else{
                                        UnitvarianceExist = false;
                                    }
                                }else if(unitPr == billItem.ERP7__Amount__c){
                                    UnitvarianceExist = false;
                                }*/
                            if(siQty != billItem.ERP7__Quantity__c && billItem.ERP7__Quantity__c>siQty){//&& !UnitvarianceExist//Moin added is on 02nd february 2024 for partial matching && billItem.ERP7__Quantity__c>siQty
                                var amtD = (((billItem.ERP7__Quantity__c/siQty)*100)-100).toFixed(2);
                                if(amtD>component.get("v.qtyTolerance")){
                                    sel_ObjMap[x].varianceExists = true;
                                    QTYvarianceExist = true;
                                    //helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Their is some quantity mismatch with the bill  please adjust the logistics and po');
                                }else{
                                    QTYvarianceExist = false;
                                }
                            }
                            else if((siQty == billItem.ERP7__Quantity__c) || (billItem.ERP7__Quantity__c<siQty)){
                                QTYvarianceExist = false;
                            }
                            
                        }
                        else{
                            sel_ObjMap[x].varianceExists = false;
                            /*if(billItem.ERP7__Product__r.ERP7__Item_Type__c != 'Service'){
                                for(var k=0;k<invoiceReconcileList.length;k++){
                                    if(invoiceReconcileList[k].ERP7__Stock_Inward_Line_Item__c === sel_ObjMap[x].Id){
                                        TotalQtyMap -= invoiceReconcileList[k].ERP7__Quantity__c;
                                        invoiceReconcileList.splice(k,1);
                                    }
                                }
                            }else{
                                for(var k=0;k<serviceReconcileList.length;k++){
                                    if(serviceReconcileList[k].ERP7__Work_Order_Line_Items__c === sel_ObjMap[x].Id){
                                        TotalQtyMap = parseFloat(TotalQtyMap-serviceReconcileList[k].ERP7__Quantity__c);
                                        serviceReconcileList.splice(k,1);
                                    }
                                }
                            }*/
                        }
                    }
                    
                    TotalQtyMap = 0;
                    invoiceReconcile = {};
                    //invoiceReconcileList = [];
                    if(!QTYvarianceExist ){ //&& !UnitvarianceExist
                        for(var x=0;x<sel_ObjMap.length;x++){
                            if(sel_ObjMap[x].isSelect){
                                invoiceReconcile = {};
                                sel_ObjMap[x].varianceExists = false;//|| (unitPr === amountB)//added or condition shhh// &&(unitPr === amountB)
                                invoiceReconcile.ERP7__Purchase_Orders__c= billItem.ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c;
                                invoiceReconcile.ERP7__Price__c = sel_ObjMap[x].ERP7__Unit_Price__c;
                                invoiceReconcile.ERP7__Bill_Line_Item__c = billItem.Id;
                                invoiceReconcile.ERP7__Product__c = sel_ObjMap[x].ERP7__Product__c;
                                invoiceReconcile.ERP7__Quantity__c = sel_ObjMap[x].ERP7__Quantity__c;//(sel_ObjMap[x].ERP7__Quantity__c > billItem.ERP7__Quantity__c)? billItem.ERP7__Quantity__c:sel_ObjMap[x].ERP7__Quantity__c;
                                TotalQtyMap = parseFloat(TotalQtyMap+invoiceReconcile.ERP7__Quantity__c);
                                if(billItem.ERP7__Product__r.ERP7__Item_Type__c != 'Service'){
                                    invoiceReconcile.ERP7__Stock_Inward_Line_Item__c = sel_ObjMap[x].Id;
                                    console.log('inhere ERP7__Inventory_Reconciliation__c~>'+sel_ObjMap[x].ERP7__Inventory_Reconciliation__c);
                                    if(sel_ObjMap[x].ERP7__Inventory_Reconciliation__c != 'On Hold' && sel_ObjMap[x].ERP7__Inventory_Reconciliation__c != 'Rejected'){
                                        console.log('arshad adding to invoiceReconcileList here2 if more than one billi');
                                        invoiceReconcileList.push(invoiceReconcile);
                                    }else{
                                        //throw error here for ERP7__Inventory_Reconciliation__c
                                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.MatchBillStockInwardInventoryReconciliationException'));
                                    }
                                }else{
                                    invoiceReconcile. ERP7__Work_Order_Line_Items__c = sel_ObjMap[x].Id; 
                                    serviceReconcileList.push(invoiceReconcile);
                                }
                            }
                        }
                    }
                    
                }
                selObjMap[y].value = sel_ObjMap;
                break;   
            } 
        
        component.set("v.TotalSelected",TotalQtyMap);
        component.set("v.stockInwarditems",selObjMap);
        
        console.log('validationcheck invoiceReconcileList~>'+JSON.stringify(invoiceReconcileList));
        console.log('validationcheck serviceReconcileList~>'+JSON.stringify(serviceReconcileList));
        
        if(billItem.ERP7__Product__r.ERP7__Item_Type__c != 'Service')
            component.set("v.invoiceReconcileList",invoiceReconcileList);
        else
            component.set("v.serviceReconcileList",serviceReconcileList);
        
    },
    
    hidepopup : function(component,event,helper){
        var eventobj= event.currentTarget;
        var cmp =  component.find("myPopup");
        $A.util.removeClass( cmp, 'slds-show');
    },
    
    showpopup : function(component,event,helper){
        $(document).ready(function(){
            $('[data-toggle="popover"]').popover({ trigger: 'hover'});
        });//
    },
    
    fetchBillsWithCond: function(component,event,helper){
        component.set("v.offSet",parseInt(0));
        component.set('v.BillList',[]);
        var cond = ''; 
        if(component.get("v.SelectedVendorId"))
            cond = ' AND ERP7__Vendor__c =\''+component.get("v.SelectedVendorId")+'\'';
        if(component.get("v.POID"))
            cond = ' AND ERP7__Purchase_Order__c =\''+component.get("v.POID")+'\'';
        if(component.get("v.BillId"))
            cond = ' AND Id = \''+component.get("v.BillId")+'\'';
        if(component.get("v.dueDate"))
            cond = ' AND ERP7__Due_Date__c  = '+component.get("v.dueDate");
        if(component.get("v.SelectedVendorId") && component.get("v.POID"))            
            cond = ' AND ERP7__Vendor__c =\''+component.get("v.SelectedVendorId")+'\' AND ERP7__Purchase_Order__c =\''+component.get("v.POID")+'\'';
        if(component.get("v.SelectedVendorId") && component.get("v.BillId"))
            cond = ' WHERE Id = \''+component.get("v.BillId")+'\' AND ERP7__Vendor__c =\''+component.get("v.SelectedVendorId")+'\'';
        if(component.get("v.BillId") && component.get("v.POID"))            
            cond = ' AND Id = \''+component.get("v.BillId")+'\' AND ERP7__Purchase_Order__c =\''+component.get("v.POID")+'\'';
        if(component.get("v.SelectedVendorId") && component.get("v.POID") && component.get("v.BillId"))
            cond = ' AND Id = \''+component.get("v.BillId")+'\' AND ERP7__Vendor__c =\''+component.get("v.SelectedVendorId")+'\' AND ERP7__Purchase_Order__c =\''+component.get("v.POID")+'\'';
        
        var filterCond = component.set("v.filterCond",cond);
        helper.fetch_Bills(component,event);
    },
    
    handleComponentEvent2 : function(component,event,helper){
        var searchString = event.getParam("searchString");
        if(searchString.length>1){
            var billList = component.get('v.BillsSL'); //  BillList
            billList = billList.filter(function (el) {
                return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
            });
            var currList=[];var count=0;var limit=parseInt(component.get("v.show"));
            for(var inv in billList){
                if(count<limit){
                    currList.push(billList[count]);
                    count=count+1;
                }else break;
            }
            component.set("v.BillList",currList);
        }else{
            // helper.fetch_Bills(component,event);
        }
    },
    
    getSortedRecords : function(component,event,helper){
        component.set("v.OrderBy",event.currentTarget.id); 
        // component.set("v.Order",event.currentTarget.dataset.service); 
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');   
        
        helper.fetch_Bills(component,event); 
    },
    
    selectAll : function(component,event,helper){
        console.log('selectAll called');
        
        var TotalQtyMap = component.get("v.TotalSelected");
        var invoiceReconcileList = component.get("v.invoiceReconcileList");//[];//component.get("v.invoiceReconcileList");
        var serviceReconcileList = component.get("v.serviceReconcileList");//[];//component.get("v.serviceReconcileList");
        var invoiceReconcile = {};// component.get("v.invoiceReconcile");
        var billItem = component.get("v.SelectedItem");
        var selObjMap = component.get("v.stockInwarditems");
        var unitPr = 0;
        var siQty = 0;
        var UnitvarianceExist = true;
        var QTYvarianceExist = true;
        for(var  y in selObjMap){
            if(selObjMap[y].key.Id === billItem.Id){
                var sel_ObjMap = selObjMap[y].value;
                for(var x=0;x<sel_ObjMap.length;x++){
                    if(component.get("v.Selected")){                        
                        unitPr = unitPr + sel_ObjMap[x].ERP7__Unit_Price__c;
                        var amountB = billItem.ERP7__Amount__c;
                        siQty = siQty + sel_ObjMap[x].ERP7__Quantity__c;
                        var biQty = billItem.ERP7__Quantity__c;
                        if(sel_ObjMap[x].ERP7__Quantity__c == null) {
                            sel_ObjMap[x].varianceExists = true; 
                        }
                        if(siQty != billItem.ERP7__Quantity__c && billItem.ERP7__Quantity__c>siQty){//Moin added is on 02nd february 2024 for partial matching && billItem.ERP7__Quantity__c>siQty
                            var amtD = (((billItem.ERP7__Quantity__c/siQty)*100)-100).toFixed(2);
                            if(amtD>component.get("v.qtyTolerance")){
                                sel_ObjMap[x].varianceExists = true;
                                QTYvarianceExist = true;
                            }else{
                                QTYvarianceExist = false;
                                sel_ObjMap[x].varianceExists = false;
                            }
                        }
                        else if(siQty == billItem.ERP7__Quantity__c || billItem.ERP7__Quantity__c<siQty){//Moin added is on 02nd february 2024 for partial matching
                            QTYvarianceExist = false;
                            sel_ObjMap[x].varianceExists = false;
                        }
                        
                        
                        var DebitNoteUnitPrice = 0.00;
                        if(billItem.ERP7__Debit_Line_Item_Unit_Price__c!=null && billItem.ERP7__Debit_Line_Item_Unit_Price__c!=undefined && billItem.ERP7__Debit_Line_Item_Unit_Price__c!='') DebitNoteUnitPrice = billItem.ERP7__Debit_Line_Item_Unit_Price__c;
                        if(sel_ObjMap[x].ERP7__Unit_Price__c != billItem.ERP7__Amount__c && !sel_ObjMap[x].varianceExists && billItem.ERP7__Amount__c>sel_ObjMap[x].ERP7__Unit_Price__c && billItem.ERP7__Quantity__c>=siQty){//Moin added is on 02nd february 2024 for partial matching && billItem.ERP7__Quantity__c>siQty
                            var amtD = ((((billItem.ERP7__Amount__c-DebitNoteUnitPrice)/sel_ObjMap[x].ERP7__Unit_Price__c)*100)-100).toFixed(2);
                            if(amtD>component.get("v.unitPrTolerance")){
                                sel_ObjMap[x].varianceExists = true;
                                //helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','There is Some Unit Price Mismatch On The Bill. Please adjust the Logistics and Purchase Order.');
                            }
                            if(!sel_ObjMap[x].varianceExists && ((billItem.ERP7__Amount__c-DebitNoteUnitPrice)<sel_ObjMap[x].ERP7__Unit_Price__c)){
                                sel_ObjMap[x].varianceExists = true;
                                //helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','There is Some Unit Price Mismatch On The Bill. Please adjust the Bill or Purchase Order.');
                            }
                        }
                    }
                    else{      
                        
                        //component.set("v.invoiceReconcileList", []);//added this on 09th june 2023
                        //component.set("v.serviceReconcileList", []);//added this on 09th june 2023
                        //QTYvarianceExist = true;
                        sel_ObjMap[x].varianceExists = false;
                        
                        //added by Arshad 23 Aug 2023
                        sel_ObjMap[x].isSelect = false;  
                        sel_ObjMap[x].disabled = false;  
                        
                        //invoiceReconcileList = component.get("v.invoiceReconcileList");
                        //serviceReconcileList = component.get("v.serviceReconcileList");
                        TotalQtyMap = 0;
                        //Moin coomented below code and added above one as they was an issue on unselect all
                        if(billItem.ERP7__Product__r.ERP7__Item_Type__c != 'Service'){
                            for(var k=0;k<invoiceReconcileList.length;k++){
                                if(invoiceReconcileList[k].ERP7__Bill_Line_Item__c === billItem.Id){
                                    TotalQtyMap -= invoiceReconcileList[k].ERP7__Quantity__c;
                                    invoiceReconcileList.splice(k,1);
                                }
                            }
                        }else{
                            for(var k=0;k<serviceReconcileList.length;k++){
                                if(serviceReconcileList[k].ERP7__Work_Order_Line_Items__c === sel_ObjMap[x].Id){
                                    TotalQtyMap = parseFloat(TotalQtyMap-serviceReconcileList[k].ERP7__Quantity__c);
                                    serviceReconcileList.splice(k,1);
                                }
                            }
                        }
                    }
                    
                    if(!sel_ObjMap[x].varianceExists && component.get("v.Selected")){
                        //Moin added this below code on 15th March 2024 to divide the quantity of stock inward with bill quantity
                        var stockinwardSumQty = 0;
                        for(var x=0;x<sel_ObjMap.length;x++){
                            stockinwardSumQty = stockinwardSumQty + sel_ObjMap[x].ERP7__Quantity__c;
                        }
                        console.log('inward qty-->' + stockinwardSumQty);
                        console.log('bill quantity-->' + billItem.ERP7__Quantity__c);
                        var sbillvariance = parseFloat(billItem.ERP7__Quantity__c / stockinwardSumQty);
                        console.log('sbillvariance-->' + sbillvariance.toFixed(2));
                        for(var x=0;x<sel_ObjMap.length;x++){
                            invoiceReconcile = {};
                            sel_ObjMap[x].varianceExists = false;//|| (unitPr === amountB)//added or condition shhh// &&(unitPr === amountB)
                            invoiceReconcile.ERP7__Purchase_Orders__c= billItem.ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c;
                            invoiceReconcile.ERP7__Price__c = sel_ObjMap[x].ERP7__Unit_Price__c;
                            invoiceReconcile.ERP7__Bill_Line_Item__c = billItem.Id;
                            invoiceReconcile.ERP7__Product__c = sel_ObjMap[x].ERP7__Product__c;
                            invoiceReconcile.ERP7__Quantity__c = sel_ObjMap[x].ERP7__Quantity__c * sbillvariance.toFixed(2);//(sel_ObjMap[x].ERP7__Quantity__c > billItem.ERP7__Quantity__c)? billItem.ERP7__Quantity__c:sel_ObjMap[x].ERP7__Quantity__c;
                            TotalQtyMap = parseFloat(TotalQtyMap+invoiceReconcile.ERP7__Quantity__c);
                            if(billItem.ERP7__Product__r.ERP7__Item_Type__c != 'Service'){
                                invoiceReconcile.ERP7__Stock_Inward_Line_Item__c = sel_ObjMap[x].Id;
                                console.log('inhere ERP7__Inventory_Reconciliation__c~>'+sel_ObjMap[x].ERP7__Inventory_Reconciliation__c);
                                if(sel_ObjMap[x].ERP7__Inventory_Reconciliation__c != 'On Hold' && sel_ObjMap[x].ERP7__Inventory_Reconciliation__c != 'Rejected'){
                                    invoiceReconcileList.push(invoiceReconcile);
                                }else{
                                    //throw error here for ERP7__Inventory_Reconciliation__c
                                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.MatchBillStockInwardInventoryReconciliationException'));
                                }
                            }else{
                                invoiceReconcile. ERP7__Work_Order_Line_Items__c = sel_ObjMap[x].Id; 
                                serviceReconcileList.push(invoiceReconcile);
                            }
                        }
                    }
                }
                
                selObjMap[y].value = sel_ObjMap;
                
                //added by Arshad 23 Aug 2023
                if(component.get("v.Selected")){
                    selObjMap[y].selectAll = true; 
                }else{
                    selObjMap[y].selectAll = false;
                }
                
                break;  
            }
        }
        
        if(invoiceReconcileList.length<=0 && component.get("v.Selected")){
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.QtyUnitMismatch'));
        }
        component.set("v.TotalSelected",TotalQtyMap);
        component.set("v.stockInwarditems",selObjMap);
        
        console.log('selectAll invoiceReconcileList~>'+JSON.stringify(invoiceReconcileList));
        console.log('selectAll serviceReconcileList~>'+JSON.stringify(serviceReconcileList));
        
        if(billItem.ERP7__Product__r.ERP7__Item_Type__c != 'Service')
            component.set("v.invoiceReconcileList",invoiceReconcileList);
        else
            component.set("v.serviceReconcileList",serviceReconcileList);
    },
    
    fetchReconciliationRecords : function(component,event,helper){
        var arrayObj = component.get('v.BillList');
        var selectedItems =[];
        var selectedItemIds =[];
        for(var x=0;x<arrayObj.length;x++){
            if(arrayObj[x].isSelect){
                selectedItems.push(arrayObj[x]);
                selectedItemIds.push(arrayObj[x].Id);
            }     
        }
        var selectPnl = component.find('autoReconcileBills');
        var TabularPnl = component.find('selectedBills');
        
        var lineitems = component.get("c.getAutoMatchItems");
        lineitems.setParams({"BillId":selectedItemIds.toString()});
        lineitems.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue()!=null && response.getReturnValue().length>0){
                    component.set("v.autoInvReconcileList",response.getReturnValue());
                }else{
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','No matching items found.');
                }
                $A.util.addClass(selectPnl, 'slds-show');
                $A.util.addClass(TabularPnl, 'slds-hide');
                $A.util.removeClass(selectPnl, 'slds-hide');
                $A.util.removeClass(TabularPnl, 'slds-show');
                helper.hideSpinner(component);
            }
        });
        $A.enqueueAction(lineitems);
    },
    
    delete_Item : function(component, event, helper) {
        var billList = component.get("v.autoInvReconcileList");
        billList.splice(event.getSource().get("v.name"),1);
        component.set("v.autoInvReconcileList",billList);
    },
    
    closeAuto : function(component, event, helper) {
        var selectPnl = component.find('selectedBills');
        var TabularPnl = component.find('autoReconcileBills');
        $A.util.addClass(selectPnl, 'slds-show');
        $A.util.addClass(TabularPnl, 'slds-hide');
        $A.util.removeClass(selectPnl, 'slds-hide');
        $A.util.removeClass(TabularPnl, 'slds-show');
    },
    
    saveAutoReconcile : function(component, event, helper){
        helper.showSpinner(component);
        var invli=component.get("v.autoInvReconcileList");
        var action=component.get("c.processAutoMatch");
        action.setParams({
            IRList:JSON.stringify(invli)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(!response.getReturnValue()){
                    helper.showToast('Error!','error',JSON.stringify(response.getReturnValue()));
                    helper.hideSpinner(component);
                }else{
                    var arrayObj = component.get('v.BillList');
                    var selectedItems =[];
                    var selectedItemIds =[];
                    for(var x=0;x<arrayObj.length;x++){
                        if(arrayObj[x].isSelect){
                            selectedItems.push(arrayObj[x]);
                            selectedItemIds.push(arrayObj[x].Id);
                        }     
                    }
                    var lineitems = component.get("c.getBillItems");
                    lineitems.setParams({"BillId":selectedItemIds.toString()});
                    lineitems.setCallback(this,function(response){
                        var state = response.getState();
                        if(state === 'SUCCESS'){
                            var items = response.getReturnValue();
                            
                            var custs = [];
                            for(var x in items){
                                for(var i =0;i<selectedItems.length;i++)
                                    if(selectedItems[i].Id === x){
                                        custs.push({value:items[x], key:selectedItems[i]});
                                        break;
                                    }
                            } 
                            component.set("v.selecteBillList",custs);
                            if(custs.length <= 0){
                                helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.PH_MatchBill_Successfully_Matched_the_Bill'));
                                helper.matchBill(component);
                            }else{
                                helper.showToast('Success!','success','Auto Matched Successfully');
                                var selectPnl = component.find('selectedBills');
                                var TabularPnl = component.find('autoReconcileBills');
                                $A.util.addClass(selectPnl, 'slds-show');
                                $A.util.addClass(TabularPnl, 'slds-hide');
                                $A.util.removeClass(selectPnl, 'slds-hide');
                                $A.util.removeClass(TabularPnl, 'slds-show');
                            }
                            helper.hideSpinner(component);
                        }
                    });
                    $A.enqueueAction(lineitems);
                    helper.hideSpinner(component);
                }
            }
        });
        $A.enqueueAction(action);
    },
 
})