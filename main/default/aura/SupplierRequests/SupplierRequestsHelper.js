({
    setRFPDetails : function(component, helper, currentText) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchAllDetails");
        console.log('vendorId~>'+component.get("v.currentSupplier")+' & SearchStr~>'+currentText+' & rfpOffset~>'+component.get("v.Offset")+' & RecordLimit~>'+component.get('v.show')+' & rfpStatus~>'+component.get("v.singleRFPStatus"));
        action.setParams({
            vendorId    : component.get("v.currentSupplier"),
            SearchStr   : currentText,
            rfpOffset   : component.get("v.Offset"),
            RecordLimit : component.get('v.show'),
            rfpStatus   : component.get("v.singleRFPStatus"),
            //sortField   : component.set("v.sortRFPBy"),
            //sortOrder   : component.get("v.ascRFPOrder")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('setRFPDetails resp~>'+JSON.stringify(response.getReturnValue()));
                component.set("v.RFPWrap", response.getReturnValue());
                component.set("v.requests", response.getReturnValue().reqSuppliers);
                component.set("v.vendor", response.getReturnValue().vendor);
                if(response.getReturnValue().vendor != undefined && response.getReturnValue().vendor != null){
                    if(response.getReturnValue().vendor.Id != undefined && response.getReturnValue().vendor.Id != null){
                        component.set("v.currentSupplier", response.getReturnValue().vendor.Id);
                    }
                }
                component.set("v.ReviewRFPs",response.getReturnValue().reviewCount);
                component.set("v.OpenRFPs",response.getReturnValue().openCount);
                component.set("v.ClosedRFPs",response.getReturnValue().closeCount);
                component.set("v.CancelledRFPs",response.getReturnValue().cancelCount);
                
                //pagination
                component.set("v.recSize",response.getReturnValue().recSize);
                //if(component.get("v.requests").length>0){
                var startCount = component.get("v.Offset") + 1;
                var endCount = component.get("v.Offset") + component.get("v.requests").length;
                component.set("v.startCount", startCount);
                component.set("v.endCount", endCount);
                //component.set("v.PageNum",1);
                var myPNS = [];
                var ES = component.get("v.recSize");
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);
                //}
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                console.log('setRFPDetails errors~>',errors);
                component.set("v.exceptionError", errors[0].message);
                setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
                component.set("v.requests",[]);
                component.set("v.ReviewRFPs",response.getReturnValue().reviewCount);
                component.set("v.OpenRFPs",response.getReturnValue().openCount);
                component.set("v.ClosedRFPs",response.getReturnValue().closeCount);
                component.set("v.CancelledRFPs",response.getReturnValue().cancelCount);
                //pagination
                component.set("v.recSize",response.getReturnValue().recSize);
                //if(component.get("v.requests").length>0){
                var startCount = component.get("v.Offset") + 1;
                var endCount = component.get("v.Offset") + component.get("v.requests").length;
                component.set("v.startCount", startCount);
                component.set("v.endCount", endCount);
                //component.set("v.PageNum",1);
                var myPNS = [];
                var ES = component.get("v.recSize");
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);
                //}
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    setPublicRFPDetails : function(component, event, currentText){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var reqsJSON = JSON.stringify(component.get("v.requests"));
        var action = component.get("c.fetchPublicReqs");
        action.setParams({
            SearchStr : currentText,
            reqs : reqsJSON
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('setRFPDetails resp~>'+JSON.stringify(response.getReturnValue()));
                component.set("v.publicRequests", response.getReturnValue());
                $A.util.addClass(component.find("newRFP"), 'slds-fade-in-open');
                $A.util.addClass(component.find("newRFPBackdrop"), 'slds-backdrop_open');
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                console.log('setPublicRFPDetails errors~>'+errors);
                component.set("v.exceptionError", errors[0].message);
                setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    applyForRequest: function(component, event, selectedRequests){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.applyForRFPs");
        action.setParams({
            requestsToApply : JSON.stringify(selectedRequests),
            vendorId : component.get("v.currentSupplier")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                $A.util.removeClass(component.find("newRFP"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newRFPBackdrop"), 'slds-backdrop_open');
                component.set("v.serverSuccess","Application Accepted.");
                setTimeout($A.getCallback(function() {component.set("v.serverSuccess",""); }), 5000 );
                
                //$A.get('e.force:refreshView').fire();
                this.setRFPDetails(component, event, '');
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                console.log('applyForRequest errors~>'+errors);
                component.set("v.exceptionError", errors[0].message);
                setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.accountData");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'NumberOfEmployees'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        //set sorted data to accountData attribute
        component.set("v.accountData",data);
    }
})