({
	Navigate : function(component, event, helper) {
         $A.createComponent(
            "c:BillOfMaterials", {
                "versionComp":component.get("v.Vbom")
            },
             
            function(newCmp) {
                if (component.isValid()) {
                    var bodycmp = component.find("TimeCEContent");
                        var body = bodycmp.get("v.body");
                        body.push(newCmp);
                        bodycmp.set("v.body", body);
                }
            }
             
        );
       
	},
    
    Navigates : function(component, event, helper) {
        var bomitems = component.get('v.boms');
        bomitems.push({'sObjectType':'ERP7__BOM__c','Name':'','ERP7__Process_Cycle__c':'','ERP7__Quantity__c':'','ERP7__Type__c':'','ERP7__Phase__c':'','ERP7__Unit_of_Measure__c':'','ERP7__Active':true});
		component.set('v.boms',bomitems);
    }
})