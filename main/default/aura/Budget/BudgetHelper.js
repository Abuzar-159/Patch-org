({
	helperMethod : function() {
		
	},
    
    fetchBudgetList:function(cmp,event){
        var orgId=cmp.get("v.Organisation.Id");
        var action=cmp.get("c.getBudgetList");
        action.setParams({
            orgId:cmp.get("v.Organisation.Id"),OrderBy:cmp.get("v.OrderBy"),Order:cmp.get("v.Order"),Offset: cmp.get("v.Offset"),
          RecordLimit: cmp.get('v.show')
        });
        
        action.setCallback(this, function(res){
            if(res.getState()=='SUCCESS'){
                try{
                    cmp.set("v.BudgetList",res.getReturnValue().FilteredBudgetList);
                    cmp.set("v.BudgetListDum",res.getReturnValue().FilteredBudgetList);
                    var BankReconciliationlist=[];
                    BankReconciliationlist=cmp.get("v.BudgetList");
                    if(BankReconciliationlist.length<=0) cmp.set("v.NoSlotsMessage",'No Data Available');
                    var Offsetval=parseInt(cmp.get("v.Offset"));
                var records=[];   
                records = res.getReturnValue().FilteredBudgetList;   
                cmp.set('v.recSize',res.getReturnValue().recSize);    
                if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        cmp.set("v.startCount", startCount);
                        cmp.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        cmp.set("v.startCount", startCount);
                        cmp.set("v.endCount", endCount); 
                        cmp.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = 10;
                var i=0;
                var show=cmp.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                cmp.set("v.PNS", myPNS); 
                }
                catch(e){
                    console.log('doInit exception'+ e);
                }
            }
        });
        $A.enqueueAction(action);
    },

})