({
    home :function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ viewHome: true});
        evt.fire(); 
    },
    
	initial : function(cmp, event, helper) {
		
        helper.myOrder(cmp, event);
	},
    
    selectDate: function(cmp, event, helper){
        document.getElementById("searchInvoice").value=""; 
        document.getElementById("searchsales").value=""; 
        var sort=document.getElementById("dateChoose").value;
        cmp.set("v.dateChoose",sort);
        helper.myOrder(cmp, event);        
    },
    
    detailPage : function(cmp, event, helper){
        var prodId=event.currentTarget.dataset.value; 
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ 
            "viewProduct":true,
            "ProdId": prodId
        });
        evt.fire();
    },
    
    cancelOrd:function(cmp, event, helper){
        var soId=event.getSource().get("v.value");
        var action=cmp.get("c.cancelOrder");
        action.setParams({soId : soId});
        action.setCallback(this, function(response){
            var state=response.getState();	
            helper.myOrder(cmp, event);
        });
        $A.enqueueAction(action);
    },
    
    searchSales :function(cmp, event, helper){
        document.getElementById("searchInvoice").value="";        
        helper.searchMyOrder(cmp, event);
    },
    
    searchInvoice :function(cmp, event, helper){
        document.getElementById("searchsales").value="";        
        helper.searchMyOrder(cmp, event);
    },
    
    orderDetl : function(cmp, event, helper){
        try{
        cmp.set("v.myOrder",false);
        var inv=event.currentTarget.dataset.value;
        var action=cmp.get("c.orderDetails");
        action.setParams({inv : inv});
        action.setCallback(this, function(response){
            var state=response.getState();
            console.log('state'+state);
            if(state==="SUCCESS"){
                cmp.set("v.addDetails",response.getReturnValue().add);
                cmp.set("v.orderDetails",response.getReturnValue().myord);
            console.log('orderDetl')
                var DocFile = [];
                for(var i=0; i <response.getReturnValue().myord.length; i++){
                    var doc = response.getReturnValue().myord[i].conDoc;
                    }
                for(var key in doc){
                    DocFile.push({key:key, value:doc[key]});
                }
                cmp.set("v.mapUse",DocFile);
                console.log('DocFile'+DocFile)
               /* var attach = [];
                for(var i=0;i<response.getReturnValue().myord.length;i++){
                    var att = response.getReturnValue().myord[i].att;
                }
                for(var key in att){
                    attach.push({key:key, value:att[key]});
                }
                cmp.set("v.mapUse",attach);*/
            }
        });
        $A.enqueueAction(action);
        }catch(e){
            console.log('ERROR '+e);
        }
    },
    home :function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ viewHome: true});
        evt.fire(); 
    },    
    myOrder : function(cmp, event, helper){
        cmp.set("v.myOrder",true);
        helper.myOrder(cmp, event); 
    },
})