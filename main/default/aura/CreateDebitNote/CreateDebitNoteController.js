({
    
    doInit : function(component, event, helper){
        var vBillDate = new Date();
        component.set("v.DebitNote.ERP7__Credit_Note_Date__c", vBillDate.getFullYear() + "-" + (vBillDate.getMonth() + 1) + "-" + vBillDate.getDate());
        console.log('CreateDebitNote cmp doinit');
        var isAttRequired=$A.get("$Label.c.isCreateBillAttRequired");
        if(isAttRequired ==='true'){                    
            component.set("v.isAttRequired",true);
        }else{
            component.set("v.isAttRequired",false);
        }
        if(component.get('v.pId')!=undefined && component.get('v.pId')!=null && component.get('v.pId')!=''){
            
            var pId=component.get('v.pId');
            component.set("v.DebitNote.ERP7__Purchase_Orders__c", component.get("v.pId"));
            component.set('v.setRT','PO Bill');
            $A.enqueueAction(component.get("c.fetchPoli"));
        }
        if(component.get("v.ProjId") != null && component.get("v.ProjId") != undefined && component.get("v.ProjId") != ""){
            component.set("v.DebitNote.ERP7__Project__c", component.get("v.ProjId"));
        }
        if(component.get('v.DebitId')!=undefined && component.get('v.DebitId')!=null && component.get('v.DebitId')!=''){
            $A.enqueueAction(component.get("c.fetchDBLine"));
        }
        var action = component.get("c.getFunctionalityControlAllocation");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue()){
                    component.set("v.showAllocations", response.getReturnValue().allocationAccess);
                    component.set("v.ProjectAccess", response.getReturnValue().projectAccess);
                    console.log('response.getReturnValue().projectAccess->',response.getReturnValue().projectAccess);
                    component.set("v.DepartmentAccess", response.getReturnValue().departmentAccess);
                }
            }  
        });
        $A.enqueueAction(action);
        
        var action1 = component.get("c.displayNameonDebitNote");	
        action1.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue()){
                    component.set("v.displayName", response.getReturnValue());
                }
            }  
        });
        $A.enqueueAction(action1);
    },
    
    fetchbillItem : function(component, event, helper) {
        if(!component.get("v.isUpdate")){
            if(component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c") == ''){
                component.set("v.DebitNote.ERP7__Organisation__c", '');
                component.set("v.DebitNote.ERP7__Credit_Note_Number__c", '');
                component.set("v.DebitNote.ERP7__Account__c", '');
                component.set("v.showMmainSpin",true);
                var emp = [];
                var poli = component.get("v.lineItems");
                if(poli.length>0){
                    for(var x in poli){
                        poli[x].Accounts = [];
                    }
                }
                component.set("v.lineItems",emp);
                component.set("v.showMmainSpin",false);
            }else{
                component.set("v.showMmainSpin",true);
                var fetchpoliAction = component.get("c.fetch_billItems");
                fetchpoliAction.setParams({"Id":component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")});
                fetchpoliAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){
                        
                        var resultList = response.getReturnValue();
                       // console.log('Return value from apex',JSON.Stringyfy(resultList));
                        if(resultList.length > 0){
                            var po = JSON.parse(resultList[0]);
                            console.log('PO',po);
                            component.set("v.DebitNote.ERP7__Account__c", po.ERP7__Vendor__c);
                            component.set("v.DebitNote.ERP7__Organisation__c", po.ERP7__Organisation__c);
                            component.set("v.DebitNote.ERP7__Project__c", po.ERP7__Project__c);
                            component.set("v.DebitNote.ERP7__Department__c", po.ERP7__Department__c);
                            var poliList = JSON.parse(resultList[1]);
                            console.log('updatedPoli::~>',poliList);
                            var billingQty = JSON.parse(resultList[2]);
                            console.log('billingQty::~>',billingQty);
                            if(resultList.length>3) var dimeList = JSON.parse(resultList[3]);
                            if(resultList[4]=='Consumed Quantity'){
                                alert('You have consumed all the quantity of the bill. Please confirm and create the debit note.')
                            }
                            if(!$A.util.isEmpty(poliList)){
                                var billList = [];
                                for(var x in poliList){
                                    for(var y in billingQty){
                                        if(x == y){
                                            var poliAcc = [];
                                            if(dimeList != undefined && dimeList != null && resultList.length>3){
                                                for(var y in dimeList){
                                                    if(poliList[x].Id == dimeList[y].ERP7__Bill_Line_Item__c){
                                                        dimeList[y].Id = null;
                                                        poliAcc.push(dimeList[y]);
                                                    }
                                                }
                                            }
                                            if(poliList[x].ERP7__Purchase_Order__c!=null && poliList[x].ERP7__Purchase_Order__c!=undefined  && poliList[x].ERP7__Purchase_Order__c!='' ){
                                                component.set("v.displayPO", true);
                                            }
                                            if(poliList[x].ERP7__Product__c!=null){
                                            if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c){
                                                if(poliList[x].ERP7__Purchase_Order__c!=null && poliList[x].ERP7__Purchase_Order__c!=undefined  && poliList[x].ERP7__Purchase_Order__c!='' ){
                                                    var obj = {ERP7__Account_Category__c:poliList[x].ERP7__Account_Category__c, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Purchase_Line_Items__c:poliList[x].ERP7__Purchase_Order_Line_Items__c,ERP7__Bill_Line_Item__c:poliList[x].Id, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                           ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : poliList[x]. ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__r.Name
                                                              };
                                                    billList.push(obj);
                                                }else{
                                                    var obj = {ERP7__Account_Category__c:poliList[x].ERP7__Account_Category__c, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Purchase_Line_Items__c:poliList[x].ERP7__Purchase_Order_Line_Items__c,ERP7__Bill_Line_Item__c:poliList[x].Id, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                               ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : ''
                                                              };
                                                    billList.push(obj);
                                                }
                                            }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                                   if(poliList[x].ERP7__Purchase_Order__c!=null && poliList[x].ERP7__Purchase_Order__c!=undefined  && poliList[x].ERP7__Purchase_Order__c!='' ){
                                                   var obj = {ERP7__Account_Category__c:poliList[x].ERP7__Account_Category__c, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Purchase_Line_Items__c:poliList[x].ERP7__Purchase_Order_Line_Items__c,ERP7__Bill_Line_Item__c:poliList[x].Id, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                               ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : poliList[x]. ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__r.Name
                                                              };
                                                    billList.push(obj);
                                                   }else{
                                                       var obj = {ERP7__Account_Category__c:poliList[x].ERP7__Account_Category__c, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].ERP7__Purchase_Order_Line_Items__c,ERP7__Bill_Line_Item__c:poliList[x].Id, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                                  ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : ''
                                                              };
                                                    billList.push(obj);
                                                   }
                                            }else{
                                                if(poliList[x].ERP7__Purchase_Order__c!=null && poliList[x].ERP7__Purchase_Order__c!=undefined  && poliList[x].ERP7__Purchase_Order__c!='' ){
                                                var obj = {ERP7__Account_Category__c:poliList[x].ERP7__Account_Category__c, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].ERP7__Purchase_Order_Line_Items__c,ERP7__Bill_Line_Item__c:poliList[x].Id, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                               ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : poliList[x]. ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__r.Name
                                                              };
                                                    billList.push(obj);
                                                }else{
                                                    var obj = {ERP7__Account_Category__c:poliList[x].ERP7__Account_Category__c, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Purchase_Order_Line_Items__c:poliList[x].ERP7__Purchase_Order_Line_Items__c,ERP7__Bill_Line_Item__c:poliList[x].Id, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                               ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : ''
                                                              };
                                                    billList.push(obj);
                                                }
                                            }
                                            }else{
                                                if(poliList[x].ERP7__Purchase_Order__c!=null && poliList[x].ERP7__Purchase_Order__c!=undefined  && poliList[x].ERP7__Purchase_Order__c!='' ){
                                                    var obj = {ERP7__Account_Category__c:poliList[x].ERP7__Account_Category__c, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Purchase_Line_Items__c:poliList[x].ERP7__Purchase_Order_Line_Items__c,ERP7__Bill_Line_Item__c:poliList[x].Id, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                           ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : poliList[x]. ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__r.Name
                                                              };
                                                    billList.push(obj);
                                                }else{
                                                    var obj = {ERP7__Account_Category__c:poliList[x].ERP7__Account_Category__c, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Purchase_Line_Items__c:poliList[x].ERP7__Purchase_Order_Line_Items__c,ERP7__Bill_Line_Item__c:poliList[x].Id, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                               ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : ''
                                                              };
                                                    billList.push(obj);
                                                }
                                            }
                                            
                                        }
                                    }
                                }     
                                component.set("v.lineItems",billList);
                                component.set("v.showMmainSpin",false);
                            }else{
                                component.set("v.showMmainSpin",false);
                                helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_DB_Has_Already_Been_Created'));
                                setTimeout(
                                    $A.getCallback(function() {
                                        //$A.enqueueAction(component.get("c.cancelclick"));
                                    }), 3000
                                );
                                
                            }
                        }
                    }  
                });
                $A.enqueueAction(fetchpoliAction);
            }
        }
    },
    
    
	fetchPoli : function(component, event, helper) {
        if(!component.get("v.isUpdate")){
        if(component.get("v.DebitNote.ERP7__Purchase_Orders__c") == ''){
            //component.set("v.DebitNote", '');
            component.set("v.showMmainSpin",true);
            var emp = [];
            var poli = component.get("v.lineItems");
            if(poli.length>0){
                for(var x in poli){
                    poli[x].Accounts = [];
                }
            }
            component.set("v.lineItems",emp);
            component.set("v.showMmainSpin",false);
        }else{
        component.set("v.showMmainSpin",true);
        var fetchpoliAction = component.get("c.fetch_Polis");
        fetchpoliAction.setParams({"Id":component.get("v.DebitNote.ERP7__Purchase_Orders__c")});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    var po = JSON.parse(resultList[0]);
                    component.set("v.DebitNote.ERP7__Account__c", po.ERP7__Vendor__c);
                    //component.set("v.Bill.ERP7__Vendor_Contact__c", po.ERP7__Vendor_Contact__c);
                    //component.set("v.Bill.ERP7__Vendor_Address__c", po.ERP7__Vendor_Address__c);
                    //alert('PO Org : ' +po.ERP7__Organisation__c);
                    component.set("v.DebitNote.ERP7__Organisation__c", po.ERP7__Organisation__c);
                    var poliList = JSON.parse(resultList[1]);
                    console.log('updatedPoli::~>',poliList);
                    var billingQty = JSON.parse(resultList[2]);
                    //alert(JSON.parse(resultList[3]));
                    if(resultList.length>3) var dimeList = JSON.parse(resultList[3]);
                    //alert('1==>'+JSON.stringify(poliList));
                    if(!$A.util.isEmpty(poliList)){
                        
                        var billList = [];//component.get("v.billItems");
                        for(var x in poliList){
                            for(var y in billingQty){
                                if(x == y){
                                    var poliAcc = [];
                                    if(dimeList != undefined && dimeList != null && resultList.length>3){
                                        for(var y in dimeList){
                                            if(poliList[x].Id == dimeList[y].ERP7__Purchase_Line_Items__c){
                                                dimeList[y].Id = null;
                                                poliAcc.push(dimeList[y]);
                                            }
                                        }
                                    }
                                    if(poliList[x].ERP7__Purchase_Order__c!=null && poliList[x].ERP7__Purchase_Order__c!=''){
                                        component.set("v.displayPO", true);
                                    }
                                    if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c){
                                        var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Line_Items__c:poliList[x].Id,ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                   ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : poliList[x].ERP7__Purchase_Orders__r.Name
                                                  };
                                        billList.push(obj);
                                    }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                        var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Asset_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Line_Items__c:poliList[x].Id,ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                   ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : poliList[x].ERP7__Purchase_Orders__r.Name
                                                  };
                                        billList.push(obj);
                                    }else{
                                        var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:billingQty[y],ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Special_Instruction__c, ERP7__Purchase_Line_Items__c:poliList[x].Id,ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c, ERP7__Sort_Order__c:poliList[x].ERP7__Sort_Order__c
                                                   ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c, Accounts : poliAcc, PoName : poliList[x].ERP7__Purchase_Orders__r.Name
                                                  };
                                        billList.push(obj);
                                    }
                                    
                                }
                            }
                        }     
                        component.set("v.lineItems",billList);
                        component.set("v.showMmainSpin",false);
                        //component.set("v.Bill.ERP7__Discount_Amount__c",0);
                        //helper.calculateAdvBill(component,event);
                    }else{
                        component.set("v.showMmainSpin",false);
                        helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_DB_Has_Already_Been_Created'));
                        setTimeout(
                            $A.getCallback(function() {
                                //$A.enqueueAction(component.get("c.cancelclick"));
                            }), 3000
                        );
                        
                    }
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
        }
       /* var action2=component.get("c.uploadFile");
        action2.setParams({
            "pid" : component.get("v.Bill.ERP7__Purchase_Order__c")
        });
        action2.setCallback(this, function(response){
            var state = response.getState();
            if( state === "SUCCESS" ){
                 component.set("v.fileName",response.getReturnValue().Name);
                component.set("v.Attach",response.getReturnValue());
                
            }
        });
        $A.enqueueAction(action2);*/
        }
    },
    
    
    fetchDBLine : function(component, event, helper) {
        var fetchpoliAction = component.get("c.fetch_deblis");
        fetchpoliAction.setParams({"Id":component.get("v.DebitId")});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    var po = JSON.parse(resultList[0]);
                    component.set("v.DebitNote", po);
                    var poliList = JSON.parse(resultList[1]);
                    if(!$A.util.isEmpty(poliList)){
                        component.set("v.lineItems",poliList);
                        var dimeList = [];
                        if(resultList.length>1){
                            dimeList = JSON.parse(resultList[2]);
                            for(var x in poliList){
                                var poliAcc = [];
                                for(var y in dimeList){
                                    if(poliList[x].Id == dimeList[y].ERP7__Debit_Note_Item__c){
                                        poliAcc.push(dimeList[y]);
                                    }
                                }
                                poliList[x].Accounts = poliAcc;
                            }
                            component.set("v.lineItems",poliList);
                        }
                    }else{
                        /*helper.showToast('!Warning','warning','Bill Has Already Been Created');
                        setTimeout(
                            $A.getCallback(function() {
                                $A.enqueueAction(component.get("c.cancelclick"));
                            }), 3000
                        );*/
                        
                    }
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
    },
    
    
    
    
                          
    /*updateTotalDiscount : function(c, e, h){
        var items=c.get('v.billItems');
        if($A.util.isUndefined(items.length)){
            var dis=items.ERP7__Discount__c;
            c.set("v.Bill.ERP7__Discount_Amount__c",dis);
        }else{
               var dis=0;
               for(var x in items){
                   if(items[x].ERP7__Discount__c!=undefined && items[x].ERP7__Discount__c!=''){
                     var discount = items[x].ERP7__Discount__c;
                     dis=dis+discount*1;   
                   }
                  
               }
            c.set("v.Bill.ERP7__Discount_Amount__c",dis);
        }
     },*/ 
    updateTotalTax : function(c, e, h){
       
        var items=c.get('v.lineItems');
         console.log('Size of the lineItems ',items.length);
        if(items.ERP7__Tax_Rate__c==undefined)items.ERP7__Tax_Rate__c=0;
        if(items.ERP7__Other_Tax_Rate__c==undefined)items.ERP7__Other_Tax_Rate__c=0;
        if(items.ERP7__Quantity__c==undefined)items.ERP7__Quantity__c=0;
        if(items.ERP7__Amount__c==undefined)items.ERP7__Amount__c=0;
		// Fix added by Saqlain for incorrect loop data passing
        // for(var x in items){
         for(let x = 0; x < items.length; x++){
                   if(items[x].ERP7__Amount__c==undefined)items[x].ERP7__Amount__c=0;
                   if(items[x].ERP7__Other_Tax_Rate__c==undefined)items[x].ERP7__Other_Tax_Rate__c=0;
                   if(items[x].ERP7__Tax_Rate__c==undefined)items[x].ERP7__Tax_Rate__c=0;
                   if(items[x].ERP7__Quantity__c==undefined)items[x].ERP7__Quantity__c=0;
         }
        if($A.util.isUndefined(items.length)){
            var tax=((items.ERP7__Total_Amount__c)/100)*items.ERP7__Tax_Rate__c;
            var OTtax=(items.ERP7__Amount__c/100)*items.ERP7__Other_Tax_Rate__c;
            var totalTax=(tax+OTtax)*items.ERP7__Quantity__c;
             c.set("v.DebitNote.ERP7__Tax_Amount__c",parseFloat(totalTax));
        }else{
               var totaltax=0;
               var tax = 0;
               var OTtax = 0;
              /* for(var x in items){
                   tax = parseFloat(items[x].ERP7__Tax_Amount__c);
                   OTtax =(parseFloat(items[x].ERP7__Amount__c)/100)*parseFloat(items[x].ERP7__Other_Tax_Rate__c);
                   totaltax+=tax+OTtax;
               }*/
            // Fix added by Saqlain for incorrect loop data passing
            for(let t = 0; t < items.length; t++){
                tax = parseFloat(items[t].ERP7__Tax_Amount__c);
                   OTtax =(parseFloat(items[t].ERP7__Amount__c)/100)*parseFloat(items[t].ERP7__Other_Tax_Rate__c);
                   totaltax+=tax+OTtax;
                console.log('totaltax in for loop',totaltax);
            }
            c.set("v.DebitNote.ERP7__Tax_Amount__c",parseFloat(totaltax));
           }
     },
    updateTotalPrice: function(c, e, h) {

        var items=c.get('v.lineItems');
        console.log('Size of the Items:', items.length);
        console.log('items',JSON.stringify(items));
        if($A.util.isUndefined(items.length)){
            var amt=items.ERP7__Quantity__c * items.ERP7__Amount__c;
            c.set("v.DebitNote.ERP7__Amount__c",parseFloat(amt));
            console.log('Amount' ,amt);
        }else{
               var amt=0;
             /*  for(var x in items){
                  amt+=items[x].ERP7__Quantity__c * items[x].ERP7__Amount__c 
                   console.log('Amount from the for ',amt);
                   
               } */
     		// Fix added by Saqlain for incorrect loop data passing
            for (let i = 0; i < items.length; i++) {
   			 amt += items[i].ERP7__Quantity__c * items[i].ERP7__Amount__c;
   			 console.log('Amount from the for', amt);
				}

            c.set("v.DebitNote.ERP7__Amount__c",parseFloat(amt));
           
            
        }
        
       },
    

    UpdateTDS : function(c, e, h){
        
    },
    
    
    goBack : function(component, event, helper) {
        console.log("Gobackc");
        if(component.get("v.fromProject")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Milestones",
                componentAttributes: {
                    "currentProj" : component.get("v.currentProj"),
                    "projectId":component.get("v.ProjId"),
                    "newProj" : false
                }
            });
            evt.fire();
        }else{
            history.back();
        }
        
    },
    
    
    addNew : function(component, event, helper) {
        var billList = component.get("v.lineItems");
        billList.unshift({sObjectType :'ERP7__Debit_Note_Item__c'});
        component.set("v.lineItems",billList);
    },
    
    
    saveBill : function(component, event, helper) {
        console.log('Save bill called , Matheen');

        component.set("v.showMmainSpin",true);
        var fetchpoliAction = component.get("c.fetch_billItems");
        fetchpoliAction.setParams({"Id":component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0 || component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")==null || component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")=='' || component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c") == undefined){
                    var poliList = [];
					if(component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")!=null && component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")!='' && component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c") != undefined) poliList = JSON.parse(resultList[1]);
                    if(!$A.util.isEmpty(poliList) || component.get("v.isUpdate") || component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")==null || component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c")=='' || component.get("v.DebitNote.ERP7__Vendor_Invoice_Bill__c") == undefined){
                        var billList = component.get("v.lineItems");
                        var Billobj = component.get("v.DebitNote");
                        
                        Billobj.ERP7__Purchase_Orders__r = null;
                        Billobj.ERP7__Posted__c = component.get('v.setBillPost');
                        
                        var totalAmount=parseFloat(Billobj.ERP7__Amount__c);
                        component.NOerrors =  true;
                        if(component.NOerrors){
                            var showError=false;
                            if(component.get("v.DebitNote.ERP7__Credit_Note_Number__c")=='' || component.get("v.DebitNote.ERP7__Credit_Note_Number__c")==undefined || component.get("v.DebitNote.ERP7__Credit_Note_Number__c")==null){
                                showError = true;
                                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH7_DebNote_Please_Enter_the_Debit_Note_Number'));
                                component.set("v.showMmainSpin",false);
                            }
                            if(billList.length>0 && !(showError)){
                                for(var a=0;a<billList.length;a++){
                                    if(billList[a].ERP7__Chart_Of_Account__c=='' || billList[a].ERP7__Chart_Of_Account__c==null
                                       || billList[a].ERP7__Chart_Of_Account__c==undefined){
                                        showError=true;
                                        var po=component.get('v.DebitNote.ERP7__Purchase_Orders__c');
                                        if(po!=null && po!='' && po!=undefined)helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_Select_the_account_for_all_line_items'));
                                        else helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_Select_the_expense_account_for_all_line_items'));
                                        component.set("v.showMmainSpin",false);
                                    }
                                }
                            }
                            var fillList11=component.get("v.fillList");
                            if(component.get("v.isAttRequired") && (component.find("fileId").get("v.files")==null || fillList11.length == 0) && component.get('v.setRT')!='Advance to vendor' && !(showError)){
                                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Debit_Note_Attachment_is_missing'));
                                component.set("v.showMmainSpin",false);
                                return;
                            }
                           var isErrorsAA = helper.AnalyticalAccountCheck(component, event, helper);
                            console.log('🔎 Result of AnalyticalAccountCheck (isErrorsAA):', isErrorsAA);
                            
                            var isErrorsAACOA = helper.AnalyticalAccountCoaCheck(component, event, helper);
                            console.log('🔎 Result of AnalyticalAccountCoaCheck (isErrorsAACOA):', isErrorsAACOA);

                            if(billList.length>0 && !(showError)){
                                if(!isErrorsAA &&!isErrorsAACOA){
                                    let jsonBill  = JSON.stringify(Billobj);
                                    var action = component.get("c.checkTotalAmount");
                                    action.setParams({"Bill": jsonBill});
                                    action.setCallback(this,function(response){
                                        if(response.getState() === 'SUCCESS'){
                                            var totalAmount = false;
                                            if(!response.getReturnValue() || component.get("v.isUpdate")){
                                                var dimensionList = [];
                                                try{
                                                    
                                                    for(var x in billList){
                                                        if(billList[x].Accounts != undefined && billList[x].Accounts != null){
                                                            if(billList[x].Accounts.length > 0){
                                                                for(var y in billList[x].Accounts){
                                                                    if(billList[x].ERP7__Sort_Order__c==undefined) billList[x].ERP7__Sort_Order__c = parseInt(parseInt(x)+1);
                                                                    if(isNaN(billList[x].Accounts[y].ERP7__Sort_Order__c)){
                                                                        billList[x].Accounts[y].ERP7__Sort_Order__c = parseInt(parseInt(x)+1);
                                                                    }
                                                                    if(billList[x].Accounts[y].ERP7__Sort_Order__c != undefined && billList[x].Accounts[y].ERP7__Sort_Order__c != null){
                                                                        console.log('before poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                                        console.log('after poLIst['+x+'].Accounts['+y+'].ERP7__Sort_Order__c ~>'+billList[x].Accounts[y].ERP7__Sort_Order__c);
                                                                    }
                                                                }
                                                                dimensionList.push(billList[x].Accounts);
                                                            }
                                                        }
                                                    }
                                                    console.log('dimensionList : ',dimensionList);
                                                    for(var x in billList){
                                                        if(billList[x].Accounts != undefined && billList[x].Accounts != null) billList[x].Accounts = [];
                                                        billList[x].PoName = '';
                                                    }
                                                }catch(e){
                                                    console.log('arshad err,',e);
                                                    component.set("v.showMmainSpin",false);
                                                }
                                                //component.set("v.showMmainSpin",true);
                                                var saveAction = component.get("c.save_Bill");
                                                let jsonBill  = JSON.stringify(Billobj);
                                                let jsonBillItems = JSON.stringify(billList);
                                                var RTName;
                                                if(component.get('v.setRT')=='PO Bill')RTName='PO_Bill';
                                                if(component.get('v.setRT')=='Expense Bill')RTName='Expense_Bill';
                                                if(component.get('v.setRT')=='Advance to vendor')RTName='Advance_to_vendor';
                                                
                                                saveAction.setParams({"Bill": jsonBill, "BillItems" :jsonBillItems,RTName:RTName,});
                                                saveAction.setCallback(this,function(response){
                                                    if(response.getState() === 'SUCCESS'){ 
                                                        
                                                        var result = response.getReturnValue();
                                                        var bilobj = result['bill']; 
                                                        component.set("v.BillId",bilobj.Id);
                                                        if(component.get('v.setRT')=='PO Bill' || component.get('v.setRT')=='Expense Bill' || component.get('v.setRT')=='Advance to vendor'){
                                                            if(component.find("fileId").get("v.files")!=null){
                                                                
                                                                if (component.find("fileId").get("v.files").length > 0 && fillList11.length > 0) {
                                                                    var fileInput = component.get("v.FileList");
                                                                    for(var i=0;i<fileInput.length;i++)
                                                                        helper.saveAtt(component,event,fileInput[i],bilobj.Id);
                                                                }
                                                            }
                                                            if(component.get("v.Attach")!=null){
                                                                var Billobj = component.get("v.BillId");
                                                                var action=component.get("c.save_attachment2");
                                                                action.setParams({"parentId": Billobj,"Pid":component.get("v.Bill.ERP7__Purchase_Order__c"), 
                                                                                 });
                                                                action.setCallback(this,function(response){
                                                                    if(response.getState() === 'SUCCESS'){
                                                                    }
                                                                });
                                                                $A.enqueueAction(action);
                                                            }
                                                            
                                                        }
                                                        if(!$A.util.isUndefinedOrNull(result['error'])) {
                                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',result['error']);
                                                            component.set("v.showMmainSpin",false);
                                                            return ;
                                                        }
                                                        
                                                        if(dimensionList.length > 0){
                                                            try{
                                                                var action2=component.get("c.createDimensionsList");
                                                                action2.setParams({'AA':JSON.stringify(dimensionList), 'DId':component.get("v.BillId")});
                                                                action2.setCallback(this,function(response){
                                                                    if(response.getState() === "SUCCESS"){
                                                                    }else{
                                                                        var errors = response.getError();
                                                                        console.log("server error in dimelist : ", JSON.stringify(errors));
                                                                    } 
                                                                });
                                                                $A.enqueueAction(action2);
                                                            }catch(e){
                                                                console.log('arshad err 2,',e);
                                                            }
                                                        }
                                                        
                                                        if(component.get("v.isUpdate")) helper.showToast($A.get('$Label.c.Success'),'success', $A.get('$Label.c.PH_DebNote_Debit_Note_Updated_Successfully'));
                                                        else helper.showToast($A.get('$Label.c.Success'),'success', $A.get('$Label.c.PH_DebNote_Debit_Note_Created_Successfully'));
                                                        if(component.get("v.fromProject")){
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
                                                           }else if(component.get("v.navigateToRecord")) {
                                                            var evt = $A.get("e.force:navigateToComponent");
                                                            evt.setParams({
                                                                componentDef: "c:Accounts_Payable",
                                                                componentAttributes: {
                                                                    "selectedTab": 'Credit_debit_notes'
                                                                }
                                                            });
                                                            evt.fire();
                                                        }else {
                                                            var url = '/' + result['bill'].Id;
                                                            window.location.replace(url);
                                                        }
                                                    } 
                                                });
                                                $A.enqueueAction(saveAction);
                                            }else{
                                                component.set("v.showMmainSpin",false);
                                                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Debit Note Amount is greater then bill Amount');
                                            }
                                        }
                                    });
                                    $A.enqueueAction(action);
                                    
                                }else{
                                    var errorMessage = '';
                                    
                                    if(isErrorsAACOA){
                                        errorMessage = 'Please select the Accounting Account and Analytical Account.';
                                    }else if(isErrorsAA){
                                        errorMessage = 'Total Analytical Account amount of an item cannot be greater or lesser then line item total amount.';
                                    }
                                    
                                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',errorMessage);
                                } 
                            }else{
                                if(!showError)helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item'));
                                component.set("v.showMmainSpin",false);
                            } 
                        }else{
                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Review_All_Errors'));
                        }
                    }else{
                        component.set("v.showMmainSpin",false);
                        helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_DB_Has_Already_Been_Created'));
                        setTimeout(
                            $A.getCallback(function() {
                            }), 3000
                        );
                    }
                }
                if(resultList.length <= 0){
                    component.set("v.showMmainSpin",false);
                }
            }  
            //component.set("v.showMmainSpin",false);
        });
        $A.enqueueAction(fetchpoliAction);
        
    },
    
   handleFilesChange: function (component, event, helper) {
    component.set("v.showDelete", true);
    let fileName = 'No File Selected..';
    const files = event.getSource().get("v.files");

    if (files.length > 0) {
        fileName = files[0]['name'];
        const fileItem = [];
        let totalRequestSize = 0;

        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const fileSize = file.size;

            // Check individual file size (max 2 MB)
            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + file.name + ' exceeds the 2 MB limit.');
                component.set("v.fillList", []);
            component.set("v.fileName", []);
                    component.set("v.showDelete", false);
                return;
            }

            // Accumulate total request size
            totalRequestSize += fileSize;

            // Check total request size (max 6 MB)
            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                component.set("v.fillList", []);
            component.set("v.fileName", []);
                    component.set("v.showDelete", false);
                return;
            }

            fileItem.push(file.name);
        }

        component.set("v.fillList", fileItem);
        component.set("v.fileName", fileName);
    }
},
     removeAttachment : function(component, event, helper) {
        component.set("v.showDelete",false);
        var fileName = 'No File Selected..';
        component.set("v.fileName", fileName);
        //component.set('v.fillList',null);
        
        var fillList=component.get("v.fillList");
        fillList.splice(0, fillList.length); 
        component.set("v.fillList",fillList);
        /*for(var i in fillList){
            fillList[i].po
        }*/
    },
    
    deleteLineItem : function(component, event, helper) {
       component.set("v.showMmainSpin",true);
        try{
            var billList = component.get("v.lineItems");
            billList.splice(event.getParam("Index"),1);
            component.set("v.lineItems",billList);
            setTimeout(function() {
                // Hide the spinner after 2 seconds
                component.set("v.showMmainSpin", false);
            }, 2000);
            $A.enqueueAction(component.get("c.updateTotalPrice"));
            $A.enqueueAction(component.get("c.updateTotalTax"));
        }catch(e){
            console.log('deleteLineItem err',e);
            setTimeout(function() {
                // Hide the spinner after 2 seconds
                component.set("v.showMmainSpin", false);
            }, 2000);
        }
    },
    
})