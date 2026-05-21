({
    doini: function(comp, event, helper) {
        $A.util.removeClass(comp.find('mainSpin'), "slds-hide");	
        var action = comp.get("c.getInstances");    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") {  
                comp.set("v.Logistic",response.getReturnValue().Logistic); 
                comp.set("v.LogisticLI",response.getReturnValue().LogisticLI);
                comp.set("v.LogisticTypeList",response.getReturnValue().LogisticTypeList);
                comp.set("v.showReadyToShip",response.getReturnValue().showReadyToShip);
                comp.set("v.allowEditName",response.getReturnValue().allowEdit);
                comp.set("v.allowChannelRemove",response.getReturnValue().dontallowChannelRemove );
                comp.set("v.showShipDetails",response.getReturnValue().showShipmentDetails);
                comp.set("v.ShowReturnShipSection",response.getReturnValue().ShowReturnShipSection);
                $A.util.addClass(comp.find('mainSpin'), "slds-hide");
            }else{
                $A.util.addClass(comp.find('mainSpin'), "slds-hide");
                var error1=response.getError();
                console.log('Error :',error1);
                comp.set('v.exceptionError',error1[0].message);
            }         
        });
        $A.enqueueAction(action);  
    },
    
    fetchOrdItemList: function(component,event,helper){
        console.log('fetchOrdItemList called');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");	
        component.set("v.channelId",'');   
        //component.set("v.DistributeChannelId",''); 
        //component.set("v.Logistic.ERP7__Account__c",'');   
        var action = component.get("c.getordItemList");    
        action.setParams({
            "orderId":component.get("v.orderId")          
        }); // "DistributeChannelId":component.get("v.DistributeChannelId") 
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                component.set("v.LLIList",[]); 
                console.log('ordlist from fetchOrdItemList~>',response.getReturnValue());
                
                let ordList = response.getReturnValue().OrdList;    
                for(var x in ordList){
                    if(ordList[x].checked == undefined) ordList[x].checked = false; 
                }
                component.set("v.OrdItemList",ordList);
                console.log('v.OrdItemList from fetchOrdItemList~>',component.get("v.OrdItemList"));
                component.set("v.BomItemList",response.getReturnValue().BOMS);
                
                //sorting arshad
                if(response.getReturnValue().OrdList.length > 0){
                    var sortAsc = false,
                        table = component.get("v.OrdItemList");
                    table.sort(function (a, b) {
                        if (($A.util.isEmpty(a.ERP7__Reserved_Quantity__c) || $A.util.isUndefinedOrNull(a.ERP7__Reserved_Quantity__c)) && ($A.util.isEmpty(b.ERP7__Reserved_Quantity__c) || $A.util.isUndefinedOrNull(b.ERP7__Reserved_Quantity__c))) return 0;
                        if (sortAsc) {
                            if ($A.util.isEmpty(b.ERP7__Reserved_Quantity__c) || $A.util.isUndefinedOrNull(b.ERP7__Reserved_Quantity__c)) return 1;
                            if ($A.util.isEmpty(a.ERP7__Reserved_Quantity__c) || $A.util.isUndefinedOrNull(a.ERP7__Reserved_Quantity__c)) return -1;
                        } else {
                            if ($A.util.isEmpty(b.ERP7__Reserved_Quantity__c) || $A.util.isUndefinedOrNull(b.ERP7__Reserved_Quantity__c)) return -1;
                            if ($A.util.isEmpty(a.ERP7__Reserved_Quantity__c) || $A.util.isUndefinedOrNull(a.ERP7__Reserved_Quantity__c)) return 1;
                        }
                        
                        var t1 = a.ERP7__Reserved_Quantity__c == b.ERP7__Reserved_Quantity__c,
                            t2 = a.ERP7__Reserved_Quantity__c > b.ERP7__Reserved_Quantity__c;
                        return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? -1 : 1);
                    });
                }
                
                let order = response.getReturnValue().Ord;
                
                console.log('order Ship 1 : ',JSON.stringify(order));
                if(!$A.util.isEmpty(response.getReturnValue().Ord.AccountId) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.AccountId)) component.set("v.Logistic.ERP7__Account__c",response.getReturnValue().Ord.AccountId); 
                if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Contact__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Contact__c)) component.set("v.Logistic.ERP7__Contact__c",response.getReturnValue().Ord.ERP7__Contact__c); 
                if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Ship_To_Address__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Ship_To_Address__c)) component.set("v.Logistic.ERP7__To_Address__c",response.getReturnValue().Ord.ERP7__Ship_To_Address__c); 
                if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Channel__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Channel__c)) component.set("v.channelId",response.getReturnValue().Ord.ERP7__Channel__c); 
                if(!$A.util.isEmpty(response.getReturnValue().DistributeChannelId) && !$A.util.isUndefinedOrNull(response.getReturnValue().DistributeChannelId) && (component.get("v.DistributeChannelId") == null || component.get("v.DistributeChannelId") == undefined || component.get("v.DistributeChannelId") == '')) component.set("v.DistributeChannelId",response.getReturnValue().DistributeChannelId);
                if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Bill_To_Address__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Bill_To_Address__c))  component.set("v.Logistic.ERP7__Billing_Address__c",response.getReturnValue().Ord.ERP7__Bill_To_Address__c); 
                //added by shaguftha on 02_07_24
                if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Ship_From_Address__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Ship_From_Address__c))  component.set("v.Logistic.ERP7__From_Address__c",response.getReturnValue().Ord.ERP7__Ship_From_Address__c); 
                if(!$A.util.isEmpty(response.getReturnValue().fromContact) && !$A.util.isUndefinedOrNull(response.getReturnValue().fromContact)) component.set("v.Logistic.ERP7__From_Contact__c",response.getReturnValue().fromContact);
                
                console.log('Ord ERP7__Shipment_Type__c 1 : ',order.ERP7__Shipment_Type__c);
                component.set("v.Logistic.ERP7__Shipment_type__c",response.getReturnValue().Ord.ERP7__Shipment_Type__c);
                component.set("v.Logistic.ERP7__Special_Instructions__c",response.getReturnValue().Ord.Description);
                console.log('log ERP7__Shipment_Type__c 2 : ',component.get("v.Logistic.ERP7__Shipment_type__c"));
                //component.set("v.Logistic.ERP7__Shipping_Preferences__c",response.getReturnValue().Ord.ERP7__Shipment_Preference_Speed__c); 
                
                //Added by Arshad 26 Oct 2023
                if(response.getReturnValue().ShowReturnShipSection){
                    
                    console.log('ERP7__Shipment_type_Return__c here1~>'+component.get("v.Logistic.ERP7__Shipment_type_Return__c"));
                    
                    if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Shipment_type_Return__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Shipment_type_Return__c)){
                        component.set("v.Logistic.ERP7__Shipment_type_Return__c",response.getReturnValue().Ord.ERP7__Shipment_type_Return__c);
                        console.log('ord ERP7__Shipment_type_Return__c 2 : ',component.get("v.Logistic.ERP7__Shipment_type_Return__c"));
                    }
                    
                    console.log('ERP7__Shipment_type_Return__c here2~>'+component.get("v.Logistic.ERP7__Shipment_type_Return__c"));
                    
                    if($A.util.isEmpty(component.get("v.Logistic.ERP7__Shipment_type_Return__c")) || $A.util.isUndefinedOrNull(component.get("v.Logistic.ERP7__Shipment_type_Return__c"))){
                        var RlistControllingValues = component.get("v.RlistControllingValues");
                        console.log('RlistControllingValues~>',RlistControllingValues);
                        if(RlistControllingValues != undefined && RlistControllingValues != null){
                            if(RlistControllingValues.length > 0){
                                component.set("v.Logistic.ERP7__Shipment_type_Return__c",RlistControllingValues[0]);
                                console.log('ERP7__Shipment_type_Return__c here3~>'+component.get("v.Logistic.ERP7__Shipment_type_Return__c"));
                            }
                        }
                    }
                    
                    if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Bill_To_Return__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Bill_To_Return__c)){
                        component.set("v.Logistic.ERP7__Bill_To_Return__c",response.getReturnValue().Ord.ERP7__Bill_To_Return__c); 
                    }
                    if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Billing_Account_Number_Return__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Billing_Account_Number_Return__c)){
                        component.set("v.Logistic.ERP7__Billing_Account_Number_Return__c",response.getReturnValue().Ord.ERP7__Billing_Account_Number_Return__c); 
                    }
                    if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Billing_Address_Return__c ) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Billing_Address_Return__c)){
                        component.set("v.Logistic.ERP7__Billing_Address_Return__c",response.getReturnValue().Ord.ERP7__Billing_Address_Return__c); 
                    }
                    if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Billing_Contact_Return__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Billing_Contact_Return__c)){
                        component.set("v.Logistic.ERP7__Billing_Contact_Return__c",response.getReturnValue().Ord.ERP7__Billing_Contact_Return__c); 
                    }
                    if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Shipment_type_Return__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Shipment_type_Return__c)){
                        if(!$A.util.isEmpty(response.getReturnValue().Ord.ERP7__Shipping_Preferences_Return__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().Ord.ERP7__Shipping_Preferences_Return__c)){
                            component.set("v.Logistic.ERP7__Shipping_Preferences_Return__c",response.getReturnValue().Ord.ERP7__Shipping_Preferences_Return__c); 
                        }
                    }
                }
                
                
                component.set("v.isReadyToPickPack",response.getReturnValue().isReadyToPickPack);
                
                
                component.set("v.showSDBool",false);
                component.set("v.showSDBool",true);                                           
                if(component.get("v.selectedTab")=='log'){     
                    component.set("v.selectedTab",'soli');
                    component.set("v.selectedTab",'log');
                }
                else if(component.get("v.selectedTab")=='soli'){
                    component.set("v.selectedTab",'log');
                    component.set("v.selectedTab",'soli');                                                  
                }     
                setTimeout($A.getCallback(function(){
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }),3000);
                
                this.getLogisticExisting(component, event, helper);
            }else{
                var error1=response.getError();
                console.log('Error :',error1);
                component.set('v.exceptionError',error1[0].message);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            
        });
        $A.enqueueAction(action);          
    },
    
    fetchSoliList:function(component, event, helper){ 
        console.log('fetchSoliList called');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");	
        component.reset=true;
        component.set("v.channelId",'');   component.set("v.DistributeChannelId",''); component.set("v.Logistic.ERP7__Account__c",'');   
        var action = component.get("c.getSoliList");    
        action.setParams({
            "SOId":component.get("v.SOId")          
        }); // "DistributeChannelId":component.get("v.DistributeChannelId") 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.LLIList",[]); 
                console.log('SoliList : ',response.getReturnValue());
                // if(response.getReturnValue()!=null){                                             
                component.set("v.SoliList",response.getReturnValue().SoliList);
                if(!$A.util.isEmpty(response.getReturnValue().SO.ERP7__Account__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().SO.ERP7__Account__c)) component.set("v.Logistic.ERP7__Account__c",response.getReturnValue().SO.ERP7__Account__c); 
                if(!$A.util.isEmpty(response.getReturnValue().SO.ERP7__Contact__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().SO.ERP7__Contact__c)) component.set("v.Logistic.ERP7__Contact__c",response.getReturnValue().SO.ERP7__Contact__c); 
                if(!$A.util.isEmpty(response.getReturnValue().SO.ERP7__Ship_To_Address__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().SO.ERP7__Ship_To_Address__c)) component.set("v.Logistic.ERP7__To_Address__c",response.getReturnValue().SO.ERP7__Ship_To_Address__c); 
                if(!$A.util.isEmpty(response.getReturnValue().SO.ERP7__Channel__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().SO.ERP7__Channel__c)) component.set("v.channelId",response.getReturnValue().SO.ERP7__Channel__c); 
                if(!$A.util.isEmpty(response.getReturnValue().DistributeChannelId) && !$A.util.isUndefinedOrNull(response.getReturnValue().DistributeChannelId)) component.set("v.DistributeChannelId",response.getReturnValue().DistributeChannelId);
                
                //added by shaguftha on 02_07_24
                if(!$A.util.isEmpty(response.getReturnValue().SO.ERP7__Ship_From_Address__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().SO.ERP7__Ship_From_Address__c))  component.set("v.Logistic.ERP7__From_Address__c",response.getReturnValue().SO.ERP7__Ship_From_Address__c); 
                if(!$A.util.isEmpty(response.getReturnValue().fromContact) && !$A.util.isUndefinedOrNull(response.getReturnValue().fromContact)) component.set("v.Logistic.ERP7__From_Contact__c",response.getReturnValue().fromContact);
                
                component.set("v.isReadyToPickPack",response.getReturnValue().isReadyToPickPack);
                
                component.set("v.showSDBool",false);
                component.set("v.showSDBool",true);                                           
                if(component.get("v.selectedTab")=='log'){                                              
                    component.set("v.selectedTab",'soli');
                    component.set("v.selectedTab",'log');
                }
                else if(component.get("v.selectedTab")=='soli'){
                    component.set("v.selectedTab",'log');
                    component.set("v.selectedTab",'soli');                                                  
                } 
                // $A.util.addClass(component.find('mainSpin'), "slds-hide");
                this.getLogisticExisting(component, event, helper);
                
            }else{
                var error1=response.getError();
                console.log('Error :',error1);
                component.set('v.exceptionError',error1[0].message);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }        
        });
        $A.enqueueAction(action);  
        
    },
 // matheen changed on 6/8/265  for GIIH 684 wrong referrence 
    fetchPOItemList : function(component,event,helper){
        console.log('fetchPOItemList called');
        console.log('inside');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");	
        component.set("v.channelId",'');   component.set("v.DistributeChannelId",''); component.set("v.Logistic.ERP7__Account__c",'');   
        var action=component.get("c.getPOItemList");
        action.setParams({
            "POId":component.get("v.POId")
        });
        action.setCallback(this, function(response){
            if(response.getState()=="SUCCESS"){
                component.set("v.LLIList",[]); 
                //console.log('vendor address ',response.getReturnValue().PO.ERP7__Vendor_Address__c);
                component.set("v.POItemList",response.getReturnValue().POList);
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Vendor__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Vendor__c)) component.set("v.Logistic.ERP7__Account__c",response.getReturnValue().PO.ERP7__Vendor__c); 
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Shipment_Type__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Shipment_Type__c)) component.set("v.Logistic.ERP7__Shipment_Type__c",response.getReturnValue().PO.ERP7__Shipment_Type__c); 
                //if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Shipment_Preference_Speed__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Shipment_Preference_Speed__c)) component.set("v.Logistic.ERP7__Shipping_Preferences__c",response.getReturnValue().PO.ERP7__Shipment_Preference_Speed__c); 
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Vendor_Contact__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Vendor_Contact__c)) component.set("v.Logistic.ERP7__From_Contact__c",response.getReturnValue().PO.ERP7__Vendor_Contact__c); 
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Channel__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Channel__c)) component.set("v.channelId",response.getReturnValue().PO.ERP7__Channel__c); 
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Distribution_Channel__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Distribution_Channel__c)) component.set("v.DistributeChannelId",response.getReturnValue().PO.ERP7__Distribution_Channel__c);
                 //added by matheen
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Vendor_Address__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Vendor_Address__c)) component.set("v.Logistic.ERP7__From_Address__c",response.getReturnValue().PO.ERP7__Vendor_Address__c); 
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Address__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Address__c)) component.set("v.Logistic.ERP7__To_Address__c",response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Address__c);
                //added by shaguftha on 02_07_24
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Primary_Contact__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Primary_Contact__c))  component.set("v.Logistic.ERP7__Contact__c",response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Primary_Contact__c); 
                if(!$A.util.isEmpty(response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Address__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Address__c)) component.set("v.Logistic.ERP7__Billing_Address__c",response.getReturnValue().PO.ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Address__c);
                
                component.set("v.isReadyToPickPack",false);
                
                component.set("v.showSDBool",false);
                component.set("v.showSDBool",true);                                           
                if(component.get("v.selectedTab")=='log'){     
                    component.set("v.selectedTab",'soli');
                    component.set("v.selectedTab",'log');
                }
                else if(component.get("v.selectedTab")=='soli'){
                    component.set("v.selectedTab",'log');
                    component.set("v.selectedTab",'soli');                                                  
                }              
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                this.getLogisticExisting(component, event, helper);
                
            }else{
                var error1=response.getError();
                console.log('Error fetchPOItemList:',error1);
                component.set('v.exceptionError',error1[0].message);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action); 
    },
    
    fetchStoreAddress : function(component, event, helper, channelId) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");	
        var action = component.get("c.getStoreAddress");    
        action.setParams({
            "chanId":channelId           
        });   
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") { 
                if(response.getReturnValue()!=null){
                    console.log('setting dc from fetchStoreAddress');
                    component.set("v.DistributeChannelId",response.getReturnValue()); 
                    component.set("v.showSDBool",false); 
                    component.set("v.showSDBool",true);
                }  
                $A.util.addClass(component.find('mainSpin'), "slds-hide");

               /* setTimeout($A.getCallback(function(){
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }),3000);*/
            }else{
               /* setTimeout($A.getCallback(function(){
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }),3000);*/
                $A.util.addClass(component.find('mainSpin'), "slds-hide");

                var error1=response.getError();
                console.log('Error fetchStoreAddress:',error1);
                component.set('v.exceptionError',error1[0].message);
            }          
        });
        $A.enqueueAction(action);        
    },
    
    validateMandatoryFieldsParent: function(component,event, helper) {
        var Logistic=component.get("v.Logistic");
        if(component.get("v.POId") != ''){
            if(this.trim(Logistic.Name)==false || this.trim(Logistic.ERP7__Account__c)==false
               || this.trim(component.get("v.channelId"))==false || this.trim(component.get("v.DistributeChannelId"))==false){           
                // this.showToast('dismissible','', 'Error', 'All * Fields are mandatory',component);  
                return false;
            }else return true;
        }else{
            if(this.trim(Logistic.Name)==false || this.trim(Logistic.ERP7__Account__c)==false || this.trim(Logistic.ERP7__To_Address__c)==false
               || this.trim(component.get("v.channelId"))==false || this.trim(component.get("v.DistributeChannelId"))==false){           
                // this.showToast('dismissible','', 'Error', 'All * Fields are mandatory',component);  
                return false;
            }else return true;
        }
    },
    
    validateMandatoryFieldsChild:function(component,event, helper) {
        var LLIList=component.get('v.LLIList');
        var checkBool=false;  
        for(var i in LLIList){ 
            if(this.trim(LLIList[i].Name)==false || this.trim(LLIList[i].ERP7__Product__c)==false || this.trim(LLIList[i].ERP7__Quantity__c)==false){                 
                checkBool=false; return false;  //break;
            }else checkBool=true; //return true; 
        }
        return checkBool; 
    },
    
    createLogistic : function(component, event, helper) {  
        try{    console.log('in helper create logistic');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");	
        var validateMFBoolParent=this.validateMandatoryFieldsParent(component, event, helper);
        var validateMFBoolChild=this.validateMandatoryFieldsChild(component, event, helper);  
        var SoliList =[]; SoliList=component.get("v.SoliList"); 
        var OrdItemList=[]; OrdItemList=component.get('v.OrdItemList');
        var POItemList=[]; POItemList=component.get('v.POItemList');
        console.log('POItemList ',JSON.stringify(POItemList));
        if(validateMFBoolParent == true && validateMFBoolChild == true){ 
            if(component.get("v.QuantityErrorMsg") == ''){     
                if(SoliList.length > 0) component.set("v.Logistic.ERP7__Sales_Order__c",component.get("v.SOId")); 
                else if(OrdItemList.length > 0) component.set("v.Logistic.ERP7__Order_S__c",component.get("v.orderId"));
                    else if(POItemList.length > 0) component.set("v.Logistic.ERP7__Purchase_Order__c",component.get("v.POId"));
                component.set("v.Logistic.ERP7__Channel__c",component.get("v.channelId"));  
                component.set("v.Logistic.ERP7__Distribution_Channel__c",component.get("v.DistributeChannelId"));
                component.set("v.Logistic.ERP7__Active__c",true);
                if(component.get("v.POId") != '') component.set("v.Logistic.ERP7__Type__c",'Inbound');
                else component.set("v.Logistic.ERP7__Type__c",'Outbound');
                
                var action = component.get("c.getCreateLogistic");
                var Logistic=component.get("v.Logistic");  
                console.log('Logistic : ',JSON.stringify(Logistic));
                var LogisticJSON = JSON.stringify(Logistic);   
                var LLIList = component.get("v.LLIList");
                 var LLIListJSON=JSON.stringify(LLIList); 
                var OrderLineItems = component.get("v.OrdItemList"); // Ensure this is defined and initialized
                var OrderLineItems2return = [];
                var addedOrderItemIds = new Set();
                
                console.log('OrderLineItems before: ', OrderLineItems);
                
                var orderLineItemsMap = new Map();
                for (var i = 0; i < OrderLineItems.length; i++) {
                    orderLineItemsMap.set(OrderLineItems[i].Id, OrderLineItems[i]);
                }
                
               /* for (var x = 0; x < LLIList.length; x++) {
                    if (LLIList[x].ERP7__Order_Product__c && orderLineItemsMap.has(LLIList[x].ERP7__Order_Product__c)) {
                        OrderLineItems2return.push(orderLineItemsMap.get(LLIList[x].ERP7__Order_Product__c));
                    }
                }*/
                for (var x = 0; x < LLIList.length; x++) {
                    var orderProdId = LLIList[x].ERP7__Order_Product__c;
                    if (orderProdId && orderLineItemsMap.has(orderProdId) && !addedOrderItemIds.has(orderProdId)) {
                        OrderLineItems2return.push(orderLineItemsMap.get(orderProdId));
                        addedOrderItemIds.add(orderProdId);  // Ensure unique
                    }
                }
                
                var OrderLineItemsJSON = JSON.stringify(OrderLineItems2return);
                console.log('OrderLineItemsJSON after: ', OrderLineItemsJSON);

                // var bomwrap = component.get("v.BomItemList");
                
                // var bomlist = [];
                // for(var i in bomwrap){
                //     bomlist[i] = bomwrap[i].Bom;
                // }
                
                // var BomItemsJSON =  JSON.stringify(bomlist);
                // action.setParams({
                //     "LogisticJSON":LogisticJSON,
                //     "LLIListJSON":LLIListJSON,
                //     "OrderLIneItems":OrderLineItemsJSON,
                //     "BomItems":BomItemsJSON,
                // });  
                
                // --- NEW CODE START: Prepare SOLI Items ---
                var SoliList = component.get("v.SoliList");
                var SoliItems2return = [];
                var addedSoliIds = new Set();
                
                if (SoliList && SoliList.length > 0) {
                    var soliMap = new Map();
                    for (var i = 0; i < SoliList.length; i++) {
                        soliMap.set(SoliList[i].Id, SoliList[i]);
                    }
                    
                    // Match LLI items back to their parent SOLI records
                    for (var x = 0; x < LLIList.length; x++) {
                        var soliId = LLIList[x].ERP7__Sales_Order_Line_Item__c;
                        if (soliId && soliMap.has(soliId) && !addedSoliIds.has(soliId)) {
                            SoliItems2return.push(soliMap.get(soliId));
                            addedSoliIds.add(soliId); 
                        }
                    }
                }
                var SoliItemsJSON = JSON.stringify(SoliItems2return);
                console.log('SoliItemsJSON: ', SoliItemsJSON);
                
                // --- NEW CODE END ---

               var bomwrap = component.get("v.BomItemList");
                var bomlist = [];
                
                if(bomwrap && bomwrap.length > 0) {
                    // We only want to send BOMs that belong to the Order Items or SOLIs we are actually creating logistics for.
                    // We can check against the Sets we populated earlier: addedSoliIds and addedOrderItemIds
                    
                    for(var i in bomwrap) {
                        var bomWrapperItem = bomwrap[i];
                        
                        // Check if this BOM belongs to a valid Parent Item (SOLI or OrderItem) that is being processed
                        var parentId = bomWrapperItem.OrderProdId;
                        
                        // Check if the Parent ID exists in either of our "To Return" sets
                        // Note: addedSoliIds and addedOrderItemIds are Sets created earlier in this function
                        if (parentId && (addedSoliIds.has(parentId) || addedOrderItemIds.has(parentId))) {
                            bomlist.push(bomWrapperItem.Bom);
                        }
                    }
                }
                
                var BomItemsJSON = JSON.stringify(bomlist);
                
                action.setParams({
                    "LogisticJSON": LogisticJSON,
                    "LLIListJSON": LLIListJSON,
                    "OrderLIneItems": OrderLineItemsJSON,
                    "BomItems": BomItemsJSON,
                    "SoliListItems": SoliItemsJSON // <--- Pass the new SOLI JSON
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {  
                        console.log('getCreateLogistic resp~>',response.getReturnValue());
                        
                        if(response.getReturnValue() != null){
                            if(response.getReturnValue().includes('STRING_TOO_LONG')){
                                sforce.one.showToast({
                                    "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                                    "message": $A.get('$Label.c.Logistic_name_should_not_exceed_80_characters'),
                                    "type": "error"
                                });
                                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                return;
                            }
                        }   
                        
                        //if(response.getReturnValue()==null){  
                        //this.showToast('dismissible','', 'success', 'Saved Successfully',component);  
                        
                        /*var navEvt = $A.get("e.force:navigateToSObject");
                        if(navEvt != undefined){
                            navEvt.setParams({
                                "isredirect": true,
                                "recordId": response.getReturnValue(),
                                "slideDevName": "detail"
                            }); 
                            navEvt.fire(); //response.getReturnValue().Id
                        }else {*/
                        
                        if(response.getReturnValue() == null){
                            sforce.one.showToast({
                                "title": $A.get('$Label.c.Success'),
                                "message": $A.get('$Label.c.Saved_Successfully'),
                                "type": "Success"
                            });
                            if(component.get('v.orderId') !=''){
                                console.log('orderId here1');
                                try{
                                    let allloglines = component.get('v.OrdItemList');
                                    var returntologcreation = false;
                                    
                                    //Changed below by Arshad
                                    for(var x in allloglines){
                                        console.log('allloglines : ',JSON.stringify(allloglines[x]));
                                        var remainigqty = allloglines[x].Quantity - allloglines[x].ERP7__Logistic_Quantity__c;
                                        console.log('remainigqty 1: ',remainigqty);
                                        remainigqty = remainigqty - allloglines[x].ERP7__Remaining_Quantity__c;
                                        console.log('remainigqty 2: ',remainigqty);
                                        console.log('allloglines[x].ERP7__Logistic_Quantity__c : ',allloglines[x].ERP7__Logistic_Quantity__c);
                                        if(remainigqty > 0){ //|| allloglines[x].ERP7__Logistic_Quantity__c == 0
                                            returntologcreation = true; 
                                            break;
                                        }
                                    } 
                                    
                                    //added below arshad - go back to log creation screen/ stay in same url/ refresh page if partially logistic created
                                    console.log('returntologcreation : ',returntologcreation);
                                    if(returntologcreation){  
                                        console.log('arshad refreshing orditems here and..');
                                        setTimeout($A.getCallback(function(){
                                            console.log('... here it isss !!!'); 
                                            $A.createComponent("c:SalesOrderToLogistic",{ 
                                                "orderId":component.get('v.orderId'),
                                                "DistributeChannelId" :component.get('v.DistributeChannelId'), 
                                            },function(newCmp, status, errorMessage){
                                                if (status === "SUCCESS") {
                                                    var body = component.find("body");
                                                    body.set("v.body", newCmp);
                                                }   
                                            });  
                                        }),9000); 
                                    } else{
                                        console.log('arshad inhere');
                                        var RecUrl = "/lightning/r/Order/" + component.get('v.orderId') + "/view";
                                        window.open(RecUrl,'_parent'); 
                                    }
                                }catch(e){
                                    console.log('arshad err occured after saving logistic and refreshing~>'+e);
                                }
                            }
                            else if(component.get('v.SOId') !=''){
                                var RecUrl = "/lightning/r/ERP7__Sales_Order__c/" + component.get('v.SOId') + "/view";
                                window.open(RecUrl,'_parent');
                            }
                                else if(component.get('v.orderId') !=''){
                                    var RecUrl = "/lightning/r/Order/" + component.get('v.orderId') + "/view";
                                  //  window.open(RecUrl,'_parent');
                                }
                                    else if(component.get('v.POId') !=''){
                                        var RecUrl = "/lightning/r/ERP7__PO__c/" + component.get('v.POId') + "/view";
                                        window.open(RecUrl,'_parent');
                                    }
                                        else{
                                            location.reload();  
                                        }
                        }else{
                            sforce.one.showToast({
                                "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                                "message": response.getReturnValue(),
                                "type": "error"
                            });
                            $A.util.addClass(component.find('mainSpin'), "slds-hide");
                            return;
                        } 
                        setTimeout($A.getCallback(function(){
                            $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        }),9000);
                    }else{
                        //this.showToast('dismissible','', 'Error', 'System.LimitException: ERP7:Too many SOQL queries: 101',component); 
                        
                        var error1=response.getError();
                        console.log('Error :',error1);
                        component.set('v.exceptionError',error1[0].message);
                        sforce.one.showToast({
                            "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                            "message": error1[0].message,
                            "type": "error"
                        });
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }        
                });
                $A.enqueueAction(action);  
            } else{
                if(component.get("v.QuantityErrorMsg") ==$A.get('$Label.c.Invalid_Quantity')){
                    sforce.one.showToast({
                        "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                        "message": $A.get('$Label.c.Invalid_Quantity'),
                        "type": "error"
                    });
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    return;
                }
                if(component.get('v.SOId') != '' || component.get('v.orderId') != ''){
                    sforce.one.showToast({
                        "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                        "message": $A.get('$Label.c.Given_quantity_is_not_available_on_stock'),
                        "type": "error"
                    });
                }
                if(component.get('v.POId') != ''){
                    sforce.one.showToast({
                        "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                        "message": $A.get('$Label.c.Given_quantity_is_not_available'),
                        "type": "error"
                    });
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                //this.showToast('dismissible','', 'Error', 'Given quantity is not available on stock',component); 
            }     
        }else{
            var LLIList=[]; LLIList=component.get('v.LLIList');  
            if(LLIList!=''){
                sforce.one.showToast({
                    "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                    "message": $A.get('$Label.c.All_fields_are_mandatory'),
                    "type": "error"
                });
                //this.showToast('dismissible','', 'Error', 'All * fields are mandatory',component); 
            }  
            else{
                sforce.one.showToast({
                    "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                    "message": $A.get('$Label.c.Must_have_logistic_line_item'),
                    "type": "error"
                });
                //this.showToast('dismissible','', 'Error', 'Must have logistic line item',component); 
            } 
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
        }catch(e){
            console.log('error : ',e);
        }
    },
    
    handleErrors : function(component,errors) {
        // Configure error toast
        let toastParams = {
            title: $A.get('$Label.c.Error_UsersShiftMatch'),
            message: $A.get('$Label.c.Unknown_error'), // Default error message
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
                "title": title,
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
    
    trim: function(value){  
        if(value !=undefined) return ((value.toString()).trim() !=''?true:false);
        else return false;
    },
    
    getLLIDeleteSingle:function(comp, event, helper){
        var action=comp.get("c.getLogisticInstance");    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") { 
                var LLIList=[];
                LLIList.push(response.getReturnValue());
                comp.set("v.LLIList",LLIList); 
                comp.set("v.LLIList",[]); 
            }else{
                var error1=response.getError();
                console.log('Error :',error1);
                comp.set('v.exceptionError',error1[0].message);
            }          
        });
        $A.enqueueAction(action);
        
    },
    
    getLogisticExisting:function(comp, event, helper){ //$A.util.removeClass(comp.find("cnvrtLogBtnId"),'a_disabled');  
        var action=comp.get("c.getLogisticExisting"); 
        action.setParams({
            "SOId":comp.get("v.SOId"),
            "OrderId":comp.get("v.orderId"),
            "POId":comp.get("v.POId")
        });   
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (comp.isValid() && state === "SUCCESS") { 
                comp.set("v.LogisticsExisting",response.getReturnValue()); 
                this.getLLIDeleteSingle(comp, event, helper);
            }else{
                var error1=response.getError();
                console.log('Error :',error1);
                comp.set('v.exceptionError',error1[0].message);
            }          
        });
        $A.enqueueAction(action);
        
    },
    
    getDependentPicklists : function(component, event, helper) {
        console.log('getDependentPicklists called');
        var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : component.get("v.objDetail"),
            parentField : component.get("v.controllingFieldAPI"),
            childField : component.get("v.dependingFieldAPI")
        });
        
        action.setCallback(this, function(response){
            var status = response.getState();
            console.log('status : ',status);
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                console.log('pickListResponse : ',response.getReturnValue());
                //save response 
                component.set("v.depnedentFieldMap",pickListResponse.pickListMap);
                
                // create a empty array for store parent picklist values 
                var parentkeys = []; // for store all map keys 
                var parentField = []; // for store parent picklist value to set on lightning:select. 
                
                // Iterate over map and store the key
                for (var pickKey in pickListResponse.pickListMap) {
                    //console.log('pickKey~>',pickKey);
                    parentkeys.push(pickKey);
                }
                
                for (var i = 0; i < parentkeys.length; i++) {
                    //console.log('parentkeys~>',parentkeys[i]);
                    parentField.push(parentkeys[i]);
                }  
                
                console.log('parentField~>',parentField);
                
                // set the parent picklist
                component.set("v.listControllingValues", parentField);
                console.log('listControllingValues : ',component.get("v.listControllingValues"));
                console.log('setting ERP7__Shipment_type__c ERP7__Shipping_Preferences__c empty here1');
                component.set("v.Logistic.ERP7__Shipment_type__c", '');
                component.set("v.Logistic.ERP7__Shipping_Preferences__c",'');
                console.log('log Ship 1 : ',component.get("v.Logistic.ERP7__Shipment_type__c"));
                
            }
            else{
                console.log('err : ',response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getReturnDependentPicklists : function(component, event, helper) {
        console.log('getReturnDependentPicklists called');
        var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : component.get("v.objDetail"),
            parentField : component.get("v.RcontrollingFieldAPI"),
            childField : component.get("v.RdependingFieldAPI")
        });
        
        action.setCallback(this, function(response){
            var status = response.getState();
            console.log('return status : ',status);
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                console.log('return pickListResponse : ',response.getReturnValue());
                //save response 
                component.set("v.RdepnedentFieldMap",pickListResponse.pickListMap);
                
                // create a empty array for store parent picklist values 
                var parentkeys = []; // for store all map keys 
                var parentField = []; // for store parent picklist value to set on lightning:select. 
                
                // Iterate over map and store the key
                for (var pickKey in pickListResponse.pickListMap) {
                    //console.log('pickKey~>',pickKey);
                    parentkeys.push(pickKey);
                }
                
                for (var i = 0; i < parentkeys.length; i++) {
                    //console.log('parentkeys~>',parentkeys[i]);
                    parentField.push(parentkeys[i]);
                }  
                
                console.log('return parentField~>',JSON.stringify(parentField));
                
                // set the parent picklist - return //arshad
                component.set("v.RlistControllingValues", parentField);
                console.log('RlistControllingValues~> ',JSON.stringify(component.get("v.RlistControllingValues")));
                console.log('setting ERP7__Shipment_type_Return__c ERP7__Shipping_Preferences_Return__c empty here1');
                component.set("v.Logistic.ERP7__Shipping_Preferences_Return__c",'');
                component.set("v.Logistic.ERP7__Shipment_type_Return__c", ''); 
                console.log('ERP7__Shipment_type_Return__c here0~> ',component.get("v.Logistic.ERP7__Shipment_type_Return__c"));
            }
            else{
                console.log('RT err : ',response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    fetchLogDetails: function(component,event,helper){
        console.log('fetchLogDetails called');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");	
        var action=component.get("c.getLogisticAndItems");
        action.setParams({
            "LogisticId": component.get('v.LogId')
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var obj = response.getReturnValue(); 
                console.log('fetchLogDetails resp~>',obj);
                component.set("v.LLIList",obj.logItems); 
                component.set("v.Logistic",obj.logistic);
                component.set("v.Logistic.ERP7__Shipping_Preferences_Return__c",obj.shipReturnPreferences);
                component.set("v.Logistic.ERP7__Shipping_Preferences__c",obj.shipPreferences);
                component.set("v.channelId",component.get("v.Logistic").ERP7__Channel__c); 
                component.set("v.DistributeChannelId",component.get("v.Logistic").ERP7__Distribution_Channel__c); 
                component.set("v.selectedTab",'log');                                       
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                
            }else{
                var error1=response.getError();
                console.log('Error fetchPOItemList:',error1);
                component.set('v.exceptionError',error1[0].message);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action); 
    },
    
    getBillingOptionsPickList: function(component,event,helper){
        console.log('getBillingOptionsPickList called');
        var billingOptionsAction = component.get("c.getBillingOptions");
        var billingOpts=[];
        billingOptionsAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                billingOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            console.log('billingOpts~>',billingOpts);
            component.set("v.billingOptions",billingOpts);
        });
        $A.enqueueAction(billingOptionsAction); 
    },
    
})