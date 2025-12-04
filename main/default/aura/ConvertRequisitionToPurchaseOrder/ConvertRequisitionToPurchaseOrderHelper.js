({
    displayRecords: function(component, event, helper) {
        console.log('displayRecords called ');
        var initaction = component.get("c.fetchChannelandDC");
        initaction.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){ 
                try{ 
                    var obj = response.getReturnValue();
                    if(!$A.util.isEmpty(obj.distributionChannel.Id) && !$A.util.isUndefinedOrNull(obj.distributionChannel.Id)){
                        component.set("v.dcId",obj.distributionChannel.Id);
                        component.set("v.distributionChannel.Id",obj.distributionChannel.Id);
                        component.set("v.distributionChannel.Name",obj.distributionChannel.Name);
                        //component.set("v.Channel.Name",obj.distributionChannel.ERP7__Channel__r.Name);
                        component.set("v.channelId",obj.distributionChannel.ERP7__Channel__c);
                    }
                }catch(ex){
                    console.log('catch err~>'+ex);
                    //('fetchChannelandDC catch enter');
                } 
            }else{
                var errors = response.getError();
                console.log("server error in displayRecords helper : ", errors);
            }
        });
        $A.enqueueAction(initaction);
    },
    
    validationCheckDC : function (component, event) {  
        var poli_List = component.find("dcId"); //dcElem.set("v.inputStyleclass","hasError");
        poli_List.set("v.inputStyleclass","hasError");
        if($A.util.isEmpty(poli_List.get("v.selectedRecord.Id"))){
            poli_List.set("v.inputStyleclass","hasError");
            return false;
        }else{
            poli_List.set("v.inputStyleclass",""); 
            return true;
        }
    }, 
    
    getReqRecords: function(component, event, helper) {
        console.log('helper called');
        var action = component.get("c.fetchSortedRequistion");
        action.setParams({
            "OrderBy":component.get("v.OrderBy"),"Order":component.get("v.Order"),'DcId' : component.get("v.dcId"),
            'Offset' : component.get("v.Offset"),
            'RecordLimit' : component.get('v.show')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : '+state);
            if (component.isValid() && state === "SUCCESS") {
                try{
                    var obj = response.getReturnValue();
                    console.log('obj : '+JSON.stringify(obj));
                    component.set("v.requisitionList", obj);
                    
                }catch(ex){
                    console.log('fetchSortedRequistion catch enter');
                }     
            }
        });
        $A.enqueueAction(action);
        //helper.displayRecords(component, event, helper);
    },
    
    helperfetchChannelsByEmp : function (component, event, helper) {
        console.log('helperfetchChannelsByEmp called');
        //helper.validationCheckDC(component, event, helper);
        
        if(!$A.util.isEmpty(component.get("v.dcId")) && !$A.util.isUndefinedOrNull(component.get("v.dcId"))){
            //helper.validationCheckDC(component, event, helper);
            var channelAction = component.get("c.getDCByChan");
            channelAction.setParams({"recordId":component.get("v.dcId"),'Offset' : component.get("v.Offset"),
                                     'RecordLimit' : component.get('v.show')});
            channelAction.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    try{
                        console.log('helperfetchChannelsByEmp res :',response.getReturnValue().poli);
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
                        
                    }catch(ex){
                        console.log('catch err~>'+ex);
                        //('getDCByChan catch enter');
                    }    
                }
                else{
                    var errors = response.getError();
                    console.log("server error in helperfetchChannelsByEmp : ", errors);
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
       
    },
    
})