({
    Navigate: function(component, event, helper) {
        var obj = component.get("v.listtceObj");
        if (obj == '') {
            $A.createComponent(
                "c:Expense_Line_Item", {
                    "expenseComp": component.get("v.Expense")
                },
                function(newCmp) {
                    if (component.isValid()) {
                        var bodycmp = component.find("TimeCEContent");
                        var body = bodycmp.get("v.body");
                        body.reverse();
                        body[body.length] = newCmp;
                        body.reverse();
                        bodycmp.set("v.body", body);
                    }
                }
            );
        } else {
            for (var i = 0; i < obj.length; i++) {
                $A.createComponent(
                    "c:Expense_Line_Item", {
                        "expenseComp": component.get("v.Expense"),
                        "eLineItem": obj[i]
                    },
                    function(newCmp) {
                        if (component.isValid()) {
                            var body = component.get("v.body");
                            body.push(newCmp);
                            component.set("v.body", body);
                        }
                    }
                );
            }
        }
    }
    
})