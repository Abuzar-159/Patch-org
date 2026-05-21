({
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
    
    SOLIDOInit: function(component, event, helper) {
        var action = component.get("c.populateSOLI");
        if(component.get("v.soliID") != null){
            action.setParams({
                soliID:component.get("v.soliID")
            });
            action.setCallback(this, function(a) {
                var prliList = component.get("v.prli");
                prliList.unshift(a.getReturnValue());
                component.set("v.prli",prliList);
            });
        }    
        $A.enqueueAction(action);
    },
    
    OrdItmDOInit : function(cmp,event,helper){
        var orderId=cmp.get('v.orderId');
        var action=cmp.get('c.populateOrdItems');
        action.setParams({
            "orderId1":orderId
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                if(response.getReturnValue() == null){
                    cmp.set('v.exceptionError', $A.get('$Label.c.No_line_items_without_stock'));  
                }
                else{
                    var pli = response.getReturnValue().wPOLIs;
                    var stocklst = response.getReturnValue().productStocks;
                    for(var x in pli){
                        for(var y in stocklst){
                            if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                pli[x].demand = stocklst[y].Demand;
                                pli[x].ItemsinStock = stocklst[y].Stock;
                            }
                        }
                    }
                    cmp.set("v.prli",pli);   
                }
                
                
            }
            else{
                var error1=response.getError();
                cmp.set('v.exceptionError',error1[0].message);
            }
            this.getExistingPR(cmp, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    mrplineInit: function(component, event, helper) {
        var action = component.get("c.populateMrpline");
        if(component.get("v.mrplineId") != null){
            action.setParams({
                mrplineId:component.get("v.mrplineId")
            });
            action.setCallback(this, function(a) {
                var prliList = component.get("v.prli");
                
                //imran added for quantityMultiplier
                var poli = a.getReturnValue().poli;
                poli.ERP7__Quantity__c = poli.ERP7__Quantity__c/component.get("v.quantityMultiplier")
                
                prliList.unshift(poli);
                component.set("v.prli",prliList);
                component.set("v.MPsMOId",a.getReturnValue().MOId);
            });
        }    
        $A.enqueueAction(action);
    },
    
    MOInit: function(component, event, helper) {
        if(component.get("v.MOId") != null){
            component.set("v.PR.ERP7__Manufacturing_Order__c",component.get("v.MOId")); 
            var action = component.get("c.populateMOlines");
            action.setParams({
                MOId:component.get("v.MOId")
            });
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS"){
                    var pli = response.getReturnValue().wPOLIs;
                    var stocklst = response.getReturnValue().productStocks;
                    for(var x in pli){
                        for(var y in stocklst){
                            if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                pli[x].demand = stocklst[y].Demand;
                                pli[x].ItemsinStock = stocklst[y].Stock;
                            }
                        }
                    }
                    component.set("v.prli",pli);
                }
                //component.set("v.prli",a.getReturnValue());
            });
            $A.enqueueAction(action);
        }  
    },
    
    WOInit: function(component, event, helper) {
        if(component.get("v.WOId") != null){
            component.set("v.PR.ERP7__Work_Order__c",component.get("v.WOId")); 
            var action = component.get("c.populateWOlines");
            action.setParams({
                WOId:component.get("v.WOId")
            });
            action.setCallback(this, function(a) {
                component.set("v.prli",a.getReturnValue());
            });
            $A.enqueueAction(action);
        }  
    },
    
    validationCheckName : function (component, event) {
        var NOerrorsval = true;
        var NOerrorsPRq = true;
        var prName = component.find("prName");
        if(!$A.util.isUndefined(prName))
            NOerrorsval =  this.checkValidationField(prName);
        
        var prliList = component.find("prli");
        if(!$A.util.isUndefined(prliList))
            if(prliList.length>0){
                let flag = true;
                for(let x  in prliList)
                    flag = prliList[x].callValidate(); 
                if(!flag) return false;
                // else return flag;
            }else{
                NOerrorsPRq = prliList.callValidate(); 
            }
        console.log('NOerrorsPRq : ',NOerrorsPRq);
        console.log('NOerrorsval : ',NOerrorsval);
        var NOerrors = NOerrorsPRq && NOerrorsval;
        console.log('NOerrors : ',NOerrors);
        return NOerrors;
    },
    
    validationCheckDC : function (component, event) {
        var NOerrorsval = true;
        var NOerrorsPRq = true;
        var DCId = component.find("dcId");
        if(!$A.util.isUndefined(DCId))
            NOerrorsval =  this.checkvalidationLookup(DCId);
        
        var prliList = component.find("prli");
        if(!$A.util.isUndefined(prliList))
            if(prliList.length>0){
                let flag = true;
                for(let x  in prliList)
                    flag = prliList[x].callValidate(); 
                if(!flag) return false;
                // else return flag;
            }else{
                NOerrorsPRq = prliList.callValidate(); 
            }
        var NOerrors = NOerrorsPRq && NOerrorsval;
        return NOerrors;
    },
    
    validationCheckCh : function (component, event) {
        var NOerrorsval = true;
        var NOerrorsPRq = true;
        var CHId = component.find("chId");
        if(!$A.util.isUndefined(CHId))
            NOerrorsval =  this.checkvalidationLookup(CHId);
        
        var prliList = component.find("prli");
        if(!$A.util.isUndefined(prliList))
            if(prliList.length>0){
                let flag = true;
                for(let x  in prliList)
                    flag = prliList[x].callValidate(); 
                if(!flag) return false;
                // else return flag;
            }else{
                NOerrorsPRq = prliList.callValidate(); 
            }
        var NOerrors = NOerrorsPRq && NOerrorsval;
        return NOerrors;
    },
    
    checkvalidationLookup : function(poli_List){
        if($A.util.isEmpty(poli_List.get("v.selectedRecord.Id"))){
            poli_List.set("v.inputStyleclass","hasError");
            return false;
        }else{
            poli_List.set("v.inputStyleclass",""); 
            return true;
        }
    },
    
    checkValidationField : function(cmp){
        if($A.util.isEmpty(cmp.get("v.value"))){
            cmp.set("v.class","hasError");
            return false;
        }else{
            cmp.set("v.class","");
            return true;
        }
        
    },
    
    displayRecords: function(component, event, helper) {
        var initaction = component.get("c.fetchChannelandDC");
        initaction.setParams({
            OId:component.get("v.orderId"),
            SOLIId : component.get("v.soliID")
        });
        initaction.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                try{ 
                    var obj = response.getReturnValue();
                    if(!$A.util.isEmpty(obj.distributionChannel.Id)){
                        component.set("v.distributionChannel.Id",obj.distributionChannel.Id);
                        component.set("v.distributionChannel.Name",obj.distributionChannel.Name);
                        component.set("v.Channel.Name",obj.distributionChannel.ERP7__Channel__r.Name);
                        component.set("v.channelId",obj.distributionChannel.ERP7__Channel__c);
                        component.set("v.PR.ERP7__Organisation__r.Id",obj.OrgAcc.Id);
                        component.set("v.PR.ERP7__Organisation__r.Name",obj.OrgAcc.Name);
                        component.set("v.PR.ERP7__Delivery_Contact__r.Id",obj.DeliveryCon.Id);
                        component.set("v.PR.ERP7__Delivery_Contact__r.Name",obj.DeliveryCon.Name);
                        component.set("v.PR.ERP7__Delivery_Address__r.Name",obj.DeliveryAdd.Name);
                        component.set("v.PR.ERP7__Delivery_Address__r.Id",obj.DeliveryAdd.Id);
                        component.set("v.PR.ERP7__Employee_Requester__c",obj.emplRequester.Id);
                        component.set("v.PR.ERP7__Originating_Business_Unit__r",obj.BusinessUnit);
                        var vBillDate = new Date();
                        vBillDate.setDate(vBillDate.getDate());
                        component.set("v.PR.ERP7__Expected_Delivery_Date__c", vBillDate.getFullYear() + "-" + (vBillDate.getMonth()) + "-" + (vBillDate.getDate() + 1));
                        component.set("v.isSalesOrder",obj.salesAccess);
                        if(component.get("v.soliID") != null || component.get("v.soliID") != undefined || component.get("v.soliID") != ''){ component.set("v.PR.ERP7__Sales_Order__c",obj.SOID1);}
                    }
                }catch(ex){
                    //('fetchChannelandDC catch enter');
                } 
            }
        });
        $A.enqueueAction(initaction);
    },
    
    validationCheckQuantity : function (component, event, helper) {
        var isErrors = false; 
        // var isErrorsUP = false;
        var qtyElem=[]; 
        qtyElem=component.get("v.prli");  
        var qtyElem1=[]; 
        qtyElem1=component.find("qty");
        try{  
            for(var i in qtyElem){   
                if(qtyElem[i].ERP7__Quantity__c<=0 || qtyElem[i].ERP7__Quantity__c==undefined || qtyElem[i].ERP7__Quantity__c=='') {
                    //component.set("v.qmsg",'not valid');
                    isErrors=true;
                    return isErrors;
                }
                else{ 
                    
                    isErrors=false; 
                } 
                
                /*  if(qtyElem[i].ERP7__Price__c<=0 || qtyElem[i].ERP7__Price__c=='' || qtyElem[i].ERP7__Price__c==undefined) {
                 component.set("v.qmsg",'not valid');
                isErrorsUP=true; return isErrorsUP;
              
             }
             else{ 
               
               isErrorsUP=false;
             }  */                  
             
             
         }   
        }catch(ex){}
        
        return isErrors;
    },
    validationCheckUnitPrice : function (component, event, helper) {
        // var isErrors = false; 
        var isErrorsUP = false;
        var qtyElem=[]; 
        qtyElem=component.get("v.prli");  
        var qtyElem1=[]; 
        qtyElem1=component.find("qty");
        
        try{  
            for(var i in qtyElem){  
                /* if(qtyElem[i].ERP7__Quantity__c<=0 || qtyElem[i].ERP7__Quantity__c==undefined || qtyElem[i].ERP7__Quantity__c=='') {
                 component.set("v.qmsg",'not valid');
                 isErrors=true;
                 return isErrors;
              
             }
             else{ 
              
               isErrors=false; 
             } */
             
             if(qtyElem[i].ERP7__Price__c<=0 || qtyElem[i].ERP7__Price__c=='' || qtyElem[i].ERP7__Price__c==undefined) {
                 //component.set("v.qmsg",'not valid');
                 isErrorsUP=true; return isErrorsUP;
             }
             else{ 
                 
                 isErrorsUP=false; 
             }                   
             
             
         }   
        }catch(ex){}
        return isErrorsUP;
    },
    
    
    goBackTaskM : function(component, event) {
        $A.createComponent("c:AddMilestoneTask",{
            "aura:id" : "taskCmp",
            "projectId" : component.get("v.projectId"),
            "taskId" : component.get("v.Mtask.Id"),
            "newTask" : component.get("v.Mtask"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    }, 
    getExistingPR : function(comp, event, helper){ //$A.util.removeClass(comp.find("cnvrtLogBtnId"),'a_disabled');  
        
        var action=comp.get("c.getExistingPReq"); 
        action.setParams({"SOId":comp.get("v.SalesId"),
                          "OrderId":comp.get("v.orderId")});   
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (comp.isValid() && state === "SUCCESS") {          
                comp.set("v.PRExisting",response.getReturnValue());
                // this.getLLIDeleteSingle(comp, event, helper);
            }
        });
        $A.enqueueAction(action);
        
    },
    PopulateFields :  function(comp, event, helper){
        var OrId =  comp.get('v.orderId');
    },
    SalesDOInit : function(cmp,event,helper){
        var soliID=cmp.get('v.SalesId');
        var orderId=cmp.get('v.orderId');
        var action=cmp.get('c.populateOrdItems');
        action.setParams({
            "orderId1":orderId,
            "SalesId":soliID
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                if(response.getReturnValue() != null){
                    var pli = response.getReturnValue().wPOLIs;
                    var stocklst = response.getReturnValue().productStocks;
                    for(var x in pli){
                        for(var y in stocklst){
                            if(pli[x].ERP7__Product__c == stocklst[y].Product){
                                pli[x].AwaitingStock = stocklst[y].AwaitingStocks;
                                pli[x].demand = stocklst[y].Demand;
                                pli[x].ItemsinStock = stocklst[y].Stock;
                            }
                        }
                    }
                    cmp.set("v.prli",pli);
                    cmp.set("v.PR.ERP7__Sales_Order__c",cmp.get('v.SalesId'));
                }
                else{
                    cmp.set('v.exceptionError',$A.get('$Label.c.No_Products_Available_for_Requisition'));
                }
            }
            else{
                var error1=response.getError();
                cmp.set('v.exceptionError',error1[0].message);
            }
            this.getExistingPR(cmp, event, helper);
        });
        $A.enqueueAction(action);
    },    
    
})