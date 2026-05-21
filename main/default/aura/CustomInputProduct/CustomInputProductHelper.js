({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'queryFilter' : component.get("v.qry"),
            'SearchField' : component.get("v.SearchField")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var storeResponse = response.getReturnValue();
                console.log('storeResponse : ',JSON.stringify(storeResponse));
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                console.log('storeResponse : ',JSON.stringify(component.get("v.listOfSearchRecords")));
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    fetchRecordById : function(component,event){
        let recordAction  = component.get("c.fetchLookUpValueById");
        recordAction.setParams({
            'ObjectName' : component.get("v.objectAPIName"),
            'SearchField' : component.get("v.SearchField"),
            'recordId' : component.get("v.selectedRecordId")
          });
        recordAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
               if(response.getReturnValue() !=null) 
            component.set("v.selectedRecord",response.getReturnValue());
            }else{
            }    
                
        });
        $A.enqueueAction(recordAction);
    }
})