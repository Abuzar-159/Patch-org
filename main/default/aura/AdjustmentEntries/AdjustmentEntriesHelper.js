({
    addDebits : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.addDebitEntries');
        action.setParams({ins:JSON.stringify(component.get('v.Instance'))});
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                try{
                    console.log('resp addDebits~>',response.getReturnValue());
                    var wrapper = [];
                    if(component.get('v.newInstanceFGLEs') != undefined && component.get('v.newInstanceFGLEs') != null) wrapper = component.get('v.newInstanceFGLEs');
                    console.log('addDebits before wrapper~>'+wrapper.length);
                  //  wrapper.push(response.getReturnValue());
                  
                    var newEntry = response.getReturnValue();

var curr = component.get('v.Instance.adjEntries.Trans.CurrencyIsoCode');

if(curr && newEntry && newEntry.GEntries){
    newEntry.GEntries.CurrencyIsoCode = curr;
}

wrapper.push(newEntry);
                    component.set('v.newInstanceFGLEs',wrapper);
                    console.log('addDebits after wrapper~>'+wrapper.length);
                    component.set('v.showSpinner', false);
                }catch(e){
                    console.log('err',e);
                }
            }
            else{
                console.log('Error Occured', response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    addCredits: function(component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.addCreditEntries');
        action.setParams({ins:JSON.stringify(component.get('v.Instance'))});
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('resp addCredit~>',response.getReturnValue());
                var wrapper = [];
                if(component.get('v.newInstanceFGLEs') != undefined && component.get('v.newInstanceFGLEs') != null) wrapper = component.get('v.newInstanceFGLEs');
                console.log('addCredits before wrapper~>'+wrapper.length);
              //  wrapper.push(response.getReturnValue());
              var newEntry = response.getReturnValue();

var curr = component.get('v.Instance.adjEntries.Trans.CurrencyIsoCode');

if(curr && newEntry && newEntry.GEntries){
    newEntry.GEntries.CurrencyIsoCode = curr;
}

wrapper.push(newEntry);
                component.set('v.newInstanceFGLEs',wrapper);
                console.log('addCredits after wrapper~>'+wrapper.length);
                component.set('v.showSpinner', false);
            }
            else{
                console.log('Error Occured',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    //todo
    clearAll : function(component, event, helper) {
        component.set('v.showSpinner', true);
        console.log('before instance~>'+JSON.stringify(component.get('v.newInstanceFGLEs')));
        
        //component.set('v.newInstanceFGLEs', component.get('v.Instance.dummyadjEntries.FGLEs'));
        
        console.log('after instance~>'+JSON.stringify(component.get('v.newInstanceFGLEs')));
        component.set('v.TotalDebit', 0);  component.set('v.TotalCredit', 0);
        component.set('v.showSpinner', false);  
    },
    
    getTransactions : function(component, event, helper) {
        console.log('getTransactions called instance~>'+JSON.stringify(component.get('v.Instance')));
        component.set('v.showSpinner', true);
        var action = component.get('c.getAdjTransactions');
        action.setParams({Offset: component.get("v.Offset"),
                          RecordLimit: component.get('v.show'),
                          searchString :component.get('v.setSearch'),
                          ins : JSON.stringify(component.get('v.Instance')) });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('success in getTransactions adjustmentList~>'+JSON.stringify(response.getReturnValue().adjustmentList));
                component.set('v.Instance.adjustmentList', response.getReturnValue().adjustmentList);    
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().adjustmentList;   
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
                component.set('v.showSpinner', false);    
            }else{
                console.log('getTransactions error occured');
                var errors = response.getError();
                console.log("server error in getTransactions : ", JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchcurrency : function(component, event, helper) {
        var action=component.get("c.getCurrencies");
        action.setParams({});
        action.setCallback(this,function(response){
            component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
            component.set("v.currencyList",response.getReturnValue().currencyList);
        });
        $A.enqueueAction(action);
    },
})