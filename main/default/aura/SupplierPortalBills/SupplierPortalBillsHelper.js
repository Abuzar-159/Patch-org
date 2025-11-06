({
    getBills : function(component,event){
        console.log('getBills called');
        var accIds = [];
        var selectedPOS = component.get("v.SelectedPOS");//component.get("v.SelectedAccounts");
        
        if(!$A.util.isUndefined(selectedPOS.length)){
            accIds.push(selectedPOS); 	 	
        }else{
            for(var x in selectedPOS){
                accIds.push(selectedPOS[x]);
            }
        } // accIds.push('a321o0000002ncEAAQ');  
        var venIds = [];
        var selectedvend = component.get("v.SelectedVen");
        
        if(!$A.util.isUndefined(selectedvend.length)){
            venIds.push(selectedvend);
        }else{
            for(var x in selectedvend){
                venIds.push(selectedvend[x]);
            }
        }

        var fetchBillAction = component.get("c.fetchBills");
        //fetchPoAction.setStorable();
        
        fetchBillAction.setParams({AccId: component.get("v.AccId"),OrderBy:component.get("v.OrderBy"),Order:component.get("v.Order"),Offset: component.get("v.Offset"),
                                   RecordLimit: component.get('v.show'),searchString :component.get('v.SearchString')});
        fetchBillAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('fetchBills success json~>'+JSON.stringify(response.getReturnValue()));
                component.set("v.Bills",response.getReturnValue().Bills);
                component.set("v.BillsSL",response.getReturnValue().BillsSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().Bills;   
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
                console.log("server error in getBills : ", errors);
            } 
        });
        $A.enqueueAction(fetchBillAction);
    },
})