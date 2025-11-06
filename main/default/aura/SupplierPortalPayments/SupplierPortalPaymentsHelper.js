({
    getPayments : function(component,event){
        var selIds = [];
        var selectedVouchers = component.get("v.SelectedVouchers");
        for(var x in selectedVouchers)
            selIds.push(selectedVouchers[x].Id);                   
        
        var accIds = [];
        var selectedAcc = component.get("v.SelectedAccounts");
        for(var x in selectedAcc)
            accIds.push(selectedAcc[x].Id);
        
        var fetchPayAction = component.get("c.fetchPayments");
        //fetchPayAction.setStorable();
        
        fetchPayAction.setParams({
            AccId: component.get("v.AccId"),
            OrderBy:component.get("v.OrderBy"),Order:component.get("v.Order"), 
            RecordLimit: component.get('v.show'),searchString :component.get('v.SearchString'),
            Offset: component.get("v.Offset")
        });
        fetchPayAction.setCallback(this,function(response){
            var state = response.getState();
            //alert('state==>'+state);
            if(response.getState() === 'SUCCESS'){
                component.set("v.Payments",response.getReturnValue().Payments);
                component.set("v.PaymentsSL",response.getReturnValue().PaymentsSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().Payments;   
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
            }
            else{
                console.log("errors -> ", response.getError());
            }
        });
        $A.enqueueAction(fetchPayAction);
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
})