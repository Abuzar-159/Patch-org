({ 
    TimeEventHandler: function(component, event, helper) {
        try{
         var RIndex=event.getParam("RIndex");
         var DIndex=event.getParam("DIndex");
         var action=event.getParam("action");
         var value=event.getParam("value");
         var ResourceList=[]; ResourceList=component.get("v.ResourceList");
         var DateList=[];DateList=component.get("v.DateList"); 
         var RRecord=ResourceList[RIndex];      
         var TimeOffRecord=RRecord.TimeOffList[DIndex];        
         var selDate=new Date(DateList[DIndex]);
         var selDayName =selDate.toString().split(' ')[0];
         var TimeDuration=component.get("v.TimeDuration"); 
        
        if(action=='st' || action=='et'){ 
        if(action=='st'){
               if(selDayName=='Mon') RRecord.Mon_Start_Time=TimeOffRecord.Start_Time;
          else if(selDayName=='Tue') RRecord.Tue_Start_Time=TimeOffRecord.Start_Time;
          else if(selDayName=='Wed') RRecord.Wed_Start_Time=TimeOffRecord.Start_Time;
          else if(selDayName=='Thu') RRecord.Thu_Start_Time=TimeOffRecord.Start_Time;
          else if(selDayName=='Fri') RRecord.Fri_Start_Time=TimeOffRecord.Start_Time;
          else if(selDayName=='Sat') RRecord.Sat_Start_Time=TimeOffRecord.Start_Time;
          else if(selDayName=='Sun') RRecord.Sun_Start_Time=TimeOffRecord.Start_Time; 
          /*
          if(value!=undefined && value!='' && TimeDuration>0){   
          var newTimeVal=helper.addMinutes(component, event, helper,value,TimeDuration);
          RRecord.TimeOffList[DIndex].End_Time=newTimeVal;             
          ResourceList[RIndex]=RRecord;
          component.set("v.ResourceList",ResourceList);
            
          if(selDayName=='Mon') RRecord.Mon_End_Time=newTimeVal;
          else if(selDayName=='Tue') RRecord.Tue_End_Time=newTimeVal;
          else if(selDayName=='Wed') RRecord.Wed_End_Time=newTimeVal;
          else if(selDayName=='Thu') RRecord.Thu_End_Time=newTimeVal;
          else if(selDayName=='Fri') RRecord.Fri_End_Time=newTimeVal;
          else if(selDayName=='Sat') RRecord.Sat_End_Time=newTimeVal;
          else if(selDayName=='Sun') RRecord.Sun_End_Time=newTimeVal;      
        } */
        } 
        else if(action=='et'){
               if(selDayName=='Mon') RRecord.Mon_End_Time=TimeOffRecord.End_Time;
          else if(selDayName=='Tue') RRecord.Tue_End_Time=TimeOffRecord.End_Time;
          else if(selDayName=='Wed') RRecord.Wed_End_Time=TimeOffRecord.End_Time;
          else if(selDayName=='Thu') RRecord.Thu_End_Time=TimeOffRecord.End_Time;
          else if(selDayName=='Fri') RRecord.Fri_End_Time=TimeOffRecord.End_Time;
          else if(selDayName=='Sat') RRecord.Sat_End_Time=TimeOffRecord.End_Time;
          else if(selDayName=='Sun') RRecord.Sun_End_Time=TimeOffRecord.End_Time;          
        }      
        }
       
      if(action=='bst' || action=='bet'){ 
        if(action=='bst'){
               if(selDayName=='Mon') RRecord.Mon_Break_Start_Time=TimeOffRecord.BST;
          else if(selDayName=='Tue') RRecord.Tue_Break_Start_Time=TimeOffRecord.BST;
          else if(selDayName=='Wed') RRecord.Wed_Break_Start_Time=TimeOffRecord.BST;
          else if(selDayName=='Thu') RRecord.Thu_Break_Start_Time=TimeOffRecord.BST;
          else if(selDayName=='Fri') RRecord.Fri_Break_Start_Time=TimeOffRecord.BST;
          else if(selDayName=='Sat') RRecord.Sat_Break_Start_Time=TimeOffRecord.BST;
          else if(selDayName=='Sun') RRecord.Sun_Break_Start_Time=TimeOffRecord.BST;
            
          if(value!=undefined && value!='' && TimeDuration>0){      
          var newTimeVal=helper.addMinutes(component, event, helper,value,TimeDuration);
               RRecord.TimeOffList[DIndex].BET=newTimeVal;             
               ResourceList[RIndex]=RRecord;
               component.set("v.ResourceList",ResourceList);            
              if(selDayName=='Mon') RRecord.Mon_Break_End_Time=newTimeVal;
              else if(selDayName=='Tue') RRecord.Tue_Break_End_Time=newTimeVal;
              else if(selDayName=='Wed') RRecord.Wed_Break_End_Time=newTimeVal;
              else if(selDayName=='Thu') RRecord.Thu_Break_End_Time=newTimeVal;
              else if(selDayName=='Fri') RRecord.Fri_Break_End_Time=newTimeVal;
              else if(selDayName=='Sat') RRecord.Sat_Break_End_Time=newTimeVal;
              else if(selDayName=='Sun') RRecord.Sun_Break_End_Time=newTimeVal;             
         }     
        
        } 
        else if(action=='bet'){
               if(selDayName=='Mon') RRecord.Mon_Break_End_Time=TimeOffRecord.BET;
          else if(selDayName=='Tue') RRecord.Tue_Break_End_Time=TimeOffRecord.BET;
          else if(selDayName=='Wed') RRecord.Wed_Break_End_Time=TimeOffRecord.BET;
          else if(selDayName=='Thu') RRecord.Thu_Break_End_Time=TimeOffRecord.BET;
          else if(selDayName=='Fri') RRecord.Fri_Break_End_Time=TimeOffRecord.BET;
          else if(selDayName=='Sat') RRecord.Sat_Break_End_Time=TimeOffRecord.BET;
          else if(selDayName=='Sun') RRecord.Sun_Break_End_Time=TimeOffRecord.BET;          
        } 
      
      }
            
         var RRecordJSON=JSON.stringify(RRecord);  
        
         var action = component.get("c.getUpdateResources");  
         action.setParams({
              "RRecordJSON":RRecordJSON                           
          });  
          action.setCallback(this, function(response) {
          var state = response.getState();
          if (component.isValid() && state === "SUCCESS") {
               
             component.set("v.showTimePanel",false);  
          }          
         });
         $A.enqueueAction(action);       
        
      
        }catch(ex){ }     
    }, 
  
    /*FOR INITIALIZING COMPONENT*/ 
	doinit : function(component, event, helper) {  
        if(component.get("v.callDoInit")){
        helper.fetchLocationsAndServices(component, event, helper); 
        var d = new Date();                                                                        
        var dateFormat = $A.get("$Locale.dateFormat"); 
        var dateString = $A.localizationService.formatDateTime(d, dateFormat);          
        component.set("v.FirstAvailableDate",dateString);        
        }       
	},
    
    /*FOR PAGINATION*/  
    PaginationEventHandler:function(component, event, helper) { 
        
        //if(component.find("mainSpinId").getElement() !=undefined && component.find("mainSpinId").getElement() !=null) component.find("mainSpinId").getElement().style.visibility = "visible";
        var RecordList=[];RecordList=event.getParam("RecordList");
        component.set("v.ResourceList",RecordList);
        //if(component.find("mainSpinId").getElement() !=undefined && component.find("mainSpinId").getElement() !=null) component.find("mainSpinId").getElement().style.visibility = "hidden";  
    },
     
    /*FOR NEXT WEEK */
    next : function(component, event, helper) {
       helper.next(component, event, helper);	
    },
    
     /*FOR PREVIOUS WEEK */
    previous : function(component, event, helper) {
          helper.previous(component, event, helper);	
    },
 
     /*FOR ONCHANGE LOCATION,SERVICE, TEAM PICK LIST*/
    onchange : function(component, event, helper) {	
        helper.fetchResources(component, event, helper);	 
    },
 
    
  /*=======================FOR MANAGE TIME OFF==============================*/    
 getManageResourcePage:function(component, event, helper){   
     var RId=''; if(component.get("v.ResourceList")[0]!=undefined && component.get("v.ResourceList").length>0) RId=component.get("v.ResourceList")[0].Id;
     /*var evt = $A.get("e.force:navigateToComponent");   
     //window.open('/' + event.getParam('recordId'));   
     evt.setParams({
         componentDef:"c:ManageResource",
            componentAttributes :{
               "RId":RId,
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
      evt.fire(); */   
       $A.createComponent(
            "c:ManageResource", {
                 "RId":RId,
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
                "checker":component.get("v.checker")
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
    );
                                                          
  },     
    
})