({
   saveRPOLI : function(component, event, helper) {                                                             
      var action = component.get("c.getEditRPOLI"); 
      var RPOLIJSON=JSON.stringify(component.get("v.RPOLI"));
      action.setParams({
            "RPOLIJSON":RPOLIJSON,
            "action":component.get("v.action")
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {  
          
          var RPOLI=component.get("v.RPOLI");
          var SelectRMALI=[]; SelectRMALI=component.get("v.SelectRMALI");
          var ind;                                              
          for(var i in SelectRMALI){ 
              
              if(SelectRMALI[i].Id==RPOLI.Id) { 
                  
                  SelectRMALI[i]=response.getReturnValue().RAMLI_List[0];
                  break;
              }                                              
          }                                          
          component.set("v.SelectRMALI",SelectRMALI);                                             
         // component.set("v.SelectRMALI",response.getReturnValue().RAMLI_List);
          
          $A.util.removeClass(component.find("editModal"),'slds-show'); //.getElement()                                               
          $A.util.addClass(component.find("editModal"),'slds-hide'); //.getElement()
                                                    
         // $A.util.toggleClass(component.find("editModal").getElement(),'slds-hide');                                               
          
      }        
     });
     $A.enqueueAction(action);        
    },
    
    
       
    PoliByCustomer :function(component, event, helper) {
        if(component.get("v.DistributeChannelId")=='' || component.get("v.DistributeChannelId")==undefined)
        if(component.get("v.RPO.ERP7__Distribution_Channel__c")!='' && component.get("v.RPO.ERP7__Distribution_Channel__c")!=undefined)
        component.set("v.DistributeChannelId",component.get("v.RPO.ERP7__Distribution_Channel__c"));
        
        this.fetchCustomerInfo(component, event, helper);    
        var fetchsoli = component.get("c.getPoliByCustomer");
        
        var PoliList=[]; PoliList=component.get("v.SelectRMALI");
        var selPolis='';
        for(var i in PoliList) selPolis+=PoliList[i].Id+',';  //selPolis.push(PoliList[i].Id);
        fetchsoli.setParams({
            "CustID":component.get("v.RPO.ERP7__Vendor__c"),"DistributeChannelId":component.get("v.DistributeChannelId"), "selPolis":selPolis    
        });
        fetchsoli.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var newobj = [];
                var obj = response.getReturnValue();
                if(obj!=null){ 
                    component.set("v.PoliList",obj.PoliList); component.set("v.PoliListD",obj.PoliList);  
                }
              this.doFilterPoliByCustomer(component, event, helper);
            }else{
                this.handleErrors(component,response.getError());
            }
        });
        $A.enqueueAction(fetchsoli);
    
    },
    
    
      doFilterPoliByCustomer :function(component, event, helper) {
        if(component.get("v.DistributeChannelId")=='' || component.get("v.DistributeChannelId")==undefined)
        if(component.get("v.RPO.ERP7__Distribution_Channel__c")!='' && component.get("v.RPO.ERP7__Distribution_Channel__c")!=undefined)
        component.set("v.DistributeChannelId",component.get("v.RPO.ERP7__Distribution_Channel__c"));
        
      //  this.fetchCustomerInfo(component, event, helper);    
        var fetchsoli = component.get("c.getPoliByCustomer");
        
        var PoliList=[]; PoliList=component.get("v.SelectRMALI");
        var selPolis='';
        for(var i in PoliList) selPolis+=PoliList[i].Id+',';  //selPolis.push(PoliList[i].Id);
                                                              
        fetchsoli.setParams({
            "CustID":component.get("v.RPO.ERP7__Vendor__c"),"DistributeChannelId":component.get("v.DistributeChannelId"), "selPolis":selPolis    
        });
        fetchsoli.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){ component.find("mainSpinId").getElement().style.visibility='hidden';
                var newobj = [];
                var obj = response.getReturnValue();
                if(obj!=null){ 
                    component.set("v.PoliList",obj.PoliList); component.set("v.PoliListD",obj.PoliList);  
                }
              
            }else{
                this.handleErrors(component,response.getError());
            }
        });
        $A.enqueueAction(fetchsoli);
    
    },
    
    
    
   fetchCustomerInfo : function(component, event, helper) {
      
        var customerinfo = component.get("c.FetchcustomerInfo");
        customerinfo.setParams({"custId":component.get("v.RPO.ERP7__Vendor__c")});
        customerinfo.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var obj = response.getReturnValue(); 
                if(obj.Address != null){
                    component.set("v.Address.Id",obj.Address.Id);
                    component.set("v.Address.Name",obj.Address.Name);
                }else{
                    component.set("v.Address.Id",'');
                    component.set("v.Address.Name",'');
                }
                if(obj.contact != null){
                    
                    component.set("v.CustContact.Id",obj.contact.Id);  component.set("v.RPO.ERP7__Vendor_Contact__c",obj.contact.Id);  
                    component.set("v.CustContact.Name",obj.contact.Name);  
                }else{
                   component.set("v.CustContact.Id",'');  component.set("v.RPO.ERP7__Vendor_Contact__c",'');  
                    component.set("v.CustContact.Name",'');  
                } 
             
                component.set("v.PoliList",[]);
              
               
            }else{
                helper.handleErrors(component,response.getError());
            }
            
        });
        /*
        if(!component.get("v.RMA.Id")&& component.get("v.Customer.Id"))*/
      $A.enqueueAction(customerinfo);
      
    },
 
    fetchDistributeChannelDetails : function(component, event, helper) { 
        this.PoliByCustomer(component, event, helper);
        
        var customerinfo = component.get("c.getDistributeChannelDetails");
        customerinfo.setParams({"dcId":component.get("v.DistributeChannelId")});
        customerinfo.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var obj = response.getReturnValue(); 
                
                if(obj!= null){
                    component.set("v.SiteAddress",obj);
                    component.set("v.SiteAddressId",obj.Id);  
                } 
               else
                helper.handleErrors(component,response.getError());
            }
            
        });
        /*
        if(!component.get("v.RMA.Id")&& component.get("v.Customer.Id"))*/
      $A.enqueueAction(customerinfo);
      
    },
    
    commitRPO : function(component, event, helper){        
        var validateMFBool=this.validateMandatoryFields(component, event, helper);
        //validateMFBool=true;
        
        if(validateMFBool){
        component.set("v.RPO.ERP7__Vendor_Address__c",component.get("v.Address.Id"));
        component.set("v.RPO.ERP7__Channel__c",component.get("v.channelId"));
        component.set("v.RPO.ERP7__Distribution_Channel__c",component.get("v.DistributeChannelId"));
            
       // this.showToast('dismissible','', 'success', 'Saved Successfully',component); 
        
        var customerinfo = component.get("c.getCreateRPO");
        var SelectRMALIA=[]; SelectRMALIA=component.get("v.SelectRMALI");
        var SelectRMALIJ=JSON.stringify(SelectRMALIA); //JSON.stringify(SelectRMALI)
        customerinfo.setParams({"RPO":JSON.stringify(component.get("v.RPO")),"Polis":SelectRMALIJ});
        customerinfo.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
               component.set("v.RPO.Id",response.getReturnValue().Id);
               component.set("v.RPOId",response.getReturnValue().Id); 
               this.showToast('dismissible','', 'success', 'Saved Successfully',component); 
                
            }else{
                this.handleErrors(component,response.getError());
            }
            
        });
        $A.enqueueAction(customerinfo);
      }  
    },
   
   validateMandatoryFields: function(component,event, helper) {
       var RPO=component.get("v.RPO");
       if(this.trim(RPO.Name)==false || this.trim(RPO.ERP7__Vendor__c)==false || this.trim(component.get("v.DistributeChannelId"))==false || component.get("v.RPO.ERP7__Expected_Date__c")=='' || component.get("v.RPO.ERP7__Expected_Date__c")==undefined){
           
          this.showToast('dismissible','', 'Error', 'All * Fields are mandatory',component);  
           return false;
       }else return true;
       
        
    },
    
    
   getTotalAmount: function(component,event, helper) {
         var TotalAmount=0; 
         var selectRMA=[]; selectRMA=component.get("v.SelectRMALI");
       for(var i in selectRMA){           
           if(selectRMA[i].ERP7__Return_Quanitty__c!=undefined && isNaN(selectRMA[i].ERP7__Unit_Price__c)==false)
               TotalAmount +=selectRMA[i].ERP7__Return_Quanitty__c*selectRMA[i].ERP7__Unit_Price__c; //ERP7__Total_Price__c;           
       }    
		 component.set("v.RPO.ERP7__Total_Amount__c",TotalAmount);
    },
 
    handleErrors : function(component,errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        let msg = component.get('v.message');
        msg['Title'] = 'Error';
        msg['Severity']='error';
        msg['Text'] = toastParams.message;
        component.set('v.message',msg);
        // Fire error toast
        // let toastEvent = $A.get("e.force:showToast");
        // toastEvent.setParams(toastParams);
        //toastEvent.fire();
    },
    showToast : function(modeType,title, type, message,component) {	
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":modeType,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }else{
            let msg = component.get('v.message');
            msg['Title'] = title;
            msg['Severity']=type;
            msg['Text'] = message;
            component.set('v.message',msg);
        }
    },
    
    
    hideModal: function(component, event) {
        component.set("v.savehide",false);
        var cmpTarget = component.find('showModal');
        $A.util.removeClass(cmpTarget, 'slds-show');
        $A.util.addClass (cmpTarget, 'slds-hide');
        
    },
    
    trim: function(value){  
        if(value !=undefined ) return ((value.toString()).trim() !=''?true:false);
        else return false;
    },  
    
    
 
    doSearchbyKeyword: function(component, event, keyvalue) {
        var fetchsoli = component.get("c.getSoliBykeyWord");
        fetchsoli.setParams({
            "CustID":component.get("v.Customer.Id"),
            "keyword":keyvalue,
            "SoId" : component.get("v.RMA.ERP7__SO__c")
            
        });
        fetchsoli.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var spinner = component.find('spinner');
                $A.util.addClass(spinner, "slds-hide");
                var newobj = {};
                var obj = response.getReturnValue();
                if(obj.length >0){
                    for(var i=0;i<obj.length;i++){
                        obj[i].returnQty = obj[i].RMALI.ERP7__Quantity_Return__c;
                        obj[i].accepType = obj[i].RMALI.ERP7__Acceptance_Type__c;
                        obj[i].reasonReason = obj[i].RMALI.ERP7__Return_Reason__c;
                    }
                }
                component.set("v.solis",obj);
                
            }else{
                var spinner = component.find('spinner');
                $A.util.addClass(spinner, "slds-hide");
                this.handleErrors(component,response.getError());
            }
        });
        if(keyvalue.length >2){
            var spinner = component.find('spinner');
            $A.util.removeClass(spinner, "slds-hide");
            $A.enqueueAction(fetchsoli);
        }
        
        //else 
         //   this.SoliByCustomer(component, event);
    },
    focusTOscan:function(component, event){
        $(document).ready(function() {
            component.set("v.scanValue",'');
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
                        }), 500
                    );                                 
                }              
                pressed = true;
            }); // end of window key press function         
            
            $(window).keypress(function(e){
                if ( e.which === 13 ) {        
                    e.preventDefault();
                }
            });  // end of preventing from default enter 
        });
        $(window).trigger('keypress');
    },
    BuildRMALIBYSO : function(component,event){
        
        if(!$A.util.isEmpty(component.get("v.RMA.ERP7__SO__c"))){
            component.set("v.EditRMA",true);
            var fetchaction = component.get("c.Build_RMALI");
            fetchaction.setParams({"So_Id":component.get("v.RMA.ERP7__SO__c")}); 
            fetchaction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    var obj = response.getReturnValue();
                    
                    var customerdata = obj.sObj;
                    if(customerdata){
                        try{
                            if(!$A.util.isEmpty(customerdata.ERP7__Account__c)){
                                component.set("v.Customer.Id",customerdata.ERP7__Account__c);
                                component.set("v.Customer.Name",customerdata.ERP7__Account__r.Name);
                            }
                                component.set("v.channelId",customerdata.ERP7__Channel__c);
                            var con = {};
                            if(!$A.util.isEmpty(customerdata.ERP7__Contact__c)){
                                con.Id =customerdata.ERP7__Contact__c;
                                con.Name=customerdata.ERP7__Contact__r.Name;
                            }
                            component.set("v.CustContact",con);
                            var addr = {};
                            if(!$A.util.isEmpty(customerdata.ERP7__Ship_To_Address__c)){
                                addr.Id =customerdata.ERP7__Ship_To_Address__c;
                                addr.Name=customerdata.ERP7__Ship_To_Address__r.Name;
                            }
                                component.set("v.Address",addr);
                        }catch(err){
                            console.log('err '+err);
                        }
                    }
                    component.set("v.solis",[]);
                    if(obj != null  && obj.sObj != null && obj.RAMLI_List.length>0){
                        component.set("v.SelectRMALI",obj.RAMLI_List);
                    }else{
                        component.set("v.SelectRMALI",[]);
                        var toastEvent = $A.get("e.force:showToast");
                        if(toastEvent != undefined){
                            toastEvent.setParams({
                                "mode":"dismissible",
                                "type": "Warning",
                                "message":'No Items To Return For Selected Sales Order.'
                            });
                            toastEvent.fire();
                        }else{
                            let msg = component.get('v.message');
                            msg['Title'] = title;
                            msg['Severity']=type;
                            msg['Text'] = 'No Items To Return For Selected Sales Order.';
                            component.set('v.message',msg);
                        }
                    }
                }else{
                    this.handleErrors(component,response.getError());
                }
            });
            
            $A.enqueueAction(fetchaction);
        }
        else{
           if(!component.reset)
            this.resetAttribute(component,event);
        }
        
    },
    resetAttribute : function(component,event){
        if(!component.reset){
            component.reset = true;
            //component.find("InvoiceId").set("v.selectedRecordId",'');
            //component.set("v.RMA.ERP7__Invoice__c",undefined);
            component.set("v.RMA",{});
            //component.find("InvoiceId").set("v.selectedRecordId",'');
            //component.find("OrderId").set("v.selectedRecordId",'');
            component.set("v.SelectRMALI",[]);
            component.set("v.Customer.Id",'');
            component.set("v.Customer.Name",'');
            component.set("v.CustContact.Id",'');
            component.set("v.Address.Id",'');
            component.set("v.CustContact.Name",'');
            component.set("v.Address.Name",'');
            component.set("v.solis",[]);
           
            
        }    
    },
    
    fetchCRUD: function(component, event, helper) {
        var action = component.get("c.getCRUD");
        action.setCallback(this, function(a) {
            component.set("v.crudValues", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    fetchStatus: function(component, event,helper){
    var action = component.get("c.getStatus");
    var inputsel = component.find("InputSelectDynamic");
    var opts=[];
    action.setCallback(this, function(a) {
        for(var i=0;i< a.getReturnValue().length;i++){
            opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
        }
        inputsel.set("v.options", opts);

    });
    $A.enqueueAction(action); 
    },
    
    helper_getParameterByName : function(name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

})