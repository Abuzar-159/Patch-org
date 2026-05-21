({
	showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }else{
            sforce.one.showToast({
                "title": title,
                "message": message,
                "type": type
            });
        }
        
    },
    
    validation_Check : function (component, event) {
       // component.NOerrors = true;
        var billName = component.find("billName");
        if(!$A.util.isUndefined(billName)) 
             this.checkValidationField(component,billName);
        var vendorAcc = component.find("vendorAccount");
        if(!$A.util.isUndefined(vendorAcc))
             this.checkvalidationLookup(component,vendorAcc);
        var billList = component.find("bill_Items");
        if(!$A.util.isUndefined(billList))
        if(billList.length>0){
            var flag = true;
            for(var x=0;x<billList.length;x++)
             flag = billList[x].callValidate(); 
            if(!flag && component.NOerrors) component.NOerrors = false;
        }else{
           component.NOerrors = billList.callValidate(); 
        }       
    },
    
    
     saveAtt : function(component,event,file,parentId){
       		var reader = new FileReader();
            reader.onloadend = function() {
                var contents = reader.result;
                var base64Mark = 'base64,';
                var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                var fileContents = contents.substring(dataStart);
                        
                var action = component.get("c.uploadFile");
                
                action.setParams({
                    parent: parentId,
                    fileName: file.name,
                    base64Data: encodeURIComponent(fileContents),
                    contentType: file.type
                });
                action.setCallback(this, function(response) {
                    if(response.getState() === 'SUCCESS'){
                    }else{
                        console.log('Error :',response.getError());
                    }
                });
                $A.enqueueAction(action); 
            }
            reader.readAsDataURL(file);
    },
    
    
     OrderProcess : function(cmp, event, helper) {
        var action = cmp.get("c.getFunctionalityControlOrderProcess");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue()){
                    cmp.set("v.isStdOrder",true);
                }
            }  
        });
        $A.enqueueAction(action);  
              
    },
})