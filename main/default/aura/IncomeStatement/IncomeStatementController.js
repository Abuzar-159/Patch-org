({
    fetchUpdatedData : function(component, event, helper){
        console.log('fetchUpdatedData called');
        //alert(component.get('v.stopRepeat'));
        if(component.get('v.InitLoad')){
            component.set('v.showSpinner' ,true);
            var selectedCurrency=component.get('v.Instance.SelectedCurrency');//event.currentTarget.dataset.record
            
            console.log('fetchUpdatedData here1 before sending ~>'+JSON.stringify(component.get('v.Instance')));
            var action = component.get('c.ComputeUpdatedData');
            action.setParams({Ins : JSON.stringify(component.get('v.Instance'))});
            action.setCallback(this, function(response){
                if( response.getState() === "SUCCESS" ){
                    console.log('resp of fetchUpdatedData~>',response.getReturnValue());
                    component.set('v.stopRepeat',false);
                    
                    var myMap = new Map();
                    console.log('fetchUpdatedData v.expenseWrapperList~>'+JSON.stringify(response.getReturnValue().wraplist));
                    component.set("v.expenseWrapperList",response.getReturnValue().wraplist);
                    
                    var custs = [];
                    var conts = response.getReturnValue().incomeMap;
                    for(var key in conts){
                        custs.push({value:conts[key], key:key});
                    }
                    
                    component.set("v.IncomeCOAData", custs);
                    
                    var custs = [];
                    var conts = response.getReturnValue().ExpenseMap;
                    for(var key in conts){
                        custs.push({value:conts[key], key:key});
                        //alert(conts[key]);
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
                    component.set("v.TotalIncome", totalin.toFixed(2));
                    console.log('TotalIncome here1~>'+component.get("v.TotalIncome"));
                    console.log('v.Instance.userIsoCode here1~>'+component.get("v.Instance.userIsoCode"));
                    console.log('v.Instance.currencyRate here1~>'+component.get("v.Instance.currencyRate"));
                    
                    /*
                    var totalexp= response.getReturnValue().totalExpense;
                    component.set("v.TotalExpense", totalexp.toFixed(2));
                    console.log('TotalExpense here1~>'+component.get("v.TotalExpense"));
                    console.log('v.Instance.userIsoCode here1~>'+component.get("v.Instance.userIsoCode"));
                    console.log('v.Instance.currencyRate here1~>'+component.get("v.Instance.currencyRate"));
                    */
                    
                    var wrap = [];
                    wrap = response.getReturnValue().wraplist;
                    var totalexp = 0.00;
                    for(var x in wrap){
                        totalexp = parseFloat(totalexp) + parseFloat(wrap[x].totalExpense);
                    }
                    component.set("v.TotalExpense", totalexp.toFixed(2));
                    console.log('TotalExpense here1~>'+component.get("v.TotalExpense"));
                    console.log('v.Instance.userIsoCode here1~>'+component.get("v.Instance.userIsoCode"));
                    console.log('v.Instance.currencyRate here1~>'+component.get("v.Instance.currencyRate"));
                    
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
                    component.set('v.stopRepeat',false);
                    
                    
                    component.set('v.Org',component.get('v.Instance.Select_Organisation.ERP7__Organisation__c'));
                    component.set('v.SD',component.get('v.Instance.transSdate'));
                    component.set('v.ED',component.get('v.Instance.transEdate'));
                    
                    component.set("v.renderCurrencyOutputField",false);
                    component.set("v.renderCurrencyOutputField",true);
                    //helper.fetchUpdatedDataHelper(component, event, helper);
                }else{
                    component.set('v.showSpinner' ,false);
                    var errors = response.getError();
                    console.log("server error in fetchUpdatedData : ", JSON.stringify(errors));
                }
            });
            $A.enqueueAction(action);
            
            var currencies = component.get("c.getCurrencies");
            currencies.setCallback(this,function(response){
                //component.find("stStatus").set("v.options", response.getReturnValue());     
                component.set("v.stStatusOptions", response.getReturnValue());    
            });
            $A.enqueueAction(currencies);
        } 
    },
    
    doinit : function(component, event, helper) {
        if(component.get('v.stopRepeat')){
            console.log('doinit called');
            component.set('v.showSpinner' ,true);
            var selectedCurrency=component.get('v.Instance.SelectedCurrency');//event.currentTarget.dataset.record
            var action = component.get('c.fetchDetails');
            action.setParams({Ins : JSON.stringify(component.get('v.Instance')),
                              selectedIso : selectedCurrency});
            action.setCallback(this, function(response){
                var state = response.getState();
                //alert('Loading Data'); 
                if( state === "SUCCESS" ){
                    
                    component.set('v.stopRepeat',true);
                    component.set('v.Instance', response.getReturnValue());
                    //component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                    //component.set('v.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                    
                    //component.set('v.Instance.multiCurrencyEnabled', true);
                    component.set('v.showSpinner' ,false);
                    component.set('v.stopRepeat',true);
                    
                    
                    //alert(component.get('v.Instance.transSdate'));
                    component.set('v.SD',component.get('v.Instance.transSdate'));
                    component.set('v.ED',component.get('v.Instance.transEdate'));
                    component.set('v.Org',component.get('v.Instance.Select_Organisation.ERP7__Organisation__c'));
                    helper.fetchUpdatedDataHelper(component, event, helper);
                }else{
                    component.set('v.showSpinner' ,false);
                    var errors = response.getError();
                    console.log("server error in doInit : ", JSON.stringify(errors));
                }
            });
            $A.enqueueAction(action);
            var currencies = component.get("c.getCurrencies");
            currencies.setCallback(this,function(response){
                //component.find("stStatus").set("v.options", response.getReturnValue());     
                component.set("v.stStatusOptions", response.getReturnValue());    
            });
            $A.enqueueAction(currencies);
        } 
        //$A.enqueueAction(component.get("c.fetchUpdatedData"));
    },
    
    fetchDetailscontroller : function(component, event, helper){
        if(component.get('v.stopRepeat')){
            component.set('v.showSpinner',true);
            var selectedCurrency=component.get('v.Instance.SelectedCurrency');
            var action = component.get('c.fetchDetails');
            action.setParams({Ins : JSON.stringify(component.get('v.Instance')),
                              selectedIso : selectedCurrency});
            action.setCallback(this, function(response){
                var state = response.getState();
                if( state === "SUCCESS" ){
                    
                    component.set('v.stopRepeat',false);
                    component.set('v.Instance', response.getReturnValue());
                    component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                    //component.set('v.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                    
                    //component.set('v.Instance.multiCurrencyEnabled', true);
                    component.set('v.showSpinner' ,false);
                    component.set('v.stopRepeat',true);
                    
                    
                    component.set('v.Org',component.get('v.Instance.Select_Organisation.ERP7__Organisation__c'));
                    component.set('v.SD',component.get('v.Instance.transSdate'));
                    component.set('v.ED',component.get('v.Instance.transEdate'));
                    
                }else{
                    component.set('v.showSpinner' ,false);
                    component.doInit();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    perform : function(component, event, helper) {
        //alert("called");
        component.set('v.showFilter', true);
        //component.find("indus").set("v.options", component.get('v.Instance.getPickList'));
        component.set("v.indusOptions",component.get('v.Instance.getPickList'));
    }, 
    
    closeconfirm : function(component, event, helper) {
        //alert("called");
        component.set('v.showFilter', false);
    },
    
    changeTabFY : function(component, event, helper) {
        if(component.get('v.stopRepeat')){
            component.set('v.showSpinner' ,true);
            var action = component.get('c.ComputeData');
            action.setParams({Ins : JSON.stringify(component.get('v.Instance'))})
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state==="SUCCESS"){
                    component.set('v.stopRepeat',false);
                    component.set('v.Instance', response.getReturnValue());
                    component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                    
                    //component.set('v.Instance.multiCurrencyEnabled', true);
                    
                    component.set('v.showSpinner' ,false);
                    component.set('v.stopRepeat',true);
                }else{
                    component.set('v.showSpinner' ,false);
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    
    changeTab : function(component, event, helper) {
        var Tab = event.currentTarget.getAttribute("name");
        component.set('v.showSpinner' ,true);
        if( Tab == 'Tab2'){
            var action = component.get('c.ComputeData');
            action.setParams({Ins : JSON.stringify(component.get('v.Instance'))})
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state==="SUCCESS"){
                    component.set('v.stopRepeat',false);
                    //component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                    var dataList = response.getReturnValue().datalist;
                    var k =[]; var v = []; var k4 =[]; var v4 = [];   var k2 =[]; var v2 = []; 
                    for(var a in dataList ){
                        k.push(dataList[a].name); v.push(dataList[a].data3);  
                        v4.push(dataList[a].data4);
                        v2.push(dataList[a].data2);
                    }
                    //k.sort(function(a, b){return b-a});
                    component.set('v.setKeys', k);
                    component.set('v.setValues', v);
                    component.set('v.setValues2', v2);
                    component.set('v.setValues4', v4);
                    //component.set('v.Instance', response.getReturnValue());
                    component.set('v.Tab', Tab);
                    component.set('v.showSpinner' ,false);
                    component.set('v.stopRepeat',true);
                    //component.find("FY").set("v.options", component.get('v.Instance.getPickListFY'));
                    component.set("v.FYOptions",component.get('v.Instance.getPickListFY'));
                    var label = 'Revenue In '+component.get('v.Instance.CurrencyISO');
                    component.set('v.chartyLabel', label);
                    //component.set('v.Instance.multiCurrencyEnabled', true);
                    
                }else{
                    component.set('v.showSpinner' ,false);
                }
                
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.Tab', Tab); 
            component.set('v.showSpinner' ,false);
            component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
            //component.find('FY').set('v.options', component.get('v.picklists'));
            var stockTakeStatus = component.get("c.getCurrencies");
            stockTakeStatus.setCallback(this,function(response){
                //component.find("stStatus").set("v.options", response.getReturnValue());  
                component.set("v.stStatusOptions", response.getReturnValue());
            });
            $A.enqueueAction(stockTakeStatus);
        }
    },
    
    changeGraphData : function(component, event, helper){
        var selType= event.currentTarget.getAttribute("name");
        switch(selType) {
            case 'Fyear'    :component.set('v.setView', 'Annually');
                break;
            case 'FQuarter' : component.set('v.setView', 'Quaterly');
                break;
            case 'FMonthly' :component.set('v.setView', 'Monthly');
                break;
        }
        component.set('v.showSpinner' ,true);
        component.set('v.Instance.YearorQuarter', selType); 
        var action = component.get('c.ComputeData');
        action.setParams({Ins : JSON.stringify(component.get('v.Instance'))})
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state==="SUCCESS"){
                component.set('v.stopRepeat',false);
                component.set('v.Instance', response.getReturnValue());
                
                //component.set('v.Instance.multiCurrencyEnabled', true);
                var dataList = response.getReturnValue().datalist;
                var k3 =[]; var v3 = [];  var k4 =[]; var v4 = [];   var k2 =[]; var v2 = []; 
                for(var a in dataList ){
                    k3.push(dataList[a].name); v3.push(dataList[a].data3);   
                    v4.push(dataList[a].data4);
                    v2.push(dataList[a].data2);
                }
                //k.sort(function(a, b){return b-a});
                // k.sort(function(a, b){return a-b});
                component.set('v.setKeys', k3);
                component.set('v.setValues', v3);
                component.set('v.setValues2', v2);
                component.set('v.setValues4', v4);
                component.set('v.showGraph', false);
                component.set('v.showGraph', true);
                component.set('v.showSpinner' ,false);
                component.set('v.stopRepeat',true);
                var label = 'Revenue In '+component.get('v.Instance.CurrencyISO');
                component.set('v.chartyLabel', label);
                
            }else{
                component.set('v.showSpinner' ,false);
            }
        });
        $A.enqueueAction(action);
        
    }
})