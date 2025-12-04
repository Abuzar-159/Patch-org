({
    "doInit" : function(component, event, helper) {
       
          var actionDate = component.get("c.orgFYStartDate");
          actionDate.setCallback(this, function(response) {
          component.set('v.start_date', response.getReturnValue().sDate);
            
          /*var startDate = new Date($A.localizationService.formatDate(component.find("start_date").get("v.value")));
          var temp = component.find("start_date").get("v.value");
    	  temp = new Date(startDate.getFullYear(), startDate.getMonth(), 1);
          temp.setMonth(temp.getMonth() + (12));
    	  temp.setDate(temp.getDate() - 1); */
          component.set('v.end_date',response.getReturnValue().eDate);
          //helper.initRecords(component);
           helper.defaultRecords(component); 
              	window.onscroll = function() {myFunction()};

               // var header = document.getElementById("myHeader");
               // var sticky = header.offsetTop;
                
                function myFunction() {
                 /* if (window.pageYOffset >= sticky) {
                    header.classList.add("sticky");
                  } else {
                    header.classList.remove("sticky");
                  }*/
                }
                              
         });
       $A.enqueueAction(actionDate);
  },
    
     "changeDate" : function(component, event, helper){
    	 var startDate = new Date($A.localizationService.formatDate(component.find("start_date").get("v.value")));
       var temp = component.find("start_date").get("v.value");
    	 temp = new Date(startDate.getFullYear(), startDate.getMonth(), 1);
         temp.setMonth(temp.getMonth() + (12));
    	temp.setDate(temp.getDate() - 1); 
        
       	 component.set('v.end_date',temp.getFullYear() + "-" +(temp.getMonth()+1)+ "-" +temp.getDate());
        component.set("v.wrongPeriod", false);
        helper.getRecOnDates(component,event, helper);
    },
    
    "changeEndDate" : function(component, event, helper)
    {
      component.set("v.wrongPeriod", false);
      helper.getRecOnDates(component,event, helper);
      
    },
   
     "changeOrg" : function(component, event, helper)
    {
      var actionOrg = component.get("c.updateRecords");
        
       actionOrg.setParams({
           passed_start_date: component.get("v.start_date"), 
           passed_end_date: component.get("v.end_date"),
           org : component.get("v.AP.ERP7__Organisation__c")
       		});
        
      actionOrg.setCallback(this, function(response) {
            component.set('v.accounting_period', response.getReturnValue().APS);
            var checkTotalRecords = response.getReturnValue().checkTotalRecords;
                /*if(checkTotalRecords == true){
                     var button = component.find('button');
                     button.set("v.disabled",true);
                   // button.set.backgroundColor = 'red';
                }else{
                     var button = component.find('button');
                     button.set("v.disabled",false);
                }*/
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
            component.set("v.wrongPeriod", false);
            var state = response.getState();
            
            
        });
		  $A.enqueueAction(actionOrg);
        
    },
    
  passDate: function(component, event, helper) {  //passDate
    // Fetch the account list from the Apex controller   
      var sDate=component.get("v.start_date");
      var eDate=component.get("v.end_date");
      var org=component.get("v.AP.ERP7__Organisation__c");
      var stemp = component.find("start_date").get("v.value");
      var etemp = component.find("end_date").get("v.value");
      //var diff = sDate.monthsBetween(eDate);
      //var total_months = (etemp.getFullYear() - stemp.getFullYear() )*12 + (etemp.getMonth() - stemp.getMonth() );
      if(org==''){
           if(eDate<=sDate){
              component.set("v.nameSortType", 0); 
              component.set("v.startDateSortType", 0);
        	  component.set("v.endDateSortType", 0);
              component.set("v.statusnameSortType", 0);
              component.set("v.wrongPeriod", true);
              component.set("v.checkRecords", false);
      }else{
      	  helper.getRecordsOnOrgNull(component,event, helper);
      		}
      }else
       if(eDate<=sDate){
             component.set("v.nameSortType", 0); 
             component.set("v.startDateSortType", 0);
        	 component.set("v.endDateSortType", 0);
             component.set("v.statusnameSortType", 0);
             component.set("v.wrongPeriod", true);
             component.set("v.checkRecords", false);
      }else{
          helper.getAccounting_Period_List(component,event, helper);}
    
  },
    
    sortByName: function(component, event, helper) {
        var sortField = 'Name';
        var stype=component.get("v.nameSortType");
        if(stype==0 || stype==1){
         component.set("v.nameSortType", -1);
        }else{ component.set("v.nameSortType", 1);}
         component.set("v.sortField", "Name");
        helper.sortBy(component, "Name");
        component.set("v.startDateSortType", 0);
        component.set("v.endDateSortType", 0);
        component.set("v.statusnameSortType", 0);
        
    },
    sortByStartDate: function(component, event, helper) {
        var sortField = 'ERP7__Start_Date__c';
        var stype=component.get("v.startDateSortType");
        if(stype==0 || stype==1){
         component.set("v.startDateSortType", -1);
        }else{ component.set("v.startDateSortType", 1);}
         component.set("v.sortField", "ERP7__Start_Date__c");
        helper.sortBy(component, "ERP7__Start_Date__c");
        component.set("v.nameSortType", 0);
        component.set("v.endDateSortType", 0);
        component.set("v.statusnameSortType", 0);
    },
     sortByEndDate: function(component, event, helper) {
        var sortField = 'ERP7__End_Date__c';
          var stype=component.get("v.endDateSortType");
        if(stype==0 || stype==1){
         component.set("v.endDateSortType", -1);
        }else{ component.set("v.endDateSortType", 1);}
         component.set("v.sortField", "ERP7__End_Date__c");
        helper.sortBy(component, "ERP7__End_Date__c");
         component.set("v.nameSortType", 0);
        component.set("v.startDateSortType", 0);
        component.set("v.statusnameSortType", 0);
    },
     sortByStatus: function(component, event, helper) {
        var sortField = 'ERP7__Status__c';
          var stype=component.get("v.statusnameSortType");
        if(stype==0 || stype==1){
         component.set("v.statusnameSortType", -1);
        }else{ component.set("v.statusnameSortType", 1);}
         component.set("v.sortField", "ERP7__Status__c");
        helper.sortBy(component, "ERP7__Status__c");
         component.set("v.nameSortType", 0);
        component.set("v.startDateSortType", 0);
        component.set("v.endDateSortType", 0);
    },
    hideNotification : function(component, event, helper) {
        component.set("v.checkInsertion",false);
    },
    hideNotification2 : function(component, event, helper) {
        component.set("v.existRecords",false);
    },
    
    selectFY : function(component, event, helper) {
        component.set("v.showMmainSpin", true);
        if(component.get("v.selectedFY")=='LAST_FISCAL_YEAR'){
            var actionDate = component.get("c.orgPrevFYStartDate");
            actionDate.setCallback(this, function(response) {
                component.set('v.start_date', response.getReturnValue().sDate);
                /*var startDate = new Date($A.localizationService.formatDate(component.find("start_date").get("v.value")));
                var temp = component.find("start_date").get("v.value");
                temp = new Date(startDate.getFullYear(), startDate.getMonth(), 1);
                temp.setMonth(temp.getMonth() + (12));
                temp.setDate(temp.getDate() - 1); 
                component.set('v.end_date',temp.getFullYear() + "-" +(temp.getMonth()+1)+ "-" +temp.getDate());*/
                component.set('v.end_date', response.getReturnValue().eDate);
                helper.getRecOnDates(component,event, helper);
            });
            $A.enqueueAction(actionDate);
        }else{
            var actionDate = component.get("c.orgFYStartDate");
            actionDate.setCallback(this, function(response) {
                component.set('v.start_date', response.getReturnValue().sDate);
                /*var startDate = new Date($A.localizationService.formatDate(component.find("start_date").get("v.value")));
                var temp = component.find("start_date").get("v.value");
                temp = new Date(startDate.getFullYear(), startDate.getMonth(), 1);
                temp.setMonth(temp.getMonth() + (12));
                temp.setDate(temp.getDate() - 1); 
                component.set('v.end_date',temp.getFullYear() + "-" +(temp.getMonth()+1)+ "-" +temp.getDate());*/
                component.set('v.end_date', response.getReturnValue().eDate);
                helper.getRecOnDates(component,event, helper);
            });
            $A.enqueueAction(actionDate);
        }
    },
    
    navigateToMyComponent : function(component, event, helper) {
        var recordId = event.getSource().get("v.value");
        var accList = component.get("v.accounting_period");
        var selectedAcc;
        for(var i in accList){
            if(accList[i].Id === recordId){
                selectedAcc = accList[i];
            }
        }
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ManageClosingOfBooksCheckList",
            componentAttributes: {
                AP:selectedAcc,
                OrgId : selectedAcc.ERP7__Organisation__c
            }
        });
        evt.fire();
    }
})