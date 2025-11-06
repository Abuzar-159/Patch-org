({    
    doInit: function(component, event, helper) {
        component.set("v.showMmainSpin",true);   component.set("v.CallResourcesByGroup",false);
        var action = component.get("c.getUsersAvailibilities"); 
        action.setParams({
            "ServiceId":component.get("v.ServiceId"),
            "LocationId":component.get("v.LocationId") ,
            selectedDate:component.get("v.selectedDate"),
            "UserId":component.get("v.UserId")
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var Groups=[]; Groups=response.getReturnValue();          
                for(var g=0; g<Groups.length; g++){
                    var UserAvailabilityList=ResourceWrapperList=Groups[g].UserAvailabilityList;
                    for(var u=0; u<UserAvailabilityList.length; u++){
                        var ResourceWrapperList=[]; ResourceWrapperList=UserAvailabilityList[u].ResourceAvailabilityList; 
                        for(var r=0; r<ResourceWrapperList.length; r++){
                            var TR=ResourceWrapperList[r].TimeOffList;              
                            for(var t=0; t<TR.length; t++){  
                                if(TR[t].StartTime!=undefined) TR[t].StartTime=helper.convertMillisecondToTime(TR[t].StartTime); else TR[t].StartTime=null;
                                if(TR[t].EndTime!=undefined) TR[t].EndTime=helper.convertMillisecondToTime(TR[t].EndTime); else TR[t].EndTime=null;
                                if(TR[t].BSTime!=undefined) TR[t].BSTime=helper.convertMillisecondToTime(TR[t].BSTime); else TR[t].BSTime=null;
                                if(TR[t].BETime!=undefined) TR[t].BETime=helper.convertMillisecondToTime(TR[t].BETime); else TR[t].BETime=null;
                            }
                        }
                    }
                }
                component.set("v.GroupWrapperList",response.getReturnValue()); 
                if(response.getReturnValue().length>0){ 
                                                       component.set("v.LoginUserId",response.getReturnValue()[0].LoginUserId); 
                                                       var UserFilter=component.get("v.UserFilter");
                                                       if(response.getReturnValue()[0].LoginUserId!=null) UserFilter=UserFilter+' AND Id=\''+response.getReturnValue()[0].LoginUserId+'\''; 
                                                       component.set("v.UserFilter",UserFilter);          
                                                      } 
                component.set("v.showMmainSpin",false);  component.set("v.CallResourcesByGroup",true);
                
            }         
        });
        $A.enqueueAction(action);         
    },
    removeGroup: function(component, event, helper) {
        try{
            var Index=event.currentTarget.dataset.record;
            var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList"); 
            GroupWrapperList.splice(Index,1); 
            component.set("v.GroupWrapperList",GroupWrapperList);
        }catch(ex){console.log('removeGroup exception=>'+ex); } 
    },
    
    
    navHome : function(component, event, helper) {
        $A.createComponent(
            "c:UsersShiftMatch", {
                "ServiceId":component.get("v.ServiceId"),
                "LocationId":component.get("v.LocationId"),
                selectedDate:component.get("v.selectedDate"),
                "GroupId" : component.get("v.GroupId"),
                showPrevious:component.get("v.showPrevious"),
                FromOtherComp:true
            },
            function(newComp) {
                var content = component.find("body");
                content.set("v.body", newComp);
            });	
    },
    
    
    SaveAndHome : function(component, event, helper) {
        component.set("v.SaveErrorMsg",'');  
        var proceed=helper.verifiyMandatoryFields(component, event, helper);
        if(proceed){            
            var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList"); 
            var IsValid=true;   
            for(var i in GroupWrapperList){
                var UserAvailabilityList=[]; UserAvailabilityList=GroupWrapperList[i].UserAvailabilityList;
                for(var u in UserAvailabilityList){
                    var ResourceAvailabilityList=[]; ResourceAvailabilityList=GroupWrapperList[i].UserAvailabilityList[u].ResourceAvailabilityList; 
                    for(var j in ResourceAvailabilityList){
                        var Availibility=[]; Availibility=ResourceAvailabilityList[j].TimeOffList;  
                        for(var k in Availibility){
                            Availibility[k].Start_Time=Availibility[k].StartTime;
                            Availibility[k].End_Time=Availibility[k].EndTime;
                            Availibility[k].BS_Time=Availibility[k].BSTime;
                            Availibility[k].BE_Time=Availibility[k].BETime;
                            if(Availibility[k].IsValid==false && IsValid) IsValid=false;
                        }  
                    } 
                } 
            } 
            var action = component.get("c.Save"); 
            action.setParams({
                "GroupWrapperList":JSON.stringify(GroupWrapperList) 
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    $A.createComponent(
                        "c:UsersShiftMatch", {
                            "ServiceId":component.get("v.ServiceId"),
                            "LocationId":component.get("v.LocationId"),
                            selectedDate:component.get("v.selectedDate"),
                            showPrevious:component.get("v.showPrevious"),
                            FromOtherComp:true,
                            'UserId':null
                        },
                        function(newComp) {
                            var content = component.find("body");
                            content.set("v.body", newComp);
                        });
                    
                }
            });
            if(IsValid) $A.enqueueAction(action);
            else component.set("v.SaveErrorMsg",'Timings mismatch');  
            
        }else{
            component.set("v.SaveErrorMsg",'Required field missing');
        }     
    }, 
    
    onClick:function(component, event, helper) {
        component.set("v.SaveErrorMsg",'');
    },
    
    addGroup: function(component, event, helper) { 
        var action = component.get("c.getAddGroup");    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");
                GroupWrapperList.push(response.getReturnValue());
                component.set("v.GroupWrapperList",GroupWrapperList);
            }        
        });
        $A.enqueueAction(action);  
    },
    
    addResource: function(component, event, helper) { 
        var Index=event.currentTarget.dataset.record;
        var UIndex=event.currentTarget.getAttribute("data-UIndex");
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");                                                
        var action = component.get("c.getAddResource");  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                response.getReturnValue().UserId=GroupWrapperList[Index].UserAvailabilityList[UIndex].User.Id; 
                GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList.push(response.getReturnValue());       
                component.set("v.GroupWrapperList",GroupWrapperList);
            }        
        });
        $A.enqueueAction(action);  
    },
    
    removeResourceConfirmation: function(component, event, helper) {
        try{
            var Index=event.currentTarget.dataset.record;
            var UIndex=event.currentTarget.getAttribute("data-UIndex");                                                    
            var RIndex=event.currentTarget.getAttribute("data-RIndex");
            var RId=event.currentTarget.getAttribute("data-RId");
            component.set("v.GIndex",Index); component.set("v.UIndex",UIndex); component.set("v.RIndex",RIndex);
            if(RId==null || RId=='null'){
                var GroupWrapperList=[]; 
                GroupWrapperList=component.get("v.GroupWrapperList");            
                var RList=[]; 
                RList=GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList;
                var ResourceId=RList[RIndex].Id; 
                RList.splice(RIndex,1); 
                GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList=RList;
                if(GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList.length<=0) GroupWrapperList[Index].UserAvailabilityList.splice(UIndex,1);                                                   
                if(GroupWrapperList[Index].UserAvailabilityList.length<=0) {
                    GroupWrapperList.splice(Index,1);
                    component.set("v.GroupWrapperList",GroupWrapperList);  
                }else{
                    var UserAvailabilityListOld=[];UserAvailabilityListOld=GroupWrapperList[Index].UserAvailabilityList;
                    var UserAvailabilityListNew=[]; 
                    
                    for(var i in UserAvailabilityListOld){
                        if(UserAvailabilityListOld[i].User.Id!='' && UserAvailabilityListOld[i].User.Id!=undefined && UserAvailabilityListOld[i].User.Id!=null){
                            UserAvailabilityListNew.push(UserAvailabilityListOld[i]);  
                        } 
                    } 
                    GroupWrapperList[Index].UserAvailabilityList=[];       
                    GroupWrapperList[Index].UserAvailabilityList=UserAvailabilityListNew; 
                    component.set("v.GroupWrapperList",GroupWrapperList);       
                }
            }else{
                $A.util.removeClass(component.find('resourceDeleteConfirmId').getElement(), 'slds-hide');
                $A.util.addClass(component.find('resourceDeleteConfirmId').getElement(), 'slds-show');
                
            } 
        }catch(ex){console.log('removeResourceConfirmation exception=>'+ex);}	
    }, 
    
    cancelRemoveResourceConfirmation:function(component, event, helper){ 
        $A.util.removeClass(component.find('resourceDeleteConfirmId').getElement(), 'slds-show'); 
        $A.util.addClass(component.find('resourceDeleteConfirmId').getElement(), 'slds-hide');                                                  
    },   

    removeResource: function(component, event, helper) {
        try{
            var Index=component.get("v.GIndex");
            var UIndex=component.get("v.UIndex");
            var RIndex=component.get("v.RIndex");
            
            var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");                                                        
            var RList=[]; RList=GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList; 
            var ResourceId=RList[RIndex].Id;
            RList.splice(RIndex,1); 
            GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList=RList;                                                                                                                
            if(GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList.length<=0) GroupWrapperList[Index].UserAvailabilityList.splice(UIndex,1);                                                   
            if(GroupWrapperList[Index].UserAvailabilityList.length<=0 || GroupWrapperList[Index].UserAvailabilityList==null || GroupWrapperList[Index].UserAvailabilityList=='undefined' || GroupWrapperList[Index].UserAvailabilityList=='')
                GroupWrapperList.splice(Index,0); 
            var action = component.get("c.getDeleteResource");    
            action.setParams({
                "ResourceId":ResourceId
            });  
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") { 
                    component.set("v.GroupWrapperList",GroupWrapperList);
                    $A.util.removeClass(component.find('resourceDeleteConfirmId').getElement(), 'slds-show');
                    $A.util.addClass(component.find('resourceDeleteConfirmId').getElement(), 'slds-hide');       
                    
                }         
            });
            if(ResourceId!=undefined && ResourceId!='') $A.enqueueAction(action);
            
        }catch(ex){console.log('removeResource exception=>'+ex);}     
        
        
    },
    
    
    fetchUsersAvailibilityByGroup: function(component, event, helper) {
        component.set("v.showMmainSpin",true);  
        var Index=component.get("v.GroupIndex");
        if(Index==undefined || Index==null || Index=='') Index=event.getSource().get("v.name");          
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList"); 
        var GroupWrapper=[]; GroupWrapper=GroupWrapperList[Index]; 
        var action = component.get("c.getUsersAvailibilityByGroup");    
        action.setParams({
            "GroupWrapper":JSON.stringify(GroupWrapper)         
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                GroupWrapperList[Index]=response.getReturnValue();
                var UserAvailabilityList=[]; UserAvailabilityList=GroupWrapperList[Index].UserAvailabilityList;
                for(var u=0; u<UserAvailabilityList.length; u++){
                    var ResourceWrapperList=[]; ResourceWrapperList=GroupWrapperList[Index].UserAvailabilityList[u].ResourceAvailabilityList;          
                    for(var r=0; r<ResourceWrapperList.length; r++){
                        var TR=ResourceWrapperList[r].TimeOffList;              
                        for(var t=0; t<TR.length; t++){  
                            if(TR[t].StartTime!=undefined) TR[t].StartTime=helper.convertMillisecondToTime(TR[t].StartTime); else TR[t].StartTime=null;
                            if(TR[t].EndTime!=undefined) TR[t].EndTime=helper.convertMillisecondToTime(TR[t].EndTime); else TR[t].EndTime=null;
                            if(TR[t].BSTime!=undefined) TR[t].BSTime=helper.convertMillisecondToTime(TR[t].BSTime); else TR[t].BSTime=null;
                            if(TR[t].BETime!=undefined) TR[t].BETime=helper.convertMillisecondToTime(TR[t].BETime); else TR[t].BETime=null;
                        }
                    }  
                }
                GroupWrapperList[Index].UserAvailabilityList=UserAvailabilityList;
                GroupWrapperList[Index].GroupId=GroupWrapper.GroupId;   
                component.set("v.GroupWrapperList",GroupWrapperList);
                component.set("v.showMmainSpin",false); 
            }else{
                component.set("v.showMmainSpin",false); 
            }
            
        });
        if(Index!=undefined && GroupWrapper.ServiceId!=undefined && GroupWrapper.ServiceId!=null && GroupWrapper.LocationId!=undefined && GroupWrapper.LocationId!=null
           )
            $A.enqueueAction(action);
        else{component.set("v.showMmainSpin",false); }  
    },
    
    setIndex:function(component, event, helper){
        var GIndex=event.target.dataset.record;
        var Index=event.currentTarget.getAttribute('data-GIndex');
        if(GIndex==undefined || GIndex==null || GIndex=='') GIndex=Index;
        if(GIndex==undefined && GIndex==null && GIndex=='') component.set("v.GroupIndex",GIndex);
    },
    
    addUser: function(component, event, helper) { 
        var Index=event.currentTarget.dataset.record;
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");                                                
        var action = component.get("c.getAddUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                GroupWrapperList[Index].UserAvailabilityList.push(response.getReturnValue());
                if(component.get("v.LoginUserId")!=undefined && component.get("v.LoginUserId")!=null) response.getReturnValue().User.Id=component.get("v.LoginUserId"); 
                component.set("v.GroupWrapperList",GroupWrapperList);
            }          
        });
        $A.enqueueAction(action);  
    },
    
    changeService : function(component, event, helper) {
        var Index=event.currentTarget.getAttribute('data-Index');
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");
        var ServiceId=GroupWrapperList[Index].ServiceId;
        if(ServiceId!=undefined && ServiceId!='')
            helper.changeService(component, event, helper,GroupWrapperList[Index].ServiceId, GroupWrapperList[Index].LocationId, GroupWrapperList[Index].GroupId);
        else {                
            component.set("v.SaveErrorMsg",''); 
            GroupWrapperList[Index].LocationId=null;
            GroupWrapperList[Index].GroupId=null;
            GroupWrapperList[Index].StartDate=null;
            GroupWrapperList[Index].EndDate=null;
            GroupWrapperList[Index].EndDate=null;
            GroupWrapperList[Index].UserAvailabilityList=[];
            component.set("v.GroupWrapperList",GroupWrapperList);
            
        }
    },   
    
    changeLocation : function(component, event, helper) {
        var Index=event.currentTarget.getAttribute('data-Index');
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");
        var LocationId=GroupWrapperList[Index].LocationId;
        if(LocationId!=undefined && LocationId!='')
            helper.changeService(component, event, helper,GroupWrapperList[Index].ServiceId, GroupWrapperList[Index].LocationId, GroupWrapperList[Index].GroupId);
        else {
            component.set("v.SaveErrorMsg",''); 
            GroupWrapperList[Index].LocationId=null;
            GroupWrapperList[Index].GroupId=null;
            GroupWrapperList[Index].StartDate=null;
            GroupWrapperList[Index].EndDate=null;
            GroupWrapperList[Index].EndDate=null;
            GroupWrapperList[Index].UserAvailabilityList=[];
            component.set("v.GroupWrapperList",GroupWrapperList);
        }
    },   
    
    changeGroup: function(component, event, helper) {
        var Index=event.currentTarget.getAttribute('data-Index');
        component.set("v.GroupIndex",Index);
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");
        var GroupId=GroupWrapperList[Index].GroupId;
        var action = component.get("c.getGroupRecord"); 
        action.setParams({"GroupId":GroupId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                GroupWrapperList[Index].StartDate=response.getReturnValue().ERP7__Start_Date__c;
                GroupWrapperList[Index].EndDate=response.getReturnValue().ERP7__End_Date__c;
                component.set("v.GroupWrapperList",GroupWrapperList);
                helper.fetchUsersAvailibilityByGroup(component, event, helper);
            }         
        });
        if(GroupId!=undefined && GroupId!='' && GroupId!=null) $A.enqueueAction(action);
        else{
            component.set("v.SaveErrorMsg",''); 
            GroupWrapperList[Index].GroupId=null;
            GroupWrapperList[Index].StartDate=null;
            GroupWrapperList[Index].EndDate=null;
            GroupWrapperList[Index].EndDate=null;
            GroupWrapperList[Index].UserAvailabilityList=[];
            if(GroupWrapperList[Index].ServiceId!=null && GroupWrapperList[Index].LocationId!=null) 
                helper.changeService(component, event, helper,GroupWrapperList[Index].ServiceId, GroupWrapperList[Index].LocationId, GroupWrapperList[Index].GroupId);
            component.set("v.GroupWrapperList",GroupWrapperList);
        }     
    }, 
    
    setIndexForValidateTime:function(component, event, helper){
        var GIndex=event.currentTarget.dataset.record;
        var UIndex=event.currentTarget.getAttribute("data-UIndex");                                                    
        var RIndex=event.currentTarget.getAttribute("data-RIndex");
        if(GIndex!=null && GIndex!='null' && GIndex!=undefined && GIndex!='') component.set("v.GIndex",GIndex);
        if(UIndex!=null && UIndex!='null' && UIndex!=undefined && UIndex!='') component.set("v.UIndex",UIndex);
        if(RIndex!=null && RIndex!='null' && RIndex!=undefined && RIndex!='') component.set("v.RIndex",RIndex);
    },
    
    validateSelectedTime: function(component, event, helper) {
        try{                          
            var GIndex=component.get("v.GIndex");
            var UIndex=component.get("v.UIndex");
            var RIndex=component.get("v.RIndex");
            var DayIndex=event.getSource().get("v.tabindex");    
            var STIdElement =component.find('STId')[DayIndex]; 
            var ETIdElement =component.find('ETId')[7*RIndex+DayIndex];    
            var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");
            var StartTime=GroupWrapperList[GIndex].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex].TimeOffList[DayIndex].StartTime;
            var EndTime=GroupWrapperList[GIndex].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex].TimeOffList[DayIndex].EndTime;
            if(EndTime<=StartTime &&  (StartTime!=null || EndTime!=null)){ 
                GroupWrapperList[GIndex].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex].TimeOffList[DayIndex].IsValid=false;
                $A.util.addClass(ETIdElement, 'HighlightClass');               
            }else{
                $A.util.removeClass(ETIdElement, 'HighlightClass');              
                GroupWrapperList[GIndex].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex].TimeOffList[DayIndex].IsValid=true;
            }                 
            component.get("v.GroupWrapperList",GroupWrapperList); 
            
        }catch(ex){console.log('validateSelectedTime exception=>'+ex); }    
        
    },
    
    validateSelectedBreakTime: function(component, event, helper) {
        try{               
            var DayIndex=event.getSource().get("v.tabindex");
            var GIndex=component.get("v.GIndex");
            var UIndex=component.get("v.UIndex");
            var RIndex=component.get("v.RIndex");
            
            var STIdElement =component.find('BreakSTId')[DayIndex]; 
            var ETIdElement =component.find('BreakETId')[DayIndex];     
            var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");
            var BSTime=GroupWrapperList[GIndex].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex].TimeOffList[DayIndex].BSTime;
            var BETime=GroupWrapperList[GIndex].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex].TimeOffList[DayIndex].BETime;
            if(BETime<=BSTime && (BSTime!=null || BETime!=null)){ 
                GroupWrapperList[GIndex].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex].TimeOffList[DayIndex].IsValid=false;
                $A.util.addClass(ETIdElement, 'HighlightClass');               
            }else{
                $A.util.removeClass(ETIdElement, 'HighlightClass'); 
                GroupWrapperList[GIndex].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex].TimeOffList[DayIndex].IsValid=true;               
            }
        }catch(ex){console.log('validateSelectedBreakTime exception=>'+ex); }    
        
    },
    
    
    
    cloneRecord: function(component, event, helper) {
        var Index=event.currentTarget.dataset.record;
        var UIndex=event.currentTarget.getAttribute("data-UIndex");
        var RIndex=event.currentTarget.getAttribute("data-RIndex");
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");                                                
        var action = component.get("c.getAddResource");  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                response.getReturnValue().UserId=GroupWrapperList[Index].UserAvailabilityList[UIndex].User.Id; 
                var Resource=GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex];
                var TimeOffListOld=[]; TimeOffListOld=Resource.TimeOffList; 
                
                for(var i in TimeOffListOld){
                    response.getReturnValue().TimeOffList[i].EndTime = TimeOffListOld[i].EndTime;
                    response.getReturnValue().TimeOffList[i].isAvailable = TimeOffListOld[i].isAvailable; 
                    response.getReturnValue().TimeOffList[i].isHoliday = TimeOffListOld[i].isHoliday; 
                    response.getReturnValue().TimeOffList[i].isTimeOff = TimeOffListOld[i].isTimeOff; 
                    response.getReturnValue().TimeOffList[i].IsValid = TimeOffListOld[i].IsValid; 
                    response.getReturnValue().TimeOffList[i].StartTime = TimeOffListOld[i].StartTime; 
                    response.getReturnValue().TimeOffList[i].TOBool = TimeOffListOld[i].TOBool; 
                    response.getReturnValue().TimeOffList[i].TOType = TimeOffListOld[i].TOType; 
                    response.getReturnValue().TimeOffList[i].BSTime = TimeOffListOld[i].BSTime; 
                    response.getReturnValue().TimeOffList[i].BETime = TimeOffListOld[i].BETime;               
                }             
                response.getReturnValue().Start_Date=Resource.Start_Date;
                response.getReturnValue().End_Date=Resource.End_Date; 
                response.getReturnValue().TeamId=Resource.TeamId; 
                Resource=GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList[RIndex];
                GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList.push(response.getReturnValue());       
                component.set("v.GroupWrapperList",GroupWrapperList);
            }
        });
        $A.enqueueAction(action);  
    },
    
})