({
	fetchTimeSlots : function(component, event, helper, UserId) {
        var timeZone=$A.get("$Locale.timezone");
        component.set("v.TimeZone",timeZone);
		component.set("v.showMmainSpin",true); 
        component.set("v.NoSlotsMessage",''); 
            var pageSize1 = component.get("v.pageSize1");
        var sRec = component.get("v.UserRecords");  
        var action = component.get("c.getTimeAvailibility"); 
        action.setParams({
            'ServiceId':component.get("v.ServiceId"), 
            'LocationId':component.get("v.LocationId"), 
            selectedDate:component.get("v.selectedDate"),
            'Action':'', WeekSelectedDate:component.get("v.WeekSelectedDate")
        });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") { 
              try{ 
                if(response.getReturnValue()!=null && response.getReturnValue()!=undefined && response.getReturnValue()!=''){
                  component.set("v.DayDetails",response.getReturnValue().DayList);
                  if(response.getReturnValue().UserList.length>0) component.set("v.User",response.getReturnValue().UserList[0].User); 
                  component.set("v.UserType",response.getReturnValue().UserType);  
                   
                  var filter = ''; var records=[]; records=response.getReturnValue().ProgramIds;
                  for(var obj in records){
                      if(obj == 0) filter = ' And ( Id = \''+records[obj]+'\'';
                       else filter += ' Or Id = \''+records[obj]+'\'';
                  }
                  filter += ')'; 
                 component.set("v.ProgramsFilter",filter);
                   
                  filter = ''; records=response.getReturnValue().ServiceIds;
                  for(var obj in records){
                      if(obj == 0) filter = ' And ( Id = \''+records[obj]+'\'';
                       else filter += ' Or Id = \''+records[obj]+'\'';
                  }
                  filter += ')'; 
                  component.set("v.ServicesFilter",filter);
                   
                  filter = ''; records=response.getReturnValue().LocationIds;
                  for(var obj in records){
                      if(obj == 0) filter = ' And ( Id = \''+records[obj]+'\'';
                       else filter += ' Or Id = \''+records[obj]+'\'';
                  }
                  filter += ')'; 
                 component.set("v.LocationsFilter",filter);
              	 component.set("v.UserWrapperListDum",response.getReturnValue().UserList);
              
                  if(response.getReturnValue().UserList.length<=0)  component.set("v.NoSlotsMessage",'No user available'); 
                  component.set("v.selectedDate",response.getReturnValue().selectedDate);
                  if(component.get("v.Action")!='Calendar') component.set("v.WeekSelectedDate",response.getReturnValue().selectedDate); 
                   
                  component.set("v.FirstDate",response.getReturnValue().FirstDate); 
                   component.set("v.showNext",response.getReturnValue().showNext);  
                   if(component.get("v.FromOtherComp")==false) component.set("v.showPrevious",response.getReturnValue().showPrevious);  
                   component.set("v.ShiftPlanner",response.getReturnValue()); 
                   component.set("v.showMmainSpin",false); 
                   component.set("v.SearchString",''); 
                   component.set("v.UserRecords", response.getReturnValue().UserList); 
                   component.set("v.UnfilteredUserRecords", response.getReturnValue().UserList); 
                   component.set("v.totalSize1", component.get("v.UserRecords").length);
                   component.set("v.start1",0);
                   component.set("v.end1",pageSize1-1);
                   var UserRecordspage = [];
                   if(response.getReturnValue().UserList.length < pageSize1){
                       UserRecordspage=response.getReturnValue().UserList;
                   }
                   else{
                       for(var i=0; i< pageSize1; i++){
                        UserRecordspage.push(response.getReturnValue().UserList[i]); 
                    } 
                }
                    try{
                        
                        component.set("v.UserRecordspage", UserRecordspage);
                        component.set("v.UnfilteredUserRecordspage", UserRecordspage);
                    }
                    
                  catch(err) {
                    component.set("v.exceptionError", err.message);
                }
                helper.helperMethodPaginationEvent(component, event, helper,'1');
                }
               }catch(ex){
               }     
            }else{
                var errors = response.getError();
                console.log("server error : ", errors);
                component.set("v.errorMessage", errors[0].message);
            }       
        });
       $A.enqueueAction(action);
    },
    
  getPagination : function(component, event, helper) { 
    component.set("v.SearchString",''); 
    var counter=0;   
    var RecordList=[]; RecordList=component.get("v.UserWrapperListDum");
    var Entries=component.get("v.Entries");    
	var PageNumbers=(RecordList.length)/Entries;                         
    var PageNumbersArray = new Array(); 
    for(var i=0;i<PageNumbers; i++ ){         
        PageNumbersArray.push(i+1);          
    }
    if(PageNumbersArray.length==0) PageNumbersArray.push(1);
    component.set("v.pageNumbers",PageNumbersArray);
    
     if(PageNumbersArray.length==1) component.set("v.nextDisa",true); 
     else  component.set("v.nextDisa",false);     
    var RecordListNew=[]; 
    
    if(Entries<=RecordList.length){  counter=counter+Entries;  
         for(var i=0;i<Entries; i++) RecordListNew.push(RecordList[i]);
    }  
    else{ counter=RecordList.length; 
         for(var i=0;i<RecordList.length; i++) RecordListNew.push(RecordList[i]);
   }   
   component.set("v.counter",counter);
   component.set("v.UserWrapperList",RecordListNew);                                                   
   if(RecordListNew.length==0 || RecordListNew==undefined || RecordListNew=='') component.set("v.criteriaMsg",'No Resource Found');
   else component.set("v.criteriaMsg",''); 
                                                      
      setTimeout(
          $A.getCallback(function() {
              if(component.find("PNIds")!=undefined)
                  if(component.find("PNIds")[0]!=undefined) $A.util.addClass(component.find("PNIds")[0].getElement(),"pageNumberClass");
                  else $A.util.addClass(component.find("PNIds").getElement(),"pageNumberClass");
          }), 1000
      );
   component.set("v.prevDisa",true);                                                                                                    
  },  
  
    
    next : function(component, event, helper, UserId) {
		var timeZone=$A.get("$Locale.timezone"); 
        component.set("v.TimeZone",timeZone);
          var pageSize1 = component.get("v.pageSize1");
        var sRec = component.get("v.UserRecords");  
		component.set("v.showMmainSpin",true); component.set("v.NoSlotsMessage",'');  
        var action = component.get("c.getNextTimeSlots");
        action.setParams({'ServiceId':component.get("v.ServiceId"), 'LocationId':component.get("v.LocationId"), selectedDate:component.get("v.selectedDate"),'Action':'Next'});
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") { 
              try{
               if(response.getReturnValue()!=null && response.getReturnValue()!=undefined && response.getReturnValue()!=''){
                  component.set("v.DayDetails",response.getReturnValue().DayList);  
                  component.set("v.UserWrapperListDum",response.getReturnValue().UserList);
                  if(response.getReturnValue().UserList.length<=0) component.set("v.NoSlotsMessage",'No user available');  
                  component.set("v.selectedDate",response.getReturnValue().selectedDate); 
                  component.set("v.WeekSelectedDate",response.getReturnValue().selectedDate);  
                  component.set("v.FirstDate",response.getReturnValue().FirstDate); 
                  component.set("v.showNext",response.getReturnValue().showNext);  
                  component.set("v.showPrevious",response.getReturnValue().showPrevious);  
                  component.set("v.ShiftPlanner",response.getReturnValue()); 
                  component.set("v.showMmainSpin",false);
                  component.set("v.SearchString",''); 
                  component.set("v.UserRecords", response.getReturnValue().UserList); 
                component.set("v.UnfilteredUserRecords", response.getReturnValue()); 
                component.set("v.totalSize1", component.get("v.UserRecords").length);
                component.set("v.start1",0);
                component.set("v.end1",pageSize1-1);
                var UserRecordspage = [];
                    if(response.getReturnValue().UserList.length < pageSize1){
                    UserRecordspage=response.getReturnValue().UserList;
                }
                else{
                    for(var i=0; i< pageSize1; i++){
                        UserRecordspage.push(response.getReturnValue().UserList[i]); 
                    } 
                }
				 try{
                     
                component.set("v.UserRecordspage", UserRecordspage);
                       }
                
                  catch(err) {
                    component.set("v.exceptionError", err.message);
                }
                helper.helperMethodPaginationEvent(component, event, helper,'1'); 
                }
               }catch(ex){ }      
            }       
        });
       $A.enqueueAction(action);
    },
    
    previous : function(component, event, helper, UserId) {
		var timeZone=$A.get("$Locale.timezone"); component.set("v.FromOtherComp",false);
        component.set("v.TimeZone",timeZone);
         var pageSize1 = component.get("v.pageSize1");
        var sRec = component.get("v.UserRecords");  
		component.set("v.showMmainSpin",true); component.set("v.NoSlotsMessage",'');  
        var action = component.get("c.getPreviousTimeSlots");
        action.setParams({'ServiceId':component.get("v.ServiceId"), 'LocationId':component.get("v.LocationId"), selectedDate:component.get("v.selectedDate"),'Action':'Prev'});
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") { 
              try{
               if(response.getReturnValue()!=null && response.getReturnValue()!=undefined && response.getReturnValue()!=''){
                  component.set("v.DayDetails",response.getReturnValue().DayList);   
                  component.set("v.UserWrapperListDum",response.getReturnValue().UserList);
                  if(response.getReturnValue().UserList.length<=0) component.set("v.NoSlotsMessage",'No user available');  
                  component.set("v.selectedDate",response.getReturnValue().selectedDate);
                  component.set("v.WeekSelectedDate",response.getReturnValue().selectedDate);  
                  component.set("v.FirstDate",response.getReturnValue().FirstDate); 
                  component.set("v.showNext",response.getReturnValue().showNext);  
                  component.set("v.showPrevious",response.getReturnValue().showPrevious);  
                  component.set("v.ShiftPlanner",response.getReturnValue()); 
                  component.set("v.showMmainSpin",false); 
                  component.set("v.SearchString",'');
                  component.set("v.UserRecords", response.getReturnValue().UserList); 
                component.set("v.UnfilteredUserRecords", response.getReturnValue()); 
                component.set("v.totalSize1", component.get("v.UserRecords").length);
                component.set("v.start1",0);
                component.set("v.end1",pageSize1-1);
                var UserRecordspage = [];
                    if(response.getReturnValue().UserList.length < pageSize1){
                    UserRecordspage=response.getReturnValue().UserList;
                }
                else{
                    for(var i=0; i< pageSize1; i++){
                        UserRecordspage.push(response.getReturnValue().UserList[i]); 
                    } 
                }
                   try{
                       
                       component.set("v.UserRecordspage", UserRecordspage);
                   }
                   
                   catch(err) {
                       component.set("v.exceptionError", err.message);
                   }
                helper.helperMethodPaginationEvent(component, event, helper,'1');  
                }
               }catch(ex){ }      
            }       
        });
       $A.enqueueAction(action);
    },
    getCurrentDayTimeOff : function(component, event, currentDate, currentSlot, uId){
        var action = component.get("c.getCurrentTimeOffReason");
        action.setParams({
            toDate          : currentDate,
            slotDate        : JSON.stringify(currentSlot),
            selectedUserId  : uId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.currentTO_reason", response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("error ~> ", errors);
                component.set("v.errorMessage", errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    helperMethodPaginationEvent :function(component, event, helper,pageNumber){
        
        var pageSize1 = component.get("v.pageSize1");//Number Of Row Per Page
        var totalpage1=Math.ceil(component.get("v.UserRecords").length/pageSize1);
        var   paginationPageNumb1=[];
        var cont=1;
        if(pageNumber<7){
            
            for(var i=1; i<= totalpage1; i++){
                paginationPageNumb1.push(i);
                if(cont>7){
                    paginationPageNumb1.push('...');
                    paginationPageNumb1.push(totalpage1);
                    break;
                }
                cont++;
            }
        }
        else{
            paginationPageNumb1.push('1');
            paginationPageNumb1.push('2');
            paginationPageNumb1.push('...');
            pageNumber=(pageNumber<=0)?2:((pageNumber>=totalpage1)? (totalpage1-3) :(( pageNumber==totalpage1-1 )?(pageNumber = pageNumber-2):( (pageNumber==totalpage1-2 ) ? (pageNumber-1):pageNumber ))) ;
            for(var i=pageNumber-2; i<=pageNumber+2 ; i++){
                paginationPageNumb1.push(i);
            }
            paginationPageNumb1.push('...');
            paginationPageNumb1.push(totalpage1);
        }
        component.set('v.paginationPageNumb1', null);
        component.set('v.paginationPageNumb1', paginationPageNumb1);
        
    },
    
})