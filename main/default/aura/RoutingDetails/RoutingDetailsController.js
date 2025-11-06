({
	doInit : function(comp, event, helper) {
      
       var Clone=false; Clone=getQueryVariable("Clone");           
       function getQueryVariable(variable) {
         var query = window.location.search.substring(1);
         var vars = query.split("&");
         for (var i=0;i<vars.length;i++) {
              var pair = vars[i].split("=");
              if (pair[0] == variable) {
                  return pair[1];
               }
          }             
       }
       if(Clone==undefined) comp.set("v.Clone",false); 
       else comp.set("v.Clone",Clone);  
      // if(Clone) comp.set("v.ProductId","");
       
       helper.fetchRecordList(comp, event, helper);
       helper.fetchPicklistValues(comp, event, helper);
     //  comp.set("v.CloneURL","/apex/ERP7__ProductLifecycleManagement?id="+comp.get("v.ProductId")+"&Clone=true");
        
        
	},
    getTab:function(comp, event, helper){
      var Tab=event.currentTarget.dataset.name;
      var TabIndex=event.currentTarget.dataset.service; 
      var TabElem=comp.find("TabId");  
      comp.set("v.Tab",event.currentTarget.dataset.name);

      for(var i=0; i<TabElem.length; i++){
          $A.util.removeClass(TabElem[i].getElement(),'active');
          if(i==TabIndex)  $A.util.addClass(TabElem[TabIndex].getElement(),'active');
      }  
     comp.set("v.showPopup",false);   comp.set("v.seBool",false); 
    },
    getRecord:function(comp, event, helper){
      comp.set("v.showPopup",true);   
      var action=event.currentTarget.dataset.name;
      var index=event.currentTarget.dataset.service; 
      comp.set("v.action",action);  
      helper.setRecord(comp, event, helper, comp.get("v.Tab"),event.currentTarget.dataset.service);        
    },
    
    
    
    showNewPopup:function(comp, event, helper){
      comp.set("v.Tab",event.currentTarget.dataset.name);  
      comp.set("v.showPopup",true);   comp.set("v.seBool",false); 
      comp.set("v.action",event.currentTarget.dataset.service);   
    },
    HideNewPopup:function(comp, event, helper){
      comp.set("v.showPopup",false);  comp.set("v.seBool",false); 
      helper.getInstances(comp, event, helper, comp.get("v.Tab"));
        
    },
    saveRecord:function(comp, event, helper){
      helper.saveRecord(comp, event, helper);  
    },
    
    getDelete:function(comp, event, helper){
      comp.set("v.action",event.currentTarget.dataset.name);    
      $A.util.removeClass(comp.find("deleteConfirmId").getElement(),'slds-hide');  
      comp.set("v.Index",event.currentTarget.dataset.service);
      helper.setRecord(comp, event, helper, comp.get("v.Tab"),event.currentTarget.dataset.service);  
        
    },
   cancelDelete:function(comp, event, helper){
      $A.util.addClass(comp.find("deleteConfirmId").getElement(),'slds-hide');  
        
    },
    
    getNotificationHide:function(comp, event, helper){
        comp.set("v.SaveMsg",""); comp.set("v.seBool",false); 
    }, 
    
    
    createRecord : function(component,event,helper){
         component.set("v.Tab",event.currentTarget.dataset.name);         
         helper.createRecord(component,event,'ERP7__Routing__c'); //,defaults  ERP7__Routing__c Product2
    },
    
  
    searchEventHandler : function(cmp,event,helper){
        var searchString = event.getParam("searchString").toString();
        if(searchString.length>1){
        if(cmp.get("v.Tab")=='ope'){ 
            var OperationList = cmp.get("v.OperationListD");
            OperationList = OperationList.filter(function (el) {
             var cond1=false; 
             if(el.ERP7__Work_Center__c!=undefined)   
             if(el.ERP7__Work_Center__r.Name!=undefined){ 
                el.ERP7__Work_Center__r.Name=(el.ERP7__Work_Center__r.Name).toString();                
                cond1=el.ERP7__Work_Center__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
             }
             var cond2=false;   
             if(el.ERP7__Fixed_Cost__c!=undefined){ 
                el.ERP7__Fixed_Cost__c=(el.ERP7__Fixed_Cost__c).toString();                 
                cond2=el.ERP7__Fixed_Cost__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;               
             }  
			 var cond3=false;   
             if(el.ERP7__Process_Cycle__c!=undefined){ 
                el.ERP7__Process_Cycle__r.Name==(el.ERP7__Process_Cycle__r.Name).toString();                 
                cond3=el.ERP7__Process_Cycle__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;               
             } 
                
             return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2 || cond3);
            });
            cmp.set("v.OperationList",OperationList);
            
         }   
            
       }else{
             cmp.set("v.OperationList",cmp.get("v.OperationListD"));                             
         
      }   
     },
    
    cancelRecord:function(comp, event, helper){  
        $A.createComponent(
            "c:ProductLifecycleManagement", {
                "ProductId":comp.get("v.ProductId"),
                "Tab":'rou'
            },
            function(newComp) {
                var content = comp.find("body");
                content.set("v.body", newComp);
            }
         ); 
    },
    
})