({
    doInit : function(component, event, helper){
        helper.fetchcurrency(component, event, helper);
        //alert(component.get("v.BId"));
        //alert(component.get("v.pId"));
        //component.set("v.Bill.Id",component.get("v.BId"));
        //alert('called');
        var isAttRequired=$A.get("$Label.c.isCreateBillAttRequired");
        if(isAttRequired ==='true'){                    
            component.set("v.isAttRequired",true);
        }else{
            component.set("v.isAttRequired",false);
        }
        helper.FieldBill(component, event);
        helper.FieldAccess(component, event);
        var isMulticurrency = component.get('v.isMultiCurrency');
        if(isMulticurrency == true) { 
            helper.fetchBillCurrncy(component,event,helper); 
        }
    },
    
    
    fetch_vendor_details: function(component, event, helper){
        /*
        var action = component.get('c.fetchvendordetails');
        action.setParams({
            VendorId : component.get("v.Bill.ERP7__Vendor__c"),
            bill_number : component.get("v.Bill.ERP7__Vendor_Bill_Number__c")
        });    
        action.setCallback(this, function(response){
            var state = response.getState();
            if( state === "SUCCESS" ){
                if(response.getReturnValue()==true)
                    alert('Bill with this Vendor Bill Number already exist');
            }
        });
        $A.enqueueAction(action);*/
        
    },
                           
    updateTotalDiscount : function(c, e, h){
        var items=c.get('v.billItems');
        if($A.util.isUndefined(items.length)){
            var dis=items.ERP7__Discount__c;
            c.set("v.Bill.ERP7__Discount_Amount__c",dis);
        }else{
               var dis=0;
               for(var x in items){
                   if(items[x].ERP7__Discount__c!=null && items[x].ERP7__Discount__c!=''){
                     dis+=parseInt(items[x].ERP7__Discount__c);   
                   }
                  
               }
            c.set("v.Bill.ERP7__Discount_Amount__c",dis);
        }
     }, 
    updateTotalTax : function(c, e, h){
        var items=c.get('v.billItems');
        if(items.ERP7__Tax_Rate__c==undefined)items.ERP7__Tax_Rate__c=0;
        if(items.ERP7__Other_Tax_Rate__c==undefined)items.ERP7__Other_Tax_Rate__c=0;
        if(items.ERP7__Quantity__c==undefined)items.ERP7__Quantity__c=0;
        if(items.ERP7__Amount__c==undefined)items.ERP7__Amount__c=0;
         for(var x in items){
                   if(items[x].ERP7__Amount__c==undefined)items[x].ERP7__Amount__c=0;
                   if(items[x].ERP7__Other_Tax_Rate__c==undefined)items[x].ERP7__Other_Tax_Rate__c=0;
                   if(items[x].ERP7__Tax_Rate__c==undefined)items[x].ERP7__Tax_Rate__c=0;
                   if(items[x].ERP7__Quantity__c==undefined)items[x].ERP7__Quantity__c=0;
         }
         
        if($A.util.isUndefined(items.length)){
            var tax=(items.ERP7__Amount__c/100)*items.ERP7__Tax_Rate__c;
            var OTtax=(items.ERP7__Amount__c/100)*items.ERP7__Other_Tax_Rate__c;
            var totalTax=(tax+OTtax)*items.ERP7__Quantity__c;
             c.set("v.Bill.ERP7__VAT_TAX_Amount__c",totalTax);
        }else{
               var totaltax=0;
               var tax = 0;
               var OTtax = 0;
               for(var x in items){
                   tax =(items[x].ERP7__Amount__c/100)*items[x].ERP7__Tax_Rate__c;
                   OTtax =(items[x].ERP7__Amount__c/100)*items[x].ERP7__Other_Tax_Rate__c;
                   totaltax+=(tax+OTtax)*items[x].ERP7__Quantity__c;
               }
            c.set("v.Bill.ERP7__VAT_TAX_Amount__c",totaltax);
           }
          $A.enqueueAction(c.get("c.updateTotalPrice"));
     },
    updateTotalPrice: function(c, e, h) {
       var items=c.get('v.billItems');
        if($A.util.isUndefined(items.length)){
            var amt=items.ERP7__Quantity__c * items.ERP7__Amount__c;
            c.set("v.Bill.ERP7__Amount__c",amt);
        }else{
               var amt=0;
               for(var x in items){
                  amt+=items[x].ERP7__Quantity__c * items[x].ERP7__Amount__c 
               }
            c.set("v.Bill.ERP7__Amount__c",amt);
        }
        
       },
    
    saveBill : function(component, event, helper) {
        try{
            
            component.set("v.showMmainSpin",true);
            var billList = component.get("v.billItems");
            var Billobj = component.get("v.Bill");
            
            //alert('Bill=>'+JSON.stringify(component.get("v.Bill")));
            Billobj.ERP7__Vendor_Contact__r = null;
            Billobj.ERP7__Vendor_Address__r = null;
            Billobj.ERP7__Purchase_Order__r = null;
            Billobj.ERP7__Posted__c = component.get('v.setBillPost');
            
            var totalAmount=parseFloat(Billobj.ERP7__Amount__c);
            var advAmount=component.get('v.advPayment');
            if(component.get('v.setRT')=='Advance to vendor'){
                var amount1=component.find('amount1').get('v.value');
                if(parseFloat(amount1) <= 0 || amount1 ==''){
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_enter_a_valid_amount'));
                    return;
                }
                if(amount1 > (totalAmount-advAmount)){
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Can_not_enter_more_than_total_due_amount'));
                    return;
                }
                Billobj.ERP7__Amount__c=amount1;
            }else{
                Billobj.ERP7__Amount__c-=advAmount;
            }
            if(component.get("v.isAttRequired") && component.find("fileId").get("v.files")==null && component.get("v.clone")){
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Bill_Attachment_is_missing'));
                component.set("v.showMmainSpin",false);
                return;
            }
            component.NOerrors =  true;
            helper.validation_Check(component,event);
            if(component.NOerrors){var showError=false;
                                   if(billList.length>0){
                                       for(var a in billList ){
                                           if(component.get("v.isMultiCurrency")) billList[a].CurrencyIsoCode = component.get("v.Bill.CurrencyIsoCode");
                                           if(billList[a].ERP7__Chart_Of_Account__c=='' || billList[a].ERP7__Chart_Of_Account__c==null
                                              || billList[a].ERP7__Chart_Of_Account__c==undefined){
                                               showError=true;
                                               var po=component.get('v.Bill.ERP7__Purchase_Order__c');
                                               if(po!=null && po!='' && po!=undefined)helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_Select_the_inventory_account_for_all_line_items'));
                                               else helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_Select_the_expense_account_for_all_line_items'));
                                           }
                                       }
                                   }
                                   if(billList.length>0 && !(showError)){
                                       var saveAction = component.get("c.save_UpdatedBill");
                                       let jsonBill  = JSON.stringify(Billobj);
                                       let jsonBillItems = JSON.stringify(billList);
                                       var RTName;
                                       if(component.get('v.setRT')=='PO Bill')RTName='PO_Bill';
                                       if(component.get('v.setRT')=='Expense Bill')RTName='Expense_Bill';
                                       if(component.get('v.setRT')=='Advance to vendor')RTName='Advance_to_vendor';
                                       
                                       saveAction.setParams({"Bill": jsonBill, "BillItems" :jsonBillItems,RTName:RTName,clone:component.get("v.clone")});
                                       saveAction.setCallback(this,function(response){
                                           if(response.getState() === 'SUCCESS'){ 
                                               component.set("v.showMmainSpin",false);
                                               
                                               var result = response.getReturnValue();
                                               
                                               if(!$A.util.isUndefinedOrNull(result['error'])) {
                                                   helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',result['error']);
                                                   return ;
                                               }
                                               
                                               var bilobj = result['bill']; 
                                               
                                               if (!$A.util.isUndefinedOrNull(bilobj) && !$A.util.isUndefinedOrNull(bilobj.Id) && !$A.util.isUndefined(bilobj.Id) && !$A.util.isEmpty(bilobj.Id)) {
                                                   component.set("v.BillId",bilobj.Id);
                                                   component.set("v.bbName",bilobj.Name);
                                                   var file, getchunk,filename,fileType, fileContents ;
                                                   if(component.get("v.clone")) helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+$A.get('$Label.c.Bill_Created_Successfully'));
                                                   else helper.showToast($A.get('$Label.c.Success'),'success', result['bill'].Id+$A.get('$Label.c.Bill_Updated_Successfully'));
                                                   //For attachment
                                                   if(!component.get("v.clone")){
                                                       component.set("v.showMmainSpin",true);
                                                       if(component.get("v.navigateToRecord")){
                                                           var navEvt = $A.get("e.force:navigateToSObject");
                                                           if(navEvt != undefined){
                                                               navEvt.setParams({
                                                                   "isredirect": true,
                                                                   "recordId": component.get("v.BillId"),
                                                                   "slideDevName": "detail"
                                                               }); 
                                                               navEvt.fire();
                                                           }else {
                                                               var selectedBillList=[];
                                                               var url = '/'+component.get("v.BillId");
                                                               window.location.replace(url);
                                                           }
                                                       }else{
                                                           var selectedBillList=[];
                                                           var evt = $A.get("e.force:navigateToComponent");
                                                           evt.setParams({
                                                               componentDef : "c:Accounts_Payable",
                                                               componentAttributes: {
                                                                   "selectedTab" : 'Bills',
                                                                   "setSearch" : component.get("v.bbName")
                                                               }
                                                           });
                                                           evt.fire(); 
                                                       }
                                                   }
                                                   if(component.get('v.setRT')=='PO Bill' || component.get('v.setRT')=='Expense Bill' || component.get('v.setRT')=='Advance to vendor'){
                                                       if(component.find("fileId").get("v.files")!=null){
                                                           if (component.find("fileId").get("v.files").length > 0) {
                                                               var fileInput = component.find("fileId").get("v.files");
                                                               file = fileInput[0];
                                                               helper.saveAtt(component,event,file,bilobj.Id);
                                                           }
                                                       }if(component.get("v.Attach")!=null){
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
                                               }else{
                                                   helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','Id is Undefined');
                                                   return ;
                                               }
                                               
                                           } 
                                           else{
                                               component.set("v.showMmainSpin",false);
                                           }
                                       });
                                       $A.enqueueAction(saveAction);
                                       
                                   }else{
                                       if(!showError)helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item'));
                                   } 
                                  }else{
                                      helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_DebNote_Review_All_Errors'));
                                  }
            
        }
        catch(e){console.log(e);}
        
    },
    
    goBack : function(component, event, helper) {
        //location.reload();
        if(component.get("v.fromAP")){
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
        else if(component.get("v.supplier")){
            $A.createComponent("c:SupplierPortalBills",{
           },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
            var body = component.find("body");
            body.set("v.body", newCmp);
        }
        });
        }else{
        $A.createComponent("c:SupplierPortalPO",{
           },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
            var body = component.find("body");
            body.set("v.body", newCmp);
        }
        });
        }
        //history.back();  
    },
    validateField : function(component, event, helper){
        var billName = component.find("billName");
        if(!$A.util.isUndefined(billName)) 
            helper.checkValidationField(component,billName);
    },
    addNew : function(component, event, helper) {
        var billList = component.get("v.billItems");
        billList.unshift({sObjectType :'ERP7__Bill_Line_Item__c'});
        component.set("v.billItems",billList);
    },
    delete_Item : function(component, event, helper) {
        var billList = component.get("v.billItems");
        billList.splice(component.get("v.Index2del"),1);
        component.set("v.billItems",billList);
    },
   
     deleteLineItem : function(component, event, helper) {
       var billList = component.get("v.billItems");
        billList.splice(event.getParam("Index"),1);
        component.set("v.billItems",billList);
    },
    
    fetchPoli : function(component, event, helper) {
        
        
       if(component.get("v.fetchBill")){
       var fetchpoliAction = component.get("c.fetch_billItems");
        fetchpoliAction.setParams({"Id":component.get("v.Bill.Id")});
        fetchpoliAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var resultList = response.getReturnValue();
                if(resultList.length > 0){
                    
                    component.set("v.fetchBill",false);
                    var po = JSON.parse(resultList[0]);
                    component.set("v.Bill",po);
                    
                    component.set("v.setRT",po.RecordType.Name);
                    //alert(component.get("v.setRT"));
                    //component.set("v.Bill.ERP7__Vendor__c", po.ERP7__Vendor__c);
                    //component.set("v.Bill.ERP7__Vendor_Contact__c", po.ERP7__Vendor_Contact__c);
                    //component.set("v.Bill.ERP7__Vendor_Address__c", po.ERP7__Vendor_Address__c);
                    //component.set("v.Bill.ERP7__Organisation__c", po.ERP7__Organisation__c);
                    var poliList = JSON.parse(resultList[1]);
                    if(!$A.util.isEmpty(poliList)){
                        //alert(poliList);
                        var billList = [];
                        for(var x in poliList){
                            var obj = {ERP7__Chart_Of_Account__c:poliList[x].ERP7__Chart_Of_Account__c,ERP7__Item_Type__c:'Item',Name:poliList[x].Name,ERP7__Quantity__c:poliList[x].ERP7__Quantity__c,ERP7__Amount__c:poliList[x].ERP7__Amount__c,ERP7__Item_Description__c:poliList[x].ERP7__Item_Description__c, ERP7__Discount__c:0.00,ERP7__Tax_Amount__c:poliList[x].ERP7__Tax_Amount__c
                                       ,ERP7__Other_Tax__c:0.00,ERP7__Description__c:poliList[x].ERP7__Description__c,ERP7__Total_Amount__c:poliList[x].ERP7__Total_Amount__c
                                      };
                            
                            
                            
                            billList.push(obj);
                           }
                        component.set("v.billItems",poliList);
                        //alert(component.get("v.billItems"));
                    }else{
                        var billList = [];
                        component.set("v.billItems",billList);
                        
                    }
                }
            }  
        });
        $A.enqueueAction(fetchpoliAction);
        }
        
    },
    fetchVendorDetails  : function(component,event,helper){
        let vendorAction = component.get("c.getVendorDetails");
        var recID = component.get("v.Bill.ERP7__Vendor__c");
        if(!$A.util.isEmpty(recID)){
            vendorAction.setParams({"recordId":recID});
            vendorAction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    //component.set("v.Bill.ERP7__Vendor__c",recID);
                    //var bill = component.get("v.Bill");
                    var dueDate = new Date();
                    if(!$A.util.isUndefined(response.getReturnValue().ERP7__Payment_Terms__c))
                        dueDate.setDate(dueDate.getDate() + parseInt(response.getReturnValue().ERP7__Payment_Terms__c));
                    component.set("v.Bill.ERP7__Due_Date__c",dueDate.getFullYear() + "-" + (dueDate.getMonth() + 1) + "-" + dueDate.getDate()); //bill.ERP7__Due_Date__c = response.getReturnValue().ERP7__Payment_Terms__c;
                }
            });
            $A.enqueueAction(vendorAction);
        }else
            component.set("v.Bill.ERP7__Vendor__c",'');
    },
    onCheck: function(component,event,helper){
         var poCheck=component.find('pOcheckbox').get("v.value");
         var billCheck=component.find('billcheckbox').get("v.value");
        var Advcheckbox=component.find('Advcheckbox').get("v.value");
         if(poCheck)component.set('v.setRT','PO Bill');
         if(billCheck)component.set('v.setRT','Expense Bill');
        if(Advcheckbox)component.set('v.setRT','Advance to vendor');
         component.set('v.ShowBillType',false);
         component.set('v.showPage',true);
         
    },
    setpostFalse:function(component,event,helper){
        component.set('v.setBillPost',false);
    },
    setpostTrue:function(component,event,helper){
        component.set('v.setBillPost',true);
    },
    /*doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },*/
 
      removeAttachment: function (component, event, helper) {
    component.set("v.showDelete", false);

    console.log("Removing attachment and clearing file input...");

    // Clear UI-related attributes
    component.set("v.fileList", []);
    component.set("v.fileName", []);

    // ✅ Reset any data that may go to Apex
    component.set("v.fileName", null);
    component.set("v.Attach", null);

    // ✅ Also clear the file reference itself
    var fileInputCmp = component.find("fileId");
    if (fileInputCmp && fileInputCmp.get("v.files")) {
        var files = fileInputCmp.get("v.files");
        if (files.length > 0) {
            var file = null; // <-- explicitly clear the file variable
            console.log("File variable cleared:", file);
        }
    }

    // ✅ Clear the file input element
    if (fileInputCmp && fileInputCmp.getElement()) {
        fileInputCmp.getElement().value = ""; 
        console.log("File input cleared.");
    } else {
        console.warn("File input element not found or not accessible.");
    }

    console.log("Apex-bound data reset to null.");
    console.log("File list after removal:", component.get("v.fileList"));
    console.log("File names after removal:", component.get("v.fileName"));
},



      
    handleFilesChange: function (component, event, helper) {
    component.set("v.showDelete", true);
    var fileName = "No File Selected..";
    var files = event.getSource().get("v.files");
    var fileItem = [];
    var totalRequestSize = 0;

    // Check each file for size limits
    for (var i = 0; i < files.length; i++) {
        var fileSize = files[i].size; // Use the 'size' property for file size
        console.log("fileSize : ", fileSize);

        // Check individual file size (max 2 MB)
        if (fileSize > 2000000) {
            helper.showToast("Error", "error", "File " + files[i].name + " exceeds the 2 MB limit.");
            component.set("v.fillList", []);
            component.set("v.fileName", []);
           
            return;
        }

        // Add to total request size
        totalRequestSize += fileSize;
        console.log("totalRequestSize : ", totalRequestSize);

        // Check total request size (max 6 MB)
        if (totalRequestSize > 6000000) {
            helper.showToast(
                "Error",
                "error",
                "Total request size exceeds the 6 MB limit. Please upload fewer or smaller files."
            );
            component.set("v.fillList", []);
            component.set("v.fileName", []);
           
            return;
        }

        // Collect file names for display
        fileItem.push(files[i].name);
    }

    // Update component attributes if all validations pass
    if (files.length > 0) {
        fileName = files[0].name; // Get the name of the first file
    }
    component.set("v.fillList", fileItem);
    component.set("v.fileName", fileName);
},

    updateTDS : function(cmp, e, h){
       
        var tds_rate = cmp.get('v.TDS_Rate');
        if(tds_rate==undefined || tds_rate==null)tds_rate=0
        var TDS_Amount =0;
        if(tds_rate>0)TDS_Amount=(cmp.get('v.Bill.ERP7__Amount__c')/100)*tds_rate;
        cmp.set('v.Bill.ERP7__TDS_Amount__c',TDS_Amount);
    },
    
      cancelclick : function(cmp,event,helper){
         /*var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
        componentDef : "c:Accounts_Payable",
        componentAttributes: {
            "selectedTab" : 'Bills'
        }
       });
       evt.fire();*/
          
       $A.createComponent("c:Accounts_Payable",{
             "selectedTab" : 'Bills'
         },function(newCmp, status, errorMessage){
             if (status === "SUCCESS") {
                 var body = cmp.find("body");
                 body.set("v.body", newCmp);
             }
         }); 
       
    },
    
    
    navigatetoPO : function(component, event, helper) {
         var POId=component.get('v.Bill.ERP7__Purchase_Order__c');
         if(POId == undefined){
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_select_Purchase_Order'));
            return;
         }
         /*var evt = $A.get("e.force:navigateToComponent");
         evt.setParams({
             componentDef : "c:CreatePurchaseOrder",
             componentAttributes: {
                 recordId : component.get("v.Bill.ERP7__Purchase_Order__c"),
                 fromCB : "true"
             }
         });
         evt.fire();*/
         
        $A.createComponent("c:CreatePurchaseOrder",{
             recordId : component.get("v.Bill.ERP7__Purchase_Order__c"),
                 fromMB : true,
            billId : component.get("v.Bill.Id")
         },function(newCmp, status, errorMessage){
             if (status === "SUCCESS") {
                 var body = component.find("body");
                 body.set("v.body", newCmp);
             }
         }); 
         
         
        /*var url = '/apex/ERP7__CreatePurchaseOrderLC?PoId=';
         url = url + component.get("v.Bill.ERP7__Purchase_Order__c");
         url = url + '&fromCB=true'
         window.location.replace(url);*/
         //window.open(url,"__self");
    },
    
})