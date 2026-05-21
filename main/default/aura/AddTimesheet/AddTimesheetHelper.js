({
    displayMainCom: function(component, event, helper) {
        $A.createComponent(
            "c:My_Timesheets_Main_Comp", {
            },
            function(newCmp) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);
                    location.reload();
                }
            }
        );
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
    
    Navigate: function(component, event, helper) {
        try {       
        var weekint = '0';
        var obj = component.get("v.listtceObj");
        if (obj == '' || obj == null) {
            $A.createComponent(
                "c:AddTimeCardEntry", {
                    "tSheetcomp": component.get("v.timeSheet"),
                    "intweek": weekint
                },
                function(newCmp) {
                    if (component.isValid()) {
                        var bodycmp = component.find("TimeCEContent");
                        var body = bodycmp.get("v.body");
                        component.set("v.weekint", 7);
                        body.push(newCmp);
                        bodycmp.set("v.body", body);
                    }
                }
            );
        } else {
            component.set("v.weekint", 0);
            for (var i = 0; i < obj.length; i++) {
                $A.createComponent(
                    "c:AddTimeCardEntry", {
                        "tSheetcomp": component.get("v.timeSheet"),
                        "tceObj": obj[i]
                    },
                    function(newCmp) {
                        if (component.isValid()) {
                            var bodycmp = component.find("TimeCEContent");
                            var body = bodycmp.get("v.body");
                            var x = component.get("v.weekint");
                            x = parseInt(x) + 7;
                            component.set("v.weekint", x);
                            body.push(newCmp);
                            bodycmp.set("v.body", body);
                        }
                    }
                );
            }
        }
    } catch (e) {
        console.log('err '+e);
    }
    }
})