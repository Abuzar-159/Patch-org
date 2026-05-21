({
    
    doInit : function(component, event, helper) { 
      /*if(!component.get("v.isSupervisor") && component.get("v.ResourceListDum").length>1){
        var myqry = '';
        var ResourceList=[]; ResourceList=component.get("v.ResourceListDum");
        var RIds=[]; 
        for(var r in ResourceList) RIds.push(ResourceList[r].Id);
        if(RI
        ds !=''){
            for(var i in RIds){
                if(i==0) myqry =' And ( Id = \''+RIds[i]+'\'';
                myqry += ' Or Id = \''+RIds[i]+'\'';
            }
            myqry += ')';           
        } else myqry = '';
        component.set("v.RId",component.get("v.ResourceId"));    
        component.set("v.resourceQuery",myqry); 
      }*/ 
      
      var UserId=component.get("v.userId");
    // if(UserId=='' || UserId==undefined || UserId==null || UserId=='null') UserId=component.get("v.User").Id;   
        
     if(UserId!='' && UserId!=undefined  && UserId!=null  && UserId!='null'){  
	  var action = component.get("c.getTimeoffRecord");    
      action.setParams({
            "userId":UserId           
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
       if(response.getReturnValue().TimeoffList!=null){
                                                     
          var TimeoffList=[]; TimeoffList=response.getReturnValue().TimeoffList; 
          component.set("v.Timeoff",response.getReturnValue().Timeoff); 
          component.set("v.TOTypeList",response.getReturnValue().TOTypeList); 
          component.set("v.User",response.getReturnValue().User);             
          component.set("v.Today",response.getReturnValue().Today); 
          component.set("v.userId",UserId);
          
          for(var i in TimeoffList){
               if(TimeoffList[i].ERP7__Start_Time__c!=undefined) TimeoffList[i].ERP7__Start_Time__c=
                  helper.convertTimeToFormat(helper.convertMillisecondToTime(TimeoffList[i].ERP7__Start_Time__c),12);
                if(TimeoffList[i].ERP7__End_Time__c!=undefined) TimeoffList[i].ERP7__End_Time__c=
                    helper.convertTimeToFormat(helper.convertMillisecondToTime(TimeoffList[i].ERP7__End_Time__c),12);
          }
          component.set("v.TimeoffList",TimeoffList);
          if(TimeoffList.length==0) component.set("v.AvailabilityMsg",'No Item Found');                
          else component.set("v.AvailabilityMsg",'');   
       }else{
            component.set("v.Timeoff",response.getReturnValue().Timeoff); 
            component.set("v.TOTypeList",response.getReturnValue().TOTypeList); 
            component.set("v.Today",response.getReturnValue().Today); 
            component.set("v.TimeoffList",[]); component.set("v.AvailabilityMsg",'No Item Found'); 
       }                                           
      }else{
          console.log('getTimeoffRecords Exception Occured',response.getError());          
      }
          
     });
     $A.enqueueAction(action); 
     }else{ 
         
          component.set("v.TimeoffList",[]); component.set("v.AvailabilityMsg",'No Item Found'); 
         // component.set("v.userId",null);
     }     
	},
	/*doInit : function(component, event, helper) { 
      if(!component.get("v.isSupervisor") && component.get("v.ResourceListDum").length>1){
        var myqry = '';
        var ResourceList=[]; ResourceList=component.get("v.ResourceListDum");
        var RIds=[]; 
        for(var r in ResourceList) RIds.push(ResourceList[r].Id);
        if(RI
        ds !=''){
            for(var i in RIds){
                if(i==0) myqry =' And ( Id = \''+RIds[i]+'\'';
                myqry += ' Or Id = \''+RIds[i]+'\'';
            }
            myqry += ')';           
        } else myqry = '';
        component.set("v.RId",component.get("v.ResourceId"));    
        component.set("v.resourceQuery",myqry); 
      }*
      
     //if(component.get("v.userId")!=undefined && component.get("v.userId")!=''){  
	  var action = component.get("c.getTimeoffRecord");    
      action.setParams({
            "userId":component.get("v.userId")            
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
       if(response.getReturnValue().TimeoffList!=null){ 
                                                 
          var TimeoffList=[]; TimeoffList=response.getReturnValue().TimeoffList; 
          component.set("v.Timeoff",response.getReturnValue().Timeoff); 
          component.set("v.TOTypeList",response.getReturnValue().TOTypeList); 
          component.set("v.User",response.getReturnValue().User);             
          component.set("v.Today",response.getReturnValue().Today); 
           
          for(var i in TimeoffList){
               if(TimeoffList[i].ERP7__Start_Time__c!=undefined) TimeoffList[i].ERP7__Start_Time__c=
                  helper.convertTimeToFormat(helper.convertMillisecondToTime(TimeoffList[i].ERP7__Start_Time__c),12);
                if(TimeoffList[i].ERP7__End_Time__c!=undefined) TimeoffList[i].ERP7__End_Time__c=
                    helper.convertTimeToFormat(helper.convertMillisecondToTime(TimeoffList[i].ERP7__End_Time__c),12);
          }
          component.set("v.TimeoffList",TimeoffList);
          if(TimeoffList.length==0) component.set("v.AvailabilityMsg",'No Item Found');                
          else component.set("v.AvailabilityMsg",'');   
       }else{
            component.set("v.Timeoff",response.getReturnValue().Timeoff); 
            component.set("v.TOTypeList",response.getReturnValue().TOTypeList); 
            component.set("v.Today",response.getReturnValue().Today); 
            component.set("v.TimeoffList",[]); component.set("v.AvailabilityMsg",'No Item Found'); 
       }                                           
      }      
     });
     $A.enqueueAction(action); 
    // }     
	},*/
    TimeoffPopup : function(component, event, helper) { 
     try{    
       if(event.currentTarget.getAttribute('data-activity')=='show' && event.currentTarget.getAttribute('data-action')=='new'){
             component.set("v.showTimeoffPopup",true); component.set("v.action",'new');
             helper.getTOInstance(component, event, helper);
            
        }
         
       if(event.currentTarget.getAttribute('data-activity')=='show' && event.currentTarget.getAttribute('data-action')=='update'){
             component.set("v.showTimeoffPopup",true); component.set("v.action",'update');
             helper.TimeoffEdit(component, event, helper);
            
        }        
   
        else if(event.currentTarget.getAttribute('data-activity')=='hide' && (event.currentTarget.getAttribute('data-action')=='delete' || event.currentTarget.getAttribute('data-action')=='cancel')){
          component.set("v.showTimeoffPopup",false);
          component.set("v.action",'delete'); component.set("v.saveErrorMsg",''); component.set("v.DateErrorMsg",'');  component.set("v.eDateMsg",'');
        }
     }catch(ex){
             
     }   
    },
    
    TimeoffDelete:function(component, event, helper) {
        if(event.currentTarget.getAttribute('data-activity')=='show'){
             component.set("v.Id",event.currentTarget.getAttribute('data-Id'));
             component.set("v.action",event.currentTarget.getAttribute('data-action')); 
            
             $A.util.removeClass(component.find('timeoffDeleteConfirmId').getElement(), 'slds-hide'); 
             $A.util.addClass(component.find('timeoffDeleteConfirmId').getElement(), 'slds-show');    
        }
        else if(event.currentTarget.getAttribute('data-activity')=='hide'){
             $A.util.removeClass(component.find('timeoffDeleteConfirmId').getElement(), 'slds-show'); 
             $A.util.addClass(component.find('timeoffDeleteConfirmId').getElement(), 'slds-hide');    
        }
     },
    
    goToHome:function(component, event, helper) {
        if(component.get("v.FromSP")){ 
         
          $A.createComponent(
            "c:UsersShiftMatch", {
                "ServiceId":component.get("v.selectedService"),
                "LocationId":component.get("v.selectedExpLocation")
              
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
      );
         
               
     }else{
         $A.createComponent(
            "c:TimeManagement", {
                 "RId":component.get("v.RId"),
                "ResourceList":component.get("v.ResourceList"), 
                "ResourceListDum":component.get("v.ResourceListDum"),
                "TeamList":component.get("v.TeamList"),
                "expertLocsList":component.get("v.expertLocsList"),
                "prodServiceList":component.get("v.prodServiceList"),
                "DateList":component.get("v.DateList"),
                "dateFormat":component.get("v.dateFormat"),
                "isSupervisor":component.get("v.isSupervisor"),
                "selectedTeam":component.get("v.selectedTeam"),
                "selectedExpLocation":component.get("v.selectedExpLocation"),
                "selectedService":component.get("v.selectedService"),
                "TimeDuration":component.get("v.TimeDuration"),
                "callDoInit":false,
                "checker":component.get("v.checker")
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            });
     }
     /* var evt = $A.get("e.force:navigateToComponent");   
     //window.open('/' + event.getParam('recordId'));   
     evt.setParams({
         componentDef:"c:TimeManagement",
            componentAttributes :{
               "RId":component.get("v.RId"),
                "ResourceList":component.get("v.ResourceList"),
                "TeamList":component.get("v.TeamList"),
                "expertLocsList":component.get("v.expertLocsList"),
                "prodServiceList":component.get("v.prodServiceList"),
                "DateList":component.get("v.DateList"),
                "dateFormat":component.get("v.dateFormat"),
                "isSupervisor":component.get("v.isSupervisor"),
                "selectedTeam":component.get("v.selectedTeam"),
                "selectedExpLocation":component.get("v.selectedExpLocation"),
                "selectedService":component.get("v.selectedService"),
                "TimeDuration":component.get("v.TimeDuration")
            }
        });      
      evt.fire();
      */ 
        
        
        
      /*var url=window.location.href;   
      window.location = url.replace('https://www.w3schools.com'); ///apex/TimesManagementApp       
      location.replace("https://www.w3schools.com");
      */ 
   /*   
    var eUrl= $A.get("e.force:navigateToURL"); var ev=component.getEvent("HeaderEvent");  //var ev1= $A.getEvent("e.force:navigateToURL"); 
    var evt1 = $A.get("e.force:navigateToComponent"); //var evt = $A.get("e.force:navigateToComponent");    
     //window.open('/' + event.getParam('recordId'));   
    eUrl.setParams({
      "url": 'https://www.w3schools.com/' 
    });
    eUrl.fire();
     */   
        
    },
   
    getNotificationHide: function(component, event, helper) {
         component.set("v.saveErrorMsg",'');
    },
    
     onClick:function(component, event, helper) {
        component.set("v.saveErrorMsg",'');
    },
    
 saveTimeoff: function(component, event, helper) {
       component.set("v.TimeErrorMsg",''); component.set("v.saveErrorMsg",''); component.set("v.DateErrorMsg",''); component.set("v.eDateMsg",'');
       var action=component.get("v.action");
       if(action=='new' || action=='update'){
         var Timeoff=component.get("v.Timeoff");
        
        /*if(helper.trim(Timeoff.ERP7__Start_Date__c)==false) component.set("v.saveErrorMsg",'Required Field');
        else component.set("v.saveErrorMsg",'');
           
        if(helper.trim(Timeoff.ERP7__End_Date__c)==false) component.set("v.saveErrorMsg",'Required Field');
        else component.set("v.saveErrorMsg",'');*/
           
           if(helper.trim(Timeoff.ERP7__Start_Date__c)==false) component.set("v.saveErrorMsg",'Required Field Missing');
        else component.set("v.saveErrorMsg",'');
           
        if(helper.trim(Timeoff.ERP7__End_Date__c)==false) component.set("v.saveErrorMsg",'Required Field Missing');
        else component.set("v.saveErrorMsg",'');
		
		if(helper.trim(Timeoff.ERP7__End_Date__c)!=false)
		{
			if(helper.trim(Timeoff.ERP7__Start_Date__c)==false) component.set("v.saveErrorMsg",'Required Field Missing');
		}
        
       
        /*if(Timeoff.ERP7__Start_Date__c!=undefined && Timeoff.ERP7__Start_Date__c!=''){     
        if(!Date.parse(Timeoff.ERP7__Start_Date__c)) component.set("v.saveErrorMsg",'Invalid Value');
        else component.set("v.saveErrorMsg",'');    
        }
        
        if(Timeoff.ERP7__End_Date__c!=undefined && Timeoff.ERP7__End_Date__c!=''){     
        if(!Date.parse(Timeoff.ERP7__End_Date__c)) component.set("v.saveErrorMsg",'Invalid Value');
        else component.set("v.saveErrorMsg",'');    
        }*/
           
        var DateCompBool=Timeoff.ERP7__End_Date__c<Timeoff.ERP7__Start_Date__c;
        
        if(DateCompBool) component.set("v.saveErrorMsg",'End Date must be greater than or equal to Start Date');
        
         if(Timeoff.ERP7__Start_Date__c<component.get("v.Today") && component.get("v.saveErrorMsg")=='')     
         component.set("v.saveErrorMsg",'Start Date cannot be past');
           
         if(component.get("v.saveErrorMsg")=='')
         {
         if((helper.trim(Timeoff.ERP7__Start_Time__c)==false && helper.trim(Timeoff.ERP7__End_Time__c)==false) || (helper.trim(Timeoff.ERP7__Start_Time__c)==true && helper.trim(Timeoff.ERP7__End_Time__c)==true))
         component.set("v.saveErrorMsg",'');     
         else component.set("v.saveErrorMsg",'If you are giving start time than end time is also mandatory with valid time and Vice versa');        
         
         if((Timeoff.ERP7__End_Time__c!=undefined && Timeoff.ERP7__End_Time__c!='' && Timeoff.ERP7__Start_Time__c!=undefined && Timeoff.ERP7__Start_Time__c!='') && (Timeoff.ERP7__End_Time__c<=Timeoff.ERP7__Start_Time__c)) component.set("v.saveErrorMsg",'End Time should be greater than start time');
         }
         if(component.get("v.saveErrorMsg")=='') // && component.get("v.STErrorMsg")=='' && component.get("v.ETErrorMsg")==''
             helper.saveTimeoff(component, event, helper);   
       }else  if(action=='delete' ) helper.saveTimeoff(component, event, helper);        	    
	},
    
    DateDiffrenceHandler:function(component,event,helper){
        component.set("v.NODays",0); 
        if(helper.trim(component.get("v.Timeoff.ERP7__Start_Date__c")) && helper.trim(component.get("v.Timeoff.ERP7__End_Date__c"))){
        var oneDay = 24 * 60 * 60 * 1000; 
        var DateDiff = Math.abs(new Date(component.get("v.Timeoff.ERP7__End_Date__c")).getTime()
                                - new Date(component.get("v.Timeoff.ERP7__Start_Date__c")).getTime()) / (oneDay);
        component.set("v.NODays",DateDiff+1);     
        }
    },
})