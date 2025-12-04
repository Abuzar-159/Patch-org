({
	getpurchaseOrder : function(component,event){
        var fetchPoAction = component.get("c.fetchPO");
        //fetchPoAction.setStorable();
        fetchPoAction.setParams({
            Offset: component.get("v.Offset"),
            AccId: component.get("v.AccId"),
            RecordLimit: component.get('v.show'),
            searchString :component.get('v.SearchString'),
            OrderBy:component.get("v.OrderBy"),
            Order:component.get("v.Order")
        });
        fetchPoAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('fetchPO resp~>'+JSON.stringify(response.getReturnValue()));
                 component.set("v.POList",response.getReturnValue().PO);
                component.set("v.POListDup",response.getReturnValue().POSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().PO;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
                
            }else{
                var errors = response.getError();
                console.log('setRFPDetails errors~>'+JSON.stringify(errors));
            }
        });
        $A.enqueueAction(fetchPoAction);
    },
       hideSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");    
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");   
    },
    
    getFieldsSetApiNameHandler : function(component,objectApiName,fieldSetApiName){
        var action = component.get("c.selectStarFromSObject");
        action.setParams({
            sObjectName : objectApiName});
        action.setCallback(this,function(response){
            if(objectApiName==='ERP7__PO__c')
                component.set("v.fields",response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
     createBill_PO : function(component,event,helper,POId){ 
        component.set("v.revert",false);
        var obj = {'ERP7__Amount__c':0.00,'ERP7__Discount_Amount__c':0.00,'ERP7__VAT_TAX_Amount__c':0.00};
         if(!$A.util.isUndefinedOrNull(POId) && !$A.util.isEmpty(POId)){
             //obj['ERP7__Purchase_Order__r'] = {'Id':event.target.dataset.record,'Name':event.target.dataset.name};
             $A.createComponent("c:CreateBill",{
                 "showExpenseAccount":false,
                 "aura:id": "mBill",
                 "Bill": obj,
                 "navigateToRecord":false,
                 "cancelclick":component.getReference("c.backTO"),
                 "saveclick":component.getReference("c.saveBill"),
                 "fromPortal":true,
             },function(newCmp, status, errorMessage){
                 if (status === "SUCCESS") {
                     var body = component.find("body");
                     newCmp.set('v.Bill.ERP7__Purchase_Order__c',POId);
                     //newCmp.set('v.Bill.ERP7__Organisation__c',component.get("v.Organisation.Id"));
                     body.set("v.body", newCmp);
                 }
             });   
         } else{
         }
    },
})