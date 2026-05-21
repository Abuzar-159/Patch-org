({
    searchProd : function(component, event,searchtext) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var action = component.get('c.getsearchedProducts');
        action.setParams({
            "searchStr":searchtext
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                if(result.length == 0) component.set('v.exceptionError',$A.get('$Label.c.Sorry_no_Products_avilable'));
                else component.set('v.prodlst',result);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
                
            }
        });
        $A.enqueueAction(action);
    },
    productStatusCount : function(component, event) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var products = component.get("v.prodlst");
        var listPROJ = [];
        for (var i in products) {
            if(products[i].prod.ERP7__Status__c == "Released") {
                listPROJ.push(products[i]);
            }
        }
        component.set("v.ReservedProducts", listPROJ.length);
        listPROJ = [];
        for (var i in products) {
            if(products[i].prod.ERP7__Status__c == "Certified") {
                listPROJ.push(products[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.CertifiedProducts", listPROJ.length);
        listPROJ = [];
        for (var i in products) {
            if(products[i].prod.ERP7__Status__c == "In Development") {
                listPROJ.push(products[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.IndevelopmentProducts", listPROJ.length);
        listPROJ = [];
        
        for (var i in products) {
            if(products[i].prod.ERP7__Status__c == "End of Lifecycle") {
                listPROJ.push(products[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.EndOfcycleProjects", listPROJ.length);
        
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",false);
    },
    
    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            //component.set("v.showMainSpin",false);
            toastEvent.fire();
        }
    },
    
    navigatetosetup : function(Prcss,Ver,prod,action,component){
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        console.log('prod~>'+JSON.stringify(prod));
        console.log('Prcss~>'+JSON.stringify(Prcss));
        console.log('Ver~>'+JSON.stringify(Ver));
        console.log('action~>'+action);
        
        $A.createComponent("c:MOProductSetupSection",{
            "Productdetails":prod,
            "Process" : Prcss,
            "SelectedVersion" : Ver,
            "ProcessToClone" : Prcss,
            "SelectedVersionToClone" : Ver,
            "Action" : action
        },function(newCmp, status, errorMessage){
            
            if (status === "SUCCESS") {
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    getFieldsSetApiNameHandler : function(component,objectApiName,fieldSetApiName){
        try{
             	console.log('getFieldsSetApiNameHandler called');
            	var action = component.get("c.getFieldsSetApiName");
            	action.setParams({
                sObjectName : objectApiName,
                fieldSetApiName :fieldSetApiName});
            	action.setCallback(this,function(response){
                console.log('getFieldsSetApiNameHandler reuslt:',response.getReturnValue());
                component.set("v.fieldsSet",response.getReturnValue());
                
               
                    /*var renderedFields = response.getReturnValue();
                    for(var  x in renderedFields){ 
                        
                        if(renderedFields[x].get('v.fieldName')==='ERP7__Issue_Manufacturing_Order__c'){
                            console.log('Founded Field : ',renderedFields[x].get('v.fieldName')); 
                            renderedFields[x].set('v.value',true);
                            console.log('Founded Field value : ',renderedFields[x].get('v.value'));  
                        }
                    }*/
                    
                    //component.set("v.fieldsSet", renderedFields);
       				//component.set("v.isCreateOrUpdate", true);
                    
            });
            $A.enqueueAction(action);
        }
        catch(e){console.log('Error in getFieldsSetApiNameHandler:',e);}
    },
    
})