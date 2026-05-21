({
    doInit : function(component, event, helper) {
        if(component.get('v.stopRepeat')){
            component.set('v.showSpinner', true);
            var action = component.get('c.fetchDetails');
            action.setParams({
                Ins : JSON.stringify(component.get('v.Instance')),
                selectedIso : component.get('v.Instance.SelectedCurrency')
            });    
            action.setCallback(this, function(response){
                var state = response.getState();
                if( state === "SUCCESS" ){
                    component.set('v.showSpinner', false);
                    component.set('v.stopRepeat', false);
                    component.set('v.Instance', response.getReturnValue());
                    console.log('Currency: '+response.getReturnValue().CurrencyISO);
                     console.log('Currency 2: '+response.getReturnValue().userIsoCode);
                    //component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                    
                    //component.set('v.Instance.userIsoCode','INR');
                    // component.set('v.Instance.isoCode','GPB'); 
                    //component.set('v.Instance.currencyRate',80);
                    //component.set('v.Instance.multiCurrencyEnabled',true);
                    
                   
                    component.set('v.stopRepeat', true);
                }else{
                }
            });
            $A.enqueueAction(action);
            var stockTakeStatus = component.get("c.getCurrencies");
            stockTakeStatus.setCallback(this,function(response){
                //component.find("stStatus").set("v.options", response.getReturnValue());  
                component.set("v.stStatusOptions",response.getReturnValue());
            });
            $A.enqueueAction(stockTakeStatus);
        }
    },
    
    fetchDetailscontroller : function(component, event, helper){
        if(component.get('v.stopRepeat')){
            component.set('v.showSpinner', true);
            var action = component.get('c.fetchDetails');
            action.setParams({
                Ins : JSON.stringify(component.get('v.Instance')),
                selectedIso : component.get('v.Instance.SelectedCurrency')
            });    
            action.setCallback(this, function(response){
                var state = response.getState();
                if( state === "SUCCESS" ){
                    component.set('v.showSpinner', false);
                    component.set('v.stopRepeat', false);
                    component.set('v.Instance', response.getReturnValue());
                    
                    component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                    
                    //component.set('v.Instance.userIsoCode','INR');
                    // component.set('v.Instance.isoCode','GPB'); 
                    //component.set('v.Instance.currencyRate',80);
                    //component.set('v.Instance.multiCurrencyEnabled',true);
                    
                    component.set('v.stopRepeat', true);
                }else{
                }
            });
            $A.enqueueAction(action);
            
            
        }
    },   
    perform : function(component, event, helper) {
        component.set('v.showFilter', true);
        //component.find("indus").set("v.options", component.get('v.Instance.getPickList'));
        component.set("v.indusOptions",component.get('v.Instance.getPickList'));
    },
    closeconfirm : function(component, event, helper) { 
        component.set("v.showFilter",false);
    },
    
    
    excelOpen : function(component, event, helper) {
        var url = '/apex/ERP7__TrialBalanceExcelRender?CurrencyIso=';
        if(component.get("v.Instance.SelectedCurrency")==undefined && component.get("v.Instance.multiCurrencyEnabled")){
            url = url + 'cad';
        }else{
            url = url + component.get("v.Instance.SelectedCurrency");
        }
        url = url + '&stDate=';
        url = url + component.get("v.Instance.transSdate");
        url = url + '&enDate=';
        url = url + component.get("v.Instance.transEdate");
        window.open(url,'_blank');
    },
    
    pdfOpen : function(component, event, helper) {
        var url = '/apex/ERP7__TrialBalanceAsPDF?CurrencyIso=';
        if(component.get("v.Instance.SelectedCurrency")==undefined && component.get("v.Instance.multiCurrencyEnabled")){
            url = url + 'cad';
        }else{
            url = url + component.get("v.Instance.SelectedCurrency");
        }
        url = url + '&stDate=';
        url = url + component.get("v.Instance.transSdate");
        url = url + '&enDate=';
        url = url + component.get("v.Instance.transEdate");
        window.open(url,'_blank');
    }
})