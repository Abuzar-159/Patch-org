({
    helperTotalPrice : function(component, event) {
        
        var item = component.get("v.Item");
        if(!$A.util.isUndefined(item)){
            var totalPrice = 0.00;
            if(item.ERP7__Quantity__c==0) item.ERP7__Quantity__c=1;
            totalPrice += parseFloat(item.ERP7__Quantity__c) * parseFloat(item.ERP7__Amount__c);
            if(totalPrice > 0.00){
                //component.set("v.Item.ERP7__Total_Amount__c",totalPrice);
                component.set("v.TotalPrice",totalPrice);
            }
                
        }
        
    },
    checkvalidationLookup : function(component,poli_List){
        if($A.util.isEmpty(poli_List.get("v.selectedRecordId"))){
            poli_List.set("v.inputStyleclass","hasError");
            if(component.NoErrors)component.NoErrors = false;
        }else{
            poli_List.set("v.inputStyleclass","");
            
        }
    },
    checkValidationField : function(component,cmp){
        if($A.util.isEmpty(cmp.get("v.value"))){
            cmp.set("v.class","slds-input hasError");
            if(component.NoErrors)component.NoErrors = false;
        }else{
            cmp.set("v.class","slds-input");
        }
        
    },
     UpdateTDSOnChange : function(cmp, event, helper){
        
        var TDS_Rate = cmp.get('v.Item.ERP7__TDS_Rate__c');
        
         if(TDS_Rate!=undefined){
             var TDS_Amount = (cmp.get('v.Item.ERP7__Amount__c')/100)*TDS_Rate;
        cmp.set("v.Update_TDS_Amount",TDS_Amount);
        cmp.set('v.Item.ERP7__TDS_Amount__c',TDS_Amount);
        cmp.set('v.TDS_Amount',TDS_Amount);
        cmp.set('v.TDS_Rate',TDS_Rate);
         }
        
        
        
    },
})