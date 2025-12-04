({
	focusTOscan: function (component, event) {
        console.log('focusTOscan helper called');
        $(document).ready(function () {
            component.set("v.scanValue", '');
            var barcode = "";
            var pressed = false;
            var chars = [];
            $(window).keypress(function (e) {
                
                $(".scanMN").keypress(function (e) {
                    e.stopPropagation()
                });
                
                chars.push(String.fromCharCode(e.which));
                if (pressed == false) {
                    setTimeout(
                        function () {
                            pressed = false;
                            if (chars.length >= 3) {
                                var barcode = chars.join("");
                                barcode = barcode.trim();
                                chars = [];
                                pressed = false;
                                component.set("v.scanValue", barcode);
                                console.log('scanValue : ',component.get("v.scanValue"));
                                chars = [];
                                pressed = false;
                            }
                            chars = [];
                            pressed = false;
                        }, 500);
                }
                pressed = true;
            }); // end of window key press function         
            
            $(window).keydown(function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                }
            });
        });
    },
    
    getLogisticRecords : function(component, event, helper) {
         $A.util.removeClass(component.find('mainSpin'), "slds-hide");
       
    	 var action = component.get("c.fetchSortedLogistics");
        action.setParams({
            "OrderBy":component.get("v.OrderBy"),
            "SortOrder":component.get("v.Order"),
            'DcId' : component.get("v.selectedSite"),
            'ChId' : component.get("v.currentEmployee.ERP7__Channel__c"),
            'Show' : component.get("v.show"),
            'Offset' : 0,
            'filter' : component.get('v.filtertype')
        }); 
        
        action.setCallback(this, function(response) {
                    var state = response.getState();
            if (state === "SUCCESS") {
                 component.set("v.PreventChange", true);
                component.set("v.Container", response.getReturnValue());
                component.set("v.currentEmployee", response.getReturnValue().Employee);
                //component.find("Site").set("v.options", response.getReturnValue().channelSites);
                component.set("v.SiteOptions",response.getReturnValue().channelSites);
                component.set("v.selectedSite", response.getReturnValue().selectedSite);
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                component.set("v.PreventChange", false);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
                           
        
    }
})