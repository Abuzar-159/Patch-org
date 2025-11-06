({
	fetchRecords : function(component,event,helper,Order) {
        console.log('ObjectAPIName:',component.get("v.ObjectAPIName"));
        console.log('OrderBy',component.get("v.OrderBy"));
        console.log('Order',Order);
        console.log('Query',component.get("v.Query"));
        console.log('Fields',component.get("v.Fields"));
        console.log('show',parseInt(component.get("v.show")));
      var action = component.get("c.getRecord");    
      action.setParams({
          "ObjectAPIName":component.get("v.ObjectAPIName"),
          "OrderBy":component.get("v.OrderBy"),
          "Order":Order,//component.get("v.Order"),
          "Query":component.get("v.Query"),
          "Fields":component.get("v.Fields"),
          "show":parseInt(component.get("v.show"))
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
          console.log('res of fetchRecords:',response.getReturnValue());
           component.set("v.RecordList",response.getReturnValue()); 

            var SortEvent = component.getEvent("SortRecord");
            SortEvent.setParams({"RecordList" : response.getReturnValue()});
            SortEvent.fire();
          
      }else{
          console.log('Error:',response.getError());
      }
                    
     });
     $A.enqueueAction(action);  
	}
})