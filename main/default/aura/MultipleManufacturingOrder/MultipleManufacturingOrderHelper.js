({
	validateFields : function(cmp,event) {
		var MOrder2Insert=cmp.get("v.MOrder2Insert");
        if(MOrder2Insert.length==0){
            cmp.set("v.errorMsg",'Item not available');
            return false;
        }
        var isValid=true;
        for(var i in MOrder2Insert){
            if(MOrder2Insert[i].ERP7__Product__c !=''){
                if($A.util.isEmpty(MOrder2Insert[i].ERP7__Product__c) || $A.util.isUndefinedOrNull(MOrder2Insert[i].ERP7__Product__c)){
                    cmp.set("v.errorMsg",'Product Missing');
                    isValid=false;
                }
                if($A.util.isEmpty(MOrder2Insert[i].ERP7__Quantity__c) || $A.util.isUndefinedOrNull(MOrder2Insert[i].ERP7__Quantity__c)){
                    cmp.set("v.errorMsg",'Quantity Missing');
                    isValid=false;
                }
                if($A.util.isEmpty(MOrder2Insert[i].ERP7__ExpectedDate__c) || $A.util.isUndefinedOrNull(MOrder2Insert[i].ERP7__ExpectedDate__c)){
                    cmp.set("v.errorMsg",'Expected Date Missing');
                    isValid=false;
                }                
                if($A.util.isEmpty(MOrder2Insert[i].ERP7__Routing__c) || $A.util.isUndefinedOrNull(MOrder2Insert[i].ERP7__Routing__c)){
                    cmp.set("v.errorMsg",'Routing Missing');
                    isValid=false;
                }
                if($A.util.isEmpty(MOrder2Insert[i].ERP7__StartDate__c) || $A.util.isUndefinedOrNull(MOrder2Insert[i].ERP7__StartDate__c)){
                    cmp.set("v.errorMsg",'Start Date Missing');
                    isValid=false;
                }
                if($A.util.isEmpty(MOrder2Insert[i].ERP7__Version__c) || $A.util.isUndefinedOrNull(MOrder2Insert[i].ERP7__Version__c)){
                    cmp.set("v.errorMsg",'Version Missing');
                    isValid=false;
                }
            }
        }
        if(isValid) return true;
        else return false;
	},
})