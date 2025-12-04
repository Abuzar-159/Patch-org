({
    showSpinner : function( component ) {
        
        $A.util.removeClass( component.find( 'spinner' ), 'slds-hide' );
        
    },
    
    hideSpinner : function( component ) {
        
        $A.util.addClass( component.find( 'spinner' ), 'slds-hide' );
        
    },
    
    fetch_Bills : function(component,event) {
        var qryFilter = component.get("v.filterCond");
        if(!$A.util.isUndefined(component.get("v.organisation.Id")))
            qryFilter += ' AND ERP7__Organisation__c =\''+component.get("v.organisation.Id")+'\'';
        //Asra's change start
        var selectedPOs = component.get("v.SelectedPOs") || [];
        console.log('selectedPOs: ',selectedPOs);
        var isValidId = function(id) { return /^[a-zA-Z0-9]{15,18}$/.test(id); };
        
        var poIds = selectedPOs
        .filter(Boolean)
        .map(function(id){ return String(id).trim(); })
        .filter(isValidId);
        
        if (poIds.length === 1) {
             qryFilter += ' AND ERP7__Purchase_Order__c = \'' + poIds[0] + '\'';
        } else if (poIds.length > 1) {
            
            var poLiterals = poIds.map(function(id){ return "'" + id + "'"; }).join(","); 
            qryFilter += ' AND ERP7__Purchase_Order__c IN (' + poLiterals + ' ) ';
        }
        //Asra's change end
        console.log('fetch_Bills qryFilter : '+qryFilter);
        var fetchBill_action = component.get("c.fetchBills");
        fetchBill_action.setParams({"OFF_SET":component.get("v.offSet"),"qryFilter":qryFilter,
                                    "OrderBy":component.get("v.OrderBy"),"Order":component.get("v.Order")})
        fetchBill_action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                console.log('BillList MatchBill response:',response.getReturnValue());
                var objArray = component.get('v.BillList');
                var resObj = response.getReturnValue();
                for(var x=0;x<resObj.length;x++){
                    var obj =resObj[x];
                    obj.isSelect = false;
                    objArray.push(obj);
                }
                //component.set('v.BillList',objArray);
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(fetchBill_action);
    },
    
    helper_MatchBill : function(component,event){
        var arrayObj = component.get('v.BillList');
        var selectedItems =[];
        var selectedItemIds =[];
        for(var x=0;x<arrayObj.length;x++){
            if(arrayObj[x].isSelect){
                selectedItems.push(arrayObj[x]);
                selectedItemIds.push(arrayObj[x].Id);
            }     
        }
        var selectPnl = component.find('selectedBills');
        var TabularPnl = component.find('tablurdata');
        
        // component.set('v.selecteBillList',selectedItems);
        var lineitems = component.get("c.getBillItems");
        lineitems.setParams({"BillId":selectedItemIds.toString()});
        lineitems.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var items = response.getReturnValue();
                
                var custs = [];
                for(var x in items){
                    for(var i =0;i<selectedItems.length;i++)
                        if(selectedItems[i].Id === x){
                            custs.push({value:items[x], key:selectedItems[i]});
                            break;
                        }
                } 
                component.set("v.selecteBillList",custs);
                var selectList = component.get("v.selecteBillList");
                if(selectList.length==0) {
                    this.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error','There are no line items to match.');
                    setTimeout(
                        $A.getCallback(function() {
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:Accounts_Payable",
                                componentAttributes: {
                                    "selectedTab" : 'Bills'
                                }
                            });
                            evt.fire();
                        }), 3000
                    );
                }
                $A.util.addClass(selectPnl, 'slds-show');
                $A.util.addClass(TabularPnl, 'slds-hide');
                $A.util.removeClass(selectPnl, 'slds-hide');
                $A.util.removeClass(TabularPnl, 'slds-show');
                this.hideSpinner(component);
            }
        });
        if(selectedItemIds.length>0) $A.enqueueAction(lineitems);
        else
            this.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.PH_MatchBill_Please_Select_a_Bill')); 
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
            toastEvent.fire();
        }
    },
    /* helper_fetch:function(component,event,helper){
        var action=component.get('c.getStockInWardLineItems');
        action.setParams({""})
         lineitems.setParams({"BillId":selectedItemIds.toString()});
        
    }*/
    
    matchBill : function(component){
        var billItem = component.get('v.BillList');
        var arrayObj = component.get('v.BillList');
        var selectedItems =[];
        var selectedItemIds =[];
        for(var x=0;x<arrayObj.length;x++){
            if(arrayObj[x].isSelect){
                selectedItems.push(arrayObj[x]);
                selectedItemIds.push(arrayObj[x].Id);
            }     
        }
        var updateAction = component.get("c.update_Bill_to_Match");
        updateAction.setParams({"BillId":selectedItemIds.toString()});
        updateAction.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                setTimeout(
                    $A.getCallback(function() {
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:Accounts_Payable",
                            componentAttributes: {
                                "selectedTab" : 'Bills',
                                "setSearch" : billItem[0].Name
                            }
                        });
                        evt.fire();
                    }), 3000
                );
            }
            
        });
        $A.enqueueAction(updateAction);
    },
    
    
    fetchTolerance : function(component, event, helper){
        var action = component.get("c.getModule");
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                component.set("v.qtyTolerance",  response.getReturnValue().qtyTolerance);
                component.set("v.unitPrTolerance", response.getReturnValue().unitPrTolerance);
            }else{
                console.log('Error :',response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})