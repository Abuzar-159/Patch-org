({
    init :function(cmp, event, helper)  {
       //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var logId = cmp.get("v.logisticIds");
         var logisticIds = logId.split(",");
        var LIds = JSON.stringify(logisticIds);
        console.log('LIds : ',JSON.stringify(logisticIds));
        cmp.set("v.IsSpinner",true);
     	var search = cmp.get("v.searchText");
        var action = cmp.get("c.getLogisticDetails");
        
        action.setParams({LogisticIds:LIds});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : ',state);
            if (state === "SUCCESS") {
                console.log('response : ',response.getReturnValue());
                cmp.set("v.IsSpinner",false);
                cmp.set('v.logWrap',response.getReturnValue().solisItemList);
                cmp.set('v.pickItem',response.getReturnValue().pickItems);
                cmp.set('v.searchText',response.getReturnValue().LogName);
                cmp.set('v.packItem',response.getReturnValue().packItems);
                cmp.set('v.shipItem',response.getReturnValue().shipItems);
                cmp.set("v.IsSpinner",false);
            }
        });
        $A.enqueueAction(action);
    
    },
	   createPicks : function(cmp, event, helper) {
    	var logIds = cmp.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Pick",{
            "logisticIds":logIds
        },function(newCmp, status, errorMessage){
             
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    createPacks : function(cmp, event, helper) {
    	var logIds = cmp.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Pack",{
            "logisticIds":logIds
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
        
    },
    
    createShips : function(cmp, event, helper) {
    	var logIds = cmp.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Ship",{
            "logisticIds":logIds
        },function(newCmp, status, errorMessage){
            
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
     Back2Outbound : function(cmp, event, helper) {
        $A.createComponent("c:OutboundLogistics",{
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                //var body = cmp.find("body");
               // body.set("v.body", newCmp);
            }
        });
    },
     handleKeyUp : function (cmp, event, helper) {
       // alert('handleKeyUp:' + event.which);
         if (event.which == 13){ }
		/* var entersearch =event.getSource().get("v.searchText"); 
            var action = component.get("c.findByName");
            action.setParams({
                "searchKey": searchKey
            });
            action.setCallback(this, function(a) {
                component.set("v.searchText", a.getReturnValue());
            });
            $A.enqueueAction(action);
        }*/
    },
 /*   handleInput : function (cmp, event, helper) {
        var entersearch = cmp.get("{!v.searchText}");
        var messageempty = (entersearch ===""?" empty":"") ;
        //alert('handle Input: ' + entersearch + messageempty );
        
    },
     setScriptLoaded : function(cmp, event, helper) {
        //alert();
        //$j('[data-toggle="popover"]').popover();
    },
     searchKeyChange: function(component, event) {
        var searchKey = component.find("searchKey").get("v.value");
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            component.set("v.searchText", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
      LoadNow : function(cmp, event, helper) {
      alert('Load called');
       alert('Load Now called');
        var search = cmp.find("enter-search").get("v. value");
      	//var offset = cmp.get("v.Container.Offset");
        
       
        if(search == undefined) alert('Please enter text to search');
         
        if(!cmp.get("v.PreventChange")){
          //  $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.getLogisticDetails");
            action.setParams({LogisticIds:'',searchText:search});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    cmp.set("v.PreventChange", true);
                    cmp.set("v.IsSpinner",false);
                    cmp.set('v.logWrap',response.getReturnValue().solisItemList);
                    cmp.set('v.pickItem',response.getReturnValue().pickItems);
                    cmp.set('v.searchText',response.getReturnValue().LogName);
                    cmp.set('v.packItem',response.getReturnValue().packItems);
                    cmp.set('v.shipItem',response.getReturnValue().shipItems);
                    cmp.set("v.IsSpinner",false);
                    
                    cmp.set("v.PreventChange", false);
                  //  $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }
    }, */
     Load : function(cmp, event, helper) {
         
         var texts = cmp.get("v.searchText");
         var action = cmp.get("c.findByName");
         action.setParams({searchKey:search});
         cmp.set("v.IsSpinner",true);
         action.setCallback(this, function(response) {
             var state = response.getState();
             if(state === "SUCCESS"){
                 cmp.set("v.PreventChange", true);
                 cmp.set("v.IsSpinner",false);
                 cmp.set('v.logWrap',response.getReturnValue().solisItemList);
                 cmp.set('v.pickItem',response.getReturnValue().pickItems);
                 cmp.set('v.searchText',response.getReturnValue().LogName);
                 cmp.set('v.packItem',response.getReturnValue().packItems);
                 cmp.set('v.shipItem',response.getReturnValue().shipItems);
                 cmp.set("v.IsSpinner",false);
                 
                 cmp.set("v.PreventChange", false);
                 //  $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
             }
         });
         $A.enqueueAction(action);
         
         
     }
        
   
    
})