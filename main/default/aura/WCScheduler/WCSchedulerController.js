({
    fetchWorkCenterInfo : function(cmp, event, helper) {
        try{
            var selectedDate = cmp.get("v.selDate"); 
            console.log('selectedDate fetchWorkCenterInfo: ',selectedDate);
            var act = cmp.get("v.Action");
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.fetchWorkCenterDetails");
            var wcId = cmp.get("v.WCId");
            var woId = cmp.get("v.WOId");
            action.setParams({"WCId":wcId, "selDate":selectedDate, "Action":act, "WOId":woId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    console.log('fetchWorkCenterDetails : ',response.getReturnValue());
                   
                    cmp.set("v.selDate", response.getReturnValue().selDate);
                    cmp.set("v.showEditable", response.getReturnValue().showDateEdiatable);
                    cmp.set("v.NextDisabled", response.getReturnValue().NextDisabled);
                    cmp.set("v.PrevDisabled", response.getReturnValue().PrevDisabled);
                    cmp.set("v.SliderTimeSlots", response.getReturnValue().SliderTimeSlots);
                    cmp.set("v.WorkCenterList", response.getReturnValue().WorkCenterList);
                    cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    console.log('err : ',cmp.get("v.errorMsg"));
                    //added shaguftha-  below 2 lines to disable the schedule MO button when work center is unavialable 01_01_24
                    if(cmp.get("v.errorMsg") == 'Work center unavailable') cmp.set('v.disableScheduleMO',true);
                    else cmp.set('v.disableScheduleMO',false);
                    console.log('disableScheduleMO : ',cmp.get('v.disableScheduleMO'));
                    cmp.set("v.Action",'');
                    
                    cmp.set("v.SliderStartTime", response.getReturnValue().SliderStartTime);
                    cmp.set("v.SliderEndTime", response.getReturnValue().SliderEndTime);
                    cmp.set("v.SliderLandingStartTime", response.getReturnValue().SliderLandingStartTime);
                    cmp.set("v.SliderLandingEndTime", response.getReturnValue().SliderLandingEndTime);
                
                  
                    var SliderStartTime = response.getReturnValue().SliderStartTime;
                    console.log('SliderStartTime : ',SliderStartTime);
                    var SliderEndTime = response.getReturnValue().SliderEndTime;
                    console.log('SliderEndTime : ',SliderEndTime);
                    var sst = response.getReturnValue().SliderLandingStartTime;
                    var set = response.getReturnValue().SliderLandingEndTime; 
                    
                    setTimeout(
                        $A.getCallback(function() {
                            var slider = document.getElementById(cmp.get("v.WCUniqueId"));
                            console.log('slider : ',slider);
                            if(slider != null){
                                if(slider.noUiSlider != undefined) slider.noUiSlider.destroy();
                                if(slider.noUiSlider == undefined){
                                    noUiSlider.create(slider, {
                                        start: [sst, set],
                                        connect: true,
                                        step: 1,
                                        behaviour: 'drag-tap',
                                        pips: {
                                            mode: 'steps',
                                            density: 5,
                                            format: wNumb({
                                                decimals: 2,
                                                prefix: ''
                                            })
                                        },
                                        
                                        cssPrefix : 'noUi-',
                                        cssClasses: {
                                            target: 'target',
                                            base: 'base',
                                            origin: 'origin',
                                            handle: 'handle',
                                            handleTouchArea: 'handle-touch-area',
                                            handleLower: 'active',
                                            handleUpper: 'active',
                                            horizontal: 'horizontal',
                                            vertical: 'vertical',
                                            background: 'background',
                                            connect: 'connect',
                                            ltr: 'ltr',
                                            rtl: 'rtl',
                                            draggable: 'draggable',
                                            drag: 'state-drag',
                                            tap: 'state-tap',
                                            active: 'active',
                                            tooltip: 'tooltip',
                                            pips: 'pips',
                                            pipsHorizontal: 'pips-horizontal',
                                            pipsVertical: 'pips-vertical',
                                            marker: 'marker',
                                            markerHorizontal: 'marker-horizontal',
                                            markerVertical: 'marker-vertical',
                                            markerNormal: 'marker-normal',
                                            markerLarge: 'marker-large',
                                            markerSub: 'marker-sub',
                                            value: 'value',
                                            valueHorizontal: 'value-horizontal',
                                            valueVertical: 'value-vertical',
                                            valueNormal: 'value-normal',
                                            valueLarge: 'value-large',
                                            valueSub: 'value-sub'
                                        },
                                        
                                        range: {
                                            'min': (SliderStartTime == null || SliderStartTime == undefined || SliderStartTime == '') ?  0 : SliderStartTime,
                                            'max': (SliderEndTime == null || SliderEndTime == undefined || SliderEndTime == '') ?  1 : SliderEndTime 
                                        },
                                        
                                        format: wNumb({
                                            decimals: 0
                                        })
                                        
                                    }); 
                                }
                                cmp.set("v.initial", !cmp.get("v.initial"));
                                slider.noUiSlider.on('set', function () { cmp.set('v.selectedbyuser',false); cmp.set("v.initial", !cmp.get("v.initial")); });
                            }
                        }), 1000
                    );
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        } catch(e){
            cmp.set("v.errorMsg", e);
        } 
    },
    
    previous : function(cmp, event, helper) {
        cmp.set("v.Action", "prev");
        cmp.fetchWorkCenterInfo();
    },
    
    next : function(cmp, event, helper) {
        cmp.set("v.Action", "next");
        cmp.fetchWorkCenterInfo();
    },
    
    calendar : function(cmp, event, helper) {
        cmp.set("v.Action", "");
        cmp.fetchWorkCenterInfo();
    },
    
    ScheduleTime : function(cmp, event, helper) {
        try{
            var selectedDate = cmp.get("v.selDate");
            console.log("selectedbyuser: " +cmp.get('v.selectedbyuser'));
            var slider = document.getElementById(cmp.get("v.WCUniqueId")); 
            var seletedTimesVal ;
            if(slider != null) seletedTimesVal = slider.noUiSlider.get();
            console.log('seletedTimesVal : ',seletedTimesVal);
            var action = cmp.get("c.ScheduledWOTime");
            action.setParams({"selDate":selectedDate, "st":seletedTimesVal[0], "et":seletedTimesVal[1]});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    console.log('ScheduledWOTime : ',response.getReturnValue());
                    if(response.getReturnValue().errorMsg == ''){
                        var cmpEvent = cmp.getEvent("cmpEvent");
                        
                        cmpEvent.setParams({"WO" : response.getReturnValue().WO, Index : cmp.get("v.WCUniqueId"),selectedbyuser : cmp.get('v.selectedbyuser') });
                        cmpEvent.fire();
                    }
                    else cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                }
            });
            $A.enqueueAction(action);
        } catch(e){ console.log('*** Catch error =>'+e); } 
    },
    setSelectedDate : function(cmp, event, helper) {
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
        if(event.getParam("oldValue") != event.getParam("value")){
            cmp.set('v.selectedbyuser',true);
            
            var action =cmp.get('c.fetchWorkCenterInfo');
            $A.enqueueAction(action);
        }
       
        
    },
    fetchdataInfo : function(cmp, event, helper) {
        console.log(" fetch INfo selectedbyuser: " +cmp.get('v.selectedbyuser'));
        
        
        let selecteddetails = event.getParam('arguments');
        console.log('selecteddetails : ',JSON.stringify(selecteddetails));
        if(selecteddetails){
            cmp.set('v.selDate',selecteddetails.SelectedNewDate);
            cmp.set('v.selectedbyuser',selecteddetails.selectedbyuser1);
            if(cmp.get('v.selectedbyuser')){
                console.log('fetch INfo called');
                var action =cmp.get('c.fetchWorkCenterInfo');
                $A.enqueueAction(action);
            }
        }  
    }
     
    
})