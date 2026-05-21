({
    
    doInit : function(component, event, helper){
        console.log('CreateCreditNote cmp doinit');
        component.set("v.CreditNote.ERP7__Restock_Tax__c", 0);
        component.set("v.CreditNote.ERP7__Shipping_Amount__c", 0);
        component.set("v.CreditNote.ERP7__Shipping_Tax__c", 0);
        component.set("v.CreditNote.ERP7__Fees__c", 0);
        var vBillDate = new Date();
        component.set("v.CreditNote.ERP7__Date__c", vBillDate.getFullYear() + "-" + (vBillDate.getMonth() + 1) + "-" + vBillDate.getDate());
        var isAttRequired=$A.get("$Label.c.isCreateBillAttRequired");
        if(isAttRequired ==='true'){                    
            component.set("v.isAttRequired",true);
        }else{
            component.set("v.isAttRequired",false);
        }
        if(component.get('v.invId')!=undefined && component.get('v.invId')!=null && component.get('v.invId')!=''){
            
            var invId=component.get('v.invId');
            component.set("v.CreditNote.ERP7__Invoice__c", component.get("v.invId"));
            component.set('v.setRT','PO Bill');
            $A.enqueueAction(component.get("c.fetchinvli"));
        }
        
        if(component.get('v.credId')!=undefined && component.get('v.credId')!=null && component.get('v.credId')!=''){
            $A.enqueueAction(component.get("c.fetchcredList"));
        }
        
        helper.OrderProcess(component, event, helper);  
    },
    
    
    fetchcredList : function(component, event, helper) {
        var fetchpoliAction = component.get("c.fetch_credlis");
        fetchpoliAction.setParams({"Id":component.get("v.credId")});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    var po = JSON.parse(resultList[0]);
                    component.set("v.CreditNote", po);
                    var poliList = JSON.parse(resultList[1]);
                    component.set("v.lineItems",poliList);
                    /*if(!$A.util.isEmpty(poliList)){
                        var billList = [];
                        for(var x in poliList){
                            if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c){
                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity_Return__c,ERP7__Amount__c:poliList[x].ERP7__Sale_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Product__r.ERP7__Description__c,ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c*poliList[x].ERP7__Quantity_Return__c
                                           ,ERP7__Other_Tax__c:0.00
                                          };
                                billList.push(obj);
                            }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Asset_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity_Return__c,ERP7__Amount__c:poliList[x].ERP7__Sale_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Product__r.ERP7__Description__c, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c*poliList[x].ERP7__Quantity_Return__c
                                           ,ERP7__Other_Tax__c:0.00
                                          };
                                billList.push(obj);
                            }else{
                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity_Return__c,ERP7__Amount__c:poliList[x].ERP7__Sale_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Product__r.ERP7__Description__c, ERP7__Discount__c:0.00, ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c*poliList[x].ERP7__Quantity_Return__c
                                           ,ERP7__Other_Tax__c:0.00
                                          };
                                billList.push(obj);
                            }
                        } 
                        component.set("v.lineItems",billList);
                     }else{
                        helper.showToast('!Warning','warning','Bill Has Already Been Created');
                        setTimeout(
                            $A.getCallback(function() {
                                $A.enqueueAction(component.get("c.cancelclick"));
                            }), 3000
                        );
                        
                    }*/
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
    },
    
    
	fetchinvli : function(component, event, helper) {
        component.set("v.disabledEdit", false);
        //alert(component.get("v.CreditNote.ERP7__Invoice__c"));
        if(!component.get("v.isUpdate")){
        if(component.get("v.CreditNote.ERP7__Return_Merchandise_Authorisation__c")==null || component.get("v.CreditNote.ERP7__Return_Merchandise_Authorisation__c")==undefined){
        var fetchpoliAction = component.get("c.fetch_invlis");
        fetchpoliAction.setParams({"Id":component.get("v.CreditNote.ERP7__Invoice__c")});
            fetchpoliAction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    var resultList = response.getReturnValue();
                    if(resultList.length > 0 && resultList[2]!='True'){
                        
                        var po = JSON.parse(resultList[0]);
                        component.set("v.CreditNote.ERP7__Account__c", po.ERP7__Account__r.Id);
                        component.set("v.CreditNote.ERP7__Sales_Order__c", po.ERP7__Order__c);
                        component.set("v.CreditNote.ERP7__Organisation__c", po.ERP7__Organisation__c);
                        component.set("v.invRT", po.ERP7__Record_Type_Name__c);
                        component.set("v.invoice", po);
                        component.set("v.CreditNote.ERP7__Additional_Cost__c", 0);
                        component.set("v.SchInvoiceAmount", po.ERP7__Invoice_Amount__c - po.ERP7__Tax_Amount__c);
                        component.set("v.CreditNote.ERP7__Amount__c", po.ERP7__Invoice_Amount__c - po.ERP7__Tax_Amount__c);
                        component.set("v.CreditNote.ERP7__Tax_Amount__c", po.ERP7__Tax_Amount__c);
                        if(component.get("v.invoice.ERP7__Down_Payment__c")>0 || po.ERP7__Record_Type_Name__c == 'Schedule_Invoice'){
                            component.set("v.disabledEdit", false);
                            if(component.get("v.invoice.ERP7__Down_Payment__c")>0){
                                component.set("v.SchInvoiceAmount", po.ERP7__Total_Down_Payment_Amount__c);
                                component.set("v.CreditNote.ERP7__Amount__c", po.ERP7__Total_Down_Payment_Amount__c);
                                component.set("v.CreditNote.ERP7__Tax_Amount__c", 0.00);
                            }
                        }
                        if(po.ERP7__Order_S__c!=null){
                            component.set("v.CreditNote.ERP7__Order__c", po.ERP7__Order_S__c);
                            if(component.get("v.invRT")=='Sale'){
                            component.set("v.CreditNote.ERP7__Shipping_Amount__c", po.ERP7__Shipping_Amount__c);
        					component.set("v.CreditNote.ERP7__Shipping_Tax__c", po.ERP7__Shipping_Tax_Amount__c);
                            }
                        }
                        if(po.ERP7__Paid_Amount_Applied__c!=undefined){
                            component.set("v.CreditNote.ERP7__Advance_Amount_Applied__c", po.ERP7__Paid_Amount_Applied__c);
                            component.set("v.AdvanceAmount", po.ERP7__Paid_Amount_Applied__c);
                        }else{
                            component.set("v.CreditNote.ERP7__Advance_Amount_Applied__c", 0);
                            component.set("v.AdvanceAmount", 0);
                        }
                        if(component.get("v.invRT")!='Sale'){
                            var TotalAmount = 0.00;
                            TotalAmount = parseFloat(component.get("v.CreditNote.ERP7__Amount__c")) + parseFloat(component.get("v.CreditNote.ERP7__Tax_Amount__c")) +  parseFloat(component.get("v.CreditNote.ERP7__Additional_Cost__c")) - parseFloat(component.get("v.CreditNote.ERP7__Advance_Amount_Applied__c"));
                            component.set("v.totalSchAmount", TotalAmount.toFixed(2));
                        }
                        var poliList = JSON.parse(resultList[1]);
                        if(!$A.util.isEmpty(poliList)){
                            var billList = [];
                            var Discount = 0.00;
                            for(var x=0;x<poliList.length;x++){
                                if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c){
                                    var obj = {ERP7__Invoice_Line_Item__c:poliList[x].Id, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Description__c:poliList[x].ERP7__Detailed_Description__c ,ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Total_Tax__c
                                               ,ERP7__Other_Tax__c:0.00
                                              };
                                    billList.push(obj);
                                }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                    var obj = {ERP7__Invoice_Line_Item__c:poliList[x].Id, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Asset_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Description__c:poliList[x].ERP7__Detailed_Description__c , ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Total_Tax__c
                                               ,ERP7__Other_Tax__c:0.00
                                              };
                                    billList.push(obj);
                                }else{
                                    var obj = {ERP7__Invoice_Line_Item__c:poliList[x].Id, ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Unit_Price__c,ERP7__Description__c:poliList[x].ERP7__Detailed_Description__c , ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Total_Tax__c
                                               ,ERP7__Other_Tax__c:0.00
                                              };
                                    billList.push(obj);
                                }
                                Discount +=poliList[x].ERP7__Discount_Amount__c;
                            } 
                            if(component.get("v.invRT")=='Sale' && po.ERP7__Order_S__c!=null){
                            component.set("v.CreditNote.ERP7__Discount_Amount__c",Discount);
                            }
                            let originalClone = JSON.parse(JSON.stringify(billList));
                            component.set("v.orglineItems",originalClone);//ASRA changed
                            component.set("v.lineItems",billList);
                            console.log('billList:',billList);
                            console.log('orglineItems:'+JSON.stringify(component.get("v.orglineItems")));
                            console.log('billList:'+JSON.stringify(billList));
                        }else{
                            helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_CredNotes_Bill_Has_Already_Been_Created'));
                            setTimeout(
                                $A.getCallback(function() {
                                    $A.enqueueAction(component.get("c.cancelclick"));
                                }), 3000
                            );
                            
                        }
                    }else{
                        helper.showToast($A.get('$Label.c.PH_Warning'),'warning','Their is already Credit Note against this Invoice');
                    }
                }  
            });
        $A.enqueueAction(fetchpoliAction);
        }
        }
    },
    
    
    fetchrmali : function(component, event, helper) {
        if(!component.get("v.isUpdate")){
        var fetchpoliAction = component.get("c.fetch_rmalis");
        fetchpoliAction.setParams({"Id":component.get("v.CreditNote.ERP7__Return_Merchandise_Authorisation__c")});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    var po = JSON.parse(resultList[0]);
                    component.set("v.CreditNote.ERP7__Invoice__c", po.ERP7__Invoice__c);
                    component.set("v.CreditNote.ERP7__Account__c", po.ERP7__Account__r.Id);
                    component.set("v.CreditNote.ERP7__Sales_Order__c", po.ERP7__SO__c);
                    component.set("v.CreditNote.ERP7__Organisation__c", po.ERP7__Organisation__c);
                    component.set("v.disabledEdit",false);
                    if(po.ERP7__Invoice__c!=null) component.set("v.invRT", po.ERP7__Invoice__r.ERP7__Record_Type_Name__c);
                    else component.set("v.invRT", 'Sale');
                    if(po.ERP7__Restock_Fee__c != null) component.set("v.CreditNote.ERP7__Fees__c", po.ERP7__Restock_Fee__c);
                    else component.set("v.CreditNote.ERP7__Fees__c", 0);
                    if(po.ERP7__ReStock_Tax__c != null) component.set("v.CreditNote.ERP7__Restock_Tax__c", po.ERP7__ReStock_Tax__c);
                    else component.set("v.CreditNote.ERP7__Restock_Tax__c", 0);
                    if(po.ERP7__Shipping_Amount__c != null) component.set("v.CreditNote.ERP7__Shipping_Amount__c", po.ERP7__Shipping_Amount__c);
                    else component.set("v.CreditNote.ERP7__Shipping_Amount__c", 0);
                    if(po.ERP7__Shipping_Tax__c != null) component.set("v.CreditNote.ERP7__Shipping_Tax__c", po.ERP7__Shipping_Tax__c);
                    else component.set("v.CreditNote.ERP7__Shipping_Tax__c", 0);
                    var poliList = JSON.parse(resultList[1]);
                    if(!$A.util.isEmpty(poliList)){
                        var billList = [];
                        for(var x=0;x<poliList.length;x++){
                            if(poliList[x].ERP7__Product__r.ERP7__Track_Inventory__c){
                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Inventory_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity_Return__c,ERP7__Amount__c:poliList[x].ERP7__Sale_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Product__r.ERP7__Description__c,ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c*poliList[x].ERP7__Quantity_Return__c
                                           ,ERP7__Other_Tax__c:0.00
                                          };
                                billList.push(obj);
                            }else if(poliList[x].ERP7__Product__r.ERP7__Is_Asset__c){
                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Asset_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity_Return__c,ERP7__Amount__c:poliList[x].ERP7__Sale_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Product__r.ERP7__Description__c, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c*poliList[x].ERP7__Quantity_Return__c
                                           ,ERP7__Other_Tax__c:0.00
                                          };
                                billList.push(obj);
                            }else{
                                var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Product__c:poliList[x].ERP7__Product__c,ERP7__Quantity__c:poliList[x].ERP7__Quantity_Return__c,ERP7__Amount__c:poliList[x].ERP7__Sale_Price__c,ERP7__Item_Description__c:poliList[x].ERP7__Product__r.ERP7__Description__c, ERP7__Discount__c:0.00, ERP7__Tax_Amount__c:poliList[x].ERP7__Tax__c*poliList[x].ERP7__Quantity_Return__c
                                           ,ERP7__Other_Tax__c:0.00
                                          };
                                billList.push(obj);
                            }
                        } 
                        component.set("v.lineItems",billList);
                     }else{
                        helper.showToast($A.get('$Label.c.PH_Warning'),'warning',$A.get('$Label.c.PH_CredNotes_Bill_Has_Already_Been_Created'));
                        setTimeout(
                            $A.getCallback(function() {
                                $A.enqueueAction(component.get("c.cancelclick"));
                            }), 3000
                        );
                        
                    }
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
        }
    },
    
    
    updateTotalTax : function(c, e, h){
        var items=c.get('v.lineItems');
        if(items.ERP7__Tax_Rate__c==undefined)items.ERP7__Tax_Rate__c=0;
        if(items.ERP7__Other_Tax_Rate__c==undefined)items.ERP7__Other_Tax_Rate__c=0;
        if(items.ERP7__Quantity__c==undefined)items.ERP7__Quantity__c=0;
        if(items.ERP7__Amount__c==undefined)items.ERP7__Amount__c=0;
         for(var x=0;x<items.length;x++){
                   if(items[x].ERP7__Amount__c==undefined)items[x].ERP7__Amount__c=0;
                   if(items[x].ERP7__Other_Tax_Rate__c==undefined)items[x].ERP7__Other_Tax_Rate__c=0;
                   if(items[x].ERP7__Tax_Rate__c==undefined)items[x].ERP7__Tax_Rate__c=0;
                   if(items[x].ERP7__Quantity__c==undefined)items[x].ERP7__Quantity__c=0;
         }
        if($A.util.isUndefined(items.length)){
            var tax=((items.ERP7__Total_Amount__c)/100)*items.ERP7__Tax_Rate__c;
            var OTtax=(items.ERP7__Amount__c/100)*items.ERP7__Other_Tax_Rate__c;
            var totalTax=(tax+OTtax)*items.ERP7__Quantity__c;
             if(c.get("v.invRT")=='Sale') c.set("v.CreditNote.ERP7__Tax_Amount__c",totalTax);
        }else{
               var totaltax=0;
               var tax = 0;
               var OTtax = 0;
               for(var x=0;x<items.length;x++){
                   tax = items[x].ERP7__Tax_Amount__c;
                   OTtax =(items[x].ERP7__Amount__c/100)*items[x].ERP7__Other_Tax_Rate__c;
                   totaltax+=tax+OTtax;
               }
            if(c.get("v.invRT")=='Sale')c.set("v.CreditNote.ERP7__Tax_Amount__c",totaltax);
           }
     },
    updateTotalPrice: function(c, e, h) {
       var items=c.get('v.lineItems');
        if($A.util.isUndefined(items.length)){
            var amt=items.ERP7__Quantity__c * items.ERP7__Amount__c;
            if(c.get("v.invRT")=='Sale')c.set("v.CreditNote.ERP7__Amount__c",amt);
        }else{
               var amt=0;
               for(var x=0;x<items.length;x++){
                  amt+=items[x].ERP7__Quantity__c * items[x].ERP7__Amount__c 
               }
            if(c.get("v.invRT")=='Sale')c.set("v.CreditNote.ERP7__Amount__c",amt);
        }
        
       },
    

    UpdateTDS : function(c, e, h){
        
    },
    
    
    goBack : function(component, event, helper) {
        history.back();
    },
    
    
    addNew : function(component, event, helper) {
        var billList = component.get("v.lineItems");
        billList.unshift({sObjectType :'ERP7__RMA_Line_Item__c'});
        component.set("v.lineItems",billList);
    },
    
    
    saveBill : function(component, event, helper) {
        component.set("v.showMmainSpin", true);
        var billList = component.get("v.lineItems");
        var orgbillList = component.get("v.orglineItems");
        var Billobj = component.get("v.CreditNote");
		        
        //alert('Bill=>'+JSON.stringify(component.get("v.Bill")));
        Billobj.ERP7__Invoice__r  = null;
        //Billobj.ERP7__Vendor_Address__r = null;
        //Billobj.ERP7__Account__r = null;
        //Billobj.ERP7__Posted__c = component.get('v.setBillPost');
        
        var totalAmount=parseFloat(Billobj.ERP7__Amount__c);
        
        
       component.NOerrors =  true;
        //helper.validation_Check(component,event);
        
        if(component.NOerrors){
            var showError=false;
            if((component.get("v.CreditNote.ERP7__Invoice__c")==undefined || component.get("v.CreditNote.ERP7__Invoice__c")==null)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_CredNotes_Please_select_the_Invoice'));
            }
            if((component.get("v.CreditNote.ERP7__Reference_Number__c")=='' || component.get("v.CreditNote.ERP7__Reference_Number__c")==undefined || component.get("v.CreditNote.ERP7__Reference_Number__c")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH3_please_Enter_the_reference_number'));
            }
            if((component.get("v.CreditNote.ERP7__Account__c")==undefined || component.get("v.CreditNote.ERP7__Account__c")==null)&& !(showError)){
                showError = true;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_CredNotes_Please_select_the_Customer'));
            }
            console.log('here?');
            for(let x=0; x<orgbillList.length; x++){
                console.log('here1?');
                for(let y=0; y<billList.length; y++){
                    console.log('here2?');
                    if(x==y){
                        console.log('here3?');
                        console.log('org: '+orgbillList[x].ERP7__Quantity__c+' , changed: '+ billList[y].ERP7__Quantity__c);
                        if(orgbillList[x].ERP7__Quantity__c < billList[y].ERP7__Quantity__c){
                            showError = true;
                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','The credit note quantity cannot be greater than the Invoice quantity');
                        }
                    }
                }
            }
            
            /*if(billList.length>0 && !(showError)){
                for(var a in billList ){
                    if(billList[a].ERP7__Chart_Of_Account__c=='' || billList[a].ERP7__Chart_Of_Account__c==null
                       || billList[a].ERP7__Chart_Of_Account__c==undefined){
                        showError=true;
                        var po=component.get('v.DebitNote.ERP7__Purchase_Orders__c');
                        if(po!=null && po!='' && po!=undefined)helper.showToast('Error!','error','Please Select the account for all line items');
                        else helper.showToast('Error!','error','Please Select the expense account for all line items');
                    }
                }
            }*/
            
            var fillList11=component.get("v.fillList");
            /*if(component.get("v.isAttRequired") && (component.find("fileId").get("v.files")==null || fillList11.length == 0) && !(showError)){
                helper.showToast('Error!','error','Credit Note Attachment is missing.');
                return;
            }*/
            component.set("v.showMmainSpin", false);
            if(billList.length>0 && !(showError)){
                component.set("v.showMmainSpin",true);
                var saveAction = component.get("c.saveCreditNote");
                let jsonBill  = JSON.stringify(Billobj);
                let jsonBillItems = JSON.stringify(billList);
                var RTName;
                saveAction.setParams({"creditNote": jsonBill, "credItems" :jsonBillItems});
                saveAction.setCallback(this,function(response){
                    if(response.getState() === 'SUCCESS'){ 
                        try{
                            var result = response.getReturnValue();
                            //if(!$A.util.isUndefined(result)){
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
                                helper.showToast('Error!','error',result['error']);
                                component.set("v.showMmainSpin",false);
                                return ;
                            }
                            if(component.get("v.isUpdate")) helper.showToast($A.get('$Label.c.Success'),'success', $A.get('$Label.c.PH_CredNotes_Credit_Note_Updated_Successfully'));
                            else helper.showToast($A.get('$Label.c.Success'),'success', $A.get('$Label.c.PH_CredNotes_Credit_Note_Created_Successfully'));
                            
                            if(component.get("v.navigateToRecord")){
                                var navEvt = $A.get("e.force:navigateToSObject");
                                if(navEvt != undefined){
                                    /*navEvt.setParams({
                                    "isredirect": true,
                                    "recordId": result['bill'].Id,
                                    "slideDevName": "detail"
                                }); 
                                navEvt.fire();*/
                                    var url = '/'+result['bill'].Id;
                                    window.location.replace(url);
                                }else {
                                    var selectedBillList=[];
                                    selectedBillList.push(result['bill'].Id);
                                    var url = '/'+result['bill'].Id;
                                    window.location.replace(url);
                                }
                            }else{
                                var selectedBillList=[];
                                var result = response.getReturnValue(); 
                                /*var bilobj = result['bill2'];
                            var evt = $A.get("e.force:navigateToComponent");
                                evt.setParams({
                                    componentDef : "c:Accounts_Payable",
                                    componentAttributes: {
                                        "selectedTab" : 'Bills',
                                        "setSearch" : bilobj.Name,
                                    }
                                });
                                evt.fire(); */
                                var url = '/'+result['bill'].Id;
                                window.location.replace(url);
                            }
                            component.set("v.showMmainSpin",false);
                        }catch(e){
                            component.set("v.showMmainSpin",false);
                            console.log('exception in trycatch~>'+e);
                        }
                    }else{
                        component.set("v.showMmainSpin",false);
                        var errors = response.getError();
                        console.log("server error : ", errors);
                        helper.showToast('Error!','error',errors[0].message);
                    }
                });
                $A.enqueueAction(saveAction);
            }else{
                if(!showError)helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item'));
            } 
        }else{
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Review_All_Errors'));
            component.set("v.showMmainSpin", false);
        }
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
       var billList = component.get("v.lineItems");
        billList.splice(event.getParam("Index"),1);
        component.set("v.lineItems",billList);
    },
    
    
    checkAdvance : function(component, event, helper) {
        if(!$A.util.isEmpty(component.get("v.CreditNote.ERP7__Advance_Amount_Applied__c"))){
            if(component.get("v.CreditNote.ERP7__Advance_Amount_Applied__c")>component.get("v.AdvanceAmount")){
                helper.showToast('!Warning','warning','Advance Amount Applied is more than Invoice Advance Applied Amount');
                component.set("v.CreditNote.ERP7__Advance_Amount_Applied__c", component.get("v.AdvanceAmount"));
            }
        }else{
            component.set("v.CreditNote.ERP7__Advance_Amount_Applied__c", 0);
        }
        var TotalAmount = 0.00;
        TotalAmount = parseFloat(component.get("v.CreditNote.ERP7__Amount__c")) + parseFloat(component.get("v.CreditNote.ERP7__Tax_Amount__c")) +  parseFloat(component.get("v.CreditNote.ERP7__Additional_Cost__c")) - parseFloat(component.get("v.CreditNote.ERP7__Advance_Amount_Applied__c"));
        component.set("v.totalSchAmount", TotalAmount.toFixed(2));
    },
    
    checkEmpty : function(component, event, helper) {
        if($A.util.isEmpty(component.get("v.CreditNote.ERP7__Amount__c"))){
            component.set("v.CreditNote.ERP7__Amount__c", 0)
        }
        if($A.util.isEmpty(component.get("v.CreditNote.ERP7__Tax_Amount__c"))){
            component.set("v.CreditNote.ERP7__Tax_Amount__c", 0)
        }
        if($A.util.isEmpty(component.get("v.CreditNote.ERP7__Additional_Cost__c"))){
            component.set("v.CreditNote.ERP7__Additional_Cost__c", 0)
        }
        var TotalAmount = 0.00;
        TotalAmount = parseFloat(component.get("v.CreditNote.ERP7__Amount__c")) + parseFloat(component.get("v.CreditNote.ERP7__Tax_Amount__c")) +  parseFloat(component.get("v.CreditNote.ERP7__Additional_Cost__c")) - parseFloat(component.get("v.CreditNote.ERP7__Advance_Amount_Applied__c"));
        component.set("v.totalSchAmount", TotalAmount.toFixed(2));
        
    },
    
    
    checkCreditAmount : function(component, event, helper) {
        if(!$A.util.isEmpty(component.get("v.CreditNote.ERP7__Amount__c"))){
            if(component.get("v.CreditNote.ERP7__Amount__c")>component.get("v.SchInvoiceAmount")){
                helper.showToast('!Warning','warning','Credit Applied is more than the Invoice Amount');
                component.set("v.CreditNote.ERP7__Amount__c", component.get("v.SchInvoiceAmount"));
            }
        }else{
            component.set("v.CreditNote.ERP7__Amount__c", 0);
        }
        var TotalAmount = 0.00;
        TotalAmount = parseFloat(component.get("v.CreditNote.ERP7__Amount__c")) + parseFloat(component.get("v.CreditNote.ERP7__Tax_Amount__c")) +  parseFloat(component.get("v.CreditNote.ERP7__Additional_Cost__c")) - parseFloat(component.get("v.CreditNote.ERP7__Advance_Amount_Applied__c"));
        component.set("v.totalSchAmount", TotalAmount.toFixed(2));
    },
    
    checkCreditTax : function(component, event, helper) {
        if(!$A.util.isEmpty(component.get("v.CreditNote.ERP7__Amount__c"))){
            if(component.get("v.CreditNote.ERP7__Tax_Amount__c")>component.get("v.invoice.ERP7__Tax_Amount__c")){
                helper.showToast('!Warning','warning','Credit Tax Applied is more than the schedule invoice Tax Amount');
                component.set("v.CreditNote.ERP7__Tax_Amount__c", component.get("v.invoice.ERP7__Tax_Amount__c"));
            }
        }else{
            component.set("v.CreditNote.ERP7__Tax_Amount__c", 0);
        }
        var TotalAmount = 0.00;
        TotalAmount = parseFloat(component.get("v.CreditNote.ERP7__Amount__c")) + parseFloat(component.get("v.CreditNote.ERP7__Tax_Amount__c")) +  parseFloat(component.get("v.CreditNote.ERP7__Additional_Cost__c")) - parseFloat(component.get("v.CreditNote.ERP7__Advance_Amount_Applied__c"));
        component.set("v.totalSchAmount", TotalAmount.toFixed(2));
    },
    
    
    checkCreditAdvAmount : function(component, event, helper) {
        if(!$A.util.isEmpty(component.get("v.CreditNote.ERP7__Amount__c"))){
            if(component.get("v.CreditNote.ERP7__Amount__c")>component.get("v.SchInvoiceAmount")){
                helper.showToast('!Warning','warning','Credit Applied is more than the Advance Amount');
                component.set("v.CreditNote.ERP7__Amount__c", component.get("v.SchInvoiceAmount"));
            }
        }else{
            component.set("v.CreditNote.ERP7__Amount__c", 0);
        }
        var TotalAmount = 0.00;
        TotalAmount = parseFloat(component.get("v.CreditNote.ERP7__Amount__c")) + parseFloat(component.get("v.CreditNote.ERP7__Tax_Amount__c")) +  parseFloat(component.get("v.CreditNote.ERP7__Additional_Cost__c")) - parseFloat(component.get("v.CreditNote.ERP7__Advance_Amount_Applied__c"));
        component.set("v.totalSchAmount", TotalAmount.toFixed(2));
    },
})