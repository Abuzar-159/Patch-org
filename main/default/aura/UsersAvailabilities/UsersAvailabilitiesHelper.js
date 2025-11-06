({
    verifiyMandatoryFields:function (component, event, helper) {
        var isProceed=true;
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList"); 
        for(var i in GroupWrapperList){
            if(GroupWrapperList[i].ServiceId==null || GroupWrapperList[i].ServiceId==undefined ||  GroupWrapperList[i].ServiceId==''
               || GroupWrapperList[i].LocationId==null || GroupWrapperList[i].LocationId==undefined ||  GroupWrapperList[i].LocationId=='') {isProceed=false; break; }
            var UserAvailabilityList=[]; UserAvailabilityList=GroupWrapperList[i].UserAvailabilityList;
            for(var u in UserAvailabilityList){ 
                if((UserAvailabilityList[u].User.Id==null || UserAvailabilityList[u].User.Id==undefined || UserAvailabilityList[u].User.Id=='') && (UserAvailabilityList[u].ResourceAvailabilityList!=[] && UserAvailabilityList[u].ResourceAvailabilityList!=undefined)) 
                {
                    isProceed=false; 
                    break;
                }
            }
            if(isProceed==false) break;                            
        }
        return isProceed; 
    },
    
    changeService : function(component, event, helper, ServiceId, LocationId, GroupId) {
        var action = component.get("c.getLocations"); 
        action.setParams({'ServiceId':ServiceId,'LocationId':LocationId, 'GroupId':GroupId});
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") { 
                try{ 
                    if(response.getReturnValue().LocationIds!=null && response.getReturnValue().LocationIds!=undefined && response.getReturnValue().LocationIds!=''){ 
                        var records=response.getReturnValue().LocationIds; 
                        var filter = '';
                        for(var obj in records){
                            if(obj == 0) filter = ' And ( Id = \''+records[obj]+'\'';
                            else filter += ' Or Id = \''+records[obj]+'\'';
                        }
                        filter += ')'; 
                        component.set("v.LocationsFilter",filter);
                    } else component.set("v.LocationId",'');
                    
                    
                    if(response.getReturnValue().GroupIds!=null && response.getReturnValue().GroupIds!=undefined && response.getReturnValue().GroupIds!=''){ 
                        var records=response.getReturnValue().GroupIds; 
                        var filter = '';
                        for(var obj in records){
                            if(obj == 0) filter = ' And ( Id = \''+records[obj]+'\'';
                            else filter += ' Or Id = \''+records[obj]+'\'';
                        }
                        filter += ')';  
                        if(LocationId!=null && LocationId!=undefined && LocationId!='' && ServiceId!=null && ServiceId!=undefined && ServiceId!='') component.set("v.GroupsFilter",filter);
                        else component.set("v.GroupsFilter",'AND Id=null');   
                    }
                }catch(ex){console.log('changeService catch exception=>'+ex);}      
            }       
        });
        $A.enqueueAction(action);        
    },    
    
    
    
    removeResource: function(component, event, helper, GIndex, UIndex, RIndex) {                                        
        var GroupWrapperList=[]; GroupWrapperList=component.get("v.GroupWrapperList");                                                        
        var RList=[]; RList=GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList; 
        var ResourceId=RList[RIndex].Id;
        RList.splice(RIndex,1); 
        GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList=RList;                                                                                                                
        if(GroupWrapperList[Index].UserAvailabilityList[UIndex].ResourceAvailabilityList.length<=0) GroupWrapperList[Index].UserAvailabilityList.splice(UIndex,1);                                                   
        if(GroupWrapperList[Index].UserAvailabilityList.length<=0) GroupWrapperList.splice(Index,1); 
        var action = component.get("c.getDeleteResource");    
        action.setParams({
            "ResourceId":ResourceId
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                component.set("v.GroupWrapperList",GroupWrapperList);
                $A.util.removeClass(component.find('resourceDeleteConfirmId').getElement(), 'slds-hide');
                $A.util.addClass(component.find('resourceDeleteConfirmId').getElement(), 'slds-show');       
            }        
        });
        if(ResourceId!=undefined && ResourceId!='') $A.enqueueAction(action);
        
    },
    
    convertMillisecondToTime: function msToTime(s) { 
        function pad(n, z) {
            z = z || 2;
            return ('00' + n).slice(-z);
        }
        
        var ms = s % 1000;
        s = (s - ms) / 1000;
        var secs = s % 60;
        s = (s - secs) / 60;
        var mins = s % 60;
        var hrs = (s - mins) / 60;
        
        var TimeValue=pad(hrs) + ':' + pad(mins); 
        TimeValue+=':00.000Z';
        return TimeValue;
    },
    
    /*CONVERT TIME TO 24 HOURSE*/
    convertTimeTo_24:  function(sTime) {      
        try{ 
            var iTime=new Array(); 
            var sTimeList = new Array(); 
            var sMinF=new Array();      
            sTimeList=sTime.split(':');
            var hr; var min; var fr;
            if(sTimeList!=undefined){ 
                hr=sTimeList[0]; 
                sMinF=sTimeList[1].split(' ');
                min=sMinF[0];              
                fr=sMinF[1];
            }    
            if(fr=='PM' && hr<12){ 
                hr=parseInt(hr)+12;
                iTime.push(hr);
            }else if(fr=='AM' && hr==12){ 
                iTime.push(0); 
            }
                else{        
                    iTime.push(hr);
                }
            iTime.push(min); 
            
            return iTime; 
        }catch(ex){console.log('convertTimeTo_24 Catch exception=>'+ex);}     
    } ,   
    
    fetchUsersAvailibilityByGroup: function(component, event, helper) {
        component.set("v.showMmainSpin",true);   
        var FromDoInit=component.get("v.CallResourcesByGroup");   
        var Index=0;
        Index=component.get("v.GroupIndex");  
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
                var UserAvailabilityList=[]; UserAvailabilityList=GroupWrapperList[Index].UserAvailabilityList;//ResourceAvailabilityList; 
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
                component.set("v.GroupWrapperList",GroupWrapperList);
                component.set("v.showMmainSpin",false); 
            }else{
                component.set("v.showMmainSpin",false); 
            }
            
        });
        if(GroupWrapper.ServiceId!=undefined && GroupWrapper.ServiceId!=null && GroupWrapper.LocationId!=undefined && GroupWrapper.LocationId!=null) $A.enqueueAction(action); 
        
    },
    
})