({
    
    loadData: function(component, event, helper) {          
 
      //call apex class method
      var action = component.get('c.fetchProducts');
        action.setParams({
            accID:component.get("v.accID"),
            profileID:component.get("v.profileID")
            //,channelID:component.get("v.channelID")
        })  
      action.setCallback(this, function(response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
          //set response value in wrapperList attribute on component.
          component.set('v.productWrapperList', response.getReturnValue());
        }
      });
      $A.enqueueAction(action); 
      
    },
    
    calculateProducts : function(component, event, helper)
    {
        
        var recordID = event.getSource().get("v.name");  
        var pbeList = component.get("v.productWrapperList.pbeList");
        var cartItems = component.get("v.cartItems");
        var totalPrice = 0.00;
        
        var flag = true;
        
        for(var pb=0; pb<pbeList.length;pb++){
            
         if(pbeList[pb].pbe.Product2Id === recordID){ 
             pbeList[pb]["cartbtn"] = true;
            
             pbeList[pb].stock = parseFloat(pbeList[pb].stock - pbeList[pb].pbe.Product2.ERP7__MOQ__c);
             if(cartItems.length>0){
                 for(var i = 0; i<cartItems.length;i++){
                     if(cartItems[i].pbe.Product2Id === recordID){
                         flag = false;
                         //pbeList[pb].stock = parseFloat(pbeList[pb].stock + cartItems[i].pbe.Product2.ERP7__MOQ__c);
                        cartItems[i] = pbeList[pb];
                         
                        break;
                     }
                 }
             }
             
             if(Boolean(flag)){
                 cartItems.push(pbeList[pb]); 
                 
             }
             break;
           }
      }
        for(var j = 0; j<cartItems.length;j++){
            totalPrice += (parseFloat(cartItems[j].pbe.Product2.ERP7__MOQ__c) * parseFloat(cartItems[j].pbe.UnitPrice));
        }
        component.set("v.productWrapperList.pbeList",pbeList);
        component.set("v.cartItems",cartItems);
        component.set("v.totalPrice",totalPrice);
        helper.saveRecordsToCart(component, event, helper);
    },
    
    productCart: function(component, event, helper) {

    $A.createComponent(
        "c:ProductsCart", {
            "cartProducts":component.get("v.cartItems"),
            "totalPrice":component.get("v.totalPrice"),
            "accID":component.get("v.accID"),
            "profileID":component.get("v.profileID")
        },
        function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);

            }
        }
    );
},
    
    handleFamilyEvent: function(component, event, helper) {
        
        var action = component.get('c.fetchProducts');
        action.setParams({
            accID:component.get("v.accID"),
            profileID:component.get("v.profileID"),
            //channelID:component.get("v.channelID"),
            family:event.getParam("familyType")
        })  
      action.setCallback(this, function(response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
          //set response value in wrapperList attribute on component.
          component.set('v.productWrapperList', response.getReturnValue());
        }
      });
      $A.enqueueAction(action); 
    },
    
     calculateIndividualProducts : function(component, event, helper)
    {
        
        var recordID = event.getSource().get("v.name");  
        
        var pbeList = component.get("v.productWrapperList.pbeList");
        
        var cartItems = component.get("v.cartItems");
        
        var totalPrice = 0.00;
         
        var flag = true;
        
        for(var pb=0; pb<pbeList.length;pb++){
            
         if(pbeList[pb].pbe.Product2Id === recordID){ 
             pbeList[pb]["cartbtn"] = true;
             
             pbeList[pb].stock = parseFloat(pbeList[pb].stock - pbeList[pb].pbe.Product2.ERP7__MOQ__c);
            
             if(cartItems.length>0){
                 for(var i = 0; i<cartItems.length;i++){
                     if(cartItems[i].pbe.Product2Id === recordID){
                         flag = false;
                         //pbeList[pb].stock = parseFloat(pbeList[pb].stock + cartItems[i].pbe.Product2.ERP7__MOQ__c);
                        cartItems[i] = pbeList[pb];
                         
                        break;
                     }
                 }
             }
             
             if(Boolean(flag)){
                 cartItems.push(pbeList[pb]); 
             }
             break;
           }
      }
        for(var j = 0; j<cartItems.length;j++){
            totalPrice += (parseFloat(cartItems[j].pbe.Product2.ERP7__MOQ__c) * parseFloat(cartItems[j].pbe.UnitPrice));
        }
        component.set("v.productWrapperList.pbeList",pbeList);
        component.set("v.cartItems",cartItems);
        component.set("v.totalPrice",totalPrice);
        helper.saveRecordsToCart(component, event, helper);
    }
})