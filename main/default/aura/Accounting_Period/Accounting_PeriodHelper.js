({
    initRecords : function(component,event, helper)
    {
          var action = component.get("c.initRecords");
          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.accounting_period', response.getReturnValue().APS);
                var list=response.getReturnValue().APS;
                if(list=='' || list==null)
                {
                 component.set("v.nameSortType", 0); 
                 component.set("v.startDateSortType", 0);
                 component.set("v.endDateSortType", 0);
                 component.set("v.statusnameSortType", 0);
                }else{
                     component.set("v.nameSortType", 1); 
                     component.set("v.startDateSortType", 0);
                     component.set("v.endDateSortType", 0);
                     component.set("v.statusnameSortType", 0);
                }
            
            }
               });
		  $A.enqueueAction(action);
        
    },
    
    defaultRecords : function(component,event, helper){
          var action = component.get("c.getDefaultOrg");
           action.setParams({
           passed_start_date: component.get("v.start_date"), 
           passed_end_date: component.get("v.end_date"), 
           });  
          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.AP.ERP7__Organisation__c', response.getReturnValue().acc.ERP7__Organisation__c);
                component.set('v.accounting_period', response.getReturnValue().APS);
                var checkTotalRecords = response.getReturnValue().checkTotalRecords;
                if(checkTotalRecords == true){
                     var button = component.find('button');
                     button.set("v.disabled",true);
                   // button.set.backgroundColor = 'red';
                }else{
                     var button = component.find('button');
                     button.set("v.disabled",false);
                }
                var list=response.getReturnValue().APS;
                if(list=='' || list==null){
                 component.set("v.nameSortType", 0); 
                 component.set("v.startDateSortType", 0);
                 component.set("v.endDateSortType", 0);
                 component.set("v.statusnameSortType", 0);
                }else{
                     component.set("v.nameSortType", 1); 
                     component.set("v.startDateSortType", 0);
                     component.set("v.endDateSortType", 0);
                     component.set("v.statusnameSortType", 0);
                }
            
            }else{ }
               });
		  $A.enqueueAction(action);
        
    },
    getRecordsOnOrgNull: function(cmp,event, helper)
    {
         var action = cmp.get("c.getRecordsOnOrgNull");
       var selectedOrg= cmp.get("v.AP");
       
      	//alert("####Value:"+selectedOrg.ERP7__Organisation__c);
       action.setParams({
           passed_start_date: cmp.get("v.start_date"), 
           passed_end_date: cmp.get("v.end_date"), 
           org : cmp.get("v.AP.ERP7__Organisation__c")
       });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.accounting_period', response.getReturnValue().APS);
                var checkTotalRecords = response.getReturnValue().checkTotalRecords;
                if(checkTotalRecords == true){
                     var button = cmp.find('button');
                     button.set("v.disabled",true);
                   // button.set.backgroundColor = 'red';
                }else{
                     var button = cmp.find('button');
                     button.set("v.disabled",false);
                }
                
                    var list=response.getReturnValue().APS;
                    if(list=='' || list==null)
                    {
                     cmp.set("v.nameSortType", 0); 
                     cmp.set("v.startDateSortType", 0);
                     cmp.set("v.endDateSortType", 0);
                     cmp.set("v.statusnameSortType", 0);
                    }else{
                         cmp.set("v.nameSortType", 1); 
                         cmp.set("v.startDateSortType", 0);
                         cmp.set("v.endDateSortType", 0);
                         cmp.set("v.statusnameSortType", 0);
                    }
                   
                cmp.set('v.checkInsertion', response.getReturnValue().checkinserted);
                cmp.set('v.existRecords', response.getReturnValue().existRecords);
                cmp.set('v.checkRecords', response.getReturnValue().checkRecords);
                
                if(response.getReturnValue().checkinserted)
                    setTimeout(
                        $A.getCallback(function() {
                            cmp.set('v.checkInsertion',false);
                        }), 3000
                    );
                
                 if(response.getReturnValue().existRecords)
                     setTimeout(
                        $A.getCallback(function() {
                            cmp.set('v.existRecords',false);
                        }), 3000
                    );
                
                }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error~>"+errors);
                }
            }
        });
		  $A.enqueueAction(action);
    },
    
    getAccounting_Period_List: function(cmp,event, helper) {
       var action = cmp.get("c.setDate");
       var selectedOrg= cmp.get("v.AP");
       
      	//alert("####Value:"+selectedOrg.ERP7__Organisation__c);
       action.setParams({
           passed_start_date: cmp.get("v.start_date"), 
           passed_end_date: cmp.get("v.end_date"), 
           org : cmp.get("v.AP.ERP7__Organisation__c")
       });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                    cmp.set('v.accounting_period', response.getReturnValue().APS);
                    var checkTotalRecords = response.getReturnValue().checkTotalRecords;
                    if(checkTotalRecords == true){
                         var button = cmp.find('button');
                         button.set("v.disabled",true);
                       // button.set.backgroundColor = 'red';
                    }else{
                         var button = cmp.find('button');
                         button.set("v.disabled",false);
                    }
                                    
                    var list=response.getReturnValue().APS;
                    if(list=='' || list==null)
                    {
                     cmp.set("v.nameSortType", 0); 
                     cmp.set("v.startDateSortType", 0);
                     cmp.set("v.endDateSortType", 0);
                     cmp.set("v.statusnameSortType", 0);
                    }else{
                         cmp.set("v.nameSortType", 1); 
                         cmp.set("v.startDateSortType", 0);
                         cmp.set("v.endDateSortType", 0);
                         cmp.set("v.statusnameSortType", 0);
                    }
                   
                cmp.set('v.checkInsertion', response.getReturnValue().checkinserted);
                cmp.set('v.existRecords', response.getReturnValue().existRecords);
                cmp.set('v.checkRecords', response.getReturnValue().checkRecords);
                
                if(response.getReturnValue().checkinserted)
                    setTimeout(
                        $A.getCallback(function() {
                            cmp.set('v.checkInsertion',false);
                        }), 3000
                    );
                 if(response.getReturnValue().existRecords)
                     setTimeout(
                         $A.getCallback(function() {
                             cmp.set('v.existRecords',false);
                         }), 3000
                     );
                }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error~>"+errors);
                }
            }
        });
		  $A.enqueueAction(action);
  },
    
    
    getRecOnDates : function(component) {
        var action = component.get("c.updateOnDates");
      
        action.setParams({
           passed_start_date: component.get("v.start_date"), 
           passed_end_date: component.get("v.end_date"), 
           org : component.get("v.AP.ERP7__Organisation__c")
       });
        
       action.setCallback(this, function(response) {
            component.set('v.accounting_period', response.getReturnValue().APS);
            var checkTotalRecords = response.getReturnValue().checkTotalRecords;
                if(checkTotalRecords == true){
                     var button = component.find('button');
                     button.set("v.disabled",true);
                   // button.set.backgroundColor = 'red';
                }else{
                     var button = component.find('button');
                     button.set("v.disabled",false);
                }
                
            var list=response.getReturnValue().APS;
            if(list=='' || list==null)
            {
             component.set("v.nameSortType", 0); 
             component.set("v.startDateSortType", 0);
        	 component.set("v.endDateSortType", 0);
             component.set("v.statusnameSortType", 0);
            }else{
                 component.set("v.nameSortType", 1); 
                 component.set("v.startDateSortType", 0);
                 component.set("v.endDateSortType", 0);
                 component.set("v.statusnameSortType", 0);
            }
           
            component.set('v.checkRecords', response.getReturnValue().checkRecords);
            var state = response.getState();
         });
		  $A.enqueueAction(action);
    },
    
     sortBy: function(component, field) {
        var sortAsc = component.get("v.sorting"),
            sortField = component.get("v.sortField"),
            records = component.get("v.accounting_period");
         sortAsc = sortField != field || !sortAsc;
         records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
         component.set("v.sorting", sortAsc);
         component.set("v.sortField", field);
         component.set("v.accounting_period", records);
        var currentDir = component.get("v.arrowDirection");
 
      if (currentDir == 'arrowdown') {
         // set the arrowDirection attribute for conditionally rendred arrow sign  
         component.set("v.arrowDirection", 'arrowup');
        
      } else {
         component.set("v.arrowDirection", 'arrowdown');
        
      }
    },
  
})