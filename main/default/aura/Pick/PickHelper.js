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

    // fetchStocks: function(cmp, event, helper) {
    //     var SWLR = cmp.get("v.soliWrapperList");
    //     var SMR = cmp.get("v.stockMap");
    //     var count = event.getSource().get("v.name");
    //     console.log('fetchStocks called for row: ', count);
    //     if (count >= 0) {
    //         $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
    //         var SWLI = JSON.stringify(SWLR[count]);
    //         console.log('SWLI: ', SWLI);
    //         var SMI = JSON.stringify(SMR);
    //         var action = cmp.get("c.fetchBinStocks");
    //         action.setParams({ SWL: SWLI, SM: SMI });
    //         action.setCallback(this, function(response) {
    //             var state = response.getState();
    //             if (state === "SUCCESS") {
    //                 console.log('fetchBinStocks Response: ', JSON.stringify(response.getReturnValue()));
    //                 cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
    //                 if (response.getReturnValue().exceptionError == '') {
    //                     SWLR[count] = response.getReturnValue().soliWrapperList[0];
    //                     console.log('Updated SWLR[' + count + ']: ', JSON.stringify(SWLR[count]));
    //                     SWLR[count].requiredQty = 1;
    //                     cmp.set("v.soliWrapperList", SWLR);
    //                     cmp.set("v.stockMap", response.getReturnValue().stockMap);
    //                     cmp.set("v.initialSTOLISerial", "");
    //                 }
    //             } else {
    //                 console.log('fetchBinStocks error: ', response.getError());
    //                 var errorMessage = "Unknown error";
    //                 if (response.getError() && response.getError()[0] && response.getError()[0].message) {
    //                     errorMessage = response.getError()[0].message;
    //                 }
    //                 cmp.set("v.exceptionError", "Error fetching stock: " + errorMessage);
    //             }
    //             $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    //         });
    //         $A.enqueueAction(action);
    //     }
    // },
    fetchStocks: function(cmp, event, helper, passedCount) {
        console.log('in fetchStocks');
        var SWLR = cmp.get("v.soliWrapperList");
        var SMR = cmp.get("v.stockMap");
        console.log('count0');
        var count;
    
        if (typeof passedCount !== "undefined") {
            count = passedCount;
        } else {
            count = event.getSource().get("v.name");
        }
        console.log('count', count);
        if (count >= 0) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var SWLI = JSON.stringify(SWLR[count]);
            console.log('SWLI : ' + SWLI);
            var SMI = JSON.stringify(SMR);
            var action = cmp.get("c.fetchBinStocks");
            console.log("swli:+ " + SWLI);
            console.log("smi:+ " + SMI);
            action.setParams({ SWL: SWLI, SM: SMI });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Response fetchStock: ' + JSON.stringify(response.getReturnValue()));
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    if (response.getReturnValue().exceptionError == '') {
                        SWLR[count] = response.getReturnValue().soliWrapperList[0];
                        console.log('Response : ' + JSON.stringify(SWLR[count]));
                        SWLR[count].requiredQty = 1;
                        cmp.set("v.soliWrapperList", SWLR);
                        console.log('soliwrapperlist bin - '+JSON.stringify(cmp.get("v.soliWrapperList")));
                        cmp.set("v.stockMap", response.getReturnValue().stockMap);
                        cmp.set("v.initialSTOLISerial", "");
                    }
                } else {
                    console.log('fetchBinStocks error: ', response.getError());
                    var errorMessage = "Unknown error";
                    if (response.getError() && response.getError()[0] && response.getError()[0].message) {
                        errorMessage = response.getError()[0].message;
                    }
                    cmp.set("v.exceptionError", "Error fetching stock: " + errorMessage);
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
        }
    }
})