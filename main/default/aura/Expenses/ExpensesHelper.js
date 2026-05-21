({
  doInit: function(cmp, ev) {
    var selectCmp = cmp.find("InputSelectDynamic");
    var action = cmp.get("c.GetRecordCounts");
    action.setParams({
      strDate: selectCmp.get("v.value"),
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        cmp.set('v.counts', response.getReturnValue());
      }
    });
    $A.enqueueAction(action);
  },
  fetchCurrencyCode: function(component, event, helper) {
    var action = component.get("c.getCurrencyIsoCode");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.currencyCode", component.get("v.currency." + (response.getReturnValue())));
      }
    });
    $A.enqueueAction(action);
  },
  Navigate: function(component, event, helper) {
    var action = component.get("c.EditExpense");
    action.setParams({
      strId: event.getParams("timId")['timId']
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set('v.TimeSheetObj', response.getReturnValue());
      }
      $A.createComponent(
        "c:AddNewExpense", {
          "Expense": response.getReturnValue().expense,
          "eLineItem": response.getReturnValue().expenseLine
        },
        function(newCmp) {
          if (component.isValid()) {
            var body = component.get("v.body");
            body.push(newCmp);
            component.set("v.body", body);
          }
        }
      );
    });
    $A.enqueueAction(action);
  },
    
    sortBy: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            table = component.get("v.table");
        sortAsc = field == sortField? !sortAsc: true;
        table.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.table", table);
    },
    
    sortByApproved: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            table2 = component.get("v.table2");
        sortAsc = field == sortField? !sortAsc: true;
        table2.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.table2", table2);
    },
    
    helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	}
})