({
    show: function(component, event, helper) {
        //var cmp = component.find('Approve');
        try{
            //var rid = component.set("v.rid", event.currentTarget.dataset.record);
          
        //var cmp = component.find('Approve');
        $A.util.addClass(component.find("Approve"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
        }catch(Exception){
            console.log('Exception',Exception);
        }
        
    },
    show1: function(component, event, helper) {
       try{
            //var rid = component.set("v.rid", event.currentTarget.dataset.record);
           
        //var cmp = component.find('Approve');
        $A.util.addClass(component.find("Approve2"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
        }catch(Exception){
            console.log('Exception',Exception);
        }
    },
    show2: function(component, event, helper) {
        try{
            //var rid = component.set("v.rid", event.currentTarget.dataset.record);
        
        //var cmp = component.find('Approve');
        $A.util.addClass(component.find("Approve3"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
        }catch(Exception){
            console.log('Exception',Exception);
        }
    },
    show3: function(component, event, helper) {
       try{
            //var rid = component.set("v.rid", event.currentTarget.dataset.record);
           
        //var cmp = component.find('Approve');
        $A.util.addClass(component.find("Approve4"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
        }catch(Exception){
            console.log('Exception',Exception);
        }
    },
    show4: function(component, event, helper) {
        try{
            //var rid = component.set("v.rid", event.currentTarget.dataset.record);
          
        //var cmp = component.find('Approve');
        $A.util.addClass(component.find("Approve5"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
        }catch(Exception){
            console.log('Exception',Exception);
        }
    },
    show5: function(component, event, helper) {
        try{
            //var rid = component.set("v.rid", event.currentTarget.dataset.record);
           
        //var cmp = component.find('Approve');
        $A.util.addClass(component.find("Approve6"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
        }catch(Exception){
            console.log('Exception',Exception);
        }
    },
    show6: function(component, event, helper) {
        try{
            //var rid = component.set("v.rid", event.currentTarget.dataset.record);
         
        //var cmp = component.find('Approve');
        $A.util.addClass(component.find("Approve7"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
        }catch(Exception){
            console.log('Exception',Exception);
        }
    },
    Modal_hide: function(component, event, helper) {
        // $A.util.removeClass(component.find("Approve"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("Approve"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("Approve2"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("Approve3"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("Approve4"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("Approve5"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("Approve6"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("Approve7"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
    },
    handleApplicationEventFired: function(component, event, helper) {
       
        component.set("v.tceObj.ERP7__Week_Day_1__c", component.get("v.counts.d"));
        component.set("v.tceObj.ERP7__Week_Day_2__c", component.get("v.counts.d1"));
        component.set("v.tceObj.ERP7__Week_Day_3__c", component.get("v.counts.d2"));
        component.set("v.tceObj.ERP7__Week_Day_4__c", component.get("v.counts.d3"));
        component.set("v.tceObj.ERP7__Week_Day_5__c", component.get("v.counts.d4"));
        component.set("v.tceObj.ERP7__Week_Day_6__c", component.get("v.counts.d5"));
        component.set("v.tceObj.ERP7__Week_Day_7__c", component.get("v.counts.d6"));
        var Obj = component.get("v.tceObj");
        for (var i in event.getParams('tCardEntry').tCardEntry) {
            if (event.getParams('tCardEntry').tCardEntry[i] != null)
                Obj[i] = event.getParams('tCardEntry').tCardEntry[i];
        }
        component.set("v.tceObj", Obj);
        component.set("v.tceObj.ERP7__Organisation__c", event.getParams('orgId').orgId);
        component.set("v.tceObj.ERP7__Organisation_Business_Unit__c", event.getParams('buId').buId);
        component.set("v.tceObj.ERP7__Timesheet__c", event.getParams('tSheetId').tSheetId);
        var action = component.get("c.saveTimeCardEntryUp");
        action.setParams({
            'tCardEntry': JSON.stringify(component.get("v.tceObj"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //('SUCCESS');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message + errors);
                    }
                } else {
                    console.log("Unknown error" + errors);
                }
            }
        });
        $A.enqueueAction(action);
                
    },
    onChange: function(component, event, helper) {
        helper.onchangeHelper(component, event, helper);
    },
    doInit: function(component, event, helper) {
        if (component.get('v.tSheetcomp')['Id'] == null) {
            var dateAction = component.get("c.initializeToTimeSheets");
            var dayadd = component.get("v.intweek");
            dateAction.setParams({
                newDay: dayadd
            });
            dateAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.timeSheet', response.getReturnValue());
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message + errors);
                        }
                    } else {
                        console.log("Unknown error" + errors);
                    }
                }
            });
            $A.enqueueAction(dateAction);
        } else {
            if (component.get("v.tceObj.ERP7__Week_Day_1__c") == undefined) {
                helper.onchangeHelper(component, event, helper);
            } else {
                component.set('v.intweek', '0');
                component.set("v.timeSheet.ERP7__Week_Date__c", component.get("v.tceObj.ERP7__Week_Day_1__c"));
            }
        }
    },
    toggle: function(component, event, helper) {
        var toggleText = component.find("text");
        $A.util.toggleClass(toggleText, "toggle");
    },
    handleDelClick: function(component, event, helper) {
        
        var recId = component.get("v.tceObj.Id");
        
        var result = confirm("Are you sure you want to delete this item?");
        if (result) {
           
            if (recId != null && recId != undefined) {
                
                var self = this;
                var deleteAction = component.get("c.deleteTcardEntry");
                
                deleteAction.setParams({
                    "recordId": recId
                });
                deleteAction.setCallback(self, function(a) {
                    
                    var recordId = a.getReturnValue();
                    
                    if (recordId == null) {} else {
                        var deleteEvent = component.getEvent("delete");
                       
                        deleteEvent.setParams({
                            "listIndex": event.target.dataset.index,
                            "oldRecord": recId
                        }).fire();
                    }
                });
                $A.enqueueAction(deleteAction);
            } else {
                
                component.destroy('null');
            }
            return true;
        } else {
            return false;
        }
    },
    handleAccountDelete: function(component, event, helper) {
        component.destroy('null');
    },
    
    hourValidation1 : function(component, event, helper)
    {
        
        /*week hours validations*/
        //var week = component.get("v.weekError1");
        
        //var evt = component.getEvent("validationError");
        
        //var validationError = evt.getParam("statusSheet");
        
        var validationError = event.getParam("statusSheet");
        //var evtVal = evt.getParam("statusSheet");
        
        
        
        var week1 = component.find("weekDay1").get("v.value");
        if(parseInt(week1) <= 24){
            component.set("v.hour1",'');
        }else{
            component.set("v.hour1",'add less than 24 hrs');
        }
         
    },
    
    hourValidation2 : function(component, event, helper)
    {
        var week1 = component.find("weekDay2").get("v.value");
        if(parseInt(week1) <= 24){
            component.set("v.hour2",'');
        }else{
            component.set("v.hour2",'add less than 24 hrs');
        }
    },
    
    hourValidation3 : function(component, event, helper)
    {
        var week1 = component.find("weekDay3").get("v.value");
        if(parseInt(week1) <= 24){
            component.set("v.hour3",'');
        }else{
            component.set("v.hour3",'add less than 24 hrs');
        }
    },
    
    hourValidation4 : function(component, event, helper)
    {
        var week1 = component.find("weekDay4").get("v.value");
        if(parseInt(week1) <= 24){
            component.set("v.hour4",'');
        }else{
            component.set("v.hour4",'add less than 24 hrs');
        }
    },
    
     hourValidation5 : function(component, event, helper)
    {
        var week1 = component.find("weekDay5").get("v.value");
        if(parseInt(week1) <= 24){
            component.set("v.hour5",'');
        }else{
            component.set("v.hour5",'add less than 24 hrs');
        }
    },
    
    hourValidation6 : function(component, event, helper)
    {
        var week1 = component.find("weekDay6").get("v.value");
        if(parseInt(week1) <= 24){
            component.set("v.hour6",'');
        }else{
            component.set("v.hour6",'add less than 24 hrs');
        }
    },
    
    hourValidation7 : function(component, event, helper)
    {
        var week1 = component.find("weekDay7").get("v.value");
        if(parseInt(week1) <= 24){
            component.set("v.hour7",'');
        }else{
            component.set("v.hour7",'add less than 24 hrs');
        }
    },
    
    displayWeekErrors: function(component, event, helper)
    {
        var validationError = event.getParam("validationError");
       
    },
    
    Navigate: function(component, event, helper) {
        var week_int = component.get("v.weekint");
        $A.createComponent(
            "c:AddTimeCardEntry", {
                "tSheetcomp": component.get("v.timeSheet"),
                "intweek": week_int.toString()
            },
            function(newCmp) {
                if (component.isValid()) {
                    week_int = parseInt(week_int) + 7;
                    component.set("v.weekint", week_int);
                    var bodycmp = component.find("TimeCEContent");
                    var body = bodycmp.get("v.body");
                    body.reverse();
                    body[body.length] = newCmp;
                    body.reverse();
                    bodycmp.set("v.body", body);
                }
            }
        );
    }
})