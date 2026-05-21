({

  
    doinit : function(component, event, helper) {
		var initaction = component.get("c.getInstance"); //doInit
        initaction.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var obj = response.getReturnValue();              
              //  component.set("v.RPO",obj.RPO);
               
                 var Status=[]; Status=obj.POStatusList; 
                 var opt=[];
                 for(var i in Status){
                        opt.push({label:Status[i],value:Status[i]});  
                 } 
               component.set("v.RPOStatusList",opt);
               component.set("v.RPOLI",obj.RPOLI);  
               component.set("v.returnRMA",window.location);
                
              
            }else{
               // helper.handleErrors(component,response.getError());
            }
            
        });
        $A.enqueueAction(initaction);
    
     
	},
    
    
    fetchRMALIValue : function(component, event, helper){   
        if(!$A.util.isEmpty(component.get("v.RPOId")))
            component.find("mainSpinId").getElement().style.visibility='visible';
        else  component.find("mainSpinId").getElement().style.visibility='hidden';                                                 
       // && component.get("v.RPOId")!=undefined && component.get("v.RPO.Id")!=undefined
                                                         
        if(!$A.util.isEmpty(component.get("v.RPOId"))){
            var fetchaction = component.get("c.fetch_RMALI");
            fetchaction.setParams({
                "RMA_Id":component.get("v.RPOId")
            }); 
            fetchaction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                   var obj = response.getReturnValue();
                   component.set("v.RPO",obj.sObj); 
                   component.set("v.channelId",obj.sObj.ERP7__Channel__c); 
                   component.set("v.DistributeChannelId",obj.sObj.ERP7__Distribution_Channel__c); 
                    
                   component.set("v.SelectRMALI",obj.RAMLI_List);
                  
                    
                    
                   if(obj.sObj.ERP7__Is_Closed__c) component.set("v.IsClosed",true);  
                   if(obj.sObj.ERP7__Ready_To_Pick_Pack__c) component.set("v.ReadyTPP",true);  
                    
                   //component.find("mainSpinId").getElement().style.visibility='hidden';
                }else { component.find("mainSpinId").getElement().style.visibility='hidden'; }
            });
           // if(!$A.util.isUndefined(component.get("v.RMA_lookup.Id")))
            	$A.enqueueAction(fetchaction);
            
        }else{
           //if(!component.reset)
         //  helper.resetAttribute(component,event);
        }
    },
    
    
     showEditModal : function (component, event, helper) {
        component.set("v.action",event.currentTarget.getAttribute('data-action')); 
       if(event.currentTarget.getAttribute('data-action')!='new'){  
        component.set('v.errMsg',''); 
        var PoliId = event.currentTarget.getAttribute('data-PoliId');
       // var recordId = event.currentTarget.getAttribute('data-recordId');
       // component.set("v.savehide",true);
        var objArray = component.get("v.SelectRMALI");
        var obj ={};
        for(var j=0;j<objArray.length;j++){
            if(objArray[j].Id === PoliId){
                obj = objArray[j];
               break;
            }       
        }
        component.set("v.RPOLI",obj);
          
       var cmpTarget = component.find('editModal');
        $A.util.addClass(cmpTarget, 'slds-show');
        $A.util.removeClass (cmpTarget, 'slds-hide');
       // helper.fetchStatus(component, event, helper);   
       }else{
         $A.util.removeClass(component.find("showModal"),'slds-hide'); 
         $A.util.addClass(component.find("showModal"),'slds-show');  
       }
         
      
    },
    hideEditModal : function (component, event, helper) {
         var cmpTarget = component.find('editModal');
        $A.util.removeClass(cmpTarget, 'slds-show');
        $A.util.addClass (cmpTarget, 'slds-hide');
        component.set('v.errMsg','No Items Select');
    },
    
   saveRPOLI : function (component, event, helper) {        
       if(helper.trim(component.get("v.RPOLI.Name"))==false) helper.showToast('dismissible','', 'Error', 'All * Fields are mandatory',component);   //component.set("v.seBool",true);  
       else{      
         //  component.set("v.seBool",false);
           helper.saveRPOLI(component, event, helper);           
       } 
       
        
    },
    
    deleteRMALI : function(component, event, helper){
        var PoliId =  event.currentTarget.getAttribute('data-PoliId');
        var objArray = component.get("v.SelectRMALI");
        for(var j=0;j<objArray.length;j++){
            if(objArray[j].Id === PoliId){
                component.set("v.DelObj",objArray[j]);//objArray.splice(j,1)
                $A.util.toggleClass(component.find("deleteModal"),"slds-hide");
                break;
            }       
        }
    },
    
    hideDeletePopup :function(component, event, helper){ $A.util.toggleClass(component.find("deleteModal"),"slds-hide");}, 
    
     
    DeleteRecordById :  function(component, event, helper){
        var del_obj  = component.get("v.DelObj");
        var objArray = component.get("v.SelectRMALI");
        for(var j=0;j<objArray.length;j++){
            if(objArray[j].Id === del_obj.Id){
                objArray.splice(j,1)
                $A.util.toggleClass(component.find("deleteModal"),"slds-hide");
                break;
            }       
        }
       component.set("v.SelectRMALI",objArray);
       helper.getTotalAmount(component,event, helper);
        
        if(del_obj.Id != null){
         	var delAction = component.get("c.DeleteByRMALIId");
            delAction.setParams({"Poli":JSON.stringify(del_obj)});
            delAction.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){   $A.util.addClass(component.find("editModal").getElement(),'slds-hide');  
                }else{
                    helper.handleErrors(component,response.getError());
                }
            });
           $A.enqueueAction(delAction); 
        }
    },
    
    BuildPoliList : function(component, event, helper) {
        if(component.get("v.RPO.ERP7__Vendor__c")!='' && component.get("v.RPO.ERP7__Vendor__c")!=undefined){
          helper.PoliByCustomer(component, event, helper);
         // helper.fetchCustomerInfo(component, event, helper);    
        }
    },
    
    showPoliList : function(component, event, helper) {
       if(helper.trim(component.get("v.RPO.ERP7__Vendor__c"))==false)  helper.showToast('dismissible','', 'Error', 'Please select vendor',component);
       else if(helper.trim(component.get("v.DistributeChannelId"))==false)  helper.showToast('dismissible','', 'Error', 'Please select Distribution Channel',component);                                                
       else{    
        $A.util.removeClass(component.find("showModal"), 'slds-hide');
        $A.util.addClass(component.find("showModal"), 'slds-show');
       }    
    },
    fetchDistributeChannelDetails : function(component, event, helper) {
        if(component.get("v.DistributeChannelId")!='' && component.get("v.DistributeChannelId")!=undefined){
          helper.fetchDistributeChannelDetails(component, event, helper);
        }
    },
  
    showModal: function(component, event, helper) {
        component.set("v.savehide",true);
        if(component.get("v.Customer.Id")){
            var obj = component.get("v.solis");
            var filterobj = [];
            let selectedObj = component.get("v.SelectRMALI");
            if(obj.length > 0 ){
                if(selectedObj.length>0){
                    for(var i=0;i<obj.length;i++){
                        
                        var flag = true;
                        if(selectedObj != undefined && selectedObj.length>0){
                            
                            for(var j=0;j<selectedObj.length;j++){
                                if(obj[i].SOLI.Id === selectedObj[j].SOLI.Id){
                                    flag = false;
                                    break;  
                                }
                            }
                            
                        }
                        if(flag){
                            filterobj.push(obj[i]);
                        }
                    }
                    component.set("v.solis",filterobj);
                }
            }else{
              
                helper.SoliByCustomer(component, event);
            }        
            
        var cmpTarget = component.find('showModal');
        $A.util.addClass(cmpTarget, 'slds-show');
        $A.util.removeClass (cmpTarget, 'slds-hide');
       
        
		}else{ 
            	helper.showToast("dismissible","Error!","error","Please select Customer",component); 
        }  
    },
    
    hideModal: function(component, event, helper) {
       helper.hideModal(component, event);

    },
   
    commitRPO : function(component, event, helper){       
         helper.commitRPO(component, event, helper);       
    },
    
   addPoli: function(component, event, helper) {
      //  component.set("v.EditRMA",true);
        var obj =[];  obj=component.get('v.PoliList');
        var selectRMA =[]; selectRMA=component.get("v.SelectRMALI");
        var nonselectRMA = [];
        //var selectIndex = [];
        if(obj.length >0){ 
            for(var i=0;i<obj.length;i++){
                if(obj[i].isSelect==true){
                 selectRMA.push(obj[i]);   
                }else{
                    nonselectRMA.push(obj[i]);
                }
            }
           
            component.set('v.PoliList',[]); component.set('v.PoliList',nonselectRMA); component.set('v.PoliListD',nonselectRMA);
            component.set("v.SelectRMALI",selectRMA);
            helper.hideModal(component, event);
          
           helper.getTotalAmount(component, event, helper);
        
            
	 }else{
            
             helper.showToast("dismissible","Error!","error","Please select a Line Item",component); 
        }
    },
   searchPoli: function(component, event, helper) {
       try{
        var searchString = component.find("searchInput").get("v.value");
        if(searchString.length>1){
            var PoliList = component.get("v.PoliList");         
            PoliList = PoliList.filter(function (el) {
             var cond1=false;   
             if(el.ERP7__Product__c!=undefined){   
               if(el.ERP7__Product__r.ProductCode!=undefined){
                 el.ERP7__Product__r.ProductCode=(el.ERP7__Product__r.ProductCode).toString();                
                cond1=el.ERP7__Product__r.ProductCode.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
              }   
             }
            var cond2=false;   
             if(el.ERP7__Purchase_Orders__c!=undefined){   
               if(el.ERP7__Purchase_Orders__r.Name!=undefined){
                 el.ERP7__Purchase_Orders__r.Name=(el.ERP7__Purchase_Orders__r.Name).toString();                
                cond2=el.ERP7__Purchase_Orders__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
              }   
             }
             
             return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2);
            });
            component.set("v.PoliList",PoliList);     
        }else{
            var PoliList=[]; PoliList=component.get("v.PoliListD");
            var SelectRMALI=[]; SelectRMALI=component.get("v.SelectRMALI");
            var PoliListMod=[];
            for(var i=0; i<PoliList.length; i++){
                for(var j=0; j<SelectRMALI.length; j++){
                 if(PoliList[i].Id!=SelectRMALI[j].Id) PoliListMod.push(PoliList[j]);
                }
            }
            component.set("v.PoliList",PoliListMod); 
            // component.set("v.PoliList",component.get("v.PoliListD"));  
            // helper.doFilterPoliByCustomer(component, event, helper);
        }
        //helper.doSearchbyKeyword(component, event, keyvalue);
       }catch(ex){ }
    },
    
      createPackageRMA : function(component, event, helper){     
        var toggleText = component.find("body");
        $A.util.toggleClass(toggleText, "slds-hide");
        var RPOId = component.get("v.RPO.Id") 
        $A.createComponent(
            "c:RMAPackage", {
                 "ReturnMAID":RPOId
            },
            function(newCmp) {
                 var content = component.get("v.body");                
                 content.set("v.body", body);
                
               /* if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);
                }*/
            }
        );
    },
    
    
    
    
    doSearch: function(component, event, helper) {
        var searchString = component.find("searchInput").get("v.value");
        if(searchString.length>1){
            var solis = component.get("v.solis");
            solis = solis.filter(function (el) {
                return (el.SOLI.ERP7__Product__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || el.SOLI.ERP7__Product__r.ProductCode.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || el.SOLI.ERP7__Sales_Order__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
            });
            component.set("v.solis",solis);
        }else{
            helper.SoliByCustomer(component, event);
        }
        //helper.doSearchbyKeyword(component, event, keyvalue);
    },
    changevalue: function(component, event, helper) {
        var recordID = event.currentTarget.getAttribute('data-recordId');
        var sel_array = [];
        var ele = component.find('checkbox');
        if(ele.length>0){
        for(var x in ele){
            if(ele[x].get('v.value')===recordID){
                ele[x].set("v.checked",!ele[x].get("v.checked"));
                break;
            }
        }
        }else{
          ele.set("v.checked",!ele.get("v.checked"));  
        }
    },

    updatetransform:function(component, event, helper) {
        var scrollTop = event.currentTarget.scrollTop;
        var offsetHeight = event.currentTarget.offsetHeight;
        var scrollHeight = event.currentTarget.scrollHeight;
        var totalscroll = parseInt(scrollTop + offsetHeight); 
        if(totalscroll===scrollHeight){
            var offset = component.get("v.offSet");
            component.set("v.offSet",parseInt(offset+50));
            component.set("v.isDoneRendering", true);
            var fetchsoli = component.get("c.getSoliByCustomer");
        fetchsoli.setParams({
            "CustID":component.get("v.Customer.Id"),
            "OFF_SET":component.get("v.offSet")
        });
        fetchsoli.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var obj = response.getReturnValue();
                if(obj.length>0){
                    var newobj = component.get("v.solis");
                    newobj.push.apply(newobj, obj);
                    component.set("v.solis",newobj);
                    component.set("v.isDoneRendering", false); 
                    for(var i=0;i<obj.length;i++){
                        var x = obj[i];
                        newobj.push(x);
                    }
                    
                }
            }else{
                helper.handleErrors(component,response.getError());
            }
        });
        var keyvalue = component.find("searchInput").get("v.value");
            if(keyvalue == undefined || keyvalue == ''){
                $A.enqueueAction(fetchsoli);
            }
       
            
        }
        if(parseInt(scrollTop)>0)
            	scrollTop= parseInt(scrollTop-70);
        $(component.find("tableHead").getElement()).css("transform", 'translate3d(0px,'+scrollTop+'px,1px)');
   
    },
    focusTOscan : function (component, event,helper) {
        helper.focusTOscan(component, event);
    },
    searchSOli : function (component, event, helper) {
        var scanval = component.get("v.scanValue");
        var SelectRMALI = component.get("v.SelectRMALI");
        for(var x=0;x<SelectRMALI.length;x++){
            
            if(SelectRMALI[x].RMALI.ERP7__Serial_Number__c != undefined && SelectRMALI[x].RMALI.ERP7__Serial_Number__r != undefined && SelectRMALI[x].RMALI.ERP7__Serial_Number__r.ERP7__Serial_Number__c != '' && SelectRMALI[x].RMALI.ERP7__Serial_Number__r.ERP7__Serial_Number__c === scanval){
                SelectRMALI[x].isSelect = true;
                break;
            }
        }
        component.set("v.SelectRMALI",SelectRMALI);
        /*var keyvalue = component.get("v.scanValue");
        if(component.get("v.Customer.Id")){
         var fetchsoli = component.get("c.getSoliBykeyWord");
        fetchsoli.setParams({
            "CustID":component.get("v.Customer.Id"),
            "keyword":keyvalue
        });
        fetchsoli.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var obj = response.getReturnValue();
                if(obj.length >0){
                    for(var i=0;i<obj.length;i++){
                        obj[i].returnQty = obj[i].RMALI.ERP7__Quantity_Return__c;
                        obj[i].accepType = obj[i].RMALI.ERP7__Acceptance_Type__c;
                        obj[i].reasonReason = obj[i].RMALI.ERP7__Return_Reason__c;
                    }
                }
                component.set("v.SelectRMALI",obj);
                    
            }
        });
        if(keyvalue.length >2)
            $A.enqueueAction(fetchsoli);
        }else{
            	helper.showToast("dismissible","Error!","error","Please select Customer"); 
        }
        */
    },
    
   
   
   
    
    commitRMA : function(component, event, helper){
        //component.set("v.disableSave",true);
        let msg = component.get('v.message');
        msg['Title'] = 'Error';
        msg['Severity']='error';
        msg['Text'] = '';
        component.set('v.message',msg);
        var obj = component.get("v.SelectRMALI");
        var selectedcount = 0 ;
        if(obj.length >0){
            for(var i=0;i<obj.length;i++){
                if(obj[i].RMALI.Id !=null) obj[i].isSelect = true;
                if(obj[i].isSelect) selectedcount+=1; 
                delete obj[i].returnQty;
                delete obj[i].accepType;
                delete obj[i].reasonReason;
            }
            if(selectedcount>0){
                var saveaction = component.get("c.createRMA");
                var objRMA = component.get("v.RMA");
                
                if(component.get("v.RMA_lookup") && component.get("v.RMA_lookup") != '' && component.get("v.RMA_lookup.Id") != ''){
                    objRMA['Id'] = component.get("v.RMA_lookup")['Id'];
                    objRMA['Name'] = component.get("v.RMA_lookup")['Name'];
                }else{
                    objRMA['Id'] = null;
                }
                //objRMA["ERP7__Authorize__c"] = component.find("Authorize").get("v.value");
                objRMA["ERP7__Distribution_Channel__c"] = component.get("v.DistributeChannel.Id");
                objRMA["ERP7__Site__c"] = component.get("v.site.Id");
                objRMA["ERP7__Expected_Date__c"] = (component.find("expectedDate").get("v.value") != '')?component.find("expectedDate").get("v.value"):null;
                objRMA["ERP7__Address__c"] = component.get("v.Address.Id");
                objRMA["ERP7__Channel__c"] = component.get("v.channelId");
                //objRMA["ERP7__SO__c"] = component.get("v.SO.Id");
                objRMA["ERP7__Return_Contact__c"] = component.get("v.CustomerContact.Id");
                objRMA["ERP7__Account__c"] = component.get("v.Customer.Id");
                //objRMA["Name"] = "RMA-"+component.get("v.SO.Name");
                
            saveaction.setParams({"RMAobj":JSON.stringify(objRMA),"RMALIs":JSON.stringify(obj)}); 
            saveaction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                   var rma = response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    if(toastEvent != undefined){
                        toastEvent.setParams({
                            "mode":"dismissible",
                            "type": "success",
                            "message": (objRMA['Id'] != null)? rma["Name"]+' was updated.':rma["Name"]+' was created.'
                        });
                        toastEvent.fire();
                    }else{
                        let msg = component.get('v.message');
                        msg['Title'] = 'Confirmation';
                        msg['Severity']='confirm ';
                        msg['Text'] = rma.Name+' was created.';
                        component.set('v.message',msg);
                    }
                    if(component.get("v.navigateToRecord")){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "isredirect": true,
                        "recordId": rma.Id,
                        "slideDevName": "detail"
                    }); 
                    if(navEvt != undefined)navEvt.fire();
                    }else{
                        component.set("v.RMA_lookup.Name",rma.Name);  
                        component.set("v.RMA_lookup.Id",rma.Id);   
                    }       
                }else{
                   
                    helper.handleErrors(component,response.getError());
                }
                   
            });
            $A.enqueueAction(saveaction);
            }else{
                component.set("v.disableSave",false);
                let msg = component.get('v.message');
                msg['Title'] = 'Error';
                msg['Severity']='error';
                msg['Text'] = 'Please Select Line Item';
                component.set('v.message',msg);
               // component.set("v.errMsgWhenNoEvent",'Please Select Line Item');
            }
        }
    },
    cancelRMA : function(component, event, helper){
       /* var  objArray = [];
        component.set("v.SelectRMALI",objArray);
        if(Boolean(component.get("v.showbackBtn"))){
            var so = component.get("v.RMA.ERP7__SO__c");
            var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "isredirect": true,
                        "recordId": so,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
        }else{
         
            location.reload();
        } */
        location.reload(); 
    },
    fetchContact : function(component, event, helper){
        if(component.get("v.Customer.Id") != null || component.get("v.Customer.Id") != undefined || component.get("v.CustContact.Id") != null || component.get("v.CustContact.Id") != undefined){
        var customerinfo = component.get("c.FetchContactById");
       customerinfo.setParams({"custId":component.get("v.Customer.Id"),"recordId":component.get("v.CustContact.Id")});
        customerinfo.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var obj = response.getReturnValue();
                if(obj != null || obj != undefined){
                    component.set("v.CustomerContact",obj);
                }else
                    component.set("v.CustomerContact",{});
            }else{
                helper.handleErrors(component,response.getError());
            }
            
        });
        $A.enqueueAction(customerinfo);
        }else{
            component.set("v.CustomerContact",{});
        }
    },
    fetchSiteAddress : function(component, event, helper){
        if( component.get("v.SiteAddressId")){
        var siteAddressAction = component.get("c.FetchAddressById");
        siteAddressAction.setParams({"custId":'',"recordId":component.get("v.SiteAddressId")});
        siteAddressAction.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var obj = response.getReturnValue();
                
                if(obj != null || obj != undefined)
                	component.set("v.SiteAddress",obj);
                else
                    component.set("v.SiteAddress",{});
            }else{
                helper.handleErrors(component,response.getError());
            }
            
        });
        $A.enqueueAction(siteAddressAction);
        }else{
            component.set("v.SiteAddress",{});
        }
    },
    fetchAddress : function(component, event, helper){
        if(component.get("v.Customer.Id") != null || component.get("v.Customer.Id") != undefined || component.get("v.Address.Id") != null || component.get("v.Address.Id") != undefined){
        var customerinfo = component.get("c.FetchAddressById");
        customerinfo.setParams({"custId":component.get("v.Customer.Id"),"recordId":component.get("v.Address.Id")});
        customerinfo.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var obj = response.getReturnValue();
                if(obj != null || obj != undefined){
                component.set("v.CustomerAddress",obj);
                }else
                    component.set("v.CustomerAddress",{});
            }else{
                helper.handleErrors(component,response.getError());
            }
            
        });
        $A.enqueueAction(customerinfo);
        }else{
            component.set("v.CustomerAddress",{});
        }
    },
    
    BuildRMALI : function(component, event, helper){
       if($A.util.isUndefined(component.get("v.RMA.Id")) && $A.util.isUndefined(component.get("v.RMA.ERP7__Invoice__c")))
        helper.BuildRMALIBYSO(component, event, helper);
        
    },
    QtyCheck : function(component, event, helper){
        var obj = component.get("v.RMALI");
        if(obj.ERP7__Quantity_Return__c >0){
            var totalPrice = parseFloat((obj.ERP7__Quantity_Return__c * obj.ERP7__Sale_Price__c)+ (obj.ERP7__Quantity_Return__c * obj.ERP7__Tax__c));
            obj.ERP7__Total_Deduction__c = totalPrice;//(obj.ERP7__Total_Deduction__c/obj.ERP7__Quantity_Return__c) * obj.ERP7__Quantity_Return__c;
            component.set("v.RMALI",obj);
        }
        	
    },
    EditRMA:function(component, event, helper){
        component.set("v.EditRMA",true);
    },
    back:function(component, event, helper){}, 
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");    
    },
 // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
         $A.util.removeClass(spinner, "slds-hide");   
    },
    fetchSiteDetails : function (component, event, helper) {
        if(component.get("v.site.Id") != null){
        var siteDetailsAction = component.get("c.getSiteDetails");
            siteDetailsAction.setParams({"recordId":component.get("v.site.Id")});
        siteDetailsAction.setCallback(this,function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){ 
                if(response.getReturnValue())
                 component.set("v.SiteAddressId",response.getReturnValue());
                else{
                   component.set("v.SiteAddressId",''); 
                }
               
            }else{
                helper.handleErrors(component,response.getError());
            }
        });
        
        $A.enqueueAction(siteDetailsAction);
        }else{
            component.set("v.SiteAddressId",''); 
        }
    },
    fetchSiteDetailsByDC : function (component, event, helper) {
        if(component.get("v.DistributeChannel.Id") != null){
        var siteDetailsActionDC = component.get("c.getSiteDetailsbyDC");
            siteDetailsActionDC.setParams({"recordId":component.get("v.DistributeChannel.Id")});
        siteDetailsActionDC.setCallback(this,function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                if(response.getReturnValue()){
                    if(!$A.util.isEmpty(response.getReturnValue()) && !$A.util.isEmpty(response.getReturnValue().ERP7__Site__c) ){
                        component.set("v.site.Id",response.getReturnValue().ERP7__Site__c);
                        component.set("v.site.Name",response.getReturnValue().ERP7__Site__r.Name);
                    }
                }

                else{
                    component.set("v.site.Id",null);
                    component.set("v.site.Name",null); 
                }
               
            }else{
                helper.handleErrors(component,response.getError());
            }
        });
        
        $A.enqueueAction(siteDetailsActionDC);
        }else{
            component.set("v.site.Id",null);
            component.set("v.site.Name",null); 
        }
    },
    
    CreatePO : function(component, event, helper){
        
        var rmaId = event.currentTarget.getAttribute('data-recordId');
        $A.createComponent("c:CreatePurchaseOrder",{
            "rmaliID":rmaId,
            "cancelclick":component.getReference("c.backTO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
            var body = component.find("body");
            body.set("v.body", newCmp);
        }
        });
    },
    
    backTO : function(component,event,helper){
       
       $A.createComponent("c:RMA",{
           "RMA_lookup.Id" :component.get("v.RMA_lookup.Id")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                let rmaID  = component.get("v.RMA_lookup.Id");
                let name = component.get("v.RMA_lookup.Name");
                newCmp.set("v.RMA_lookup.Id",rmaID);
                newCmp.set("v.RMA_lookup.Name",name);
                var body = component.find("body");
                body.set("v.body", newCmp);
        }
        }); 
    },
    
    CreateWO : function(component, event, helper){
        var rmaId = event.currentTarget.getAttribute('data-rmarecordId');
        var URL_RMA = '/apex/ERP7__WorkOrderLC?rmarecordId='+rmaId;
        window.open(URL_RMA,'_blank');
    },
    fetchRMALIByInvId : function(component, event, helper){
         if(!$A.util.isEmpty(component.get("v.RMA.ERP7__Invoice__c"))){
            var fetchaction = component.get("c.Build_RMALIByInvoice");
            fetchaction.setParams({"InvoiceId":component.get("v.RMA.ERP7__Invoice__c")}); 
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
                                component.set("v.channelId",customerdata.ERP7__Order__r.ERP7__Channel__c);
                            var con = {};
                            if(!$A.util.isEmpty(customerdata.ERP7__Order__r.ERP7__Contact__c)){
                                con.Id =customerdata.ERP7__Order__r.ERP7__Contact__c;
                                con.Name=customerdata.ERP7__Order__r.ERP7__Contact__r.Name;
                            }
                           
                            if(!$A.util.isEmpty(customerdata.ERP7__Order__c)){
                                component.set("v.RMA.ERP7__SO__c",customerdata.ERP7__Order__c);
                            }
                            
                            component.set("v.CustContact",con);
                            var addr = {};
                            if(!$A.util.isEmpty(customerdata.ERP7__Order__r.ERP7__Ship_To_Address__c)){
                                addr.Id =customerdata.ERP7__Order__r.ERP7__Ship_To_Address__c;
                                addr.Name=customerdata.ERP7__Order__r.ERP7__Ship_To_Address__r.Name;
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
                                "message":'No Items To Return For Selected Invoice.'
                            });
                            toastEvent.fire();
                        }else{
                            let msg = component.get('v.message');
                            msg['Title'] = title;
                            msg['Severity']=type;
                            msg['Text'] = 'No Items To Return For Selected Invoice.';
                            component.set('v.message',msg);
                        }
                    }
                }else{
                    helper.handleErrors(component,response.getError());
                }
            });
            if($A.util.isEmpty(component.get("v.RMA.Id")))
           	 	$A.enqueueAction(fetchaction);
        }
        else{
            if(!component.reset)
            helper.resetAttribute(component,event);
        }
    }
})