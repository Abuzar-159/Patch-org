({  
    /*FOR FETCHING RESOURCES */ 
    fetchResources : function(component, event, helper) { 
        component.set("v.criteriaMsg",'');
        if(component.find("mainSpinId").getElement() !=undefined && component.find("mainSpinId").getElement() !=null) component.find("mainSpinId").getElement().style.visibility = "visible";
        component.set("v.criteriaMsg",'');
        var action = component.get("c.getResource");
        var checker = component.get("v.checker");
        var selectedExpLocation=component.get("v.selectedExpLocation");
        var selectedService=component.get("v.selectedService"); 
        var selectedTeam=component.get("v.selectedTeam");
        var count=checker-7;
        action.setParams({             
            selectedLocation:selectedExpLocation,
            ServiceId:selectedService,
            count:count,
            selectedTeam:selectedTeam
        });  
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") { 
                var response = response.getReturnValue();              
                component.set("v.ResourceList",response.ResourcesList);
                component.set("v.ResourceListDum",response.ResourcesList); 
                component.set("v.TOTList",response.TOTList);
                component.set("v.DateList",response.DateList);
                component.set("v.FirstAvailableDate",response.DateList[0]); 
                if(component.get("v.callDoInit")) component.set("v.isSupervisor",response.isSupervisor); 
                component.set("v.callDoInit",false);    
                component.set("v.showPNPannel",true);
                
               //component.set("v.criteriaMsg",'No Resource Found'); 
               if(response.ResourcesList.length==0) component.set("v.criteriaMsg",'No Resource Found'); 
               if(component.find("mainSpinId").getElement() !=undefined && component.find("mainSpinId").getElement() !=null) component.find("mainSpinId").getElement().style.visibility="hidden"; 
                
               if(count==0) component.set("v.hidePreviousBool",true);
               else component.set("v.hidePreviousBool",false); 
            }else{
                 component.set("v.criteriaMsg",'No Resource Found');            
                 if(component.find("mainSpinId").getElement() !=undefined && component.find("mainSpinId").getElement() !=null) component.find("mainSpinId").getElement().style.visibility="hidden";
            }          
        });
        $A.enqueueAction(action);     
    },
    
    /*FOR FETCHING EXPERT LOCATIONS*/
	fetchLocationsAndServices : function(component, event, helper) {
        
       if(component.find("mainSpinId").getElement()!=undefined && component.find("mainSpinId").getElement()!=null) component.find("mainSpinId").getElement().style.visibility="visible"; 
	    var action = component.get("c.getLocationsAndServices"); 
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") { 
               if(response.getReturnValue()!=null){
                   
                if(response.getReturnValue()!=undefined && response.getReturnValue()!=null){                                   
                 component.set("v.expertLocsList",response.getReturnValue().expertLocsList);
                 component.set("v.prodServiceList",response.getReturnValue().prodServiceList);
                 component.set("v.TeamList",response.getReturnValue().TeamList);
                 
                 if(response.getReturnValue().sysCode!=undefined){   
                   if(!$A.util.isEmpty(response.getReturnValue().sysCode.ERP7__Date_Format__c)) component.set("v.dateFormat",response.getReturnValue().sysCode.ERP7__Date_Format__c);  
                 }else component.set("v.dateFormat", $A.get("$Locale.dateFormat")); 
                 
                 if(response.getReturnValue().sysCode!=undefined){   
                   if(!$A.util.isEmpty(response.getReturnValue().sysCode.ERP7__Resource_Time_Interval__c)) component.set("v.TimeDuration",response.getReturnValue().sysCode.ERP7__Resource_Time_Interval__c);  
                 }else component.set("v.TimeDuration",0);
                    
                 if(response.getReturnValue().expertLocsList.length>0) component.set("v.selectedExpLocation",response.getReturnValue().expertLocsList[0].value);
                 if(response.getReturnValue().expertLocsList.length>0) component.set("v.selectedService",response.getReturnValue().prodServiceList[0].value); 
                 if(response.getReturnValue().TeamList.length>0) component.set("v.selectedTeam",response.getReturnValue().TeamList[0].selectedTeam);
              
                this.fetchResources(component, event, helper); 
                }    
                }
            }       
        });
        $A.enqueueAction(action);
	},
   
   /*FOR NEXT WEEK */
    next : function(component, event, helper) { 
        component.find("mainSpinId").getElement().style.visibility="visible";
        var checker = component.get("v.checker"); 
        var dateDiff = component.get("v.dateDiff");                
        component.set("v.checker",checker+7);
        this.fetchResources(component, event, helper);       
    },
   
   /*FOR PREVIOUS WEEK */ 
    previous : function(component, event, helper) {
        component.find("mainSpinId").getElement().style.visibility="visible";
        var checker = component.get("v.checker");
        var dateDiff = component.get("v.dateDiff");             
        component.set("v.checker",checker-7);          
        this.fetchResources(component, event, helper);        
    }, 
  
    getTimeFormatedValueFromMillisecond:function(TimeMillVal){ 
         function pad(n, z) {
                        z = z || 2;
                        return ('00' + n).slice(-z);
                      }
                      var s=TimeMillVal;
                      var ms = s % 1000;
                      s = (s - ms) / 1000;
                      var secs = s % 60;
                      s = (s - secs) / 60;
                      var mins = s % 60;
                      var hrs = (s - mins) / 60;
            
                    var TimeValue=pad(hrs) + ':' + pad(mins);
                   
                                     
      var date_format = '12'; /* FORMAT CAN BE 12 hour (12) OR 24 hour (24)*/
       var TimeValueA=[];
       TimeValueA=TimeValue.split(":");
        var hour=TimeValueA[0];
        var minutes=TimeValueA[1]; 
       
              
        var result  = hour;
        var ext     = '';       
        if(date_format == '12'){
            if(hour > 12){
                ext = 'PM';
                hour = (hour - 12);
        
                if(hour < 10){
                    result = "" + hour;
                }else if(hour == 12){
                    hour = "0"; //00
                    ext = 'AM';
                }
            }
            else if(hour < 12){
                result = ((hour < 10) ? "" + hour : hour); //0
                ext = 'AM';
            }else if(hour == 12){
                ext = 'PM';
            }
        }
        
        if(minutes < 10){
            minutes = "" + minutes; //0
        }
        
        result = result + ":" + minutes + ' ' + ext; 
       return result; 
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
       return this.convertTime(TimeValue);
     },  
    
    /*CONVERT TIME TO 24 HOURSE*/
    convertTimeTo_24:  function(sTime) {      
           try{ 
                var iTime=new Array(); 
                var sTimeList = new Array(); 
                var sMinF=new Array();      
                sTimeList=sTime.split(':');
                var hr=sTimeList[0]; 
                sMinF=sTimeList[1].split(' ');
                var min=sMinF[0];              
                var fr=sMinF[1];
                   
                if(fr=='PM' && hr<12){ //pm
                  hr=parseInt(hr)+12;
                  iTime.push(hr);
                }else if(fr=='AM' && hr==12){ //am
                 iTime.push(0); 
                }
              else{        
                   iTime.push(hr);
                }
               iTime.push(min); 
       
              return iTime; 
        }catch(ex){ }     
    } ,   

    trim: function(value){  
        if(value !=undefined ) return ((value.toString()).trim() !=''?true:false);
        else return false;
    },
   
    addMinutes:function(component, event, helper,TimeValue,minsToAdd) { // (time/*"hh:mm"*/, minsToAdd/*"N"*/)     
          var time=this.convertTimeTo_24(TimeValue);          
          function z(n){
            return (n<10? '0':'') + n;
          }                 
          var mins = parseInt(time[0])*60 + (+parseInt(time[1])) + (+parseInt(minsToAdd)); 
          var result24=z(mins%(24*60)/60 | 0) + ':' + z(mins%60); 
        
          var result12= this.convertTimeToFormat(result24,12);  
        
         return result12;        
    },
 
   /*CONVERT 24 HOURSE FORMAT TIME TO 12 HOURS FORMAT AND VICE VERSA*/
    convertTimeToFormat:function(TimeValue,df) {   /*date_format=12 OR 24*/ 
        try{
        var date_format ='12'; // 12  date_format
        var TimeValueA=[];
        TimeValueA=TimeValue.split(":");
        var hour=TimeValueA[0];
        var minutes=TimeValueA[1]; 
        var result  = hour;
        var ext     = '';       
        if(date_format == '12'){
            if(hour > 12){
                ext = 'PM';
                hour = (hour - 12);
        
                if(hour < 12){ //10
                    result = "" + hour;
                }else if(hour == 12){
                    hour = "0"; //00
                    ext = 'AM';
                }
            }
                                
            else if(hour < 12){
                result = ((hour < 10) ? "" + hour : hour); 
                ext = 'AM';
            }else if(hour == 12){
                ext = 'PM';
            }
        }      
        if(minutes < 10){
            minutes = "" + minutes; 
        }               
        return result = result + ":" + minutes + ' ' + ext; 
      }catch(ex){ } 
},
    
    
    
})