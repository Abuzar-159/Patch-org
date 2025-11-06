({
	getTOInstance : function(component,event,helper) {
      var action = component.get("c.getTOInstance");    
      action.setCallback(this, function(response) {
      if (response.getState()) {  
          component.set("v.Timeoff",response.getReturnValue());                                                      
      }else{
      }
     });
     $A.enqueueAction(action); 
	},
    
    TimeoffEdit: function(component, event, helper) { 
        if(event.target!=null && event.target!=undefined){ 
        var index=event.target.id;
            
        var TimeoffList=component.get("v.TimeoffList");
        component.set("v.Timeoff.ERP7__Reason__c ",'');   component.set("v.saveErrorMsg",''); component.set("v.DateErrorMsg",'');  component.set("v.eDateMsg",'');       
        for(var i in TimeoffList[index]) component.get("v.Timeoff")[i]=TimeoffList[index][i]; 
        component.set("v.Timeoff",component.get("v.Timeoff"));    
        /*
        component.set("v.Id",AgendaList[index].Id);
        component.set("v.Index",index);
        component.set("v.action",event.currentTarget.dataset.name);
        */
                  
            
        component.set("v.Timeoff.ERP7__Start_Time__c ",helper.convertTime_12_To_24(component.get("v.Timeoff").ERP7__Start_Time__c)); 
        component.set("v.Timeoff.ERP7__End_Time__c ",helper.convertTime_12_To_24(component.get("v.Timeoff").ERP7__End_Time__c));
            
        /*component.set("v.Timeoff.ERP7__Start_Time__c ",helper.convertMillisecondToTime(component.get("v.Timeoff").ERP7__Start_Time__c)); 
        component.set("v.Timeoff.ERP7__End_Time__c ",helper.convertMillisecondToTime(component.get("v.Timeoff").ERP7__End_Time__c));
        */    
     
       }     
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

          return pad(hrs) + ':' + pad(mins) + ':' + pad(secs) + '.' + pad(ms, 3);
    },  
    
    /*CONVERT 24 HOURSE FORMAT TIME TO 12 HOURS FORMAT AND VICE VERSA*/
    convertTimeToFormat:function(TimeValue,date_format) {   /*date_format=12 OR 24*/  //date_format 
       // var date_format ='12'; // 12  date_format
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
                result = ((hour < 10) ? "" + hour : hour); //0
                ext = 'AM';
            }else if(hour == 12){
                ext = 'PM';
            }
        }
       
        
        if(minutes < 10){
            minutes = "" + minutes; //0
        }        
        return result = result + ":" + minutes + ' ' + ext;        
},

  /*CONVERT TIME TO 24 HOURSE*/
    convertTime_12_To_24:  function(sTime) {
       //var iTime=new Array();
       var iTime=''; 
       // try{
                var sTimeList = new Array(); 
                var sMinF=new Array();      
                sTimeList=sTime.split(':');
                var hr=sTimeList[0]; 
                sMinF=sTimeList[1].split(' ');
                var min=sMinF[0];              
                var fr=sMinF[1];
                   
                if(fr=='PM' && hr<12){ //pm
                  hr=parseInt(hr)+12;
                  //iTime.push(hr);
                  iTime=hr;  
                }else if(fr=='AM' && hr==12){ //am
                 iTime.push(0);
                 iTime=0;   
                }
              else{        
                  // iTime.push(hr);
                  iTime=hr;
                }
               //iTime.push(min); 
        iTime=iTime+':'+min+':00'+':00';
              return iTime; 
    } ,      
    
    
   saveTimeoff: function(component, event, helper) {
      var act=component.get("v.action");
       
   	  var action = component.get("c.getCreateTimeoff"); 
      var Timeoff=component.get("v.Timeoff"); 
     // Timeoff.ERP7__Start_Time__c=(Timeoff.ERP7__Start_Time__c).toTimeString();
      var ST=Timeoff.ERP7__Start_Time__c; var ET=Timeoff.ERP7__End_Time__c;
      Timeoff.ERP7__Start_Time__c=null;  Timeoff.ERP7__End_Time__c=null;
      //Timeoff.ERP7__Resource__c=component.get("v.RId"); 
      Timeoff.ERP7__User__c=component.get("v.userId");
      action.setParams({
            Timeoff:JSON.stringify(Timeoff),
            ST:ST,
            ET:ET,  
            "action":component.get("v.action"),
            "TOId":component.get("v.Id"),
            //"RId":component.get("v.RId")
      });  
      action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {  
          
       if(response.getReturnValue()!=null){                                              
          var TimeoffList=[]; TimeoffList=response.getReturnValue();  //.TimeoffList
          for(var i in TimeoffList){
               if(TimeoffList[i].ERP7__Start_Time__c!=undefined) TimeoffList[i].ERP7__Start_Time__c=
                   this.convertTimeToFormat(this.convertMillisecondToTime(TimeoffList[i].ERP7__Start_Time__c),12);
                   
               if(TimeoffList[i].ERP7__End_Time__c!=undefined) TimeoffList[i].ERP7__End_Time__c=
                   this.convertTimeToFormat(this.convertMillisecondToTime(TimeoffList[i].ERP7__End_Time__c),12);
                 
          }
          component.set("v.TimeoffList",TimeoffList);
          if(TimeoffList.length==0) component.set("v.AvailabilityMsg",'No Item Found'); //component.set("v.showTimeoffPopup",false);                       
          else component.set("v.AvailabilityMsg",'');   
          component.set("v.saveErrorMsg",''); component.set("v.DateErrorMsg",'');
       }                                     
      }   
     });
     $A.enqueueAction(action); 
     
     $A.util.removeClass(component.find('timeoffDeleteConfirmId').getElement(), 'slds-show'); 
     $A.util.addClass(component.find('timeoffDeleteConfirmId').getElement(), 'slds-hide'); 
     component.set("v.showTimeoffPopup",false);  
    
       
       
	},
    
   trim: function(value){  
        if(value !=undefined ) return ((value.toString()).trim() !=''?true:false);
        else return false;
    },
    
})