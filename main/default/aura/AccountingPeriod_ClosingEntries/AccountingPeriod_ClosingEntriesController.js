({
	doInit : function(component, event, helper) {
        helper.getRE(component, event);
		var fetchEntries = component.get("c.getClosingEntries");
        fetchEntries.setParams({"recordId":component.get("v.recordId")});
        fetchEntries.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var ExpenseClosingEntries = [];
                var IncomeClosingEntries = [];
                let result = response.getReturnValue();
               
                for(let i=0;i<result.length;i++){
                    var CreditObj = {};
                    var DebitObj = {};
                    if(result[i].AccountGroup === 'Expense'){
                         
                        CreditObj['AccountName'] = result[i].AccountName;
                        CreditObj['Credit'] = parseFloat(result[i].Debit - result[i].Credit);
                        CreditObj['Debit'] = 0.00;
                        DebitObj['AccountName'] = component.get("v.RE_COA").Name;
                        DebitObj['Credit'] = 0.00;
                        DebitObj['Debit'] = parseFloat(result[i].Debit - result[i].Credit).toFixed(2);
                       
                        //if(DebitObj.Debit >0.00 || DebitObj.Credit >0.00)
                         
                        //if(CreditObj.Debit >0.00 || CreditObj.Credit >0.00)
                        ExpenseClosingEntries.push(CreditObj); 
                        ExpenseClosingEntries.push(DebitObj);
                    }else{
                        if(Boolean(result[i].ContraAccount)){
                            CreditObj['AccountName'] = result[i].AccountName;
                            CreditObj['Credit'] = parseFloat(result[i].Debit - result[i].Credit);
                            CreditObj['Debit'] = 0.00;
                            DebitObj['AccountName'] = component.get("v.RE_COA").Name;
                            DebitObj['Credit'] = 0.00;
                            DebitObj['Debit'] = parseFloat(result[i].Debit - result[i].Credit).toFixed(2);
                            
                            IncomeClosingEntries.push(CreditObj); 
                            IncomeClosingEntries.push(DebitObj); 
                        }else{
                        CreditObj['AccountName'] = result[i].AccountName;
                        CreditObj['Debit'] = parseFloat(result[i].Credit - result[i].Debit).toFixed(2);
                        CreditObj['Credit'] = 0.00;
                        DebitObj['AccountName'] = component.get("v.RE_COA").Name;
                        DebitObj['Debit'] = 0.00;
                        DebitObj['Credit'] = parseFloat(result[i].Credit - result[i].Debit).toFixed(2);
                       
                        //if(DebitObj.Debit >0.00 || DebitObj.Credit >0.00)
                        	
                        //if(CreditObj.Debit >0.00 || CreditObj.Credit >0.00)
                            IncomeClosingEntries.push(CreditObj);
                            IncomeClosingEntries.push(DebitObj); 
                            
                    }
                    }
                }
                component.set("v.ExpenseClosingEntries",ExpenseClosingEntries);
                component.set("v.IncomeClosingEntries",IncomeClosingEntries);
            }            
        });
        $A.enqueueAction(fetchEntries);
	},
    createTransaction : function(component, event, helper){
        let updateAccounting = component.get("c.closeAccountingPeriod");
        updateAccounting.setParams({"recId":component.get("v.recordId")});
        updateAccounting.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                //alert('==>'+result);
                if(result!=null && result!='')component.set('v.errmsg',result);
                
                if(result==null || result==''){
                var navEvt = $A.get("e.force:navigateToSObject");
                    if(navEvt != undefined){
                    navEvt.setParams({
                        "isredirect": true,
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "detail"
                    }); 
                    navEvt.fire();
                    }}      
            }
        });
        $A.enqueueAction(updateAccounting);
    },
    cancel : function(component, event, helper){
         var navEvt = $A.get("e.force:navigateToSObject");
                    if(navEvt != undefined){
                    navEvt.setParams({
                        "isredirect": true,
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "detail"
                    }); 
                    navEvt.fire();
                    } 
    },
    
})