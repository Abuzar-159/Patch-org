({
	fetchRecordList:function(comp, event, helper){
      var action = comp.get("c.getRoutingRecordDetails"); 
      action.setParams({
          "RoutingId":comp.get("v.RoutingId")
      });   
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (comp.isValid() && state === "SUCCESS") {
          
        var response=response.getReturnValue();
      
          comp.set("v.Routing",response.Routing);
          comp.set("v.Operation",response.Operation);  
          comp.set("v.OperationList",response.OperationList);     
          comp.set("v.OperationListD",response.OperationList);
          comp.set("v.showMainSpin",false);                                          
      }         
     });
     $A.enqueueAction(action);  
    },
    
    
   fetchPicklistValues:function(comp, event, helper){
      var action = comp.get("c.getPicklistValues");   
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (comp.isValid() && state === "SUCCESS") {  
          var response=response.getReturnValue();  
                                          
            comp.set("v.RoutingStatusList",response.RoutingStatusList);
            comp.set("v.RoutingTypeList",response.RoutingTypeList);  
            comp.set("v.RoutingRTList",response.RoutingRTList);
           
      }         
     });
     $A.enqueueAction(action);  
    },
   
 checkMandatoryFields:function(comp, event, helper, Tab){
      comp.set("v.seBool",false);  
      if(comp.get("v.Tab")=='rou'){
          var Routing=comp.get("v.Routing"); 
          if(this.trim(Routing.Name)==false){
              comp.set("v.seBool",true); return false; 
          } 
          else{
            comp.set("v.seBool",false);  return true; 
          }             
      }  
      else if(comp.get("v.Tab")=='ope'){
          var Operation=comp.get("v.Operation"); 
          if(this.trim(Operation.Name)==false || this.trim(Operation.ERP7__Process_Cycle__c)==false){
              comp.set("v.seBool",true); return false; 
          } 
          else{
            comp.set("v.seBool",false);  return true; 
          }  
      } return false;
 },  

    
    saveRecord:function(comp, event, helper){
        var Tab=comp.get("v.Tab");
        var Record;
        if(Tab=='rou') Record=comp.get("v.Routing");
        else if(Tab=='ope') Record=comp.get("v.Operation");
       
        var checkMandatoryFieldsBool=false; checkMandatoryFieldsBool=this.checkMandatoryFields(comp, event, helper, Tab); 
       
     if(checkMandatoryFieldsBool){
        if(Tab=='rou') comp.set("v.Routing.ERP7__Product__c",comp.get("v.ProductId"));
        else if(Tab=='ope'){ comp.set("v.Operation.ERP7__Routing__c",comp.get("v.RoutingId")); }       
       
        var action = comp.get("c.getCreateRoutingRecord");
        var act=comp.get("v.action");                      
        var RecordJSON=JSON.stringify(Record);        
        action.setParams({
        "Record":RecordJSON,
        "Action":act,
        "Tab":Tab,
        "RoutingId" :comp.get("v.RoutingId")  
        });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (comp.isValid() && state === "SUCCESS") {
          var response=response.getReturnValue();
          comp.set("v.showPopup",false); 
          $A.util.addClass(comp.find("deleteConfirmId").getElement(),'slds-hide'); 
                                                  
          if(Tab=='rou'){
              comp.set("v.Routing",response.Routing); comp.set("v.RoutingId",response.Routing.Id);
              var savedStr='Saved.'; 
             if(response.Routing.Id==undefined || response.Routing.Id=='') savedStr='Created.'                                              
             var SaveEventMsgStr='Routing '+'"'+response.Routing.Name+'" was '+savedStr;                                                
             comp.set("v.SaveMsg",SaveEventMsgStr);
              setTimeout(
                  $A.getCallback(function() {
                      comp.set("v.SaveMsg",""); comp.set("v.seBool",false);
                  }), 3000
              );
        } 
      
       else if(Tab=='ope') comp.set("v.OperationList",response.OperationList); comp.set("v.OperationListD",response.OperationList); 
     
          this.getInstances(comp, event, helper, Tab);
        }
      });
     $A.enqueueAction(action);  
    }        
    },
    
  getInstances:function(comp, event, helper, Tab){
    if(Tab=='ope'){   
      var action = comp.get("c.getOperation");         
      action.setCallback(this, function(response) {
      if (comp.isValid() && response.getState() === "SUCCESS") { 
          comp.set("v.Operation",response.getReturnValue());           
      }       
     });
     $A.enqueueAction(action);
     }
    
      
    },
    
   setRecord:function(comp, event, helper, Tab, index){
     if(comp.get("v.Tab")=='ope'){
         var OperationList=[]; OperationList=comp.get("v.OperationList");
         comp.set("v.Operation",OperationList[index]); 
          
     }else  return false;           
    },
    
    
    
   trim: function(value){  
        if(value !=undefined ) return ((value.toString()).trim() !=''?true:false);
        else return false;
    },  
    
   createRecord :function(component,event,sObject){ //,defaultvalues                                                      
         var windowHash = window.location.hash;
         var createRecordEvent = $A.get("e.force:createRecord");
         if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": sObject,
                "panelOnDestroyCallback": function(event) {
                 window.location.hash=history.back();
                }
          });
          createRecordEvent.fire();
        }   
        //"defaultFieldValues":defaultvalues,   windowHash window.history.back()       
    },
    
})