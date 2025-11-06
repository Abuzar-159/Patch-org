({
	myOrder : function(cmp, event) {		
        var action=cmp.get("c.myOrders");
        action.setParams({
            accId : cmp.get("v.AccId"),
            tillDate : cmp.get("v.dateChoose")
        });
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state === "SUCCESS"){
                cmp.set("v.listOfMyorder",response.getReturnValue().myord);
                var DocFile = [];
                for(var i=0; i <response.getReturnValue().myord.length; i++){
                    var doc = response.getReturnValue().myord[i].conDoc;
                }
                for(var key in doc){
                    DocFile.push({key:key, value:doc[key]});
                }
                cmp.set("v.mapUse",DocFile);
               /* var attach = [];
                for(var i=0;i<response.getReturnValue().myord.length;i++){
                    var att = response.getReturnValue().myord[i].att;
                }
                for(var key in att){
                    attach.push({key:key, value:att[key]});
                }
                cmp.set("v.mapUse",attach);	*/			
            }
        });
        $A.enqueueAction(action);
	},
    
    searchMyOrder : function(cmp, event){
        var searchsales = document.getElementById("searchsales").value;
        var searchInvoice = document.getElementById("searchInvoice").value;
        var action=cmp.get("c.searchOrder");
        action.setParams({
            accId : cmp.get("v.AccId"),
            searchsales : searchsales,
            searchInvoice : searchInvoice
        });
        action.setCallback(this, function(response){
            var state=response.getState();		
            
            if(state ==="SUCCESS"){
                cmp.set("v.listOfMyorder",response.getReturnValue().myord);
                var attach = [];
                for(var i=0;i<response.getReturnValue().myord.length;i++){
                    var att = response.getReturnValue().myord[i].att;
                }
                for(var key in att){
                    attach.push({key:key, value:att[key]});
                }
                cmp.set("v.mapUse",attach);	
            }
        });
        $A.enqueueAction(action);
    },
})