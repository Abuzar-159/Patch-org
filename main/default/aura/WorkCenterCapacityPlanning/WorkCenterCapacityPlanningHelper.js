({
    setMOs : function(component, event){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getMOs");
        action.setParams({
            currentWCCP : JSON.stringify(component.get("v.WCCP")),
            wcOffset : component.get("v.Offset"),
            RecordLimit : component.get("v.showPg")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.WCCP.MOS", response.getReturnValue().MOS);
                component.set("v.MOWRAP", response.getReturnValue().MOSWrp);
                //pagination
                component.set("v.recSize",response.getReturnValue().recSize);
                if(component.get("v.WCCP.MOS").length>0){
                    var startCount = component.get("v.Offset") + 1;
                    var endCount = component.get("v.Offset") + component.get("v.WCCP.MOS").length;
                    component.set("v.startCount", startCount);
                    component.set("v.endCount", endCount);
                    //component.set("v.PageNum",1);
                    var myPNS = [];
                    var ES = component.get("v.recSize");
                    var i=0;
                    var show=component.get('v.showPg');
                    while(ES >= show){
                        i++; 
                        myPNS.push(i); 
                        ES=ES-show;
                    } 
                    if(ES > 0) myPNS.push(i+1);
                    component.set("v.PNS", myPNS);
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                this.MOStatusCount(component, event);
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
     MOStatusCount : function(component, event) {
         console.log('helper called');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var products = component.get("v.MOStatusCount");
         console.log('products : ',products);
         for (var i in products){
             if(products[i].ERP7__Status__c == 'Draft'){
                 component.set("v.DraftMO", products[i].recordCount);
             }
             if(products[i].ERP7__Status__c == 'In Progress'){
                 component.set("v.ProgressMO", products[i].recordCount);
             }
             if(products[i].ERP7__Status__c == 'Complete'){
                 component.set("v.CompletedMO", products[i].recordCount);
             }
             if(products[i].ERP7__Status__c == 'Cancelled'){
                 component.set("v.CancelledMO", products[i].recordCount);
             }
             
         }
       /* var listPROJ = [];
        for (var i in products) {
            console.log('products[i] : '+products[i]);
            if(products[i].Morder.ERP7__Status__c == "Draft") {
                listPROJ.push(products[i].Morder);
            }
        }
         console.log('listPROJ.length : '+listPROJ.length);
        component.set("v.DraftMO", listPROJ.length);
        listPROJ = [];
        for (var i in products) {
            if(products[i].Morder.ERP7__Status__c == "In Progress") {
                listPROJ.push(products[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.ProgressMO", listPROJ.length);
        listPROJ = [];
        for (var i in products) {
            if(products[i].Morder.ERP7__Status__c == "Complete") {
                listPROJ.push(products[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.CompletedMO", listPROJ.length);
        listPROJ = [];
        
        for (var i in products) {
            if(products[i].Morder.ERP7__Status__c == "Cancelled") {
                listPROJ.push(products[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.CancelledMO", listPROJ.length);
        */
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
})