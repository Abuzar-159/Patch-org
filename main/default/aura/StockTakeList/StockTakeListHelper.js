({
    getStocktakeRecords : function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var action = component.get("c.fetchSortedList");
        action.setParams({
            "OrderBy":component.get("v.OrderBy"),
            "SortOrder":component.get("v.Order"),
            'site' : component.get("v.selectedSite"),
            'ChId' : component.get("v.currentEmployee.ERP7__Channel__c"),
            'Show' : component.get("v.show"),
            'Offset' : 0
        }); 
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.PreventChange", true);
                component.set("v.Container", response.getReturnValue());
                component.set("v.currentEmployee", response.getReturnValue().Employee);
                //component.find("Site").set("v.options", response.getReturnValue().channelSites);
                component.set("v.SiteOptions", response.getReturnValue().channelSites);
                component.set("v.selectedSite", response.getReturnValue().selectedSite);
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                component.set("v.PreventChange", false);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    focusTOscan: function (component, event) {
        console.log('focusTOscan helper called');
        $(document).ready(function () {
            component.set("v.scanValue", '');
            var barcode = "";
            var pressed = false;
            var chars = [];
            $(window).keypress(function (e) { 
                $(".cmpbody").keypress(function (e) { //change added by Arshad 05/06/2023 to fix issues if typing in free text fast or scanning anything on other pages after navigating from this cmp or typing fast on app launcher search
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
                });
            }); // end of window key press function         
            
            $(window).keydown(function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                }
            });
        });
    },
    
})