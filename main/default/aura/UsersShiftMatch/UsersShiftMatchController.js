({
  
   searchUserRecord : function(cmp,event,helper){
        
       if(event.which == 13){
             var pageSize1 = cmp.get("v.pageSize1");
        var sRec = cmp.get("v.UserRecords"); 
           cmp.set("v.NoSlotsMessage",'');
           var SearchString = cmp.get("v.SearchString");
           if(SearchString!='' && SearchString!=undefined){   
               SearchString=SearchString.toString();
               var UserWrapperList =[]; 
               UserWrapperList=cmp.get("v.UserRecordspage");
               UserWrapperList = UserWrapperList.filter(function (el) {                
                   return ((el.User.Name).toString().toLowerCase().indexOf(SearchString.toLowerCase()) != -1);
               });
               cmp.set("v.totalSize1", UserWrapperList.length);
                cmp.set("v.start1",0);
                cmp.set("v.end1",pageSize1-1);
                 cmp.set("v.UserRecords",UserWrapperList); 
                var UserRecordspage = [];
                    if(UserWrapperList.length < pageSize1){
                    UserRecordspage=UserWrapperList;
                }
                else{
                    for(var i=0; i< pageSize1; i++){
                        UserRecordspage.push(UserWrapperList[i]); 
                    } 
                }
                    
				 try{
                     
                cmp.set("v.UserRecordspage", UserRecordspage);
                      // cmp.set("v.FilterUserRecordspage", UserRecordspage);
                       }
                
                  catch(err) {
                    cmp.set("v.exceptionError", err.message);
                }
                helper.helperMethodPaginationEvent(cmp, event, helper,'1');
               if(UserWrapperList.length<=0) cmp.set("v.NoSlotsMessage",'No user available');                     
           }
          
       }
       if(event.which == undefined)
           if(cmp.get("v.SearchString") == null || cmp.get("v.SearchString") == undefined || cmp.get("v.SearchString") == "")
           {
               cmp.set("v.UserRecordspage",cmp.get("v.UnfilteredUserRecordspage"));
               cmp.set("v.totalSize1", cmp.get("v.UnfilteredUserRecords").length);
               cmp.set("v.start1",0);
               cmp.set("v.end1",cmp.get("v.pageSize")-1);
               cmp.set("v.UserRecords",cmp.get("v.UnfilteredUserRecords")); 
               helper.helperMethodPaginationEvent(cmp, event, helper,'1');
               
           }
    },        
             
    Scroll:function(component, event, helper){
        var header = document.getElementById("myHeader");
		var sticky = header.offsetTop;

		function myFunction() {
  			if (window.pageYOffset > sticky) {
    			header.classList.add("sticky");
  			} else {
    			header.classList.remove("sticky");
  			}
		}
    },
    
      clickFilter:function(component, event, helper){
        if(component.get("v.FilterShow")) component.set("v.FilterShow",false);
        else component.set("v.FilterShow",true);   
        
    },
    
    SingleUserAvailabilities:function(component, event, helper){
     var UserId=event.currentTarget.getAttribute("data-UserId");
     $A.createComponent(
            "c:UsersAvailabilities", {
                "UserId":UserId,
                "ServiceId":component.get("v.ServiceId"),
                "LocationId":component.get("v.LocationId"),
                selectedDate:component.get("v.selectedDate"),
                DayDetails:component.get("v.DayDetails"),
                showPrevious:component.get("v.showPrevious")
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
     );	
        
    },

   UsersAvailabilities:function(component, event, helper){  
     var UserIds=[];  
     var Groups=[]; 
     Groups=component.get("v.UserWrapperList");  
     for(var g=0; g<Groups.length; g++) UserIds.push(Groups[g].User.Id);
     $A.createComponent(
            "c:UsersAvailabilities", {
                "UserIds":UserIds,
                "ServiceId":component.get("v.ServiceId"),
                "LocationId":component.get("v.LocationId"),
                selectedDate:component.get("v.selectedDate"),
                DayDetails:component.get("v.DayDetails"),
                showPrevious:component.get("v.showPrevious")
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
     );	
        
    },
    
   showConfirmation: function(component, event, helper) {
        component.set("v.showConfirmationPopup",true);
        var DayIndex=event.currentTarget.getAttribute("data-DayIndex");
        var TSIndex=event.currentTarget.getAttribute("data-TSIndex");
        var SlotRecord=component.get("v.DaySlots")[DayIndex].TimeSlots[TSIndex];
        component.set("v.SlotRecord",SlotRecord);        
    },
    
    HidePopup: function(component, event, helper){
        component.set("v.showConfirmationPopup",false);
        component.set("v.selectedTime",null);        
    },
    
    doInit:function(component, event, helper) {
        helper.fetchTimeSlots(component, event, helper, '');
    },
    
    changeDate:function(component, event, helper) {
      component.set("v.Action",'Calendar')  
      helper.fetchTimeSlots(component, event, helper, '');
        
    },
    
    
   ReserveSlot: function(component, event, helper) {
        var action=component.get("c.getReserveSlot");
        var SlotRecord=component.get("v.SlotRecord");
        action.setParams({
            Slot:SlotRecord.Slot, SlotDuration:component.get("v.SlotDuration"), 
            ResourceId:component.get("v.ResourceId"), 
            ServiceId:component.get("v.ServiceId"), 
            LocationId:component.get("v.LocationId") 
        }); 
        action.setCallback(this, function(res){
            if(res.getState()=='SUCCESS'){
                component.set("v.showConfirmationPopup",false); 
                component.set("v.selectedDate",component.get("v.FirstDate"));
                helper.fetchTimeSlots(component, event, helper, component.get("v.UserId"));
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    changeService : function(component, event, helper) {
        helper.fetchTimeSlots(component, event, helper,'');   
		var action = component.get("c.getLocations"); 
        action.setParams({'ServiceId':component.get("v.ServiceId")});
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") { 
              try{ 
               if(response.getReturnValue()!=null && response.getReturnValue()!=undefined && response.getReturnValue()!=''){ 
                  var LocationsIds=response.getReturnValue().LocationIds; 
                  var filter = '';  
                  
                  for(var obj in LocationsIds){
                      if(obj == 0) filter = ' And ( Id = \''+LocationsIds[obj]+'\'';
                       else filter += ' Or Id = \''+LocationsIds[obj]+'\'';
                  }
                  filter += ')'; 
                 filter=filter+component.get("v.LocationsFilter");
                 component.set("v.LocationsFilter",filter); 
                   
                } else component.set("v.LocationId",'');
               }catch(ex){console.log('changeService catch exception=>'+ex);}      
            }       
        });
         $A.enqueueAction(action);        
    },
    
    changeLocation : function(component, event, helper) {
        helper.fetchTimeSlots(component, event, helper,'');
	},
    
    next : function(component, event, helper) {
		  component.set("v.showMmainSpin",true); component.set("v.Action",'Next');
          component.set("v.selectedDate",component.get("v.DayDetails[6]"));
		  helper.next(component, event, helper, component.get("v.UserId"));  
	},
    
    previous : function(component, event, helper) {
		  component.set("v.showMmainSpin",true); component.set("v.Action",'Prev');
          component.set("v.selectedDate",component.get("v.DayDetails[0]"));
		  helper.previous(component, event, helper, component.get("v.UserId"));  
	},
    
    changeUser : function(component, event, helper) {
        var UserId=event.currentTarget.getAttribute('data-UserId');
        component.set("v.UserId",UserId);
        component.set("v.showMmainSpin",true);
        component.set("v.selectedDate",null);
		if(UserId!=undefined && UserId!='')  helper.fetchTimeSlots(component, event, helper, UserId);  
	},
    
    searchUser : function(component,event,helper){
      try{  
        var searchString = event.getParam("searchString").toString();
        if(searchString!='' && searchString.length>0){                     
            var UserList =[];
            UserList=component.get("v.UserListAll");
            UserList = UserList.filter(function (el) {
               return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
            });
            component.set("v.UserList",UserList);            
        }    
        else component.set("v.UserList",component.get("v.UserListAll"));
      }catch(ex){
          console.log('searchUser exception=>'+ex);
      }      
    },
    
    
    getNextpage:function(component,event,helper){
    component.set("v.showMmainSpin",true); 
        setTimeout(
            $A.getCallback(function() {
                try{               
                    var RecordList=[]; RecordList=component.get("v.UserWrapperListDum");
                    var Entries=component.get("v.Entries");    
                    var RecordListNew=[]; 
                    var counter=component.get("v.counter");  
                    
                    if(parseInt(counter+Entries)<=RecordList.length){   
                        
                        for(var i=counter; i<parseInt(counter+Entries); i++) RecordListNew.push(RecordList[i]);
                        component.set("v.counter",counter+Entries);
                        if(parseInt(counter+Entries)==RecordList.length){ //* counter+1
                            component.set("v.nextDisa",true);  
                            component.set("v.counter",RecordList.length);  
                        }                                              
                    }  
                    else{
                        component.set("v.counterEnd",counter);
                        component.set("v.counter",RecordList.length);
                        for(var i=counter;i<RecordList.length; i++) RecordListNew.push(RecordList[i]);
                        component.set("v.nextDisa",true);
                    }   
                    
                    component.set("v.prevDisa",false);
                    
                    component.set("v.UserWrapperList",RecordListNew);
                    if(event.getSource().get("v.label")!=undefined) component.set("v.ClickOn",event.getSource().get("v.label")); 
                    
                    //@FOR INDICATE CURRENT PAGE RECORDS        
                    var idx = parseInt(counter)/parseInt(Entries);          
                    var pIds = component.find("PNIds");
                    for(var i=0;i<pIds.length; i++){
                        if(pIds[i]!=undefined) $A.util.removeClass(pIds[i].getElement(),"pageNumberClassActive");                
                    }
                    var ele = pIds[parseInt(idx)].getElement(); 
                    $A.util.addClass(ele,"pageNumberClassActive");       
                }catch(ex){
                    console.log('catch exception=>'+ex);
                }
                component.set("v.showMmainSpin",false); 
            }), 500
        );     
   },
     
   //##FOR PREVIOUS OF ALL  
   getPreviousPage : function(component,event,helper){  
   var ClickOn=component.get("v.ClickOn");    
   component.set("v.showMmainSpin",true); 
   setTimeout(
    $A.getCallback(function() {
      try{
     var RecordList=[]; RecordList=component.get("v.UserWrapperListDum"); //ResourceList
     var Entries=component.get("v.Entries");    
     var RecordListNew=[]; 
     var counter=component.get("v.counter"); 
     var counterDum=0;    
           
     if(parseInt(counter-Entries) <=RecordList.length){  
         var init;var des; 
         if(ClickOn=='Prev'){          
           des=counter;  
           init=parseInt((parseInt(des)-parseInt(Entries)));
         }else{
             var des=counter-10;//4
             init=parseInt(des)-10;  
             if(component.get("v.counterEnd")!=0){
                des=component.get("v.counterEnd");
                init=des-Entries
             }
         }                          
          for(var i=init; i<des; i++) RecordListNew.push(RecordList[i]);
          component.set("v.counter",init); //des         
         if(des<=10) {component.set("v.prevDisa",true); counterDum=10;// component.set("v.counter",4);
                    }
          else component.set("v.prevDisa",false);
     }  
     
     if(parseInt(counter)-parseInt(Entries)-1<=0) {component.set("v.prevDisa",true); counterDum=5;
                                                  }
     component.set("v.nextDisa",false); 
     if(event.getSource().get("v.label")!=undefined) component.set("v.ClickOn",event.getSource().get("v.label"));  
    
      component.set("v.UserWrapperList",RecordListNew);     
          
      //@FOR INDICATE CURRENT PAGE RECORDS 
      try{ 
        counter=component.get("v.counter");   
          
        var idx = parseInt(counter)/parseInt(Entries);        
        var pIds = component.find("PNIds"); 
          
        for(var i=0;i<pIds.length; i++){        
          if(pIds[i]!=undefined) $A.util.removeClass(pIds[i].getElement(),"pageNumberClassActive");                
        }    
        $A.util.addClass(pIds[parseInt(idx)].getElement(),"pageNumberClassActive");  //parseInt(idx)-1
       }catch(e){
           console.log('enner catch exception=>'+e); 
       }
      //component.set("v.UserWrapperList",RecordListNew);     
      }catch(ex){
         component.set("v.showMmainSpin",false);
      }
     component.set("v.showMmainSpin",false);
       
     if(counterDum>0) component.set("v.counter",counterDum);  
    }), 500
);   
       
     }, 
     
 
  
   getRecordOnPageNumber : function(component,event,helper){
     component.set("v.showMmainSpin",true); component.set("v.nextDisa",false); 
     var PN=event.currentTarget.getAttribute('data-pageNumber')  
     try{  
         setTimeout(
             $A.getCallback(function() {
                 var RecordList=[]; RecordList=component.get("v.UserWrapperListDum"); 
                 var Entries=component.get("v.Entries");    
                 var RecordListNew=[]; 
                 var counter=component.get("v.counter");                   
                 var initIndex=PN*Entries-Entries;
                 var finalIndex=initIndex+Entries; 
                 
                 for(var i=initIndex; i<finalIndex; i++) RecordListNew.push(RecordList[i]);
                 component.set("v.counter",finalIndex);  
                 if(parseInt(finalIndex)>=RecordList.length){
                     component.set("v.nextDisa",true);  
                     component.set("v.counter",RecordList.length);  
                 }                                              
                 
                 component.set("v.prevDisa",false);        
                 component.set("v.showMmainSpin",false);
                 component.set("v.UserWrapperList",RecordListNew); 
                 /*    
     var RecordListNew1=[];
         for(var i in RecordListNew){  
         
             if(RecordListNew[i].User!=undefined && RecordListNew[i].User!=null) RecordListNew1.push(RecordListNew[i]);  //.Name  
         } 
     component.set("v.UserWrapperList",RecordListNew1); 
      */
        
        var pIds=[]; pIds=component.find("PNIds");    
        for(var i=0;i<pIds.length; i++) if(pIds[i]!=undefined) $A.util.removeClass(pIds[i].getElement(),"pageNumberClassActive");                
        if(pIds.length>1) $A.util.addClass(pIds[parseInt(PN-1)].getElement(),"pageNumberClassActive"); 
        else {
            $A.util.addClass(pIds.getElement(),"pageNumberClassActive"); component.set("v.nextDisa",true);  component.set("v.prevDisa",true);  }  
        if(PN==1) component.set("v.prevDisa",true);    
        //component.set("v.UserWrapperList",RecordListNew);    
        
        component.set("v.RenderBody",false);
        component.set("v.RenderBody",true);  
    }), 500
     );
    }catch(Ex){ component.set("v.showMmainSpin",false); }     
       
   },
    
    onscroll : function(cmp,event,helper) {
        var header = document.getElementById("myHeader");
        var sticky = header.offsetTop;
        if (window.pageYOffset > sticky) {
            header.classList.add("sticky");
        } else {
            header.classList.remove("sticky");
        }
    },
    
    /*User time off managing*/  
    UsersTimeOff : function(component,event,helper){  
        var UserType=component.get("v.UserType");
        var isSupervisor=false; var isSuperUser=false; 
        if(UserType=='superUser') isSuperUser=true;
        else if(UserType=='supervisor')  isSupervisor=true;
        
        $A.createComponent(
            "c:ManageResource", {
                FromSP:true,
                'selectedService':component.get("v.ServiceId"),
                'selectedExpLocation':component.get("v.LocationId"),
                'User':component.get("v.User"),
                'userId':component.get("v.User").Id,
                isSuperUser:isSuperUser,
                isSupervisor:isSupervisor
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );
    },
    
    //NavScheduler : function (component, event) {
      //  var RecUrl = "/lightning/n/ERP7__Schedular";
        //$A.get("e.force:navigateToURL").setParams(
        //{"url": RecUrl}).fire();
        //window.open(RecUrl,"_self"); 
    //},
    
    NavScheduler : function (component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                "Flow":'MO',
                "NAV":'WCCPM',
                "RD":'yes',
                "tabNavi" : "MOworkbench"
            }
        });
        evt.fire();
    },

    NavServiceScheduler : function (component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                "Flow":'WO',
                "NAV":'WCCPM',
                "RD":'yes',
                "tabNavi" : "WOworkbench"
            }
        });
        evt.fire();
    },

    NavServiceBuilder : function (component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:MaintenanceBuilder",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    NavBuilder : function (component, event) {
        var RecUrl = "/lightning/n/ERP7__Manufacturing_Builder";  //"/apex/ERP7__ManageMOS";
        //$A.get("e.force:navigateToURL").setParams(
        //{"url": RecUrl}).fire();
        window.open(RecUrl,"_self");
    },
    toggleTabs : function(cmp, event){
        var tab = event.currentTarget.dataset.tab;
        if(cmp.get("v.navWorkbench") == 'MO'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:WorkCenterCapacityPlanning",
                componentAttributes: {
                    View :'Grid',
                }
            });
            evt.fire();
        }
        else if(cmp.get("v.navWorkbench") == 'WO'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:WorkCenterCapacityPlanningMaintenance",
                componentAttributes: {
                    View :'Grid',
                }
            });
            evt.fire();
        }
    },
    
    FilterSet : function (cmp, event) {
        cmp.set("v.FilterShow", !cmp.get("v.FilterShow"));
    },
    getDayTimeOff : function(component, event, helper){
        var index1 = event.currentTarget.dataset.index;
        var index2 = event.currentTarget.dataset.record;
        var index3 = event.currentTarget.dataset.recordId;
        var currentDate = component.get("v.DayDetails");
        currentDate = currentDate[index3];
        var userWrapList = component.get("v.UserRecordspage"); //v.UserWrapperList
        var currentSlot = userWrapList[index1].ResourceAvailabilityList[index2].TimeOffList[index3];
        if(!currentSlot.isHoliday && currentSlot.isTimeOff && currentSlot.RemainingCapacity!=0 && !$A.util.isUndefinedOrNull(currentSlot.Start_Time) && !$A.util.isUndefinedOrNull(currentSlot.End_Time)){
            helper.getCurrentDayTimeOff(component, event, currentDate, currentSlot, userWrapList[index1].User.Id);
        }
    },
    UsersTimeOff : function(component,event,helper){  
        var UserType=component.get("v.UserType");
        var isSupervisor=false; var isSuperUser=false; 
        if(UserType=='superUser') isSuperUser=true;
        else if(UserType=='supervisor')  isSupervisor=true;
        
        $A.createComponent(
            "c:ManageResource", {
                FromSP:true,
                'selectedService':component.get("v.ServiceId"),
                'selectedExpLocation':component.get("v.LocationId"),
                'User':component.get("v.User"),
                'userId':component.get("v.User").Id,
                isSuperUser:isSuperUser,
                isSupervisor:isSupervisor
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );
    },
    SingleUserTimeOff : function(component,event,helper){  
        var UserType=component.get("v.UserType");
        var isSupervisor=false; var isSuperUser=false; 
        if(UserType=='superUser') isSuperUser=true;
        else if(UserType=='supervisor')  isSupervisor=true;
        var userWP = component.get("v.UserRecordspage");
        var selectedUser = userWP[event.currentTarget.dataset.index].User; 
        
        $A.createComponent(
            "c:ManageResource", {
                FromSP:true,
                'selectedService':component.get("v.ServiceId"),
                'selectedExpLocation':component.get("v.LocationId"),
                User     	: selectedUser,
                userId       : selectedUser.Id,
                isSuperUser:isSuperUser,
                isSupervisor:isSupervisor
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            }
        );
    },
    previousEventl : function(component, event, helper){
        /*---Pagination previous Button Click--*/
        var UserRecords = component.get("v.UserRecords");//All Account List
        var end1 = component.get("v.end1");
        var start1= component.get("v.start1");
        var pageSize1= component.get("v.pageSize1");
        var UserRecordspage = [];
        var UserRecordspage = UserRecords.slice(start1-pageSize1,start1);//Slicing List as page number
        start1 = start1 - pageSize1;
        end1= end1 - pageSize1;
        component.set("v.start1",start1);
        component.set("v.end1",end1);
        try{
            component.set('v.UserRecordspage', UserRecordspage);
        } 
        catch(err) { }
        var currentPageNumber1= component.get('v.currentPageNumber1')-1;//Current Page Number
        component.set('v.currentPageNumber1',currentPageNumber1);
        helper.helperMethodPaginationEvent(component, event, helper,parseInt(currentPageNumber1));//Reset Pagination
    },
    currentPageEventl: function(component, event, helper) {
        /*---Pagination Number Button Click--*/
      //  var selectedItem = event.currentTarget;
       var pagenum;
     // var a=component.get("v.paginationChange");
     //  alert(a);
        
     // if(a==false)
        pagenum = event.getSource().get("v.value");
       // else
       //   pagenum =1;
        //alert(pagenum);
       //component.set("v.paginationChange",false);
            //Current Page Number
        //alert(pagenum);
        var pageSize1 = component.get("v.pageSize1");
        var UserRecords = component.get("v.UserRecords");//All Account List
        var start1 =(pagenum-1)*pageSize1;
        var end1= ((pagenum-1)*pageSize1)+parseInt(pageSize1)-1;
        var UserRecordspage = UserRecords.slice(start1,end1+1);//Slicing List as page number
        component.set("v.start1",start1);
        component.set("v.end1",end1);
        try{
            component.set('v.UserRecordspage', UserRecordspage);
        } catch(err) { }
        component.set('v.currentPageNumber1', parseInt(pagenum));
        helper.helperMethodPaginationEvent(component, event, helper,parseInt(pagenum));//Reset Pagination
    },
    nextEventl : function(component, event, helper){ /*---Pagination Next Button Click--*/
      
        var UserRecords = component.get("v.UserRecords");

        var end1 = component.get("v.end1");
        var start1 = component.get("v.start1");
        var pageSize1= component.get("v.pageSize1");
        var UserRecordspage = [];
        var UserRecordspage = UserRecords.slice(parseInt(end1)+1,parseInt(end1)+parseInt(pageSize1)+1);//Slicing List as page number
        start1= start1 + parseInt(pageSize1);
        end1 = end1 +  parseInt(pageSize1);
        component.set("v.start1",start1);
        component.set("v.end1",end1);
        try{
            component.set('v.UserRecordspage', UserRecordspage);
        } 
        catch(err) { }
          //  alert( component.get('v.EventRecordspage'));
        var currentPageNumber1= component.get('v.currentPageNumber1')+1;//Current Page Number
        component.set('v.currentPageNumber1',currentPageNumber1);
        helper.helperMethodPaginationEvent(component, event, helper,parseInt(currentPageNumber1));
       
        
    },
})