({
    fetchUpdatedDataHelper : function(component, event, helper){
        console.log('fetchUpdatedDataHelper called');
        //alert(component.get('v.stopRepeat'));
        //if(component.get('v.stopRepeat')){
        component.set('v.showSpinner' ,true);
        var selectedCurrency=component.get('v.Instance.SelectedCurrency');//event.currentTarget.dataset.record
        
        console.log('fetchUpdatedDataHelper here2 before sending ~>'+JSON.stringify(component.get('v.Instance')));
        
        var action = component.get('c.ComputeUpdatedData');
        action.setParams({Ins : JSON.stringify(component.get('v.Instance'))});
        action.setCallback(this, function(response){
            var state = response.getState();
            if( state === "SUCCESS" ){
                component.set('v.stopRepeat',false);
                var myMap = new Map();
                console.log('fetchUpdatedDataHelper resp~>',response.getReturnValue());
                //component.set("v.TotalExpense", response.getReturnValue().totalExpense);
                component.set("v.expenseWrapperList",response.getReturnValue().wraplist);
                var custs = [];
                var wrap = [];
                wrap = response.getReturnValue().wraplist;
                var totalAmot = 0.00;
                for(var x in wrap){
                    totalAmot = parseFloat(totalAmot) + parseFloat(wrap[x].totalExpense);
                }
                component.set("v.TotalExpense", totalAmot.toFixed(2));
                console.log('TotalExpense here2 helper~>'+component.get("v.TotalExpense"));
                console.log('v.Instance.userIsoCode here2 helper~>'+component.get("v.Instance.userIsoCode"));
                console.log('v.Instance.currencyRate here2 helper~>'+component.get("v.Instance.currencyRate"));
                
                var conts = response.getReturnValue().incomeMap;
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                }
                
                component.set("v.IncomeCOAData", custs);
                
                var custs = [];
                var conts = response.getReturnValue().ExpenseMap;
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                }
                
                component.set("v.ExpenseCOAData", custs);
                
                var custs = [];
                var conts = response.getReturnValue().incomeSubMap;
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                }
                
                component.set("v.subCOAData", custs);
                
                
                var custs = [];
                var conts = response.getReturnValue().expenseSubMap;
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                }
                
                component.set("v.subCOADataExp", custs);
                var totalin= response.getReturnValue().totalIncome;
                var totalexp= component.get("v.TotalExpense");
                totalexp = parseFloat(totalexp);
                component.set("v.TotalIncome", totalin.toFixed(2));
                console.log('TotalIncome here2 helper~>'+component.get("v.TotalIncome"));
                console.log('v.Instance.userIsoCode here2 helper~>'+component.get("v.Instance.userIsoCode"));
                console.log('v.Instance.currencyRate here2 helper~>'+component.get("v.Instance.currencyRate"));
                
                var netProfit = Math.abs(totalin).toFixed(2) - Math.abs(totalexp).toFixed(2);
                //var netProfit = totalin.toFixed(2)-totalexp.toFixed(2);
                component.set("v.netProfit", netProfit.toFixed(2));
                //var map=component.get("v.IncomeCOAData");
                //alert(JSON.stringify(map['Sales']));
                if(response.getReturnValue()!=null){
                    //component.set("v.IncomeCOAData", response.getReturnValue().incomeMap);
                    //component.set("v.ExpenseCOAData", response.getReturnValue().ExpenseMap);
                    //component.set("v.IncomeCOADataList", response.getReturnValue().incomeList);
                }
                //component.set('v.Instance', response.getReturnValue());
                //component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                //component.set('v.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                
                //component.set('v.Instance.multiCurrencyEnabled', true);
                component.set('v.showSpinner' ,false);
                component.set('v.stopRepeat',true);
                component.set('v.InitLoad', true);
                
                //component.set('v.Org',component.get('v.Instance.Select_Organisation.ERP7__Organisation__c'));
                //component.set('v.SD',component.get('v.Instance.transSdate'));
                //component.set('v.ED',component.get('v.Instance.transEdate'));
                component.set("v.renderCurrencyOutputField",false);
                component.set("v.renderCurrencyOutputField",true);
            }else{
                component.set('v.showSpinner' ,false);
                var errors = response.getError();
                console.log("server error in fetchUpdatedDataHelper : ", JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
        var currencies = component.get("c.getCurrencies");
        currencies.setCallback(this,function(response){
            //component.find("stStatus").set("v.options", response.getReturnValue());     
            component.set("v.stStatusOptions", response.getReturnValue());    
        });
        $A.enqueueAction(currencies);
        //} 
    }
})