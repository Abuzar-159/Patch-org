({
    enableAllCheckboxes: function (checkboxes) {
        checkboxes.forEach(function (checkbox) {
            checkbox.set("v.disabled", false);
        });
    }, 
  fetchRecords : function(cmp, event, helper) { 
      cmp.set('v.criteriaMsgCus',''); cmp.set('v.criteriaMsgOrd','');cmp.set('v.criteriaMsgInv',''); cmp.set('v.criteriaMsgPay',''); cmp.set('v.criteriaMsgCre',''); cmp.set('v.criteriaMsgDun',''); cmp.set('v.criteriaMsgDebit','')   
      var action = cmp.get("c.getRecords");
      console.log('Organisation : ',cmp.get("v.Organisation.Id"));
      if(cmp.get("v.LoaderControll") !=false) cmp.set("v.showMainSpin",true); 
      var selectedCustomersId=[]; selectedCustomersId=cmp.get("v.selectedCustomersId");
      var selectInvoiceId=[]; selectInvoiceId=cmp.get("v.SelectedPOS");
     // var searchString;
     // if(event.getParam("searchString")!=null)searchString = event.getParam("searchString").toString();
      action.setParams({
          orgId:cmp.get("v.Organisation.Id"),
          showTabs:cmp.get("v.showTabs"),
          OrderBy:cmp.get("v.OrderBy"),
          Order:cmp.get("v.Order"),
          selectedCustomersId:selectedCustomersId,
          selectInvoiceId:cmp.get("v.SelectedPOS"),
          Offset: cmp.get("v.Offset"),
          RecordLimit: cmp.get('v.show'),
          searchString :cmp.get('v.setSearch'),
          Aging : cmp.get('v.DueFilter')
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (cmp.isValid() && state === "SUCCESS") { 
          try{
           cmp.set("v.showMainSpin",false);
           cmp.set("v.debitList",response.getReturnValue().DebitList); 
           cmp.set("v.CustomerList",response.getReturnValue().CustomerList);
           cmp.set("v.OrderList",response.getReturnValue().OrderList);
           cmp.set("v.SalesOrderList",response.getReturnValue().SalesOrderList);
           cmp.set("v.standardOrder",response.getReturnValue().is_StandardOrder);
           cmp.set("v.InvoiceList",response.getReturnValue().InvoiceList);
           cmp.set("v.PaymentList",response.getReturnValue().PaymentList);
           console.log('Payment list for Standard Orders:',JSON.stringify(cmp.get("v.PaymentList")));
           cmp.set("v.CreditList",response.getReturnValue().CreditList);          
           cmp.set("v.DunningList",response.getReturnValue().DunningList);              
           cmp.set("v.CustomerListD",response.getReturnValue().CustomerList);
           cmp.set("v.InvoiceListD",response.getReturnValue().InvoiceList);
           cmp.set("v.PaymentListD",response.getReturnValue().PaymentList);
           cmp.set("v.CreditListD",response.getReturnValue().CreditList);          
           cmp.set("v.DunningListD",response.getReturnValue().DunningList);            
           cmp.set("v.TODAY",response.getReturnValue().TODAY); 
           cmp.set("v.CustomerListForSearch",response.getReturnValue().CustomerListForSearch);
           cmp.set("v.InvoiceListForSearch",response.getReturnValue().InvoiceListForSearch);
           cmp.set("v.PaymentListForSearch",response.getReturnValue().PaymentListForSearch);
           cmp.set("v.CreditListForSearch",response.getReturnValue().CreditListForSearch); 
           cmp.set("v.DebitListForSearch", response.getReturnValue().DebitListForSearch);   
          if(response.getReturnValue().CustomerRTList!=undefined) cmp.set("v.CustomerRTList",response.getReturnValue().CustomerRTList);
          if(response.getReturnValue().PaymentRTList!=undefined)cmp.set("v.PaymentRTList",response.getReturnValue().PaymentRTList);    
          if(cmp.get("v.showTabs")!='cus'){
              if(cmp.find("cusId")!=undefined) $A.util.removeClass(cmp.find("cusId").getElement(),'slds-is-active');
              var val=cmp.get("v.showTabs");
              if(cmp.find(val+'Id')!=undefined) $A.util.addClass(cmp.find(val+'Id').getElement(),'slds-is-active');                                        
          }
          cmp.set('v.criteriaMsgCus',''); cmp.set('v.criteriaMsgInv',''); cmp.set('v.criteriaMsgPay',''); cmp.set('v.criteriaMsgOrd',''); cmp.set('v.criteriaMsgCre',''); cmp.set('v.criteriaMsgDun',''); cmp.set('v.criteriaMsgDebit','');      
          if(response.getReturnValue().CustomerList==undefined || response.getReturnValue().CustomerList=='' || response.getReturnValue().CustomerList==null) cmp.set('v.criteriaMsgCus',$A.get("$Label.c.No_Items_Found"));  //Itemsthis.showToast('!Error','error','No Items Found'); //'No Customer Found'
          if(response.getReturnValue().InvoiceList=='' || response.getReturnValue().InvoiceList==undefined || response.getReturnValue().InvoiceList==null) cmp.set('v.criteriaMsgInv',$A.get("$Label.c.No_Items_Found"));      //'No Invoice Found'   
          if(response.getReturnValue().PaymentList==undefined || response.getReturnValue().PaymentList=='' || response.getReturnValue().PaymentList==null) cmp.set('v.criteriaMsgPay',$A.get("$Label.c.No_Items_Found"));		//'No Payment Found'
          if(response.getReturnValue().CreditList==undefined || response.getReturnValue().CreditList=='' || response.getReturnValue().CreditList==null) cmp.set('v.criteriaMsgCre',$A.get("$Label.c.No_Items_Found"));		//'No Credit Note Found'
          if(response.getReturnValue().DunningList==undefined || response.getReturnValue().DunningList=='' || response.getReturnValue().DunningList==null) cmp.set('v.criteriaMsgDun',$A.get("$Label.c.No_Items_Found"));      //'No Dunning Found'             
          if(response.getReturnValue().DebitList==undefined || response.getReturnValue().DebitList=='' || response.getReturnValue().DebitList==null) cmp.set('v.criteriaMsgDebit',$A.get("$Label.c.No_Items_Found"));       //'No Debit Note Found'            
         if(cmp.get("v.standardOrder")==true){
            if(response.getReturnValue().OrderList==undefined || response.getReturnValue().OrderList=='' || response.getReturnValue().OrderList==null) cmp.set('v.criteriaMsgOrd','No Order Found'); 
        }else{
            if(response.getReturnValue().SalesOrderList==undefined || response.getReturnValue().SalesOrderList=='' || response.getReturnValue().SalesOrderList==null) cmp.set('v.criteriaMsgOrd','No Order Found');
        }
          var Offsetval=parseInt(cmp.get("v.Offset"));
          var records;   
          if(cmp.get("v.showTabs")=='inv')records = response.getReturnValue().InvoiceList;   
          if(cmp.get("v.showTabs")=='cus')records = response.getReturnValue().CustomerList;
              if(cmp.get("v.showTabs")=='ord'){
            if(cmp.get("v.standardOrder")==true){
                records = response.getReturnValue().OrderList;
            }else{
                records = response.getReturnValue().SalesOrderList;
            }
        }
          if(cmp.get("v.showTabs")=='pay')records = response.getReturnValue().PaymentList;
          if(cmp.get("v.showTabs")=='cre')records = response.getReturnValue().CreditList;
          if(cmp.get("v.showTabs")=='deb')records = response.getReturnValue().DebitList;
          cmp.set('v.recSize',response.getReturnValue().recSize);    
           if(Offsetval!=0){
               if(records.length > 0) {
                   var startCount = Offsetval + 1;
                   var endCount = Offsetval + records.length;
                   cmp.set("v.startCount", startCount);
                   cmp.set("v.endCount", endCount);
               }
            }
            if(Offsetval==0){
                if(records.length > 0) {
                    var startCount = 1;
                    var endCount = records.length;
                    cmp.set("v.startCount", startCount);
                    cmp.set("v.endCount", endCount); 
                    cmp.set("v.PageNum",1);
                }
            }
              var myPNS = [];
              var ES = response.getReturnValue().recSize;
              var i=0;
              var show=cmp.get('v.show');
              while(ES >= show){
                  i++; myPNS.push(i); ES=ES-show;
              } 
              if(ES > 0) myPNS.push(i+1);
              cmp.set("v.PNS", myPNS);  
          
          }catch(ex){ } 
          }else{
                 cmp.set("v.showMainSpin",false);
        }                
     });
     $A.enqueueAction(action);
        
    /*var CreditFields=' Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                  ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                  ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Account__r.Name';*/
      var CreditFields=',ERP7__Coupon_Redemption__r.Id,ERP7__Coupon_Redemption__r.Name,ERP7__Invoice__r.Id, ERP7__Invoice__r.Name, ERP7__Organisation__r.Id, ERP7__Organisation__r.Name, ERP7__Payment__r.Id, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__r.Id, ERP7__Return_Merchandise_Authorisation__r.Name,ERP7__Sales_Order__r.Id, ERP7__Sales_Order__r.Name ,ERP7__Account__r.Id,ERP7__Account__r.Name';
    
      cmp.set("v.CreditFields",CreditFields);  
   
    //var DunningFields=' Id, Name, ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Invoice__r.ERP7__Due_Date__c,ERP7__Status__c, ERP7__Supplier_Used__c, ERP7__Supplier_Used__r.Name, ERP7__Customer__r.Name, ERP7__Dunning_Applied_Date__c,ERP7__Organisations__c, ERP7__Organisations__r.Name';
    var DunningFields=',ERP7__Invoice__r.Id, ERP7__Invoice__r.Name, ERP7__Invoice__r.ERP7__Due_Date__c, ERP7__Supplier_Used__r.Id,ERP7__Supplier_Used__r.Name,ERP7__Customer__r.Id, ERP7__Customer__r.Name,ERP7__Organisations__r.Id, ERP7__Organisations__r.Name';
    cmp.set("v.DunningFields",DunningFields);       
        
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
            toastEvent.fire();
        }
    },     
   
  fetchInvoiceUpdate:function(component,event,helper,InvoiceId,Index){
      component.set("v.SaveErrorMsg",'');   
      var action = component.get("c.getInvoiceUpdate");    
      action.setParams({
            "InvoiceId":InvoiceId             
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
          try{ 
          var InvoiceList=component.get("v.InvoiceList");
          if(response.getReturnValue()!=null){ 
          if(response.getReturnValue()!=null && response.getReturnValue().InvoiceRecord !=null && response.getReturnValue().SaveErrorMsg==''){
              InvoiceList[Index]=response.getReturnValue().InvoiceRecord;
              component.set("v.InvoiceList",InvoiceList); 
              var postedmsg = $A.get("$Label.c.Acc_Recev_Posted");
              var upostmsg = $A.get("$Label.c.Acc_Recev_Unpost")+ ' '+ $A.get("$Label.c.Success");
              if(response.getReturnValue().InvoiceRecord.ERP7__Posted__c) this.showToast($A.get('$Label.c.Success'),'success',postedmsg);//component.set("v.SaveErrorMsg",'Successfully Posted !');
              else this.showToast($A.get('$Label.c.Success'),'success',upostmsg);//component.set("v.SaveErrorMsg",'Successfully Unposted !');
              setTimeout(
                  $A.getCallback(function() {
                      component.set("v.SaveErrorMsg",'');
                  }), 2000
              );
          }else if(response.getReturnValue().SaveErrorMsg!=''){
             component.set("v.SaveErrorMsg",response.getReturnValue().SaveErrorMsg); 
              setTimeout(
                  $A.getCallback(function() {
                      component.set("v.SaveErrorMsg",'');
                  }), 10000
              );
          }
          
          }else{
               component.set("v.SaveErrorMsg",$A.get("$Label.c.Unexpected_error_occured_Please_try_again_later")); 
              setTimeout(
                  $A.getCallback(function() {
                      component.set("v.SaveErrorMsg",'');
                  }), 2000
              );
          } 
         }catch(ex){
               component.set("v.SaveErrorMsg",$A.get("$Label.c.Unexpected_error_occured_Please_try_again_later")); 
             setTimeout(
                 $A.getCallback(function() {
                     component.set("v.SaveErrorMsg",'');
                 }), 5000
             );         
        };            
      }else{
          setTimeout(
                 $A.getCallback(function() {
                     component.set("v.SaveErrorMsg",'');    
                 }), 2000
             );
           
      }
                
     });
     $A.enqueueAction(action); 
    },
   
   fetchPaymentUpdate:function(component,event,helper,PaymentId,Index){
      component.set("v.SaveErrorMsg",'');   
      var action = component.get("c.getPaymentUpdate");    
      action.setParams({
            "PaymentId":PaymentId             
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
          try{  
          var PaymentList=component.get("v.PaymentList");
          if(response.getReturnValue()!=null){ 
          if(response.getReturnValue()!=null && response.getReturnValue().PaymentRecord !=null && response.getReturnValue().SaveErrorMsg==''){
              var IndexVal=0;
              for(var p=0; p<PaymentList.length; p++){
                  if(PaymentList[p].Id==response.getReturnValue().PaymentRecord.Id){
                     IndexVal=p; break; 
                  }
              }
              
              PaymentList[IndexVal]=response.getReturnValue().PaymentRecord;              
              component.set("v.PaymentList",PaymentList);  component.set("v.PaymentListD",PaymentList);
              var postedmsg = $A.get("$Label.c.Acc_Recev_Posted");
              var upostmsg = $A.get("$Label.c.Acc_Recev_Unpost")+ ' '+ $A.get("$Label.c.Success");
              if(response.getReturnValue().PaymentRecord.ERP7__Posted__c) this.showToast($A.get('$Label.c.Success'),'success',postedmsg);//component.set("v.SaveErrorMsg",'Successfully Posted !');
              else this.showToast($A.get('$Label.c.Success'),'success',upostmsg);//component.set("v.SaveErrorMsg",'Successfully Unposted !');
              setTimeout(
                  $A.getCallback(function() {
                      component.set("v.SaveErrorMsg",'');
                  }), 2000
              ); 
              
          }else if(response.getReturnValue().SaveErrorMsg!=''){
             component.set("v.SaveErrorMsg",response.getReturnValue().SaveErrorMsg);
              setTimeout(
                  $A.getCallback(function() {
                      component.set("v.SaveErrorMsg",''); 
                  }), 10000
              );  
              
          }
         
          }   else{
              component.set("v.SaveErrorMsg",$A.get("$Label.c.Unexpected_error_occured_Please_try_again_later")); 
              setTimeout(
                  $A.getCallback(function() {
                      component.set("v.SaveErrorMsg",'');   
                  }), 2000
              ); 
              
          }    
          }catch(ex) {
              component.set("v.SaveErrorMsg",$A.get("$Label.c.Unexpected_error_occured_Please_try_again_later")); 
              setTimeout(
                  $A.getCallback(function() {
                      component.set("v.SaveErrorMsg",'');   
                  }), 2000
              );               
         };            
      }else{
          setTimeout(
              $A.getCallback(function() {
                  component.set("v.SaveErrorMsg",'');   
              }), 2000); 
          
      }
             
     });
     $A.enqueueAction(action); 
    },
    
   fetchDebitUpdate : function(component,event,helper,debitId,Index){
      component.set("v.SaveErrorMsg",'');   
      var action = component.get("c.getDebitUpdate");    
      action.setParams({
            "debitID":debitId             
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
          try{  
          var debitList=component.get("v.debitList");
          if(response.getReturnValue()!=null){ 
          if(response.getReturnValue()!=null && response.getReturnValue().debitRecord !=null && response.getReturnValue().SaveErrorMsg==''){
              var IndexVal=0;
              for(var p=0; p<debitList.length; p++){
                  if(debitList[p].Id==response.getReturnValue().debitRecord.Id){
                     IndexVal=p; break; 
                  }
              }
              
              debitList[IndexVal]=response.getReturnValue().debitRecord;              
              component.set("v.debitList",debitList);  component.set("v.DebitListD",debitList);
              var postedmsg = $A.get("$Label.c.Acc_Recev_Posted");
              var upostmsg = $A.get("$Label.c.Acc_Recev_Unpost")+ ' '+ $A.get("$Label.c.Success");
              if(response.getReturnValue().debitRecord.ERP7__Posted__c) this.showToast($A.get('$Label.c.Success'),'success',postedmsg);//component.set("v.SaveErrorMsg",'Successfully Posted !');
              else this.showToast($A.get('$Label.c.Success'),'success',upostmsg);//component.set("v.SaveErrorMsg",'Successfully Unposted !');
              setTimeout(
              $A.getCallback(function() {
                  component.set("v.SaveErrorMsg",'');    
              }), 2000);  
              
          }else if(response.getReturnValue().SaveErrorMsg!=''){
             component.set("v.SaveErrorMsg",response.getReturnValue().SaveErrorMsg);
              setTimeout(
              $A.getCallback(function() {
                  component.set("v.SaveErrorMsg",''); 
              }), 10000); 
              
          }
         
          }   else{
              component.set("v.SaveErrorMsg",$A.get("$Label.c.Unexpected_error_occured_Please_try_again_later")); 
              setTimeout(
              $A.getCallback(function() {
                  component.set("v.SaveErrorMsg",'');   
              }), 2000); 
              
          }    
          }catch(ex) {
              component.set("v.SaveErrorMsg",$A.get("$Label.c.Unexpected_error_occured_Please_try_again_later")); 
              setTimeout(
              $A.getCallback(function() {
                  component.set("v.SaveErrorMsg",'');   
              }), 2000);               
         };            
      }else{
          setTimeout(
              $A.getCallback(function() {
                  component.set("v.SaveErrorMsg",'');   
              }), 2000);
      }
             
     });
     $A.enqueueAction(action); 
    
   },
   createRecord :function(component,event,sObject,defaultvalues){                                                     
         var windowHash = window.location.hash;
         var createRecordEvent = $A.get("e.force:createRecord");
         if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": sObject,
                "defaultFieldValues":defaultvalues,
                "panelOnDestroyCallback": function(event) {
                    window.location.hash = windowHash;
                }
          });
          createRecordEvent.fire();
        }     
   },
   
   getTab:function(cmp, event, helper,showTabs){ 
        if(showTabs==undefined) showTabs=cmp.get("v.showTabs");  
        cmp.set("v.showTabs",showTabs);
        $A.util.removeClass(cmp.find("cusId").getElement(),'slds-is-active');
        $A.util.removeClass(cmp.find("invId").getElement(),'slds-is-active');
        $A.util.removeClass(cmp.find("payId").getElement(),'slds-is-active');     
        $A.util.removeClass(cmp.find("creId").getElement(),'slds-is-active');
        var val=showTabs;
       if(val=='inv') {
           //cmp.set("v.SelectedPOS",'');
           //cmp.set("v.selectedCustomers",'');
       }
       if(val=='cus'){ 
           //cmp.set("v.selectedCustomers",'');
           //cmp.set("v.selectedCustomersId",'');
       }
        $A.util.addClass(cmp.find(val+'Id').getElement(),'slds-is-active');  
       this.fetchRecords(cmp, event, helper);  
   },
    getPaymentPopupForDebit : function(component,event,helper,getDebId){
        //var getDebId = event.getParam("value");
        var ShowPaymentType,showPage;
        if(getDebId==null || getDebId=='' || getDebId==undefined){
            ShowPaymentType=true;showPage=false;
        }
        else{
            ShowPaymentType=false;showPage=true;}
        $A.createComponent("c:RecordPayment",{
            "aura:id": "recordPayment",
            "navigateToRecord":false,
            "recordId":getDebId,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.savePayment"),
            "ShowPaymentType":ShowPaymentType,
            "showPage":showPage,
            "setRT":'Debit_Note_Payments', 
            "OrgId" : component.get("v.Organisation.Id"),
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });  
    },   
      getPaymentPopup : function(component,event,helper,getInvId){
        /*var getInvId = event.currentTarget.dataset.service;
        var ShowPaymentType,showPage;
        if(getInvId==null || getInvId=='' || getInvId==undefined){
            ShowPaymentType=true;showPage=false;
        }
        else{
            ShowPaymentType=false;showPage=true;}
       $A.createComponent("c:RecordPayment",{
            "aura:id": "recordPayment",
            "navigateToRecord":false,
            "recordId":event.currentTarget.dataset.service,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.savePayment"),
            "ShowPaymentType":ShowPaymentType,
            "showPage":showPage,
            "OrgId" : component.get("v.Organisation.Id"),
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });  */
        
        //var getInvId = event.currentTarget.dataset.service;
        if(getInvId!=undefined){
        var action=component.get("c.checkPayment");
        action.setParams({
            InvId:getInvId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") { 
                if(response.getReturnValue()){
                    var ShowPaymentType,showPage;
                    if(getInvId==null || getInvId=='' || getInvId==undefined){
                        ShowPaymentType=true;showPage=false;
                    }
                    else{
                        ShowPaymentType=false;showPage=true;}
                    $A.createComponent("c:RecordPayment",{
                        "aura:id": "recordPayment",
                        "navigateToRecord":false,
                        "recordId":getInvId,
                        /*"cancelclick":component.getReference("c.backTO"),
                        "saveclick":component.getReference("c.savePayment"),*/
                        "ShowPaymentType":ShowPaymentType,
                        "showPage":showPage,
                        "OrgId" : component.get("v.Organisation.Id"),
                        "fromAccRec" : true,//to return back to Acc Rec from RecordPayment
                    },function(newCmp, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = component.find("body");
                            body.set("v.body", newCmp);
                        }
                    });
                }else{
                   helper.showToast($A.get("$Label.c.warning_UserAvailabilities"),'warning',$A.get("$Label.c.Payment_Has_Already_Been_Created"));
                }
            }
        });
         $A.enqueueAction(action);
        }else{
            $A.createComponent("c:RecordPayment",{
                        "aura:id": "recordPayment",
                        "navigateToRecord":false,
                        "ShowPaymentType":true,
                        "showPage":true,
                        "OrgId" : component.get("v.Organisation.Id"),
                    },function(newCmp, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = component.find("body");
                            body.set("v.body", newCmp);
                        }
                    });
        }
    },   
    
    
    displayDebitNotes : function(cmp, event, helper) {
        var action = cmp.get("c.getFunctionalityControl");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                cmp.set("v.displayDebitNote",response.getReturnValue());
            }  
        });
        $A.enqueueAction(action);       
    },
    
    displayApproval : function(cmp, event, helper) {
        var action = cmp.get("c.getFunctionalityControlApproval");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                cmp.set("v.approvalProcess",response.getReturnValue());
            }  
        });
        $A.enqueueAction(action);       
    },
    
    
    
    fetchOrg : function(cmp, event, helper) {
        var action = cmp.get("c.getDefaultOrganisation");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                console.log('response.getReturnValue() : ',response.getReturnValue());
                cmp.set("v.Organisation",response.getReturnValue());
            }  
        });
        $A.enqueueAction(action);  
              
    },
    functionalityControl : function(cmp, event, helper) {
        var action = cmp.get("c.getFuntionalityControl");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue()!=null){
                    try{
                        cmp.set("v.MultiOrderAgainstSingleInv", response.getReturnValue().ERP7__MultiOrderAgainstSingleInv__c );
                    }catch(e){
                        console.log('err',e);
                    }
                }
            }  
        });
        $A.enqueueAction(action);  
        
    },
})