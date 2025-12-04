({
    getRecords: function(component, event, helper) {
        console.log('getRecords SelectedRequisitionPOLI : ',component.get('v.SelectedRequisitionPOLI').length);
        var action = component.get("c.fetchRequistionLineItems");
        action.setParams({
            'searchString':component.get("v.setSearch"),
            'DcId' : component.get("v.dcId"),
            'Offset' : component.get("v.Offset"),
            'RecordLimit' : component.get('v.show'), 
            'PRId' : component.get('v.fromDetailPRId'), 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state fetchRequistionLineItems: '+state);
            if (state === "SUCCESS") {
                try{
                    component.set("v.preventChanges",true);
                    console.log('res of fetchRequistionLineItems:',response.getReturnValue());
                    var objmain = response.getReturnValue();
                    if(!$A.util.isEmpty(objmain.distributionChannel.Id) && !$A.util.isUndefinedOrNull(objmain.distributionChannel.Id)){
                        component.set("v.dcId",objmain.distributionChannel.Id);
                        component.set("v.distributionChannel.Id",objmain.distributionChannel.Id);
                        component.set("v.distributionChannel.Name",objmain.distributionChannel.Name);
                        //component.set("v.Channel.Name",obj.distributionChannel.ERP7__Channel__r.Name);
                        component.set("v.channelId",objmain.distributionChannel.ERP7__Channel__c);
                    }
                    
                    var obj = response.getReturnValue().wrap;
                    /*for(var x in obj){
                        console.log('obj[x] : '+JSON.stringify(obj[x]));
                    }*/
                    component.set("v.requisitionList", obj);
                    //console.log('SelectedRequisitionPOLI : ',component.set("v.SelectedRequisitionPOLI"));
                    var Offsetval=parseInt(component.get("v.Offset"));
                    var records;
                    records = response.getReturnValue().wrap;
                    component.set('v.recSize',records.length);
                    if(Offsetval!=0){
                        if(records.length > 0) {
                            var startCount = Offsetval + 1;
                            var endCount = Offsetval + records.length;
                            component.set("v.startCount", startCount);
                            component.set("v.endCount", endCount);
                        }
                    }
                    if(Offsetval==0){
                        if(records.length > 0) {
                            var startCount = 1;
                            var endCount = records.length;
                            
                            component.set("v.startCount", startCount);
                            component.set("v.endCount", endCount); 
                            component.set("v.PageNum",1);
                        }
                    }
                    var myPNS = [];
                    var ES = records.length;
                    var i=0;
                    var show=component.get('v.show');
                    while(ES >= show){
                        i++; myPNS.push(i); ES=ES-show;
                    } 
                    if(ES > 0) myPNS.push(i+1);
                    component.set("v.PNS", myPNS);  
                    if(records.length > 0 && !$A.util.isEmpty(component.get('v.fromDetailPRId')) && !$A.util.isUndefinedOrNull(component.get('v.fromDetailPRId'))){
                        var getAllId=[]; getAllId= component.find("boxPack");
                        for (var i = 0; i < getAllId.length; i++) {
                            try{  component.find("boxPack")[i].set("v.checked", true);  }catch(ex){}   
                        }
                        component.set("v.SelectedRequisition",records);  
                        $A.enqueueAction(component.get("c.convertMPRLI"));
                    }
                    component.set("v.preventChanges",false);
                }catch(ex){
                    console.log('catch err~>'+ex);
                    component.set("v.preventChanges",false);
                }     
            }
            else{
                var errors = response.getError();
                console.log("server error in doInit : ", errors);
            }
        });
        $A.enqueueAction(action);
        /*if((component.get("v.setSearch")!=null)&&(component.get("v.setSearch")!='')){
            
        }
        else helper.displayRecords(component, event, helper);*/
    },
    
    checkboxSelect: function(component, event, helper) {
        console.log('checkboxSelect called');
        try{
            $A.util.removeClass(component.find("poConvertId"),'a_disabled');  
            console.log('class removed');
            var selectedRec = event.getSource().get("v.checked");
            console.log('selectedRec : '+selectedRec);
            var recordId = event.getSource().get("v.value");
            console.log('selectedRec : '+selectedRec);
            var selectedRequisition = component.get('v.SelectedRequisition');
            console.log('selectedRequisition : '+selectedRequisition.length);
            var requisitionList = component.get("v.requisitionList");
            console.log('requisitionList : '+requisitionList.length);
            var getSelectedNumber = component.get("v.selectedCount");
            console.log('getSelectedNumber : '+getSelectedNumber);
            
            for(var i in selectedRequisition){
                if(selectedRequisition[i].Id == recordId){
                    if (selectedRec == true) return;
                }
            }
            console.log('selectedRec : '+selectedRec);
            if (selectedRec == true) {
                for(let x = 0; x<requisitionList.length;x++){
                    if(requisitionList[x].reqline.Id === recordId ){
                        selectedRequisition.push(requisitionList[x]);
                        requisitionList[x].selected = true; 
                    }
                    
                }
                getSelectedNumber++;
                
            } else {
                for(let x=0;x<selectedRequisition.length;x++){
                    if(selectedRequisition[x].reqline.Id === recordId ){
                        selectedRequisition.splice(x,1);
                        //delete selectedRequisition[x];
                        break;
                    }
                }
                getSelectedNumber--;
            }
            console.log('getSelectedNumber : '+getSelectedNumber);
            console.log('selectedRequisition : '+selectedRequisition.length);
            component.set("v.SelectedRequisition",selectedRequisition);
            component.set("v.selectedCount", getSelectedNumber);
            component.set("v.requisitionList", requisitionList);
        }catch(exp){
            
            $A.util.addClass(component.find("poConvertId"),'a_disabled'); 
        }
        
        if(component.get("v.SelectedRequisition")=='' || component.get("v.SelectedRequisition")==undefined)
            $A.util.addClass(component.find("poConvertId"),'a_disabled'); 
    },
    
    selectAll: function(component, event, helper) {
        
        var fetchAllIDs = [];
        
        var selectedHeaderCheck = event.getSource().get("v.checked");
        
        var getAllId=[]; getAllId= component.find("boxPack");
        
        var requisitionList=[]; requisitionList = component.get("v.requisitionList");
        
        var selectedRequisition=[]; selectedRequisition= component.get('v.SelectedRequisition');
        
        /* if (!Array.isArray(getAllId)) {  
            if (selectedHeaderCheck == true) {
                component.find("boxPack").set("v.value", true);
                component.set("v.selectedCount", 1);
            } else {
                component.find("boxPack").set("v.value", false);
                component.set("v.selectedCount", 0);
            }
        } else {
         */   
        //var requisitionList = component.get("v.requisitionList");
        
        if (selectedHeaderCheck==true) {
            
            for (var i = 0; i < getAllId.length; i++) {
                try{  
                    component.find("boxPack")[i].set("v.checked", true); 
                    fetchAllIDs.push(getAllId[i].get("v.text"));
                }catch(ex){}   
                // component.set("v.selectedCount", getAllId.length);
                //component.set("v.SelectedRequisition",requisitionList);
            }
            component.set("v.SelectedRequisition",requisitionList);  
            // if(getAllId.length==1 || getAllId.length==undefined) component.find("boxPack").set("v.value", true);
        } 
        else {
            try{
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.checked", false);
                    
                    // component.set("v.selectedCount", 0);
                    //component.set("v.SelectedRequisition",[]);
                }
            }catch(ex){}   
            component.set("v.SelectedRequisition",[]); 
            
            //if(getAllId.length==1 || getAllId.length==undefined) component.find("boxPack").set("v.value", false);     
        }
        //  }
        
        if(component.get("v.SelectedRequisition")=='' || component.get("v.SelectedRequisition")==undefined)
            $A.util.addClass(component.find("poConvertId"),'a_disabled');
        else  $A.util.removeClass(component.find("poConvertId"),'a_disabled');  
    },
    
    getTab:function(component, event, helper) {
        
        /* if(component.get("v.selectedTab")=='Purchase_Requisitions'){ 
         $A.util.addClass(component.find("poConvertId"),'a_disabled');
         //component.set("v.selectedTab",'Purchase_Orders');   component.set("v.selectedTab",'Purchase_Requisitions'); 
        }     
        else  $A.util.removeClass(component.find("poConvertId"),'a_disabled');
      */
        
        /* try{   
        var elmVal; if(event.getSource()!=undefined){ elmVal=event.getSource().get("v.value");
        
      if(elmVal==true) $A.util.removeClass(component.find("poConvertId"),'a_disabled'); 
      else*/
        $A.util.addClass(component.find("poConvertId"),'a_disabled');
        //   }   
        // }catch(ex){}     
    }, 
    
    convertMPRLI: function(component, event, helper) {
        
        try{ 
            //var selectedRec = event.getSource().get("v.value");
            
            //var getAllId = component.find("boxPack");
            
            var getSelectedNumber = component.get("v.selectedCount");
            
            var selectedRequisition = component.get('v.SelectedRequisition'); 
            
            component.set('v.SelectedRequisitionPOLI',[]);
            var SelectedRequisitionPOLI = component.get("v.SelectedRequisitionPOLI");
            
            var requisitionList = component.get("v.requisitionList");
            let orderId = [];
            for(let x=0;x<selectedRequisition.length;x++){
                var found = false;
                var NoProduct = false;
                if(selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c != null && selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c != undefined && selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c != '') { orderId.push(selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c); component.set('v.IsSalesOrder',true);}
                else if(selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Order_S__c != null && selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Order_S__c != undefined && selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Order_S__c != '') { orderId.push(selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Order_S__c); component.set('v.IsSalesOrder',false);}
                /*var reqVal = $A.get("$Label.c.Requistion_Access");
                if(reqVal=='True'){
                for(let y=0;y<SelectedRequisitionPOLI.length;y++){
                    if(selectedRequisition[x].ERP7__Product__c != undefined && SelectedRequisitionPOLI[y].ERP7__Product__c == selectedRequisition[x].ERP7__Product__c){
                        found = true;
                        SelectedRequisitionPOLI[y].ERP7__Description__c = selectedRequisition[x].ERP7__Product__r.ERP7__Vendor_Supplier_Description__c;
                        
                        if(selectedRequisition[x].ERP7__Quantity__c != undefined)
                            SelectedRequisitionPOLI[y].ERP7__Quantity__c += selectedRequisition[x].ERP7__Quantity__c;
                        if(SelectedRequisitionPOLI[y].ERP7__Quantity__c==0) SelectedRequisitionPOLI[y].ERP7__Quantity__c=1;
                        if(selectedRequisition[x].ERP7__Price__c != undefined) SelectedRequisitionPOLI[y].ERP7__Unit_Price__c += selectedRequisition[x].ERP7__Price__c;
                        if(selectedRequisition[x].ERP7__Amount__c != undefined) SelectedRequisitionPOLI[y].ERP7__Total_Price__c += selectedRequisition[x].ERP7__Amount__c;
                        break;
                    }
                }
                }*/
                if(selectedRequisition[x].reqline.ERP7__Product__c == null) NoProduct = true;
                if(!found){
                    var obj;
                    if(NoProduct) obj = { 
                        Name:selectedRequisition[x].reqline.Name,
                        ERP7__Product__c:selectedRequisition[x].reqline.ERP7__Product__c,
                        //ERP7__Product__r.ERP7__Default_Vendor__c:selectedRequisition[x].ERP7__Product__r.ERP7__Default_Vendor__c,
                        //ERP7__Product__r.ERP7__Default_Vendor__r.Name:selectedRequisition[x].ERP7__Product__r.ERP7__Default_Vendor__r.Name,
                        ERP7__Quantity__c:selectedRequisition[x].reqline.ERP7__Quantity__c,
                        ERP7__Unit_Price__c:selectedRequisition[x].reqline.ERP7__Price__c,
                        ERP7__Total_Price__c:selectedRequisition[x].reqline.ERP7__Amount__c,
                        //ERP7__Description__c: (selectedRequisition[x].reqline.ERP7__Product__c != null : selectedRequisition[x].reqline.ERP7__Product__r.ERP7__Vendor_Supplier_Description__c ? ''),
                        ERP7__Special_Instruction__c:selectedRequisition[x].reqline.ERP7__Description__c,
                        ERP7__Purchase_Requisition_Line_Items__c:selectedRequisition[x].reqline.Id,
                        ERP7__Sales_Order__c:selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c,
                        ItemsinStock:selectedRequisition[x].ItemsinStock,
                        AwaitingStock:selectedRequisition[x].AwaitingStock,
                        demand:selectedRequisition[x].demand
                    };
                    else{
                        obj = { 
                            Name:selectedRequisition[x].reqline.Name,
                            ERP7__Product__c:selectedRequisition[x].reqline.ERP7__Product__c,
                            //ERP7__Product__r.ERP7__Default_Vendor__c:selectedRequisition[x].ERP7__Product__r.ERP7__Default_Vendor__c,
                            //ERP7__Product__r.ERP7__Default_Vendor__r.Name:selectedRequisition[x].ERP7__Product__r.ERP7__Default_Vendor__r.Name,
                            ERP7__Quantity__c:selectedRequisition[x].reqline.ERP7__Quantity__c,
                            ERP7__Unit_Price__c:selectedRequisition[x].reqline.ERP7__Price__c,
                            ERP7__Total_Price__c:selectedRequisition[x].reqline.ERP7__Amount__c,
                            ERP7__Description__c: selectedRequisition[x].reqline.ERP7__Product__r.ERP7__Vendor_Supplier_Description__c ,
                            ERP7__Special_Instruction__c:selectedRequisition[x].reqline.ERP7__Description__c,
                            ERP7__Purchase_Requisition_Line_Items__c:selectedRequisition[x].reqline.Id,
                            ERP7__Sales_Order__c:selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c,
                            ItemsinStock:selectedRequisition[x].ItemsinStock,
                            AwaitingStock:selectedRequisition[x].AwaitingStock,
                            demand:selectedRequisition[x].demand
                        };   
                    }
                    //ERP7__Purchase_Requisition_Line_Items__c:selectedRequisition[x].Id
                    if(obj.ERP7__Quantity__c==0) obj.ERP7__Quantity__c=1;
                    console.log('SelectedRequisitionPOLI : ',JSON.stringify(SelectedRequisitionPOLI));
                    SelectedRequisitionPOLI.push(obj);
                }
            }
            
            if(orderId != null && orderId != undefined && orderId.length == 1) component.set("v.PROrder",orderId[0]);
            console.log('PROrder : ',component.get("v.PROrder"));
            var myproIds = [];
            var NoProductName = false;
            for(let y=0;y<SelectedRequisitionPOLI.length;y++){
                if(SelectedRequisitionPOLI[y].ERP7__Product__c != undefined){
                    myproIds.push(SelectedRequisitionPOLI[y].ERP7__Product__c);
                }
                console.log('SelectedRequisitionPOLI[y].Name : ',SelectedRequisitionPOLI[y].Name);
                if(SelectedRequisitionPOLI[y].Name != undefined){
                    NoProductName = true; 
                }
            }
            console.log('NoProductName : '+NoProductName);
            if(myproIds.length > 0 || NoProductName){
                var action = component.get("c.getReorderingRules");
                action.setParams({ 
                    SelectedSite: component.get("v.dcId"),
                    ProIds: myproIds
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        var RORs = response.getReturnValue();
                        //alert(RORs.length);
                        for(let y=0;y<SelectedRequisitionPOLI.length;y++){
                            for(let x=0;x<RORs.length;x++){
                                if(SelectedRequisitionPOLI[y].ERP7__Product__c != undefined && SelectedRequisitionPOLI[y].ERP7__Product__c == RORs[x].ERP7__Product__c){
                                    if(RORs[x].ERP7__MinimumOrderingQuantity__c > SelectedRequisitionPOLI[y].ERP7__Quantity__c) SelectedRequisitionPOLI[y].ERP7__Quantity__c = RORs[x].ERP7__MinimumOrderingQuantity__c;
                                    //alert(SelectedRequisitionPOLI[y].ERP7__Quantity__c);
                                    break;
                                }
                            }
                        }
                        component.set("v.SelectedRequisitionPOLI",SelectedRequisitionPOLI);
                        component.set("v.selectedTab",'Purchase_Orders');
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                component.set("v.SelectedRequisitionPOLI",SelectedRequisitionPOLI);
                component.set("v.selectedTab",'Purchase_Orders');
            }
            
        } catch(ex){
            console.log('convertMPRLI  catch enter : ',ex);
        }  
        
    },
    
    convertToPOSingle: function(component, event, helper) {
        try{
            var recordId = event.target.dataset.record;
            console.log('recordId : '+recordId);
            var selectedRequisition = [];
            
            var requisitionList = component.get("v.requisitionList");
            
            for(let x = 0; x<requisitionList.length;x++){
                if(requisitionList[x].reqline.Id === recordId ){
                    // requisitionList[x].selected = true;
                    selectedRequisition.push(requisitionList[x]);
                }
                
            }
            
            component.set("v.SelectedRequisition",selectedRequisition);
            //component.set("v.requisitionList",requisitionList);
            var selectedRequisition = component.get('v.SelectedRequisition');
            
            var SelectedRequisitionPOLI = component.get("v.SelectedRequisitionPOLI");
            SelectedRequisitionPOLI = [];
            console.log('SelectedRequisitionPOLI : ',SelectedRequisitionPOLI);
            var requisitionList = component.get("v.requisitionList");
            console.log('selectedRequisition.length : ',selectedRequisition.length);
            let orderId = [];
            for(let x=0;x<selectedRequisition.length;x++){
                var NoProduct = false;
                var obj;
                 if(selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c != null && selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c != undefined && selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c != '') { orderId.push(selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c); component.set('v.IsSalesOrder',true);}
                else if(selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Order_S__c != null && selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Order_S__c != undefined && selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Order_S__c != '') { orderId.push(selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Order_S__c); component.set('v.IsSalesOrder',false);}
                if(selectedRequisition[x].reqline.ERP7__Product__c == null) NoProduct = true;
                if(NoProduct) {
                    obj = { 
                        Name:selectedRequisition[x].reqline.Name,
                        ERP7__Product__c:selectedRequisition[x].reqline.ERP7__Product__c,
                        //ERP7__Product__r.ERP7__Default_Vendor__c:selectedRequisition[x].ERP7__Product__r.ERP7__Default_Vendor__c,
                        //ERP7__Product__r.ERP7__Default_Vendor__r.Name:selectedRequisition[x].ERP7__Product__r.ERP7__Default_Vendor__r.Name,
                        ERP7__Quantity__c:selectedRequisition[x].reqline.ERP7__Quantity__c,
                        ERP7__Unit_Price__c:selectedRequisition[x].reqline.ERP7__Price__c,
                        ERP7__Total_Price__c:selectedRequisition[x].reqline.ERP7__Amount__c,
                        //ERP7__Description__c: (selectedRequisition[x].reqline.ERP7__Product__c != null : selectedRequisition[x].reqline.ERP7__Product__r.ERP7__Vendor_Supplier_Description__c ? ''),
                        ERP7__Special_Instruction__c:selectedRequisition[x].reqline.ERP7__Description__c,
                        ERP7__Purchase_Requisition_Line_Items__c:selectedRequisition[x].reqline.Id,
                        ERP7__Sales_Order__c:selectedRequisition[x].reqline.ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c,
                        ItemsinStock:selectedRequisition[x].ItemsinStock,
                        AwaitingStock:selectedRequisition[x].AwaitingStock,
                        demand:selectedRequisition[x].demand
                    };
                }
                else { obj = {Name:selectedRequisition[x].reqline.Name,ERP7__Product__c:selectedRequisition[x].reqline.ERP7__Product__c,ERP7__Quantity__c:selectedRequisition[x].reqline.ERP7__Quantity__c,ERP7__Unit_Price__c:selectedRequisition[x].reqline.ERP7__Price__c,ERP7__Total_Price__c:selectedRequisition[x].reqline.ERP7__Amount__c,ERP7__Purchase_Requisition_Line_Items__c:selectedRequisition[x].reqline.Id,ItemsinStock:selectedRequisition[x].ItemsinStock,AwaitingStock:selectedRequisition[x].AwaitingStock,demand:selectedRequisition[x].demand}; }
                if(obj.ERP7__Quantity__c==0) obj.ERP7__Quantity__c=1;   
                //Assign Order Id if not undefined
                console.log('obj : ',obj);
                SelectedRequisitionPOLI.push(obj);
                console.log('SelectedRequisitionPOLI : ',SelectedRequisitionPOLI);
            }
            
            if(orderId != null && orderId != undefined && orderId.length == 1) component.set("v.PROrder",orderId[0]);
            console.log('PROrder : ',component.get("v.PROrder"));
            var myproIds = [];
            var NoProductName = false;
            for(let y=0;y<SelectedRequisitionPOLI.length;y++){
                console.log('SelectedRequisitionPOLI : '+JSON.stringify(SelectedRequisitionPOLI[y]));
                if(SelectedRequisitionPOLI[y].ERP7__Product__c != undefined){
                    myproIds.push(SelectedRequisitionPOLI[y].ERP7__Product__c);
                }
                if(SelectedRequisitionPOLI[y].Name != undefined){
                    NoProductName = true; 
                }
            }
            if(myproIds.length > 0 || NoProductName) {
                var action = component.get("c.getReorderingRules");
                action.setParams({ 
                    SelectedSite: component.get("v.dcId"),
                    ProIds: myproIds
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        var RORs = response.getReturnValue();
                        //alert(RORs.length);
                        for(let y=0;y<SelectedRequisitionPOLI.length;y++){
                            for(let x=0;x<RORs.length;x++){
                                if(SelectedRequisitionPOLI[y].ERP7__Product__c != undefined && SelectedRequisitionPOLI[y].ERP7__Product__c == RORs[x].ERP7__Product__c){
                                    if(RORs[x].ERP7__MinimumOrderingQuantity__c > SelectedRequisitionPOLI[y].ERP7__Quantity__c) SelectedRequisitionPOLI[y].ERP7__Quantity__c = RORs[x].ERP7__MinimumOrderingQuantity__c;
                                    //alert(SelectedRequisitionPOLI[y].ERP7__Quantity__c);
                                    break;
                                }
                            }
                        }
                        component.set("v.SelectedRequisitionPOLI",SelectedRequisitionPOLI);
                        component.set("v.selectedTab",'Purchase_Orders');
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                component.set("v.SelectedRequisitionPOLI",SelectedRequisitionPOLI);
                component.set("v.selectedTab",'Purchase_Orders');
            }
        }catch(ex){
            console.log('ex : ',ex);
        } 
    },
    
    reload : function(component, event, helper){
        
        location.reload();
    },
    
    lookupClickDist:function(component,helper){
        
        component.set("v.qry","");        
    },
    
    lookupClickChannel:function(component,helper){
        
        var channel = component.get("v.Channel.Id");
        
        var qry;
        
        if(channel == undefined) qry = ' ';
        else qry = ' And ERP7__Channel__c = \''+channel+'\'';
        component.set("v.qry",qry);
        
    },
    
    fetchChannelsByEmp : function (component, event, helper) {
        console.log('fetchChannelsByEmp called preventChanges~>'+component.get("v.preventChanges"));
        if(component.get("v.preventChanges") == false){
            if(!$A.util.isEmpty(component.get("v.dcId")) && !$A.util.isUndefinedOrNull(component.get("v.dcId"))){
                //helper.validationCheckDC(component, event, helper);
                var channelAction = component.get("c.getDCByChan");
                channelAction.setParams({"recordId":component.get("v.dcId"),'Offset' : component.get("v.Offset"),
                                         'RecordLimit' : component.get('v.show')});
                channelAction.setCallback(this,function(response){
                    var state = response.getState();
                    if(state ==='SUCCESS'){
                        try{
                            if(response.getReturnValue()){
                                console.log('fetchChannelsByEmp res :',response.getReturnValue().poli);
                                component.set("v.requisitionList",response.getReturnValue().poli);
                                component.set('v.recSize',response.getReturnValue().psize);
                                
                                var Offsetval=parseInt(component.get("v.Offset"));
                                var records;
                                records = response.getReturnValue().poli;
                                if(Offsetval!=0){
                                    if(records.length > 0) {
                                        var startCount = Offsetval + 1;
                                        var endCount = Offsetval + records.length;
                                        component.set("v.startCount", startCount);
                                        component.set("v.endCount", endCount);
                                    }
                                }
                                if(Offsetval==0){
                                    if(records.length > 0) {
                                        var startCount = 1;
                                        var endCount = records.length;
                                        
                                        component.set("v.startCount", startCount);
                                        component.set("v.endCount", endCount); 
                                        component.set("v.PageNum",1);
                                    }
                                }
                                var myPNS = [];
                                var ES = response.getReturnValue().psize;
                                var i=0;
                                var show=component.get('v.show');
                                while(ES >= show){
                                    i++; myPNS.push(i); ES=ES-show;
                                } 
                                if(ES > 0) myPNS.push(i+1);
                                component.set("v.PNS", myPNS); 
                                
                            }
                        }catch(ex){
                            console.log('catch err~>'+ex);
                            //('getDCByChan catch enter');
                        }    
                    }
                    else{
                        var errors = response.getError();
                        console.log("server error in fetchChannelsByEmp : ", errors);
                    }
                }); 
                $A.enqueueAction(channelAction);
                
            }
            else{
                console.log('dcId empty');
                component.set("v.requisitionList",[]);
                component.set('v.recSize',0);
                
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;
                records = [];
                if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = 0;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS); 
                
            }
        }
    },
    
    cancelPO: function (component, event, helper) {
        
        component.set("v.selectedTab",'Purchase_Requisitions');
        location.reload();
        
    },
    
    cancelPO: function (component, event, helper) {
        
        component.set("v.selectedTab",'Purchase_Requisitions');
        location.reload();
        
    },
    
    showRLIDetailsPage:function(comp,event,helper){ 
        
        var recordId = event.target.dataset.record;  
        
        comp.set("v.nameUrl",'/'+recordId); 
    },
    
    getSortedRecords : function(component,event,helper){
        console.log('getSortedRecords called');
        component.set("v.OrderBy",event.currentTarget.id);
        console.log('getSortedRecords Id : '+event.currentTarget.id);
        // component.set("v.Order",event.currentTarget.dataset.service);
        console.log('component.get("v.Order")  : '+component.get("v.Order"));
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');   
        
        helper.getReqRecords(component,event); 
    },
    
    setShow : function(cmp,event,helper){
        
        cmp.set("v.startCount", 0);
        cmp.set("v.endCount", 0);
        cmp.set("v.Offset", 0);
        cmp.set("v.PageNum", 1);
        helper.helperfetchChannelsByEmp(cmp, event, helper);
    }, 
    
    OfsetChange : function(component,event,helper){
        
        var Offsetval = event.getSource().get("v.value");
        
        var curOffset = component.get("v.Offset");
        var show = parseInt(component.get("v.show"));
        if(Offsetval > 0 && Offsetval <= component.get("v.PNS").length){
            
            if(((curOffset+show)/show) != Offsetval){
                var newOffset = (show*Offsetval)-show;
                component.set("v.Offset", newOffset);
                component.set("v.CheckOffset",true);
                var pageNum = (newOffset + show)/show;
                component.set("v.PageNum",pageNum);
            }
            helper.helperfetchChannelsByEmp(component, event, helper);
        } else component.set("v.PageNum",((curOffset+show)/show));
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.helperfetchChannelsByEmp(component, event, helper);
        }
    },
    
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.helperfetchChannelsByEmp(component, event, helper);
        }
    },
    
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.helperfetchChannelsByEmp(component, event, helper);
        }
    },
    
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.helperfetchChannelsByEmp(component, event, helper);
        }
    },
    
    deletePoli :function(component, event, helper) {
        console.log('inside deletePoli requisition');
        var poliList =[]; 
        poliList=component.get("v.SelectedRequisitionPOLI");
        console.log('poliList : ',poliList.length);
        var index=event.getParam("Index"); //component.get("v.Index2del");
        console.log('index : ',index);
        poliList.splice(index,1);   
        console.log('poliList : ',poliList.length);
        component.set("v.SelectedRequisitionPOLI",poliList);
        poliList = [];
        poliList = component.get("v.SelectedRequisition");
        console.log('poliList SelectedRequisition: ',poliList.length);
        poliList.splice(index,1);
        console.log('poliList SelectedRequisition: ',poliList.length);
        component.set('v.SelectedRequisition',poliList);
        //component.set('v.callevt',false);
        console.log('SelectedRequisitionPOLI : ',component.get("v.SelectedRequisitionPOLI").length);
        console.log('SelectedRequisition : ',component.get("v.SelectedRequisition").length);
    },
})