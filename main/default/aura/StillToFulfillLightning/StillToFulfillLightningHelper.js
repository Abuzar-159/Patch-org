({
	focusTOscan:function(component, event){
        $(document).ready(function() {
            component.set("v.scanValue",'');  
            var barcode = "";
            var pressed = false;
            var chars = [];
            $(window).keypress(function(e) {
                chars.push(String.fromCharCode(e.which));                      
                if (pressed == false) {
                    setTimeout(
                        $A.getCallback(function() {
                            if (chars.length >= 4) {
                                var barcode = chars.join("");
                                barcode = barcode.trim();
                                component.set("v.scanValue",barcode);     
                            }
                            chars = [];
                            pressed = false;
                        }), 250
                    );                                 
                }              
                pressed = true;
            }); // end of window key press function         
            
            $(window).keydown(function(e){
                if ( e.which === 13 ) { 
                    e.preventDefault();
                }
            }); 
            
        });       
        
    },
    searchhandle :function(cmp, event,search1)  {
     //  $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
       /* var logId = cmp.get("v.logisticIds");
         var logisticIds = logId.split(",");
        var LIds = JSON.stringify(logisticIds);
        */
        alert('search1 ');
     	var search = cmp.get("v.searchText");
        // cmp.set("v.IsSpinner",true);
        var action = cmp.get("c.getLogisticDetails");
        
        action.setParams({LogisticIds:LIds,searchText:search1});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.IsSpinner",false);
                cmp.set('v.logWrap',response.getReturnValue().solisItemList);
                cmp.set('v.pickItem',response.getReturnValue().pickItems);
                cmp.set('v.searchText',response.getReturnValue().LogName);
                cmp.set('v.packItem',response.getReturnValue().packItems);
                cmp.set('v.shipItem',response.getReturnValue().shipItems);
                cmp.set("v.IsSpinner",false);
            }
        });
        $A.enqueueAction(action);
    
    },
})