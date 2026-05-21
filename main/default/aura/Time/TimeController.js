({
	doInit : function(component, event, helper) {
		      var opts=[];                               
              opts.push({label:'12:00 AM', value:'12:00 AM'});  opts.push({label:'1:00 AM', value:'1:00 AM'}); 
              opts.push({label:'2:00 AM', value:'2:00 AM'}); opts.push({label:'3:00 AM', value:'3:00 AM'}); 
              opts.push({label:'4:00 AM', value:'4:00 AM'}); opts.push({label:'5:00 AM', value:'5:00 AM'}); 
              opts.push({label:'6:00 AM', value:'6:00 AM'});  opts.push({label:'7:00 AM', value:'7:00 AM'}); 
              opts.push({label:'8:00 AM', value:'8:00 AM'}); opts.push({label:'9:00 AM', value:'9:00 AM'}); 
              opts.push({label:'10:00 AM',value:'10:00 AM'}); opts.push({label:'11:00 AM',value:'11:00 AM'}); 
              opts.push({label:'12:00 PM',value:'12:00 PM'});  opts.push({label:'1:00 PM',value:'1:00 PM'}); 
              opts.push({label:'2:00 PM', value:'2:00 PM'}); opts.push({label:'3:00 PM', value:'3:00 PM'}); 
              opts.push({label:'4:00 PM', value:'4:00 PM'}); opts.push({label:'5:00 PM', value:'5:00 PM'});
              opts.push({label:'6:00 PM', value:'6:00 PM'});  opts.push({label:'7:00 PM', value:'7:00 PM'}); 
              opts.push({label:'8:00 PM', value:'8:00 PM'}); opts.push({label:'9:00 PM', value:'9:00 PM'}); 
              opts.push({label:'10:00 PM', value:'10:00 PM'}); opts.push({label:'11:00 PM', value:'11:00 PM'});              
              component.set("v.TimeList",opts);              
	},
  
    
    onblur : function (component, event, helper) {
      
        var forclose = component.find("searchRes");
         if(component.get("v.showTimePanel")){
             //$A.util.addClass(forclose, 'slds-is-close');
             //$A.util.removeClass(forclose, 'slds-is-open');
         }
        component.reset;
    },
    
    
    onfocusTime:function(component, event, helper) {
        if(component.get("v.showTimePanel")==false) { 
			component.set("v.showTimePanel",true);  
            //var forOpen = component.find("searchRes");
            //$A.util.addClass(forOpen, 'slds-is-open');
            //$A.util.removeClass(forOpen, 'slds-is-close');
        }
        else {
            component.set("v.showTimePanel",false);   
            //var forclose = component.find("searchRes");
            //$A.util.addClass(forclose, 'slds-is-close');
            //$A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    hideTimePanel:function(component,event,helper){
        if(component.get("v.value")==undefined || component.get("v.value")=='') {  
            $A.util.removeClass(component.find("inpTimeId").getElement(),'slds-input');
            $A.util.addClass(component.find("inpTimeId").getElement(),'TimeDisableClass');            
        } 
        
        setTimeout(
            $A.getCallback(function() {
                component.set("v.showTimePanel",false);
            }), 400
        );   
    },
    
    
    changeTime: function(component, event, helper) {    
        var searchVal=$(component.find("inpTimeId").getElement()).val(); 
        var way=''; if(event.currentTarget!=undefined) way=event.currentTarget.getAttribute('data-way');
        if(way!='li') component.set("v.value",searchVal);
        else component.set("v.value",event.currentTarget.getAttribute('data-time'));      
        
        var e = $A.get("e.c:TimeEvent");                                                       
        e.setParams({
                "RIndex":component.get("v.RIndex"),
                "DIndex":component.get("v.DIndex"),
                "action":component.get("v.action"),
                "value":component.get("v.value")
        });
        e.fire();
        component.set("v.showTimePanel",false);        
    },
    
     
    resetOnblur : function (component, event, helper) {
        if(component.get("v.value")==undefined || component.get("v.value")=='') {  
            
            $A.util.removeClass(component.find("inpTimeId").getElement(),'slds-input');
            $A.util.addClass(component.find("inpTimeId").getElement(),'TimeDisableClass');            
        } 
       //component.set("v.resetComp",false);  component.set("v.resetComp",true); 

       var searchVal=$(component.find("inpTimeId").getElement()).val();      
        var way=''; way=event.currentTarget.getAttribute('data-way');
        
        if(way=='inp') component.set("v.value",searchVal);
        else component.set("v.value",event.currentTarget.getAttribute('data-time'));
        
        
        var e = $A.get("e.c:TimeEvent");                                                       
        e.setParams({
                "RIndex":component.get("v.RIndex"),
                "DIndex":component.get("v.DIndex"),
                "action":component.get("v.action"),
                "value":searchVal
        });
        e.fire();
        component.set("v.showTimePanel",false); 
    
    },
   
})